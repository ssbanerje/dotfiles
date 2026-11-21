from __future__ import annotations

import gzip
import io
import os
import plistlib
import py_compile
import subprocess
import sys
import tarfile
import zipfile
from pathlib import Path
from unittest import mock

import pytest

from scripts.lib import manifest as manifest_mod
from tests.conftest import PROFILE_SPECS, REPO_ROOT

for extra in (
    REPO_ROOT / 'installer' / 'dotbot' / 'src',
    REPO_ROOT / 'installer' / 'dotbot' / 'lib' / 'pyyaml' / 'lib',
    REPO_ROOT / 'installer' / 'plugins',
):
    extra_str = str(extra)
    if extra_str not in sys.path:
        sys.path.insert(0, extra_str)

import apt
import brew
import ghrelease
import pacman

pytestmark = pytest.mark.unit


class DummyLog:
    def __init__(self) -> None:
        self.messages: list[tuple[str, str]] = []

    def info(self, msg: str) -> None:
        self.messages.append(('info', msg))

    def action(self, msg: str) -> None:
        self.messages.append(('action', msg))

    def warning(self, msg: str) -> None:
        self.messages.append(('warning', msg))

    def error(self, msg: str) -> None:
        self.messages.append(('error', msg))

    def debug(self, msg: str) -> None:
        self.messages.append(('debug', msg))


class DummyOptions:
    verbose = 0


class DummyContext:
    def __init__(
        self,
        base_dir: str | Path = REPO_ROOT,
        dry_run: bool = False,
        defaults: dict | None = None,
    ) -> None:
        self._base_dir = str(base_dir)
        self._dry_run = dry_run
        self._defaults = defaults or {}

    def base_directory(self) -> str:
        return self._base_dir

    def dry_run(self) -> bool:
        return self._dry_run

    def defaults(self) -> dict:
        return self._defaults

    def options(self) -> DummyOptions:
        return DummyOptions()


def make_plugin(
    cls,
    dry_run: bool = False,
    defaults: dict | None = None,
    base_dir: str | Path = REPO_ROOT,
):
    plugin = cls(DummyContext(base_dir=base_dir, dry_run=dry_run, defaults=defaults))
    plugin._log = DummyLog()
    return plugin


def _completed(
    argv: list[str], rc: int = 0, stdout: str = '', stderr: str = ''
) -> subprocess.CompletedProcess[str]:
    return subprocess.CompletedProcess(argv, rc, stdout=stdout, stderr=stderr)


