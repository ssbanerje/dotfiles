#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  exit 0
fi

write_bool() {
  local domain="$1" key="$2" value="$3" expected current
  if [[ "${value}" == "true" ]]; then
    expected="1"
  else
    expected="0"
  fi
  current="$(defaults read "${domain}" "${key}" 2>/dev/null || true)"
  if [[ "${current}" != "${expected}" ]]; then
    defaults write "${domain}" "${key}" -bool "${value}"
    return 0
  fi
  return 1
}

write_int() {
  local domain="$1" key="$2" value="$3" current
  current="$(defaults read "${domain}" "${key}" 2>/dev/null || true)"
  if [[ "${current}" != "${value}" ]]; then
    defaults write "${domain}" "${key}" -int "${value}"
    return 0
  fi
  return 1
}

finder_changed=0
dock_changed=0

# Keyboard repeat responsiveness & disable press-and-hold accent popup
write_int NSGlobalDomain KeyRepeat 2 || true
write_int NSGlobalDomain InitialKeyRepeat 15 || true
write_bool NSGlobalDomain ApplePressAndHoldEnabled false || true

# Finder visibility
if write_bool com.apple.finder ShowStatusBar true; then
  finder_changed=1
fi
if write_bool com.apple.finder ShowPathbar true; then
  finder_changed=1
fi

# Expand save and print panels by default
write_bool NSGlobalDomain NSNavPanelExpandedStateForSaveMode true || true
write_bool NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 true || true
write_bool NSGlobalDomain PMPrintingExpandedStateForPrint true || true
write_bool NSGlobalDomain PMPrintingExpandedStateForPrint2 true || true

# Stop creating .DS_Store files on network and USB volumes
write_bool com.apple.desktopservices DSDontWriteNetworkStores true || true
write_bool com.apple.desktopservices DSDontWriteUSBStores true || true

# Keep Mission Control spaces in fixed order for Yabai
if write_bool com.apple.dock mru-spaces false; then
  dock_changed=1
fi

if (( finder_changed )); then
  killall Finder >/dev/null 2>&1 || true
fi
if (( dock_changed )); then
  killall Dock >/dev/null 2>&1 || true
fi
