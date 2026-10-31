from __future__ import annotations

import subprocess
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.container

MAX_IMAGE_SIZE_BYTES = 900 * 1024 * 1024


def test_default_zero_arg_container_startup(profile_spec: ProfileSpec) -> None:
    assert profile_spec.docker_image is not None
    res = subprocess.run(
        ['docker', 'run', '--rm', profile_spec.docker_image],
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0, res.stderr


def test_direct_multi_arg_entrypoint_execution(profile_spec: ProfileSpec) -> None:
    assert profile_spec.docker_image is not None
    res = subprocess.run(
        ['docker', 'run', '--rm', profile_spec.docker_image, 'nvim', '--version'],
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0, res.stderr
    assert 'NVIM v' in res.stdout


def test_container_user_login_shell_and_passwordless_sudo(host: Host) -> None:
    assert host.check_output('whoami').strip() == 'dotuser'
    assert host.check_output('printf %s "$SHELL"').strip() == '/usr/bin/zsh'
    assert host.run('sudo -n true').rc == 0


def test_embedded_dotfiles_repo_is_clean(host: Host, target_home: str) -> None:
    res = host.run('git -C %s status --porcelain', f'{target_home}/.dotfiles')
    assert res.rc == 0, res.stderr
    assert res.stdout.strip() == ''


@pytest.mark.parametrize(
    'cache_rel',
    ('.cache/uv', '.cache/nvim', '.cache/yay'),
)
def test_user_build_caches_purged(host: Host, target_home: str, cache_rel: str) -> None:
    assert not host.file(f'{target_home}/{cache_rel}').exists


@pytest.mark.parametrize(
    'sys_dir',
    ('/var/cache/pacman/pkg', '/var/lib/apt/lists'),
)
def test_system_package_caches_purged(host: Host, sys_dir: str) -> None:
    d = host.file(sys_dir)
    if d.is_directory:
        listing = host.check_output('ls -A %s', sys_dir).strip()
        assert listing == '', f'Expected {sys_dir} to be empty, found: {listing}'


def test_container_image_size_within_budget(profile_spec: ProfileSpec) -> None:
    assert profile_spec.docker_image is not None
    out = subprocess.check_output(
        [
            'docker',
            'image',
            'inspect',
            '--format',
            '{{.Size}}',
            profile_spec.docker_image,
        ],
        text=True,
    ).strip()
    size_bytes = int(out)
    assert size_bytes <= MAX_IMAGE_SIZE_BYTES, (
        f'Image {profile_spec.docker_image} is {size_bytes / (1024 * 1024):.1f} MiB '
        f'(budget: {MAX_IMAGE_SIZE_BYTES / (1024 * 1024):.1f} MiB)'
    )


@pytest.mark.parametrize(
    ('uid', 'gid'),
    [
        (1000, 1000),
        (907197, 89939),
    ],
)
def test_dynamic_uid_gid_remap(profile_spec: ProfileSpec, uid: int, gid: int) -> None:
    assert profile_spec.docker_image is not None
    script = (
        f'set -euo pipefail; '
        f'test "$(id -u)" = "{uid}"; '
        f'test "$(id -g)" = "{gid}"; '
        f'test "$(whoami)" = "dotuser"; '
        f'test -r "$HOME/.bashrc"; '
        f'test -r "$HOME/.zshrc"; '
        f'sudo -n true; '
        f'test ! -s /var/log/lastlog; '
        f'zsh -i -c "alias ll >/dev/null && whence -w y | grep -q function && type z >/dev/null"'
    )
    res = subprocess.run(
        [
            'docker',
            'run',
            '--rm',
            '-u',
            '0:0',
            '-e',
            f'HOST_UID={uid}',
            '-e',
            f'HOST_GID={gid}',
            '-e',
            'TERM=xterm-256color',
            profile_spec.docker_image,
            'bash',
            '-lc',
            script,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0, (
        f'UID/GID remap ({uid}:{gid}) failed:\n{res.stdout}\n{res.stderr}'
    )
