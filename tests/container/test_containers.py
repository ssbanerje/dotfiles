from __future__ import annotations

import subprocess
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Callable

    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.container

MAX_IMAGE_SIZE_BYTES = 900 * 1024 * 1024


@pytest.fixture
def docker_image(profile_spec: ProfileSpec) -> str:
    assert profile_spec.docker_image is not None
    return profile_spec.docker_image


@pytest.fixture
def docker_run(
    docker_image: str,
) -> Callable[..., subprocess.CompletedProcess[str]]:
    def _run(
        *cmd_args: str, docker_args: tuple[str, ...] = ()
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ['docker', 'run', '--rm', *docker_args, docker_image, *cmd_args],
            capture_output=True,
            text=True,
            check=False,
        )

    return _run


def test_default_zero_arg_container_startup(
    docker_run: Callable[..., subprocess.CompletedProcess[str]],
) -> None:
    res = docker_run()
    assert res.returncode == 0, res.stderr


def test_direct_multi_arg_entrypoint_execution(
    docker_run: Callable[..., subprocess.CompletedProcess[str]],
) -> None:
    res = docker_run('nvim', '--version')
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
    ('check_expr', 'label'),
    [
        ('test ! -e "$HOME/.cache/uv"', '$HOME/.cache/uv'),
        ('test ! -e "$HOME/.cache/nvim"', '$HOME/.cache/nvim'),
        ('test ! -e "$HOME/.cache/yay"', '$HOME/.cache/yay'),
        (
            'test ! -d "/var/cache/pacman/pkg" || test -z "$(ls -A "/var/cache/pacman/pkg")"',
            '/var/cache/pacman/pkg',
        ),
        (
            'test ! -d "/var/lib/apt/lists" || test -z "$(ls -A "/var/lib/apt/lists")"',
            '/var/lib/apt/lists',
        ),
    ],
)
def test_build_and_package_caches_purged(
    docker_run: Callable[..., subprocess.CompletedProcess[str]],
    check_expr: str,
    label: str,
) -> None:
    res = docker_run('bash', '-c', check_expr)
    assert res.returncode == 0, f'Expected {label} to be purged in image'


def test_container_image_size_within_budget(docker_image: str) -> None:
    out = subprocess.check_output(
        ['docker', 'image', 'inspect', '--format', '{{.Size}}', docker_image],
        text=True,
    ).strip()
    size_bytes = int(out)
    assert size_bytes <= MAX_IMAGE_SIZE_BYTES, (
        f'Image {docker_image} is {size_bytes / (1024 * 1024):.1f} MiB '
        f'(budget: {MAX_IMAGE_SIZE_BYTES / (1024 * 1024):.1f} MiB)'
    )


@pytest.mark.parametrize(
    ('uid', 'gid'),
    [
        (1000, 1000),
        (907197, 89939),
    ],
)
def test_dynamic_uid_gid_remap(
    docker_run: Callable[..., subprocess.CompletedProcess[str]],
    uid: int,
    gid: int,
) -> None:
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
    res = docker_run(
        'bash',
        '-lc',
        script,
        docker_args=(
            '-u',
            '0:0',
            '-e',
            f'HOST_UID={uid}',
            '-e',
            f'HOST_GID={gid}',
            '-e',
            'TERM=xterm-256color',
        ),
    )
    assert res.returncode == 0, (
        f'UID/GID remap ({uid}:{gid}) failed:\n{res.stdout}\n{res.stderr}'
    )
