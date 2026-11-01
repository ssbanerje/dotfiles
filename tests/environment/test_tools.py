from __future__ import annotations

import re
import tomllib
from typing import TYPE_CHECKING

import pytest

from tests.conftest import run_env

if TYPE_CHECKING:
    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.environment

YAZI_KEY_RE = re.compile(r'^[a-z0-9-]{1,20}$')


@pytest.mark.parametrize(
    ('binary', 'flag'),
    [
        ('git', '--version'),
        ('zsh', '--version'),
        ('tmux', '-V'),
        ('nvim', '--version'),
        ('rg', '--version'),
        ('fzf', '--version'),
        ('starship', '--version'),
        ('zoxide', '--version'),
        ('tldr', '--version'),
        ('uv', '--version'),
        ('uvx', '--version'),
        ('ipython', '--version'),
        ('yazi', '--version'),
        ('ya', '--version'),
        ('lazygit', '--version'),
        ('tree-sitter', '--version'),
        ('jq', '--version'),
        ('chafa', '--version'),
        ('ports', '--help'),
    ],
)
def test_cli_binaries_execute(host: Host, binary: str, flag: str) -> None:
    res = run_env(host, binary, flag)
    assert res.rc == 0, f'{binary} {flag} failed:\n{res.stdout}\n{res.stderr}'


def test_profile_specific_binaries(host: Host, profile_spec: ProfileSpec) -> None:
    assert run_env(host, profile_spec.fd_binary, '--version').rc == 0
    if profile_spec.has_vale:
        assert run_env(host, 'vale', '--version').rc == 0


def test_neovim_version_and_headless_startup(host: Host) -> None:
    ver = run_env(host, 'nvim', '--version')
    assert ver.rc == 0
    m = re.search(r'NVIM v(\d+)\.(\d+)', ver.stdout)
    assert m is not None, f'Could not parse nvim version from: {ver.stdout}'
    assert (int(m.group(1)), int(m.group(2))) >= (0, 11)

    boot = run_env(host, 'nvim', '--headless', '+qa')
    assert boot.rc == 0, boot.stderr


@pytest.mark.parametrize('name', ('yazi.toml', 'keymap.toml'))
def test_yazi_toml_configs_valid_for_v26_schema(
    host: Host, target_home: str, name: str
) -> None:
    raw = host.file(f'{target_home}/.config/yazi/{name}').content_string
    assert raw.startswith('#:schema https://yazi-rs.github.io/schemas/')
    parsed = tomllib.loads(raw)
    assert parsed, f'Expected non-empty Yazi config in {name}'
    for key in parsed:
        assert YAZI_KEY_RE.fullmatch(key), (
            f'Invalid Yazi v26+ top-level TOML key {key!r} '
            '(must be 1-20 chars in kebab-case)'
        )


@pytest.mark.parametrize(
    'plugin_dir',
    ('tmux-power', 'tmux-resurrect', 'tmux-continuum', 'tmux-prefix-highlight'),
)
def test_tmux_tpm_plugins_installed(
    host: Host, target_home: str, plugin_dir: str
) -> None:
    assert host.file(f'{target_home}/.tmux/plugins/{plugin_dir}').is_directory


def test_tmux_config_parses_and_registers_popup_bindings(
    host: Host, target_home: str
) -> None:
    res = run_env(
        host,
        'tmux',
        '-L',
        'dotfiles_pytest',
        '-f',
        f'{target_home}/.tmux.conf',
        'start-server',
        ';',
        'list-keys',
    )
    assert res.rc == 0, res.stderr
    for expected in ('ftpane', 'ftwind', 'ftsession', 'lazygit'):
        assert expected in res.stdout


def test_dot_cli_doctor_and_bench(host: Host) -> None:
    doc = run_env(host, 'dot', 'doctor')
    assert doc.rc == 0, f'dot doctor failed:\n{doc.stdout}\n{doc.stderr}'
    assert 'Doctor checks passed' in doc.stdout

    bench = run_env(host, 'dot', 'bench', '2')
    assert bench.rc == 0, f'dot bench failed:\n{bench.stdout}\n{bench.stderr}'
    for target in ('zsh -i -c exit', 'bash -i -c exit', 'nvim --headless +qa'):
        assert f'[ok]   {target}' in bench.stdout


PROMPT_ESCAPE_RE = re.compile(r'%\{|\x1b\[[0-9;]*m|%\}|\\\[|\\\]|[\x01\x02]')