class TestAptPlugin:
    def test_batched_dpkg_query_and_cache(self) -> None:
        plugin = make_plugin(apt.Apt)

        def fake_run(argv, **kwargs):
            assert argv[0] == 'dpkg-query'
            return _completed(
                argv,
                1,
                stdout=(
                    'curl:amd64\tcurl\t7.88.1-10\tinstalled\n'
                    'git\tgit\t1:2.39.5-1\tinstalled\n'
                ),
            )

        with (
            mock.patch.object(subprocess, 'run', side_effect=fake_run) as m_run,
            mock.patch.object(subprocess, 'call', return_value=0) as m_call,
            mock.patch.object(os, 'geteuid', return_value=1000),
        ):
            assert plugin.handle('apt', ['curl', 'git', 'ripgrep']) is True
            assert m_run.call_count == 2
            m_call.assert_called_once()
            assert m_call.call_args[0][0] == [
                'sudo',
                '-E',
                'apt-get',
                'install',
                '--yes',
                'ripgrep',
            ]

            m_run.reset_mock()
            m_call.reset_mock()
            assert plugin.handle('apt', ['curl', 'git']) is True
            m_run.assert_not_called()
            m_call.assert_not_called()

    @pytest.mark.parametrize(
        ('policy_out', 'dpkg_rc', 'expected_cmd'),
        [
            (
                (
                    'neovim:\n  Installed: (none)\n  Candidate: 0.11.6-1\n'
                    'lazygit:\n  Installed: (none)\n  Candidate: 0.57.0-1\n'
                ),
                0,
                ['apt-get', 'install', '--yes', 'ripgrep', 'neovim', 'lazygit'],
            ),
            (
                (
                    'neovim:\n  Installed: (none)\n  Candidate: 0.9.5-6ubuntu2\n'
                    'lazygit:\n  Installed: (none)\n  Candidate: (none)\n'
                ),
                1,
                ['apt-get', 'install', '--yes', 'ripgrep'],
            ),
        ],
    )
    def test_conditional_packages(
        self, policy_out: str, dpkg_rc: int, expected_cmd: list[str]
    ) -> None:
        plugin = make_plugin(apt.Apt)

        def fake_run(argv, **kwargs):
            if argv[0] == 'dpkg-query':
                return _completed(argv, 1)
            if argv[0] == 'apt-cache':
                return _completed(argv, 0, stdout=policy_out)
            assert argv[0] == 'dpkg'
            return _completed(argv, dpkg_rc)

        with (
            mock.patch.object(subprocess, 'run', side_effect=fake_run),
            mock.patch.object(subprocess, 'call', return_value=0) as m_call,
            mock.patch.object(os, 'geteuid', return_value=0),
        ):
            ok = plugin.handle(
                'apt',
                [
                    'ripgrep',
                    {'neovim': {'if_available': True, 'min_version': '0.11'}},
                    {'lazygit': {'if_available': True}},
                ],
            )
            assert ok is True
            assert m_call.call_args[0][0] == expected_cmd

    @pytest.mark.parametrize(
        ('candidate', 'minimum', 'expected'),
        [
            ('1:0.9.5-6ubuntu2', '0.11', False),
            ('1:0.11.6-1', '0.11', True),
        ],
    )
    def test_epoch_version_check(
        self, candidate: str, minimum: str, expected: bool
    ) -> None:
        assert apt.Apt._version_satisfies(candidate, minimum) is expected

    def test_update_dedup_and_dry_run(self) -> None:
        plugin = make_plugin(apt.Apt, dry_run=True)
        with mock.patch.object(subprocess, 'call') as m_call:
            assert plugin.handle('aptupdate', None) is True
            assert plugin.handle('aptupdate', None) is True
            m_call.assert_not_called()
            actions = [m for k, m in plugin._log.messages if k == 'action']
            assert actions == ['Would update apt package lists']


class TestBrewPlugin:
    def test_find_brew_discovers_apple_silicon_and_prepends_path(
        self, tmp_path: Path
    ) -> None:
        plugin = make_plugin(brew.Brew)
        fake_bin = tmp_path / 'bin'
        fake_sbin = tmp_path / 'sbin'
        fake_bin.mkdir()
        fake_sbin.mkdir()
        fake_brew = fake_bin / 'brew'
        fake_brew.write_text('#!/bin/sh\n', encoding='utf-8')
        fake_brew.chmod(0o755)

        with (
            mock.patch.object(brew.Brew, '_BREW_CANDIDATES', (str(fake_brew),)),
            mock.patch.object(brew.shutil, 'which', return_value=None),
            mock.patch.dict(os.environ, {'PATH': '/usr/bin:/bin'}, clear=False),
        ):
            found = plugin._find_brew()
            assert found == str(fake_brew)
            assert os.environ['PATH'].startswith(f'{fake_bin}:{fake_sbin}:')

    def test_bootstrap_passes_noninteractive_and_uses_argv(self) -> None:
        plugin = make_plugin(brew.Brew)
        calls: list[tuple[list[str], dict[str, str]]] = []

        def fake_call(argv, **kwargs):
            calls.append((argv, kwargs.get('env', {})))
            return 0

        find_results = iter([None, '/opt/homebrew/bin/brew'])
        with (
            mock.patch.object(
                plugin, '_find_brew', side_effect=lambda: next(find_results)
            ),
            mock.patch.object(subprocess, 'call', side_effect=fake_call),
        ):
            assert plugin.handle('bootstraphomebrew', None) is True
            assert len(calls) == 2
            assert calls[0][0][:3] == ['curl', '-fsSL', brew.Brew._INSTALL_URL]
            assert calls[1][0][0] == '/bin/bash'
            assert calls[1][1].get('NONINTERACTIVE') == '1'

    def test_tap_runs_brew_trust_when_supported(self) -> None:
        plugin = make_plugin(brew.Brew)
        calls: list[list[str]] = []

        def fake_run(argv, **kwargs):
            if argv[1:] in (['tap'], ['trust', '--help']):
                return _completed(argv)
            raise AssertionError(argv)

        with (
            mock.patch.object(
                plugin, '_find_brew', return_value='/opt/homebrew/bin/brew'
            ),
            mock.patch.object(subprocess, 'run', side_effect=fake_run),
            mock.patch.object(
                subprocess,
                'call',
                side_effect=lambda argv, **kw: calls.append(argv) or 0,
            ),
        ):
            assert plugin.handle('tap', ['asmvik/formulae']) is True
            assert calls == [
                ['/opt/homebrew/bin/brew', 'tap', 'asmvik/formulae'],
                ['/opt/homebrew/bin/brew', 'trust', 'asmvik/formulae'],
            ]


