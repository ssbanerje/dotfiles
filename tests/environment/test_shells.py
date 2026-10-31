from __future__ import annotations

import re
from typing import TYPE_CHECKING

import pytest

from tests.conftest import run_bash_i, run_zsh_i, write_remote_file

if TYPE_CHECKING:
    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.environment

SHELL_ERROR_RE = re.compile(
    r'(command not found|no such file or directory|parse error)',
    re.IGNORECASE,
)


def test_zsh_interactive_starts_without_stderr_errors(
    host: Host, target_home: str
) -> None:
    assert host.file(f'{target_home}/.zsh_plugins.zsh').is_file
    assert host.file(f'{target_home}/.zsh_plugins.zsh').size > 0
    res = run_zsh_i(host, 'exit')
    assert res.rc == 0, f'zsh failed: {res.stderr}'
    assert not SHELL_ERROR_RE.search(res.stderr), (
        f'Unexpected zsh stderr:\n{res.stderr}'
    )


def test_bash_interactive_starts_without_stderr_errors(host: Host) -> None:
    res = run_bash_i(host, 'exit')
    assert res.rc == 0, f'bash failed: {res.stderr}'
    assert not SHELL_ERROR_RE.search(res.stderr), (
        f'Unexpected bash stderr:\n{res.stderr}'
    )


@pytest.mark.parametrize(
    'alias_name',
    (
        'ls',
        'll',
        'la',
        'l',
        'lsa',
        'md',
        'rd',
        'grep',
        't',
        'ccat',
        'cless',
        'ya',
        'rm',
        'mv',
        'cp',
    ),
)
def test_zsh_core_aliases_present(host: Host, alias_name: str) -> None:
    res = run_zsh_i(host, f'alias {alias_name}')
    assert res.rc == 0, f'Missing zsh alias {alias_name!r}: {res.stderr}'


@pytest.mark.parametrize(
    'symbol',
    (
        'zsh-defer',
        'zvm_define_widget',
        'z',
        'd',
        'y',
        'mkd',
        'path',
        'fs',
        'serve',
        'dotenv',
        'web_search',
        'pyclean',
    ),
)
def test_zsh_functions_and_widgets_present(host: Host, symbol: str) -> None:
    res = run_zsh_i(host, f'whence -w {symbol}')
    assert res.rc == 0, f'Missing zsh symbol {symbol!r}: {res.stderr}'


def test_zsh_y_resolves_to_yazi_function_not_yarn_alias(host: Host) -> None:
    res = run_zsh_i(host, 'whence -w y')
    assert res.rc == 0
    assert res.stdout.strip() == 'y: function'


@pytest.mark.parametrize(
    'symbol',
    ('ls', 'll', 'la', 'grep', 'y', 'mkd', 'path', 'fs', 'serve', 'dotenv'),
)
def test_bash_aliases_and_helpers_present(host: Host, symbol: str) -> None:
    res = run_bash_i(host, f'type {symbol}')
    assert res.rc == 0, f'Missing bash symbol {symbol!r}: {res.stderr}'


@pytest.mark.parametrize('cmd', ('open', 'pbcopy', 'pbpaste'))
def test_cross_platform_clipboard_and_open_defined(host: Host, cmd: str) -> None:
    assert run_zsh_i(host, f'whence -w {cmd}').rc == 0
    assert run_bash_i(host, f'type {cmd}').rc == 0


def test_zsh_history_and_options(host: Host, target_home: str) -> None:
    snippet = (
        'printf "%s\\n%s\\n%s\\n" "$HISTFILE" "$HISTSIZE" "$SAVEHIST" && '
        '[[ -o histignorespace && -o histverify && -o interactivecomments && -o sharehistory ]]'
    )
    res = run_zsh_i(host, snippet)
    assert res.rc == 0, res.stderr
    histfile, histsize, savehist = res.stdout.strip().splitlines()
    assert histfile == f'{target_home}/.zsh_history'
    assert int(histsize) >= 50000
    assert int(savehist) >= 50000


def test_shell_environment_exports(host: Host, profile_spec: ProfileSpec) -> None:
    snippet = (
        'test -n "$XDG_CONFIG_HOME" && '
        'test -n "$XDG_CACHE_HOME" && '
        'test -n "$XDG_DATA_HOME" && '
        'test -n "$XDG_STATE_HOME" && '
        'test "$EDITOR" = "nvim" && '
        'test "$VISUAL" = "nvim" && '
        'test "$DO_NOT_TRACK" = "1" && '
        'test "$HOMEBREW_NO_ANALYTICS" = "1" && '
        'test "$PYTHONIOENCODING" = "UTF-8" && '
        'printf "%s" "$FZF_DEFAULT_COMMAND"'
    )
    for runner in (run_zsh_i, run_bash_i):
        res = runner(host, snippet)
        assert res.rc == 0, res.stderr
        assert profile_spec.fd_binary in res.stdout


def test_local_shell_override_hooks(host: Host, target_home: str) -> None:
    env_local = f'{target_home}/.config/env.local.sh'
    zsh_local = f'{target_home}/.zshrc.local'
    bash_local = f'{target_home}/.bashrc.local'
    try:
        write_remote_file(
            host,
            env_local,
            'export CI_ENV_LOCAL_PROBE="from_env_local"; PREPEND_PATH "/tmp"\n',
        )
        write_remote_file(
            host,
            zsh_local,
            'export CI_ZSH_LOCAL_PROBE="ok_zsh"\n',
        )
        write_remote_file(
            host,
            bash_local,
            'export CI_BASH_LOCAL_PROBE="ok_bash"\n',
        )

        z_res = run_zsh_i(
            host, 'printf "%s:%s" "$CI_ENV_LOCAL_PROBE" "$CI_ZSH_LOCAL_PROBE"'
        )
        assert z_res.rc == 0
        assert z_res.stdout.strip() == 'from_env_local:ok_zsh'

        b_res = run_bash_i(
            host, 'printf "%s:%s" "$CI_ENV_LOCAL_PROBE" "$CI_BASH_LOCAL_PROBE"'
        )
        assert b_res.rc == 0
        assert b_res.stdout.strip() == 'from_env_local:ok_bash'
    finally:
        host.run('rm -f %s %s %s', env_local, zsh_local, bash_local)
