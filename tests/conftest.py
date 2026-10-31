from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
import testinfra

if TYPE_CHECKING:
    from collections.abc import Iterator

    from testinfra.host import Host

REPO_ROOT = Path(__file__).resolve().parent.parent


@dataclass(frozen=True)
class ProfileSpec:
    name: str
    expected_os: str
    fd_binary: str
    has_vale: bool
    has_kitty: bool
    has_macos_ui: bool
    is_container: bool = False
    docker_image: str | None = None


PROFILE_SPECS: dict[str, ProfileSpec] = {
    'macos': ProfileSpec(
        name='macos',
        expected_os='Darwin',
        fd_binary='fd',
        has_vale=True,
        has_kitty=True,
        has_macos_ui=True,
    ),
    'ubuntu': ProfileSpec(
        name='ubuntu',
        expected_os='Linux',
        fd_binary='fdfind',
        has_vale=True,
        has_kitty=True,
        has_macos_ui=False,
    ),
    'ubuntu-minimal': ProfileSpec(
        name='ubuntu-minimal',
        expected_os='Linux',
        fd_binary='fdfind',
        has_vale=False,
        has_kitty=False,
        has_macos_ui=False,
    ),
    'archlinux-minimal': ProfileSpec(
        name='archlinux-minimal',
        expected_os='Linux',
        fd_binary='fd',
        has_vale=False,
        has_kitty=False,
        has_macos_ui=False,
    ),
}


def pytest_addoption(parser: pytest.Parser) -> None:
    group = parser.getgroup('dotfiles')
    group.addoption(
        '--profile',
        action='store',
        default=None,
        choices=tuple(PROFILE_SPECS.keys()),
        help='Target dotfiles profile for local environment verification.',
    )
    group.addoption(
        '--docker-image',
        action='append',
        default=[],
        help='Docker image tag to test via testinfra docker:// backend (repeatable).',
    )


def _infer_container_profile(image: str, explicit_profile: str | None) -> ProfileSpec:
    if explicit_profile is not None:
        base = PROFILE_SPECS[explicit_profile]
    elif 'archlinux' in image:
        base = PROFILE_SPECS['archlinux-minimal']
    else:
        base = PROFILE_SPECS['ubuntu-minimal']
    return ProfileSpec(
        name=base.name,
        expected_os=base.expected_os,
        fd_binary=base.fd_binary,
        has_vale=base.has_vale,
        has_kitty=base.has_kitty,
        has_macos_ui=base.has_macos_ui,
        is_container=True,
        docker_image=image,
    )


def pytest_generate_tests(metafunc: pytest.Metafunc) -> None:
    if 'target_id' not in metafunc.fixturenames:
        return
    images: list[str] = metafunc.config.getoption('--docker-image') or []
    profile: str | None = metafunc.config.getoption('--profile')
    if images:
        targets = [f'docker:{img}' for img in images]
    elif profile:
        targets = ['local']
    else:
        targets = ['unconfigured']
    metafunc.parametrize('target_id', targets, scope='session')


def pytest_collection_modifyitems(
    config: pytest.Config, items: list[pytest.Item]
) -> None:
    images: list[str] = config.getoption('--docker-image') or []
    profile: str | None = config.getoption('--profile')

    skip_unconfigured = pytest.mark.skip(
        reason='Pass --profile or --docker-image to run live environment/container tests'
    )
    skip_non_container = pytest.mark.skip(
        reason='Container tests require --docker-image'
    )

    for item in items:
        is_env = 'environment' in item.keywords
        is_container = 'container' in item.keywords
        if not images and not profile and (is_env or is_container):
            item.add_marker(skip_unconfigured)
        elif not images and is_container:
            item.add_marker(skip_non_container)


@pytest.fixture(scope='session')
def repo_root() -> Path:
    return REPO_ROOT


@pytest.fixture(scope='session')
def target_session(
    target_id: str, pytestconfig: pytest.Config
) -> Iterator[tuple[Host, ProfileSpec]]:
    explicit_profile: str | None = pytestconfig.getoption('--profile')
    if target_id == 'unconfigured':
        pytest.skip('Live target not configured')

    if target_id == 'local':
        assert explicit_profile is not None
        yield testinfra.get_host('local://'), PROFILE_SPECS[explicit_profile]
        return

    assert target_id.startswith('docker:')
    image = target_id.removeprefix('docker:')
    spec = _infer_container_profile(image, explicit_profile)
    proc = subprocess.run(
        [
            'docker',
            'run',
            '-d',
            '--rm',
            '-e',
            'TERM=xterm-256color',
            image,
            'sleep',
            'infinity',
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    container_id = proc.stdout.strip()
    try:
        yield testinfra.get_host(f'docker://{container_id}'), spec
    finally:
        subprocess.run(
            ['docker', 'rm', '-f', container_id],
            capture_output=True,
            text=True,
            check=False,
        )


@pytest.fixture(scope='session')
def host(target_session: tuple[Host, ProfileSpec]) -> Host:
    return target_session[0]


@pytest.fixture(scope='session')
def profile_spec(target_session: tuple[Host, ProfileSpec]) -> ProfileSpec:
    return target_session[1]


@pytest.fixture(scope='session')
def target_home(host: Host) -> str:
    return host.check_output('printf %s "$HOME"').strip()


def run_env(host: Host, *argv: str):
    placeholders = ' '.join(['%s'] * len(argv))
    return host.run(
        f'bash -c %s -- {placeholders}',
        'source "$HOME/.config/env.sh" && exec "$@"',
        *argv,
    )


def run_zsh_i(host: Host, snippet: str):
    return host.run('TERM=xterm-256color zsh -i -c %s', snippet)


def run_bash_i(host: Host, snippet: str):
    return host.run('TERM=xterm-256color bash -i -c %s', snippet)


def write_remote_file(
    host: Host, path: str, content: str, mode: str | None = None
) -> None:
    host.run_expect([0], 'printf %%s %s > %s', content, path)
    if mode is not None:
        host.run_expect([0], 'chmod %s %s', mode, path)
