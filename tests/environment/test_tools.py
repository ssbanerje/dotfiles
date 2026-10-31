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
