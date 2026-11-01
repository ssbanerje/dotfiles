from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
INSTALL_BIN = str(REPO_ROOT / 'install')
PROFILES = ('macos', 'ubuntu', 'ubuntu-minimal', 'archlinux-minimal')

pytestmark = pytest.mark.unit


def test_install_help_flag() -> None:
    res = subprocess.run(
        [INSTALL_BIN, '--help'],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0
    assert 'Usage:' in res.stdout
    assert '--profile' in res.stdout


def test_install_list_profiles() -> None:
    res = subprocess.run(
        [INSTALL_BIN, '--list'],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
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
    res = subprocess.run(
        [INSTALL_BIN, *bad_args],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode != 0


@pytest.mark.parametrize('profile', PROFILES)
def test_install_dry_run_all_profiles(profile: str) -> None:
    res = subprocess.run(
        [INSTALL_BIN, '-n', '-P', profile],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0, f'{profile} dry-run failed:\n{res.stdout}\n{res.stderr}'


def test_install_passthrough_flag_order_is_equivalent() -> None:
    left = subprocess.run(
        [INSTALL_BIN, '-n', '--only', 'link', 'template', '-P', 'macos'],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    right = subprocess.run(
        [INSTALL_BIN, '-P', 'macos', '--only', 'link', 'template', '-n'],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    assert sorted(left.stdout.splitlines()) == sorted(right.stdout.splitlines())
