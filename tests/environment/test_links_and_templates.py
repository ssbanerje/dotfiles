from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from testinfra.host import Host

    from scripts.lib.manifest import ProfileManifest

pytestmark = pytest.mark.environment


def test_profile_symlinks_exist_and_resolve(
    host: Host, target_home: str, profile_manifest: ProfileManifest
) -> None:
    for rel_path, rel_target in profile_manifest.symlinks.items():
        path = f'{target_home}/{rel_path}'
        f = host.file(path)
        assert f.is_symlink, f'Expected symlink at {path}'
        assert host.file(f.linked_to).exists, (
            f'Broken symlink target for {path}: {f.linked_to}'
        )
        assert f.linked_to.endswith(f'/{rel_target}'), (
            f'Unexpected symlink target for {path}: {f.linked_to} '
            f'(expected suffix /{rel_target})'
        )

    for rel_path in profile_manifest.excluded_symlinks:
        path = f'{target_home}/{rel_path}'
        assert not host.file(path).exists, f'Unexpected platform-excluded path {path}'


def test_created_directories_and_permissions(
    host: Host, target_home: str, profile_manifest: ProfileManifest
) -> None:
    for rel_dir, expected_mode in profile_manifest.directories.items():
        d = host.file(f'{target_home}/{rel_dir}')
        assert d.is_directory, f'Expected directory at {target_home}/{rel_dir}'
        if expected_mode is not None:
            assert d.mode == expected_mode, (
                f'Directory {target_home}/{rel_dir} has mode {oct(d.mode)}, '
                f'expected {oct(expected_mode)}'
            )


def test_generated_files_present_and_rendered(
    host: Host, target_home: str, profile_manifest: ProfileManifest
) -> None:
    for rel_path in profile_manifest.templates:
        rendered = host.file(f'{target_home}/{rel_path}')
        assert rendered.is_file, f'Missing rendered template {target_home}/{rel_path}'
        content = rendered.content_string
        assert len(content) > 0
        assert '{{' not in content and '}}' not in content

    for rel_path in profile_manifest.generated_files:
        generated = host.file(f'{target_home}/{rel_path}')
        assert generated.is_file, f'Missing generated file {target_home}/{rel_path}'
        assert generated.size > 0
