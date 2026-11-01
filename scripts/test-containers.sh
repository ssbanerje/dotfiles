#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/test-containers.sh [all|ubuntu|archlinux] [uid] [gid]
  ./scripts/test-containers.sh --smoke-only <image>

Examples:
  ./scripts/test-containers.sh              # Build & smoke-test Ubuntu + Arch locally
  ./scripts/test-containers.sh ubuntu       # Build & smoke-test Ubuntu only
  ./scripts/test-containers.sh archlinux    # Build & smoke-test Arch Linux only
  ./scripts/test-containers.sh all 1000     # Override container dotuser UID (and GID)
  ./scripts/test-containers.sh --smoke-only ghcr.io/ssbanerje/dotfiles:ubuntu
EOF
}

smoke_test_images() {
  local pytest_args=() img
  for img in "$@"; do
    echo "==> Inspecting ${img}"
    docker image ls "$img"
    pytest_args+=(--docker-image "$img")
  done
  echo "==> Running parameterized pytest + testinfra suite (${*})"
  (
    cd "${REPO_ROOT}"
    uv run --frozen --only-group dev pytest tests/environment tests/container "${pytest_args[@]}"
  )
}

build_image() {
  local distro="$1"
  local target_uid="$2"
  local target_gid="$3"
  local tag="ghcr.io/ssbanerje/dotfiles:${distro}"
  local short_tag="dotfiles:${distro}"
  local dockerfile="${REPO_ROOT}/Dockerfile.${distro}"
  local extra_tag_args=(-t "${short_tag}")
  if [[ "${distro}" == "ubuntu" ]]; then
    extra_tag_args+=(
      -t "ghcr.io/ssbanerje/dotfiles:latest"
      -t "dotfiles:latest"
    )
  fi

  echo "==> Building ${tag} (${short_tag}, uid=${target_uid}, gid=${target_gid}) from Dockerfile.${distro}"
  docker build \
    -f "${dockerfile}" \
    --build-arg user=dotuser \
    --build-arg "uid=${target_uid}" \
    --build-arg "gid=${target_gid}" \
    -t "${tag}" \
    "${extra_tag_args[@]}" \
    "${REPO_ROOT}"
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
  smoke_test_images "$2"
  exit 0
fi

DEFAULT_UID=1000
DEFAULT_GID=1000
if [[ "$(uname -s)" == "Linux" ]]; then
  DEFAULT_UID="$(id -u)"
  DEFAULT_GID="$(id -g)"
fi
TARGET="${1:-all}"
TARGET_UID="${2:-${DEFAULT_UID}}"
if [[ $# -ge 2 ]]; then
  TARGET_GID="${3:-${TARGET_UID}}"
else
  TARGET_GID="${DEFAULT_GID}"
fi

if [[ -e "${REPO_ROOT}/.git" ]] && { [[ ! -x "${REPO_ROOT}/installer/dotbot/bin/dotbot" ]] \
   || [[ ! -e "${REPO_ROOT}/installer/plugins/dotbot-ifplatform/lib/distro/.git" ]] \
   || [[ ! -e "${REPO_ROOT}/installer/plugins/dotbot-template/lib/jinja/.git" ]] \
   || [[ ! -e "${REPO_ROOT}/git/gitignore/.git" ]] \
   || [[ ! -e "${REPO_ROOT}/tmux/tpm/.git" ]] \
   || [[ ! -e "${REPO_ROOT}/shell/antidote/.git" ]]; }; then
  git -C "${REPO_ROOT}" submodule update --init --recursive
fi

case "${TARGET}" in
  all)
    build_image ubuntu "${TARGET_UID}" "${TARGET_GID}"
    build_image archlinux "${TARGET_UID}" "${TARGET_GID}"
    smoke_test_images \
      "ghcr.io/ssbanerje/dotfiles:ubuntu" \
      "ghcr.io/ssbanerje/dotfiles:archlinux"
    ;;
  ubuntu)
    build_image ubuntu "${TARGET_UID}" "${TARGET_GID}"
    smoke_test_images "ghcr.io/ssbanerje/dotfiles:ubuntu"
    ;;
  archlinux)
    build_image archlinux "${TARGET_UID}" "${TARGET_GID}"
    smoke_test_images "ghcr.io/ssbanerje/dotfiles:archlinux"
    ;;
  *)
    echo "Unknown target: ${TARGET}" >&2
    usage >&2
    exit 1
    ;;
esac
