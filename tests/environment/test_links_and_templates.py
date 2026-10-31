from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from testinfra.host import Host

    from tests.conftest import ProfileSpec

pytestmark = pytest.mark.environment

CORE_SYMLINKS = (
    '.zshrc',
    '.bashrc',
    '.inputrc',
    '.hushlogin',
    '.curlrc',
    '.gdbinit',
    '.wgetrc',
    '.editorconfig',
    '.gitattributes',
    '.tmux.conf',
    '.tmux/plugins/tpm',
    '.ssh/config',
    '.config/antidote',
    '.config/env.sh',
    '.config/aliases.sh',
    '.config/starship.toml',
    '.config/zsh_plugins.txt',
    '.config/zsh_plugins_macos.txt',
    '.config/zsh_plugins_ubuntu.txt',
    '.config/zsh_plugins_arch.txt',
    '.config/nvim',
    '.config/yazi/yazi.toml',
    '.config/yazi/keymap.toml',
    '.local/bin/shim',
    '.local/bin/dot',
    '.local/bin/ports',
    '.local/bin/ftpane',
    '.local/bin/ftwind',
    '.local/bin/ftsession',
    '.local/bin/docker_cleanup',
)


@pytest.mark.parametrize('rel_path', CORE_SYMLINKS)
def test_core_symlinks_exist_and_resolve(
    host: Host, target_home: str, rel_path: str
) -> None:
    path = f'{target_home}/{rel_path}'
    f = host.file(path)
    assert f.is_symlink, f'Expected symlink at {path}'
    assert host.file(f.linked_to).exists, (
        f'Broken symlink target for {path}: {f.linked_to}'
    )


@pytest.mark.parametrize('rel_dir', ('.ssh', '.ssh/sockets', '.ssh/config.d'))
def test_ssh_directories_have_strict_permissions(
    host: Host, target_home: str, rel_dir: str
) -> None:
    d = host.file(f'{target_home}/{rel_dir}')
    assert d.is_directory
    assert d.mode == 0o700


def test_gitconfig_template_rendered_cleanly(host: Host, target_home: str) -> None:
    gitconfig = host.file(f'{target_home}/.gitconfig')
    assert gitconfig.is_file
    content = gitconfig.content_string
    assert len(content) > 0
    assert '{{' not in content and '}}' not in content


def test_global_gitignore_assembled(host: Host, target_home: str) -> None:
    gitignore = host.file(f'{target_home}/.global_gitignore')
    assert gitignore.is_file
    assert gitignore.size > 0


def test_conditional_profile_files(
    host: Host, target_home: str, profile_spec: ProfileSpec
) -> None:
    lock_screen = host.file(f'{target_home}/.local/bin/lock-screen')
    if profile_spec.expected_os == 'Darwin':
        assert lock_screen.is_symlink
    else:
        assert not lock_screen.exists

    if profile_spec.has_kitty:
        kitty_conf = host.file(f'{target_home}/.config/kitty/kitty.conf')
        keymaps = host.file(f'{target_home}/.config/kitty/keymaps.conf')
        assert kitty_conf.is_symlink
        assert keymaps.is_file
        keymap_text = keymaps.content_string
        assert '{{' not in keymap_text and '}}' not in keymap_text
        assert 'new_tab_with_cwd' in keymap_text

    if profile_spec.has_vale:
        assert host.file(f'{target_home}/.vale.ini').is_symlink

    if profile_spec.has_macos_ui:
        assert host.file(f'{target_home}/.yabairc').is_symlink
        assert host.file(f'{target_home}/.hammerspoon').is_symlink
