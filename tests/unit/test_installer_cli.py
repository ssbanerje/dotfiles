from __future__ import annotations

import subprocess

import pytest

from tests.conftest import PROFILE_SPECS, REPO_ROOT

INSTALL_BIN = str(REPO_ROOT / 'install')
PROFILES = tuple(PROFILE_SPECS.keys())

pytestmark = pytest.mark.unit


def run_install(*args: str, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [INSTALL_BIN, *args],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=check,
    )


def test_install_help_flag() -> None:
    res = run_install('--help')
    assert res.returncode == 0
    assert 'Usage:' in res.stdout
    assert '--profile' in res.stdout


def test_install_list_profiles() -> None:
    res = run_install('--list')
    assert res.returncode == 0
    listed = {line.strip() for line in res.stdout.splitlines()}
    assert set(PROFILES).issubset(listed)


@pytest.mark.parametrize(
    'bad_args',
    [
        ['-P'],
        ['--profile'],
        ['-P', 'nonexistent-profile'],
    ],
)
def test_install_rejects_invalid_profile_args(bad_args: list[str]) -> None:
    res = run_install(*bad_args)
    assert res.returncode != 0


@pytest.mark.parametrize('profile', PROFILES)
def test_install_dry_run_all_profiles(profile: str) -> None:
    res = run_install('-n', '-P', profile)
    assert res.returncode == 0, f'{profile} dry-run failed:\n{res.stdout}\n{res.stderr}'


def test_install_passthrough_flag_order_is_equivalent() -> None:
    left = run_install('-n', '--only', 'link', 'template', '-P', 'macos', check=True)
    right = run_install('-P', 'macos', '--only', 'link', 'template', '-n', check=True)
    assert sorted(left.stdout.splitlines()) == sorted(right.stdout.splitlines())
