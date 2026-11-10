from __future__ import annotations

import re
from typing import TYPE_CHECKING

import pytest

from tests.conftest import run_shell_i

if TYPE_CHECKING:
    from collections.abc import Callable

    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.environment

SHELL_ERROR_RE = re.compile(
    r'(command not found|no such file or directory|parse error)',
    re.IGNORECASE,
)

ZSH_ALIASES = (
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
)

ZSH_SYMBOLS = (
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
    'open',
    'pbcopy',
    'pbpaste',
)

BASH_SYMBOLS = (
    'ls',
    'll',
    'la',
    'grep',
    'rm',
    'mv',
    'cp',
    'y',
    'mkd',
    'path',
    'fs',
    'serve',
    'dotenv',
    'z',
    'open',
    'pbcopy',
    'pbpaste',
)


def test_interactive_shell_starts_without_stderr_errors(
    host: Host, target_home: str, interactive_shell: str
) -> None:
    if interactive_shell == 'zsh':
        compiled = host.file(f'{target_home}/.zsh_plugins.zsh')
        assert compiled.is_file
        assert compiled.size > 0
    res = run_shell_i(host, interactive_shell, 'exit')
    assert res.rc == 0, f'{interactive_shell} failed: {res.stderr}'
    assert not SHELL_ERROR_RE.search(res.stderr), (
        f'Unexpected {interactive_shell} stderr:\n{res.stderr}'
    )


def test_zsh_aliases_functions_and_widgets_present(host: Host) -> None:
    aliases_str = ' '.join(ZSH_ALIASES)
    symbols_str = ' '.join(ZSH_SYMBOLS)
    snippet = (
        f'for a in {aliases_str}; do '
        'alias "$a" >/dev/null || { echo "missing zsh alias: $a" >&2; exit 1; }; '
        'done && '
        f'for s in {symbols_str}; do '
        'whence -w "$s" >/dev/null || { echo "missing zsh symbol: $s" >&2; exit 1; }; '
        'done && '
        '[[ "$(whence -w y)" == "y: function" ]]'
    )
    res = run_shell_i(host, 'zsh', snippet)
    assert res.rc == 0, res.stderr


def test_bash_aliases_and_helpers_present(host: Host) -> None:
    symbols_str = ' '.join(BASH_SYMBOLS)
    snippet = (
        f'for s in {symbols_str}; do '
        'type "$s" >/dev/null || { echo "missing bash symbol: $s" >&2; exit 1; }; '
        'done'
    )
    res = run_shell_i(host, 'bash', snippet)
    assert res.rc == 0, res.stderr


def test_zsh_history_and_options(host: Host, target_home: str) -> None:
    snippet = (
        'printf "%s\\n%s\\n%s\\n" "$HISTFILE" "$HISTSIZE" "$SAVEHIST" && '
        '[[ -o histignorespace && -o histverify && -o interactivecomments && -o sharehistory ]]'
    )
    res = run_shell_i(host, 'zsh', snippet)
    assert res.rc == 0, res.stderr
    histfile, histsize, savehist = res.stdout.strip().splitlines()
    assert histfile == f'{target_home}/.zsh_history'
    assert int(histsize) >= 50000
    assert int(savehist) >= 50000


def test_shell_environment_exports(
    host: Host, profile_spec: ProfileSpec, interactive_shell: str
) -> None:
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
    res = run_shell_i(host, interactive_shell, snippet)
    assert res.rc == 0, res.stderr
    assert profile_spec.fd_binary in res.stdout


@pytest.mark.parametrize(
    ('shell', 'rc_local'),
    [('zsh', '.zshrc.local'), ('bash', '.bashrc.local')],
)
def test_local_shell_override_hooks(
    host: Host,
    target_home: str,
    remote_files: Callable[[str, str, str | None], None],
    shell: str,
    rc_local: str,
) -> None:
    remote_files(
        f'{target_home}/.config/env.local.sh',
        'export CI_ENV_LOCAL_PROBE="from_env_local"; PREPEND_PATH "/tmp"\n',
        None,
    )
    remote_files(
        f'{target_home}/{rc_local}',
        f'export CI_SHELL_LOCAL_PROBE="ok_{shell}"\n',
        None,
    )
    res = run_shell_i(
        host, shell, 'printf "%s:%s" "$CI_ENV_LOCAL_PROBE" "$CI_SHELL_LOCAL_PROBE"'
    )
    assert res.rc == 0
    assert res.stdout.strip() == f'from_env_local:ok_{shell}'
