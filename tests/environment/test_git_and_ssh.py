from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from tests.conftest import run_env

if TYPE_CHECKING:
    from testinfra.host import Host

pytestmark = pytest.mark.environment


@pytest.mark.parametrize(
    ('filename', 'attr', 'expected'),
    [
        ('sample.py', 'diff', 'python'),
        ('sample.rs', 'diff', 'rust'),
        ('sample.go', 'diff', 'golang'),
        ('sample.cpp', 'diff', 'cpp'),
        ('sample.sh', 'diff', 'bash'),
        ('sample.md', 'diff', 'markdown'),
        ('image.png', 'binary', 'set'),
        ('image.png', 'diff', 'unset'),
        ('manual.pdf', 'binary', 'set'),
        ('vector.svg', 'diff', 'unspecified'),
    ],
)
def test_global_gitattributes_active(
    host: Host, filename: str, attr: str, expected: str
) -> None:
    snippet = (
        'tmp="$(mktemp -d)" && '
        'trap \'rm -rf "$tmp"\' EXIT && '
        'git -C "$tmp" init -q && '
        'git -C "$tmp" check-attr "$1" "$2"'
    )
    res = host.run('bash -c %s -- %s %s', snippet, attr, filename)
    assert res.rc == 0, res.stderr
    assert res.stdout.strip() == f'{filename}: {attr}: {expected}'


@pytest.mark.parametrize(
    ('key', 'expected'),
    [
        ('init.defaultBranch', 'main'),
        ('diff.algorithm', 'histogram'),
        ('diff.submodule', 'log'),
        ('merge.conflictStyle', 'zdiff3'),
        ('branch.sort', '-committerdate'),
        ('tag.sort', 'version:refname'),
        ('fetch.prune', 'true'),
        ('pull.rebase', 'true'),
        ('rebase.autoStash', 'true'),
        ('rebase.updateRefs', 'true'),
        ('rerere.enabled', 'true'),
        ('rerere.autoupdate', 'true'),
        ('alias.pf', 'push --force-with-lease --force-if-includes'),
    ],
)
def test_gitconfig_modern_settings(host: Host, key: str, expected: str) -> None:
    res = run_env(host, 'git', 'config', '--global', '--get', key)
    assert res.rc == 0, f'Missing git config {key}: {res.stderr}'
    assert res.stdout.strip() == expected


def test_gitconfig_local_override_precedence(host: Host, target_home: str) -> None:
    local_cfg = f'{target_home}/.gitconfig.local'
    try:
        host.run_expect(
            [0],
            'printf %s %s > %s',
            '[alias]\n',
            '  ci-local-probe = status --short\n',
            local_cfg,
        )
        res = run_env(host, 'git', 'config', '--get', 'alias.ci-local-probe')
        assert res.rc == 0
        assert res.stdout.strip() == 'status --short'
    finally:
        host.run('rm -f %s', local_cfg)


def test_ssh_config_and_local_include_override(host: Host, target_home: str) -> None:
    base = host.run('ssh -G localhost')
    assert base.rc == 0, base.stderr
    assert 'hashknownhosts yes' in base.stdout.splitlines()

    local_ssh = f'{target_home}/.ssh/config.local'
    try:
        host.run_expect(
            [0],
            'printf %s > %s && chmod 600 %s',
            'Host ci-probe.invalid\n  User overrideprobe\n',
            local_ssh,
            local_ssh,
        )
        probe = host.run('ssh -G ci-probe.invalid')
        assert probe.rc == 0, probe.stderr
        assert 'user overrideprobe' in probe.stdout.splitlines()
    finally:
        host.run('rm -f %s', local_ssh)