class TestPacmanPlugin:
    def test_bootstrap_yay_uses_tempdir_and_appends_no_debug(self) -> None:
        plugin = make_plugin(pacman.Pacman)
        seen_pkgbuild: dict[str, str] = {}

        def fake_call(argv, **kwargs):
            if argv[0] == 'git':
                target = argv[-1]
                assert target != '/tmp/yay-bin'
                Path(target, 'PKGBUILD').write_text(
                    'pkgname=yay-bin\n', encoding='utf-8'
                )
                return 0
            if argv[0] == 'makepkg':
                seen_pkgbuild['content'] = Path(kwargs['cwd'], 'PKGBUILD').read_text(
                    encoding='utf-8'
                )
                return 0
            raise AssertionError(argv)

        with (
            mock.patch.object(pacman.shutil, 'which', return_value=None),
            mock.patch.object(subprocess, 'call', side_effect=fake_call),
            mock.patch.object(os, 'geteuid', return_value=1000),
        ):
            assert plugin.handle('bootstrapyay', None) is True
            assert 'options+=(!debug)' in seen_pkgbuild['content']

    def test_installed_cache_and_sudo_prefix(self) -> None:
        plugin = make_plugin(pacman.Pacman)
        with (
            mock.patch.object(
                subprocess,
                'run',
                return_value=_completed(['pacman'], 127, stdout='ripgrep\n'),
            ) as m_run,
            mock.patch.object(subprocess, 'call', return_value=0) as m_call,
            mock.patch.object(os, 'geteuid', return_value=1000),
        ):
            assert plugin.handle('pacman', ['git', 'ripgrep']) is True
            m_run.assert_called_once()
            assert m_call.call_args[0][0] == [
                'sudo',
                '-E',
                'pacman',
                '-S',
                '--needed',
                '--noconfirm',
                'ripgrep',
            ]
            m_run.reset_mock()
            m_call.reset_mock()
            assert plugin.handle('pacman', ['git', 'ripgrep']) is True
            m_run.assert_not_called()
            m_call.assert_not_called()


