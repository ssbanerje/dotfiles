#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <profile> <user>" >&2
  exit 1
fi

profile="$1"
user="$2"
repo_dir="/home/${user}/.dotfiles"

cd "${repo_dir}"
./install -vv -x -P "${profile}"
git remote set-url origin git@github.com:ssbanerje/dotfiles
git gc --prune=now --quiet
sudo install -m 0755 "${repo_dir}/scripts/docker-entrypoint.sh" /usr/local/bin/docker-entrypoint.sh
sudo usermod -s /usr/bin/zsh "${user}"

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get clean
fi

sudo rm -rf \
  /var/lib/apt/lists/* \
  /etc/apt/apt.conf.d/99norecos \
  /var/cache/pacman/pkg/* \
  /var/lib/pacman/sync/* \
  /tmp/* \
  /var/log/lastlog \
  /var/log/faillog
rm -rf \
  "/home/${user}/.cache/uv" \
  "/home/${user}/.cache/yay" \
  "/home/${user}/.cache/nvim" \
  "/home/${user}/.local/state/nvim"
find "${repo_dir}" -name "*__pycache__" -exec rm -rf {} +
