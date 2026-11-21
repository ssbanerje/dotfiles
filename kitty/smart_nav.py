from __future__ import annotations

import os
from typing import Any

from kittens.tui.handler import result_handler
from kitty.fast_data_types import GLFW_MOD_ALT, GLFW_MOD_CONTROL, KeyEvent

PASSTHROUGH_PROCS = frozenset(
    {
        'fzf',
        'mosh',
        'mosh-client',
        'nvim',
        'ssh',
        'tmux',
        'vi',
        'vim',
    }
)

DIRECTION_TO_KEY = {
    'left': 'h',
    'down': 'j',
    'up': 'k',
    'right': 'l',
}


def main(args: list[str]) -> None:
    pass


def _should_passthrough(window: Any) -> bool:
    user_vars = getattr(window, 'user_vars', {}) or {}
    is_nvim = str(user_vars.get('IS_NVIM', '')).lower()
    if is_nvim not in ('', '0', 'false'):
        return True
    child = getattr(window, 'child', None)
    fg_procs = getattr(child, 'foreground_processes', ()) or ()
    for proc in fg_procs:
        cmdline = proc.get('cmdline') or ()
        if not cmdline:
            continue
        prog = os.path.basename(cmdline[0]).lstrip('-')
        if prog in PASSTHROUGH_PROCS or prog.startswith('nvim'):
            return True
    return False


def _forward_key(window: Any, key_char: str, mods: int) -> None:
    encoded = window.encoded_key(KeyEvent(key=ord(key_char), mods=mods))
    if encoded:
        window.write_to_child(encoded)


def _resize_quality(direction: str, neighbors: dict[str, Any]) -> str | None:
    if direction == 'left':
        if neighbors.get('right'):
            return 'narrower'
        return 'wider' if neighbors.get('left') else None
    if direction == 'right':
        if neighbors.get('right'):
            return 'wider'
        return 'narrower' if neighbors.get('left') else None
    if direction == 'up':
        if neighbors.get('bottom'):
            return 'shorter'
        return 'taller' if neighbors.get('top') else None
    if direction == 'down':
        if neighbors.get('bottom'):
            return 'taller'
        return 'shorter' if neighbors.get('top') else None
    return None


@result_handler(no_ui=True)
def handle_result(
    args: list[str],
    answer: Any,
    target_window_id: int,
    boss: Any,
) -> None:
    if len(args) < 3:
        return
    action = args[1]
    direction = args[2]
    key_char = DIRECTION_TO_KEY.get(direction)
    if key_char is None:
        return

    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    mods = GLFW_MOD_CONTROL if action == 'move' else GLFW_MOD_ALT
    tab = boss.active_tab
    is_zoomed = getattr(getattr(tab, 'current_layout', None), 'name', '') == 'stack'
    if _should_passthrough(window) or tab is None or len(tab.windows) <= 1 or is_zoomed:
        _forward_key(window, key_char, mods)
        return

    if action == 'move':
        tab.neighboring_window(direction)
    elif action == 'resize':
        step = int(args[3]) if len(args) > 3 else 3
        neighbors = tab.current_layout.neighbors_for_window(window, tab.windows)
        quality = _resize_quality(direction, neighbors)
        if quality is not None:
            tab.resize_window(quality, step)