class TestGhReleasePlugin:
    @pytest.mark.parametrize(
        ('machine', 'expected'),
        [
            (
                'x86_64',
                {
                    'uname_m': 'x86_64',
                    'arch': '64-bit',
                    'go_arch': 'amd64',
                    'node_arch': 'x64',
                },
            ),
            (
                'aarch64',
                {
                    'uname_m': 'aarch64',
                    'arch': 'arm64',
                    'go_arch': 'arm64',
                    'node_arch': 'arm64',
                },
            ),
        ],
    )
    def test_arch_placeholders_and_arch_map(
        self, machine: str, expected: dict[str, str]
    ) -> None:
        tokens = ghrelease.GhRelease._arch_tokens(
            {'x86_64': '64-bit', 'arm64': 'arm64'}, machine=machine
        )
        assert tokens == expected

    def test_path_traversal_rejected_tar_and_zip(self, tmp_path: Path) -> None:
        bad_tar = tmp_path / 'bad.tar.gz'
        with tarfile.open(bad_tar, 'w:gz') as tf:
            info = tarfile.TarInfo('../evil')
            data = b'boom'
            info.size = len(data)
            tf.addfile(info, io.BytesIO(data))
        stage = tmp_path / 'stage'
        stage.mkdir()
        with pytest.raises(RuntimeError):
            ghrelease.GhRelease._extract_archive(str(bad_tar), 'bad.tar.gz', str(stage))

        abs_zip = tmp_path / 'abs.zip'
        with zipfile.ZipFile(abs_zip, 'w') as zf:
            zf.writestr('/etc/passwd', 'boom')
        with pytest.raises(RuntimeError):
            ghrelease.GhRelease._extract_archive(str(abs_zip), 'abs.zip', str(stage))

    def test_extract_tar_gz_strip_components_and_min_version_skip(
        self, tmp_path: Path
    ) -> None:
        archive = tmp_path / 'nvim.tar.gz'
        with tarfile.open(archive, 'w:gz') as tf:
            info = tarfile.TarInfo('nvim-linux-x86_64/bin/nvim')
            body = b'#!/bin/sh\necho "NVIM v0.12.6"\n'
            info.size = len(body)
            info.mode = 0o755
            tf.addfile(info, io.BytesIO(body))

        opt_dir = tmp_path / 'opt/nvim'
        bin_dir = tmp_path / 'bin'
        plugin = make_plugin(ghrelease.GhRelease, base_dir=tmp_path)
        spec = {
            'neovim/neovim': {
                'asset': 'nvim-linux-{arch}.tar.gz',
                'extract_to': str(opt_dir),
                'strip_components': 1,
                'bin_dir': str(bin_dir),
                'bins': ['bin/nvim'],
                'min_version': '0.11',
            },
        }
        with mock.patch.object(
            plugin,
            '_download',
            side_effect=lambda url, dst: Path(dst).write_bytes(archive.read_bytes()),
        ):
            assert plugin.handle('ghrelease', spec) is True
            assert (bin_dir / 'nvim').is_symlink()
            assert (opt_dir / 'bin/nvim').is_file()

        with mock.patch.object(
            plugin,
            '_download',
            side_effect=AssertionError('should not download'),
        ):
            assert plugin.handle('ghrelease', spec) is True

    def test_extract_gz_zip_and_tar_xz_with_creates_and_post_install(
        self, tmp_path: Path
    ) -> None:
        bin_dir = tmp_path / 'bin'
        gz_src = tmp_path / 'src.gz'
        with gzip.open(gz_src, 'wb') as fh:
            fh.write(b'#!/bin/sh\necho tree-sitter 0.27.1\n')

        zip_src = tmp_path / 'src.zip'
        with zipfile.ZipFile(zip_src, 'w') as zf:
            zf.writestr('yazi-x86_64/yazi', '#!/bin/sh\n')
            zf.writestr('yazi-x86_64/ya', '#!/bin/sh\n')

        txz_src = tmp_path / 'Hack.tar.xz'
        with tarfile.open(txz_src, 'w:xz') as tf:
            ti = tarfile.TarInfo('HackNerdFont-Regular.ttf')
            ti.size = 4
            tf.addfile(ti, io.BytesIO(b'font'))

        fonts_dir = tmp_path / 'fonts/Hack'
        marker = tmp_path / 'post_ran'

        def fake_dl(url: str, dst: str) -> None:
            if url.endswith('.gz') and not url.endswith('.tar.gz'):
                src = gz_src
            elif url.endswith('.zip'):
                src = zip_src
            else:
                src = txz_src
            Path(dst).write_bytes(src.read_bytes())

        plugin = make_plugin(ghrelease.GhRelease, base_dir=tmp_path)
        with (
            mock.patch.object(plugin, '_download', side_effect=fake_dl),
            mock.patch.object(ghrelease.shutil, 'which', return_value=None),
        ):
            ok = plugin.handle(
                'ghrelease',
                {
                    'tree-sitter/tree-sitter': {
                        'asset': 'tree-sitter-linux-{node_arch}.gz',
                        'bin_dir': str(bin_dir),
                        'bins': ['tree-sitter'],
                    },
                    'sxyazi/yazi': {
                        'asset': 'yazi-{uname_m}-unknown-linux-musl.zip',
                        'bin_dir': str(bin_dir),
                        'bins': ['yazi', 'ya'],
                    },
                    'ryanoasis/nerd-fonts': {
                        'asset': 'Hack.tar.xz',
                        'extract_to': str(fonts_dir),
                        'creates': str(fonts_dir / 'HackNerdFont-Regular.ttf'),
                        'post_install': [f'touch {marker}'],
                    },
                },
            )
            assert ok is True
            for b in ('tree-sitter', 'yazi', 'ya'):
                p = bin_dir / b
                assert p.is_file() and os.access(p, os.X_OK)
            assert (fonts_dir / 'HackNerdFont-Regular.ttf').is_file()
            assert marker.is_file()

    def test_resolve_latest_tag_and_dry_run(self, tmp_path: Path) -> None:
        with mock.patch.object(
            subprocess,
            'run',
            return_value=_completed(
                ['curl'],
                stdout='https://github.com/astral-sh/uv/releases/tag/0.13.6',
            ),
        ):
            assert ghrelease.GhRelease._resolve_latest_tag('astral-sh/uv') == '0.13.6'

        bin_dir = tmp_path / 'bin'
        plugin = make_plugin(ghrelease.GhRelease, dry_run=True, base_dir=tmp_path)
        with (
            mock.patch.object(ghrelease.shutil, 'which', return_value=None),
            mock.patch.object(
                plugin,
                '_resolve_latest_tag',
                side_effect=AssertionError('network called'),
            ),
            mock.patch.object(
                plugin,
                '_download',
                side_effect=AssertionError('download called'),
            ),
        ):
            ok = plugin.handle(
                'ghrelease',
                {
                    'jesseduffield/lazygit': {
                        'asset': 'lazygit_{version}_linux_{arch}.tar.gz',
                        'bin_dir': str(bin_dir),
                        'bins': ['lazygit'],
                    },
                },
            )
            assert ok is True
            assert not bin_dir.exists()


