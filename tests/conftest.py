from __future__ import annotations

import subprocess
from dataclasses import dataclass, replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
import testinfra

from scripts.lib.manifest import ProfileManifest, load_profile_modules, resolve_manifest

if TYPE_CHECKING:
    from collections.abc import Callable, Iterator

    from testinfra.host import Host

REPO_ROOT = Path(__file__).resolve().parent.parent


@dataclass(frozen=True)
class ProfileSpec:
    name: str
    expected_os: str
    fd_binary: str
    modules: frozenset[str]
    is_container: bool = False
    docker_image: str | None = None


def _profile_spec(name: str, expected_os: str, fd_binary: str) -> ProfileSpec:
    return ProfileSpec(
        name=name,
        expected_os=expected_os,
        fd_binary=fd_binary,
        modules=frozenset(load_profile_modules(REPO_ROOT, name)),
    )


PROFILE_SPECS: dict[str, ProfileSpec] = {
    'macos': _profile_spec('macos', expected_os='Darwin', fd_binary='fd'),
    'ubuntu': _profile_spec('ubuntu', expected_os='Linux', fd_binary='fdfind'),
    'ubuntu-minimal': _profile_spec(
        'ubuntu-minimal', expected_os='Linux', fd_binary='fdfind'
    ),
    'archlinux-minimal': _profile_spec(
        'archlinux-minimal', expected_os='Linux', fd_binary='fd'
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
    return replace(base, is_container=True, docker_image=image)


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
def profile_manifest(profile_spec: ProfileSpec) -> ProfileManifest:
    return resolve_manifest(repo_root=REPO_ROOT, profile=profile_spec.name)


@pytest.fixture(scope='session')
def target_home(host: Host) -> str:
    return host.check_output('printf %s "$HOME"').strip()


@pytest.fixture(params=('zsh', 'bash'))
def interactive_shell(request: pytest.FixtureRequest) -> str:
    return str(request.param)


def run_env(host: Host, *argv: str):
    placeholders = ' '.join(['%s'] * len(argv))
    return host.run(
        f'bash -c %s -- {placeholders}',
        'source "$HOME/.config/env.sh" && exec "$@"',
        *argv,
    )


def run_shell_i(host: Host, shell: str, snippet: str):
    return host.run(f'TERM=xterm-256color {shell} -i -c %s', snippet)


def write_remote_file(
    host: Host, path: str, content: str, mode: str | None = None
) -> None:
    host.run_expect([0], 'printf %%s %s > %s', content, path)
    if mode is not None:
        host.run_expect([0], 'chmod %s %s', mode, path)


@pytest.fixture
def remote_files(host: Host) -> Iterator[Callable[[str, str, str | None], None]]:
    created: list[str] = []

    def _create(path: str, content: str, mode: str | None = None) -> None:
        created.append(path)
        write_remote_file(host, path, content, mode=mode)

    try:
        yield _create
    finally:
        if created:
            placeholders = ' '.join(['%s'] * len(created))
            host.run(f'rm -f {placeholders}', *created)
