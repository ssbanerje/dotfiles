#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/test-containers.sh [all|ubuntu|archlinux] [uid]
  ./scripts/test-containers.sh --smoke-only <image>

Examples:
  ./scripts/test-containers.sh              # Build & smoke-test Ubuntu + Arch locally
  ./scripts/test-containers.sh ubuntu       # Build & smoke-test Ubuntu only
  ./scripts/test-containers.sh archlinux    # Build & smoke-test Arch Linux only
  ./scripts/test-containers.sh all 501      # Override container dotuser UID
  ./scripts/test-containers.sh --smoke-only ghcr.io/ssbanerje/dotfiles:ubuntu
EOF
}

smoke_test_image() {
  local image="$1"
  echo "==> Smoke-testing ${image}"
  echo "--- Checking default zero-arg container startup (CMD [\"zsh\"])"
  docker run --rm "$image"
  echo "--- Checking direct multi-argument command execution and PATH"
  docker run --rm "$image" nvim --version >/dev/null
  docker run --rm -e TERM=xterm-256color "$image" bash -lc '
    set -euo pipefail
    echo "--- Checking passwordless sudo and login shell"
    sudo -n true
    test "${SHELL}" = "/usr/bin/zsh"
    echo "--- Checking Git template and bin/ symlinks"
    test -s "$HOME/.gitconfig"
    command -v shim
    command -v ftpane
    test ! -e "$HOME/.local/bin/lock-screen"
    echo "--- Checking interactive zsh startup, zoxide, and Antidote cache"
    test -s "$HOME/.zsh_plugins.zsh"
    test -d "$HOME/.cache/antidote"
    if ! zsh_err="$(zsh -i -c "type zsh-defer >/dev/null && type zvm_define_widget >/dev/null && type z >/dev/null" 2>&1 >/dev/null)"; then
      echo "${zsh_err}" >&2
      exit 1
    fi
    if printf "%s\n" "${zsh_err}" | grep -qiE "no such file or directory|command not found|parse error"; then
      echo "${zsh_err}" >&2
      exit 1
    fi
    echo "--- Checking Starship prompt and tealdeer"
    starship --version
    tldr --version
    echo "--- Checking tmux and preinstalled TPM plugins"
    tmux -V
    test -d "$HOME/.tmux/plugins/tmux-power"
    echo "--- Checking Neovim binary and headless startup"
    command -v nvim
    nvim --version
    nvim --headless +qa
    echo "--- Checking tree-sitter CLI"
    command -v tree-sitter
    tree-sitter --version
    echo "--- Checking yazi"
    command -v yazi
    yazi --version
    echo "--- Checking IPython"
    if command -v ipython3 >/dev/null 2>&1; then
      ipython3 --version
    else
      ipython --version
    fi
  '
  echo "==> Smoke test passed: ${image}"
}

build_and_test() {
  local distro="$1"
  local target_uid="$2"
  local tag="ghcr.io/ssbanerje/dotfiles:${distro}"
  local dockerfile="${REPO_ROOT}/Dockerfile.${distro}"
  local extra_tag_args=()
  if [[ "${distro}" == "ubuntu" ]]; then
    extra_tag_args=(-t "ghcr.io/ssbanerje/dotfiles:latest")
  fi

  echo "==> Building ${tag} (uid=${target_uid}) from Dockerfile.${distro}"
  docker build \
    -f "${dockerfile}" \
    --build-arg user=dotuser \
    --build-arg "uid=${target_uid}" \
    -t "${tag}" \
    ${extra_tag_args[@]+"${extra_tag_args[@]}"} \
    "${REPO_ROOT}"

  smoke_test_image "${tag}"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "--smoke-only" ]]; then
  if [[ $# -ne 2 ]]; then
    usage >&2
    exit 1
  fi
  smoke_test_image "$2"
  exit 0
fi

DEFAULT_UID=1000
if [[ "$(uname -s)" == "Linux" ]]; then
  DEFAULT_UID="$(id -u)"
fi
TARGET="${1:-all}"
TARGET_UID="${2:-${DEFAULT_UID}}"

if [[ ! -x "${REPO_ROOT}/installer/dotbot/bin/dotbot" || ! -e "${REPO_ROOT}/installer/plugins/dotbot-ifplatform/lib/distro/.git" || ! -e "${REPO_ROOT}/installer/plugins/dotbot-template/lib/jinja/.git" ]]; then
  git -C "${REPO_ROOT}" submodule update --init --recursive
fi

case "${TARGET}" in
  all)
    build_and_test ubuntu "${TARGET_UID}"
    build_and_test archlinux "${TARGET_UID}"
    ;;
  ubuntu)
    build_and_test ubuntu "${TARGET_UID}"
    ;;
  archlinux)
    build_and_test archlinux "${TARGET_UID}"
    ;;
  *)
    echo "Unknown target: ${TARGET}" >&2
    usage >&2
    exit 1
    ;;
esac