class TestManifestResolver:
    @pytest.mark.parametrize('profile', tuple(PROFILE_SPECS.keys()))
    def test_resolve_manifest_sources_and_platform_exclusions(
        self, profile: str
    ) -> None:
        resolved = manifest_mod.resolve_manifest(REPO_ROOT, profile=profile)
        assert '.config/zsh_plugins.txt' in resolved.symlinks
        assert '.local/bin/dot' in resolved.symlinks
        assert '.gitconfig' in resolved.templates
        assert resolved.directories.get('.ssh') == 0o700

        for src_rel in resolved.symlinks.values():
            assert (REPO_ROOT / src_rel).exists(), (
                f'Missing symlink source {src_rel!r} in profile {profile}'
            )
        for src_rel in resolved.templates.values():
            assert (REPO_ROOT / src_rel).is_file(), (
                f'Missing template source {src_rel!r} in profile {profile}'
            )

        if profile == 'macos':
            assert '.config/kitty/os-macos.conf' in resolved.symlinks

        if profile in ('macos', 'ubuntu'):
            assert '.local/bin/lock-screen' in resolved.symlinks
        else:
            assert '.local/bin/lock-screen' not in resolved.symlinks
            assert '.local/bin/lock-screen' in resolved.excluded_symlinks

    def test_discover_submodules_and_local_hooks(self) -> None:
        submodules = dict(manifest_mod.discover_submodules(REPO_ROOT))
        assert submodules.get('installer/dotbot') is True
        assert submodules.get('shell/antidote') is True
        assert submodules.get('tmux/tpm') is True

        hooks = manifest_mod.discover_local_hooks(REPO_ROOT)
        for expected in (
            '.gitconfig.local',
            '.ssh/config.local',
            '.config/env.local.sh',
            '.zshrc.local',
            '.bashrc.local',
            '.tmux.conf.local',
            '.tmux.conf.post.local',
            '.config/nvim.local.lua',
        ):
            assert expected in hooks

    def test_run_doctor_validates_synthetic_home(self, tmp_path: Path) -> None:
        repo = tmp_path / 'repo'
        home = tmp_path / 'home'
        home.mkdir()
        (repo / 'meta/profiles').mkdir(parents=True)
        (repo / 'meta/config').mkdir(parents=True)
        (repo / 'shell').mkdir()
        (repo / 'shell/zshrc').write_text(
            '[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"\n',
            encoding='utf-8',
        )
        (repo / 'git').mkdir()
        (repo / 'git/gitconfig').write_text(
            '[user]\n  name = {{NAME}}\n', encoding='utf-8'
        )
        (repo / 'meta/profiles/ubuntu-minimal').write_text(
            'base\nshell\ngit\n', encoding='utf-8'
        )
        (repo / 'meta/config/base.yaml').write_text(
            '- create:\n    ~/.ssh:\n      mode: 0700\n', encoding='utf-8'
        )
        (repo / 'meta/config/shell.yaml').write_text(
            '- link:\n    ~/.zshrc: shell/zshrc\n', encoding='utf-8'
        )
        (repo / 'meta/config/git.yaml').write_text(
            '- template:\n    ~/.gitconfig:\n      source_file: git/gitconfig\n',
            encoding='utf-8',
        )

        ssh_dir = home / '.ssh'
        ssh_dir.mkdir(mode=0o700)
        ssh_dir.chmod(0o700)
        (home / '.zshrc').symlink_to(repo / 'shell/zshrc')
        (home / '.gitconfig').write_text('[user]\n  name = Test\n', encoding='utf-8')
        (home / '.global_gitignore').write_text('*.swp\n', encoding='utf-8')

        assert manifest_mod.run_doctor(repo, profile='ubuntu-minimal', home=home) == 0

        # Unrendered template placeholder should fail doctor
        (home / '.gitconfig').write_text(
            '[user]\n  name = {{NAME}}\n', encoding='utf-8'
        )
        assert manifest_mod.run_doctor(repo, profile='ubuntu-minimal', home=home) == 1