def test_starship_prompt_shortening_and_git_icons(host: Host) -> None:
    delim = '__STARSHIP_DELIM__'
    snippet = (
        'set -euo pipefail && '
        'source "$HOME/.config/env.sh" && '
        'export STARSHIP_CONFIG="$HOME/.config/starship.toml" && '
        'tmp="$(mktemp -d "$HOME/starshiptmp.XXXXXX")" && '
        'trap \'rm -rf "$tmp"\' EXIT && '
        'mkdir -p "$tmp/dirone/dirtwo/dirthree/Workshop" && '
        'cd "$tmp/dirone/dirtwo/dirthree/Workshop" && '
        'p_zsh="$(STARSHIP_SHELL=zsh starship prompt)" && '
        'p_bash="$(STARSHIP_SHELL=bash starship prompt)" && '
        'git init -q -b main && '
        'git config user.email "ci@example.com" && '
        'git config user.name "CI" && '
        'p_root="$(STARSHIP_SHELL=zsh starship prompt)" && '
        'mkdir -p dotfiles/shell && '
        'cd dotfiles/shell && '
        'p_sub="$(STARSHIP_SHELL=zsh starship prompt)" && '
        'cd "$tmp/dirone/dirtwo/dirthree/Workshop" && '
        'echo a > tracked.txt && '
        'git add tracked.txt && '
        'git commit -q -m "init" && '
        'git tag v1.0 && '
        'echo b > staged.txt && '
        'git add staged.txt && '
        'echo c >> tracked.txt && '
        'echo d > untracked.txt && '
        'p_dirty="$(STARSHIP_SHELL=zsh starship prompt)" && '
        'short_sha="$(git rev-parse --short=8 HEAD)" && '
        'git checkout -q --detach HEAD && '
        'git reset -q --hard && '
        'rm -f untracked.txt && '
        'p_detached="$(STARSHIP_SHELL=zsh starship prompt)" && '
        'p_vicmd="$(STARSHIP_SHELL=zsh starship prompt --keymap=vicmd)" && '
        'rp_err="$(STARSHIP_SHELL=zsh starship prompt --right --status=1)" && '
        'rp_sig="$(STARSHIP_SHELL=zsh starship prompt --right --status=130)" && '
        'rp_pipe="$(YAZI_LEVEL=1 VIMRUNTIME=/tmp STARSHIP_SHELL=zsh '
        'starship prompt --right --status=1 --pipestatus="0 1" '
        '--jobs=1 --cmd-duration=6000)" && '
        f'printf "%s\\n{delim}\\n" '
        '"$p_zsh" "$p_bash" "$p_root" "$p_sub" "$p_dirty" '
        '"$short_sha" "$p_detached" "$p_vicmd" "$rp_err" "$rp_sig" "$rp_pipe"'
    )
    res = host.run('bash -c %s', snippet)
    assert res.rc == 0, f'{res.stdout}\n{res.stderr}'
    cleaned = PROMPT_ESCAPE_RE.sub('', res.stdout)
    parts = [part.strip('\n') for part in cleaned.split(f'\n{delim}\n')[:-1]]
    (
        p_zsh,
        p_bash,
        p_root,
        p_sub,
        p_dirty,
        short_sha,
        p_detached,
        p_vicmd,
        rp_err,
        rp_sig,
        rp_pipe,
    ) = parts

    # [shell]: hidden cleanly in zsh (no stray triple space), visible in bash
    assert '[zsh]' not in p_zsh
    assert '   ' not in p_zsh
    assert '  ~/s/d/dirtwo/dirthree/Workshop » ' in p_zsh
    assert '[bash]   ~/s/d/dirtwo/dirthree/Workshop » ' in p_bash

    # [directory] + [git_branch]: repo root stays anchored inside subdirs
    assert '  ~/s/d/d/d/Workshop on    main » ' in p_root
    assert '  ~/s/d/d/d/Workshop/dotfiles/shell on    main » ' in p_sub

    # [git_status]: space-separated counters; tag hidden on attached branch
    assert 'on    main +1 !1 ?1 » ' in p_dirty
    assert '#v1.0' not in p_dirty

    # [git_commit]: detached HEAD shows @<8-sha> #<tag> without  HEAD or ()
    assert f'  ~/s/d/d/d/Workshop on   @{short_sha} #v1.0 » ' in p_detached
    assert 'HEAD' not in p_detached
    assert '(' not in p_detached

    # [character]: vi normal mode shows Neovim glyph
    assert p_vicmd.endswith('  ')

    # Right prompt: numeric error, signal name, pipestatus, jobs, context, badges
    assert rp_err.startswith('✘ 1 on ') and '@' in rp_err
    assert not rp_err.endswith(' ')
    assert rp_sig.startswith('✘ 130 INT on ')
    assert rp_pipe.startswith('[0|1] => ✘ 1 took 6s  1 on ')
    assert rp_pipe.endswith(' 󰇥 ')
