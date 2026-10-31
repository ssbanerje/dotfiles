from __future__ import annotations

import gzip
import io
import os
import subprocess
import sys
import tarfile
import tempfile
import zipfile
from pathlib import Path
from unittest import mock

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
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
        base_dir: str = str(REPO_ROOT),
        dry_run: bool = False,
        defaults: dict | None = None,
    ) -> None:
        self._base_dir = base_dir
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
    base_dir: str = str(REPO_ROOT),
):
    plugin = cls(DummyContext(base_dir=base_dir, dry_run=dry_run, defaults=defaults))
    plugin._log = DummyLog()
    return plugin


class TestAptPlugin:
    def test_batched_dpkg_query_and_cache(self) -> None:
        plugin = make_plugin(apt.Apt)

        def fake_run(argv, **kwargs):
            assert argv[0] == 'dpkg-query'
            return subprocess.CompletedProcess(
                argv,
                1,
                stdout=(
                    'curl:amd64\tcurl\t7.88.1-10\tinstalled\n'
                    'git\tgit\t1:2.39.5-1\tinstalled\n'
                ),
                stderr='',
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
                return subprocess.CompletedProcess(argv, 1, stdout='', stderr='')
            if argv[0] == 'apt-cache':
                return subprocess.CompletedProcess(
                    argv, 0, stdout=policy_out, stderr=''
                )
            assert argv[0] == 'dpkg'
            return subprocess.CompletedProcess(argv, dpkg_rc, stdout='', stderr='')

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
    def test_find_brew_discovers_apple_silicon_and_prepends_path(self) -> None:
        plugin = make_plugin(brew.Brew)
        with tempfile.TemporaryDirectory() as td:
            fake_bin = os.path.join(td, 'bin')
            fake_sbin = os.path.join(td, 'sbin')
            os.makedirs(fake_bin)
            os.makedirs(fake_sbin)
            fake_brew = os.path.join(fake_bin, 'brew')
            Path(fake_brew).write_text('#!/bin/sh\n', encoding='utf-8')
            os.chmod(fake_brew, 0o755)

            with (
                mock.patch.object(brew.Brew, '_BREW_CANDIDATES', (fake_brew,)),
                mock.patch.object(brew.shutil, 'which', return_value=None),
                mock.patch.dict(os.environ, {'PATH': '/usr/bin:/bin'}, clear=False),
            ):
                found = plugin._find_brew()
                assert found == fake_brew
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
            if argv[1:] == ['tap']:
                return subprocess.CompletedProcess(argv, 0, stdout='', stderr='')
            if argv[1:] == ['trust', '--help']:
                return subprocess.CompletedProcess(argv, 0, stdout='', stderr='')
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
                return_value=subprocess.CompletedProcess(
                    ['pacman'], 127, stdout='ripgrep\n', stderr=''
                ),
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

    def test_path_traversal_rejected_tar_and_zip(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            bad_tar = os.path.join(td, 'bad.tar.gz')
            with tarfile.open(bad_tar, 'w:gz') as tf:
                info = tarfile.TarInfo('../evil')
                data = b'boom'
                info.size = len(data)
                tf.addfile(info, io.BytesIO(data))
            stage = os.path.join(td, 'stage')
            os.makedirs(stage)
            with pytest.raises(RuntimeError):
                ghrelease.GhRelease._extract_archive(bad_tar, 'bad.tar.gz', stage)

            abs_zip = os.path.join(td, 'abs.zip')
            with zipfile.ZipFile(abs_zip, 'w') as zf:
                zf.writestr('/etc/passwd', 'boom')
            with pytest.raises(RuntimeError):
                ghrelease.GhRelease._extract_archive(abs_zip, 'abs.zip', stage)

    def test_extract_tar_gz_strip_components_and_min_version_skip(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            archive = os.path.join(td, 'nvim.tar.gz')
            with tarfile.open(archive, 'w:gz') as tf:
                info = tarfile.TarInfo('nvim-linux-x86_64/bin/nvim')
                body = b'#!/bin/sh\necho "NVIM v0.12.6"\n'
                info.size = len(body)
                info.mode = 0o755
                tf.addfile(info, io.BytesIO(body))

            opt_dir = os.path.join(td, 'opt/nvim')
            bin_dir = os.path.join(td, 'bin')
            plugin = make_plugin(ghrelease.GhRelease, base_dir=td)
            spec = {
                'neovim/neovim': {
                    'asset': 'nvim-linux-{arch}.tar.gz',
                    'extract_to': opt_dir,
                    'strip_components': 1,
                    'bin_dir': bin_dir,
                    'bins': ['bin/nvim'],
                    'min_version': '0.11',
                },
            }
            with mock.patch.object(
                plugin,
                '_download',
                side_effect=lambda url, dst: Path(dst).write_bytes(
                    Path(archive).read_bytes()
                ),
            ):
                assert plugin.handle('ghrelease', spec) is True
                assert os.path.islink(os.path.join(bin_dir, 'nvim'))
                assert os.path.isfile(os.path.join(opt_dir, 'bin/nvim'))

            with mock.patch.object(
                plugin,
                '_download',
                side_effect=AssertionError('should not download'),
            ):
                assert plugin.handle('ghrelease', spec) is True

    def test_extract_gz_zip_and_tar_xz_with_creates_and_post_install(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            bin_dir = os.path.join(td, 'bin')
            gz_src = os.path.join(td, 'src.gz')
            with gzip.open(gz_src, 'wb') as fh:
                fh.write(b'#!/bin/sh\necho tree-sitter 0.27.1\n')

            zip_src = os.path.join(td, 'src.zip')
            with zipfile.ZipFile(zip_src, 'w') as zf:
                zf.writestr('yazi-x86_64/yazi', '#!/bin/sh\n')
                zf.writestr('yazi-x86_64/ya', '#!/bin/sh\n')

            txz_src = os.path.join(td, 'Hack.tar.xz')
            with tarfile.open(txz_src, 'w:xz') as tf:
                ti = tarfile.TarInfo('HackNerdFont-Regular.ttf')
                ti.size = 4
                tf.addfile(ti, io.BytesIO(b'font'))

            fonts_dir = os.path.join(td, 'fonts/Hack')
            marker = os.path.join(td, 'post_ran')

            def fake_dl(url: str, dst: str) -> None:
                if url.endswith('.gz') and not url.endswith('.tar.gz'):
                    src = gz_src
                elif url.endswith('.zip'):
                    src = zip_src
                else:
                    src = txz_src
                Path(dst).write_bytes(Path(src).read_bytes())

            plugin = make_plugin(ghrelease.GhRelease, base_dir=td)
            with (
                mock.patch.object(plugin, '_download', side_effect=fake_dl),
                mock.patch.object(ghrelease.shutil, 'which', return_value=None),
            ):
                ok = plugin.handle(
                    'ghrelease',
                    {
                        'tree-sitter/tree-sitter': {
                            'asset': 'tree-sitter-linux-{node_arch}.gz',
                            'bin_dir': bin_dir,
                            'bins': ['tree-sitter'],
                        },
                        'sxyazi/yazi': {
                            'asset': 'yazi-{uname_m}-unknown-linux-musl.zip',
                            'bin_dir': bin_dir,
                            'bins': ['yazi', 'ya'],
                        },
                        'ryanoasis/nerd-fonts': {
                            'asset': 'Hack.tar.xz',
                            'extract_to': fonts_dir,
                            'creates': os.path.join(
                                fonts_dir, 'HackNerdFont-Regular.ttf'
                            ),
                            'post_install': [f'touch {marker}'],
                        },
                    },
                )
                assert ok is True
                for b in ('tree-sitter', 'yazi', 'ya'):
                    p = os.path.join(bin_dir, b)
                    assert os.path.isfile(p) and os.access(p, os.X_OK)
                assert os.path.isfile(
                    os.path.join(fonts_dir, 'HackNerdFont-Regular.ttf')
                )
                assert os.path.isfile(marker)

    def test_resolve_latest_tag_and_dry_run(self) -> None:
        with mock.patch.object(
            subprocess,
            'run',
            return_value=subprocess.CompletedProcess(
                ['curl'],
                0,
                'https://github.com/astral-sh/uv/releases/tag/0.13.6',
                '',
            ),
        ):
            assert ghrelease.GhRelease._resolve_latest_tag('astral-sh/uv') == '0.13.6'

        with tempfile.TemporaryDirectory() as td:
            bin_dir = os.path.join(td, 'bin')
            plugin = make_plugin(ghrelease.GhRelease, dry_run=True, base_dir=td)
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
                            'bin_dir': bin_dir,
                            'bins': ['lazygit'],
                        },
                    },
                )
                assert ok is True
                assert not os.path.exists(bin_dir)
