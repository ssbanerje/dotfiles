#!/usr/bin/env bash

if command -v fc-cache; then
  mkdir -p "${HOME}/.fonts/";
  curl -fLo "/tmp/Ubuntu.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Ubuntu.zip \
    && unzip -u /tmp/Ubuntu.zip -d "${HOME}/.fonts";
  curl -fLo "/tmp/UbuntuMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip \
    && unzip -u /tmp/UbuntuMono.zip -d "${HOME}/.fonts";
fi

if command -v gconftool-2; then \
  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/use_system_font '0';
  gconftool-2 -t bool -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited '1';
  gconftool-2 -t string -s /apps/gnome-terminal/profiles/Default/font 'Ubuntu Nerd Font 12';
  gconftool-2 -t bool -s /apps/meld/use_custom_font '1';
  gconftool-2 -t string -s /apps/meld/custom_font 'UbuntuMono Nerd Font 12';
  gconftool-2 -t int -s /apps/meld/tab_size '2';
fi