class TestShortcutUnification:
    def test_wm_and_kinesis_parity(self) -> None:
        qwerty = (REPO_ROOT / 'kinesis/qwerty.txt').read_text(encoding='utf-8')
        assert '[lctrl]>[lwin]' in qwerty
        assert '[rctrl]>[rwin]' in qwerty
        assert '[intl-\\]>[lctrl]' in qwerty
        assert '[rwin]>[rctrl][t&h250][hyper]' in qwerty
        for line in qwerty.splitlines():
            assert not line.lstrip().startswith('#')

        yabairc = ' '.join(
            (REPO_ROOT / 'yabai/yabairc').read_text(encoding='utf-8').split()
        )
        assert 'yabai -m config mouse_modifier alt' in yabairc
        assert 'yabai -m config mouse_action1 move' in yabairc
        assert 'yabai -m config mouse_action2 resize' in yabairc

        i3_conf = (REPO_ROOT / 'i3wm/i3.conf').read_text(encoding='utf-8')
        assert 'floating_modifier $mod' in i3_conf
        assert 'bindsym Mod4+space exec "rofi -show combi"' in i3_conf
        assert 'bindsym $mod+s split toggle' in i3_conf
        assert 'bindsym Mod4+Control+$mod+Shift+Return floating toggle' in i3_conf
        for legacy in ('bindsym $mod+d ', 'bindsym $mod+h ', 'bindsym $mod+v '):
            assert legacy not in i3_conf

        hs_lua = (REPO_ROOT / 'hammerspoon/init.lua').read_text(encoding='utf-8')
        assert '"display", "--focus"' in hs_lua
        assert '"window", "--display"' in hs_lua
        assert '"window", "--space"' in hs_lua

    def test_terminal_kitty_and_iterm2_convergence(self, tmp_path: Path) -> None:
        kitty_conf = (REPO_ROOT / 'kitty/kitty.conf').read_text(encoding='utf-8')
        assert 'listen_on' in kitty_conf
        mod_idx = kitty_conf.index('kitty_mod')
        clear_idx = kitty_conf.index('clear_all_shortcuts')
        keymaps_idx = kitty_conf.index('keymaps.conf')
        glob_idx = kitty_conf.index('globinclude')
        assert mod_idx < clear_idx < keymaps_idx < glob_idx

        keymaps = (REPO_ROOT / 'kitty/keymaps.conf').read_text(encoding='utf-8')
        assert 'ctrl+a>' not in keymaps
        assert 'kitten smart_nav.py move left' in keymaps
        assert 'kitten smart_nav.py resize left 3' in keymaps
        assert 'kitty_mod+shift+[' in keymaps
        assert 'ctrl+tab' in keymaps
        assert 'send_key home' in keymaps
        assert 'send_key end' in keymaps

        cfile = tmp_path / 'smart_nav.pyc'
        py_compile.compile(
            str(REPO_ROOT / 'kitty/smart_nav.py'), cfile=str(cfile), doraise=True
        )

        plist_bytes = (REPO_ROOT / 'iterm2/com.googlecode.iterm2.plist').read_bytes()
        assert plist_bytes.startswith(b'bplist00')
        plist_data = plistlib.loads(plist_bytes)
        assert plist_data['RightOption'] == 2
        for bm in plist_data['New Bookmarks']:
            assert bm['Option Key Sends'] == 2
            assert bm['Right Option Key Sends'] == 2
            km = bm['Keyboard Map']
            assert km['0xf702-0x300000'] == {'Text': '[H', 'Action': 10}
            assert km['0xf703-0x300000'] == {'Text': '[F', 'Action': 10}
            assert km['0x68-0x180000'] == {'Text': '', 'Action': 18}
            assert km['0x6c-0x180000'] == {'Text': '', 'Action': 19}
            assert km['0x6b-0x180000'] == {'Text': '', 'Action': 20}
            assert km['0x6a-0x180000'] == {'Text': '', 'Action': 21}

    def test_tmux_shell_yazi_and_nvim_unification(self) -> None:
        tmux_conf = (REPO_ROOT / 'tmux/tmux.conf').read_text(encoding='utf-8')
        assert 'bind C-l send-keys C-l' in tmux_conf
        assert 'bind -n C-l send-keys C-l' not in tmux_conf
        assert 'bind z resize-pane -Z' in tmux_conf
        assert '@pane-is-vim' in tmux_conf
        assert 'bind -n M-h' in tmux_conf

        bashrc = (REPO_ROOT / 'shell/bashrc').read_text(encoding='utf-8')
        assert bashrc.index('set -o vi') < bashrc.index('fzf --bash')

        plugins_txt = (REPO_ROOT / 'shell/plugins.txt').read_text(encoding='utf-8')
        kb_idx = plugins_txt.index('ohmyzsh/ohmyzsh path:lib/key-bindings.zsh')
        zvm_idx = plugins_txt.index('jeffreytse/zsh-vi-mode')
        cb_idx = plugins_txt.index('ohmyzsh/ohmyzsh path:plugins/copybuffer')
        fzf_idx = plugins_txt.index('ohmyzsh/ohmyzsh path:plugins/fzf')
        assert kb_idx < zvm_idx < cb_idx < fzf_idx

        yazi_km = (REPO_ROOT / 'yazi/keymap.toml').read_text(encoding='utf-8')
        assert 'on = "<C-t>"' in yazi_km
        assert 'on = "<C-n>"' not in yazi_km

        nvim_user = (REPO_ROOT / 'editors/nvim/lua/plugins/user.lua').read_text(
            encoding='utf-8'
        )
        assert 'mrjones2014/smart-splits.nvim' in nvim_user
        assert 'at_edge = "stop"' in nvim_user
        assert '["<M-h>"]' in nvim_user

        astrocore = (REPO_ROOT / 'editors/nvim/lua/plugins/astrocore.lua').read_text(
            encoding='utf-8'
        )
        for pruned in (
            'Q = {',
            'U = {',
            '["<F2>"]',
            '["<F3>"]',
            '["<Leader>wh"]',
            '["<Leader>ws"]',
            '["<Leader>wv"]',
        ):
            assert pruned not in astrocore


def test_gitconfig_sendemail_section() -> None:
    gitconfig = REPO_ROOT / 'git/gitconfig'
    get_res = subprocess.run(
        ['git', 'config', '--file', str(gitconfig), '--get', 'sendemail.smtpserver'],
        capture_output=True,
        text=True,
        check=True,
    )
    assert get_res.stdout.strip() == '{{SMTP_SERVER}}'

    legacy_res = subprocess.run(
        ['git', 'config', '--file', str(gitconfig), '--get-regexp', r'^sendmail\.'],
        capture_output=True,
        text=True,
        check=False,
    )
    assert legacy_res.returncode != 0
