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

write_string() {
  local domain="$1" key="$2" value="$3" current
  current="$(defaults read "${domain}" "${key}" 2>/dev/null || true)"
  if [[ "${current}" != "${value}" ]]; then
    defaults write "${domain}" "${key}" -string "${value}"
    return 0
  fi
  return 1
}

finder_changed=0
dock_changed=0
uiserver_changed=0

# Keyboard repeat responsiveness, full keyboard access, & code-safe typing defaults
write_int NSGlobalDomain KeyRepeat 2 || true
write_int NSGlobalDomain InitialKeyRepeat 15 || true
write_int NSGlobalDomain AppleKeyboardUIMode 3 || true
write_bool NSGlobalDomain ApplePressAndHoldEnabled false || true
write_bool NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled false || true
write_bool NSGlobalDomain NSAutomaticDashSubstitutionEnabled false || true
write_bool NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled false || true
write_bool NSGlobalDomain NSAutomaticCapitalizationEnabled false || true
write_bool NSGlobalDomain NSAutomaticSpellingCorrectionEnabled false || true

# Finder visibility, extensions, and current-folder search
if write_bool NSGlobalDomain AppleShowAllExtensions true; then
  finder_changed=1
fi
if write_bool com.apple.finder ShowStatusBar true; then
  finder_changed=1
fi
if write_bool com.apple.finder ShowPathbar true; then
  finder_changed=1
fi
if write_string com.apple.finder FXDefaultSearchScope "SCcf"; then
  finder_changed=1
fi
if write_bool com.apple.finder FXEnableExtensionChangeWarning false; then
  finder_changed=1
fi
if write_bool com.apple.finder _FXSortFoldersFirst true; then
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

# Lossless PNG screenshots without window drop-shadows
if write_string com.apple.screencapture type "png"; then
  uiserver_changed=1
fi
if write_bool com.apple.screencapture disable-shadow true; then
  uiserver_changed=1
fi

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
if (( uiserver_changed )); then
  killall SystemUIServer >/dev/null 2>&1 || true
fi
