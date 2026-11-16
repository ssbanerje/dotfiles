# Kinesis Advantage2 SmartSet Configuration

`qwerty.txt` defines an OS-agnostic USB HID layout so the **exact same physical keys** drive identical modifiers across macOS and Linux (matching `kitty_mod = cmd`, Hammerspoon/Yabai, and `i3wm`).

## Flashing Instructions (Mac & Linux)

1. Set the keyboard's base thumb mode to **Windows mode** once: **`Program + F7`** *(do not use `Program + F6` PC mode, which turns the outer thumb keys into `Ctrl` instead of `Super`/`Cmd`)*.
2. Mount the onboard SmartSet v-Drive (**`Program + Shift + F1`**).
3. Copy `qwerty.txt` to `v-Drive/active/qwerty.txt` *(keep `qwerty.txt` free of `#` comments, as SmartSet firmware parses only `[token]>[token]` and `{macro}` lines)*.
4. Eject the v-Drive cleanly from the OS, then press **`Program + Shift + F1`** to exit v-Drive mode.

## Physical Modifier Map

| Physical Key | SmartSet Rule | macOS HID Role | Linux HID Role | Usage Across Stack |
|---|---|---|---|---|
| **Left & Right Outer Top Thumbs** | `[lctrl]>[lwin]`, `[rctrl]>[rwin]` | `Command` (`Cmd`) | `Super` (`Mod4`) | App launcher (`Cmd/Super+Space`), Terminal GUI (`kitty_mod = cmd` & iTerm2) |
| **Left Inner Top Thumb** | `[lalt]` *(default)* | `Option` (`Alt`) | `Alt` (`Mod1`) | Modal WM (`Alt+n`, `Alt+Return`, `Alt+s`, `Alt+m`, `Alt+Space`), split resize (`Alt+h/j/k/l`), window jump (`Alt+1..9`) |
| **Left Keywell Bottom `Intl-\`** | `[intl-\]>[lctrl]` | `Left Control` | `Left Control` | Holdable `Ctrl` for seamless split focus (`Ctrl+h/j/k/l`), `tmux` prefix (`Ctrl+b`), Readline/Vim `<C-...>` |
| **Right Inner Top Thumb** | `[rwin]>[rctrl][t&h250][hyper]` | Tap: `Right Ctrl`<br>Hold: `Hyper` | Tap: `Right Ctrl`<br>Hold: `Hyper` | Quick layout, console, and keycaster toggles |
| **Right Keywell Bottom Arrows** | `[up]>[down]`, `[down]>[up]` | `Down` \| `Up` | `Down` \| `Up` | Aligns physical arrow columns with Vim `h l` (left well) and `j k` (right well) |
