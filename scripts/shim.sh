#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: shim [-a|--archlinux] [-u|--ubuntu] [-l|--local] [-p|--pull] [--] [command [args...]]

Options:
  -a, -archlinux, --archlinux  Use the Arch Linux container image
  -u, -ubuntu, --ubuntu        Use the Ubuntu container image (default)
  -l, -local, --local          Never pull from GHCR (require local image)
  -p, -pull, --pull            Always pull the latest image from GHCR
  -h, --help                   Show this help message and exit
EOF
}

UNAME="$(uname -s)"

DISTRO="ubuntu"
PULL_POLICY="${SHIM_PULL_POLICY:-missing}"
if [[ -n "${SHIM_NO_PULL:-}" ]]; then
  PULL_POLICY="never"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|-archlinux|--archlinux)
      DISTRO="archlinux"
      shift
      ;;
    -u|-ubuntu|--ubuntu)
      DISTRO="ubuntu"
      shift
      ;;
    -l|-local|--local)
      PULL_POLICY="never"
      shift
      ;;
    -p|-pull|--pull)
      PULL_POLICY="always"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Error: unknown option '$1'" >&2
      usage >&2
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

IMAGE="ghcr.io/ssbanerje/dotfiles:${DISTRO}"
if [[ "${PULL_POLICY}" == "never" ]]; then
  best_img=""
  best_ts=""
  for candidate in "dotfiles:${DISTRO}" "${IMAGE}"; do
    if ts="$(docker image inspect --format '{{.Created}}' "${candidate}" 2>/dev/null)"; then
      if [[ -z "${best_img}" || "${ts}" > "${best_ts}" ]]; then
        best_img="${candidate}"
        best_ts="${ts}"
      fi
    fi
  done
  if [[ -z "${best_img}" ]]; then
    echo "Error: local image not found (checked 'dotfiles:${DISTRO}' and '${IMAGE}')." >&2
    echo "Build it first with: ./scripts/test-containers.sh ${DISTRO}" >&2
    exit 1
  fi
  IMAGE="${best_img}"
fi

STARTED_SSH_AGENT=""
cleanup() {
  if [[ -n "${STARTED_SSH_AGENT}" ]]; then
    eval "$(ssh-agent -k)" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

declare -a DOCKER_ARGS=(
  --rm
  -i
  "--pull=${PULL_POLICY}"
  --network host
  -e "TERM=${TERM:-xterm-256color}"
  -e "COLORTERM=${COLORTERM:-truecolor}"
  -v "${PWD}:/cwd:rw"
  -w /cwd
)

if [[ -t 0 && -t 1 ]]; then
  DOCKER_ARGS+=(-t)
fi

if [[ "${UNAME}" == "Linux" ]]; then
  HOST_UID="$(id -u)"
  HOST_GID="$(id -g)"
  if [[ "${HOST_UID}" != "0" ]]; then
    DOCKER_ARGS+=(
      -u 0:0
      -e "HOST_UID=${HOST_UID}"
      -e "HOST_GID=${HOST_GID}"
    )
  fi
fi

if [[ -S /var/run/docker.sock ]]; then
  DOCKER_ARGS+=(-v /var/run/docker.sock:/var/run/docker.sock)
fi

# Forward SSH agent
if [[ "${UNAME}" == "Darwin" ]]; then
  DOCKER_ARGS+=(
    -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock
    -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
  )
else
  if [[ -z "${SSH_AUTH_SOCK:-}" ]] && command -v ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
    STARTED_SSH_AGENT=1
    if [[ -t 0 ]]; then
      ssh-add || true
    else
      ssh-add </dev/null >/dev/null 2>&1 || true
    fi
  fi
  if [[ -n "${SSH_AUTH_SOCK:-}" && -S "${SSH_AUTH_SOCK}" ]]; then
    DOCKER_ARGS+=(
      -v "${SSH_AUTH_SOCK}:/run/ssh-auth.sock"
      -e SSH_AUTH_SOCK=/run/ssh-auth.sock
    )
  fi
fi

# Forward restricted GPG agent socket on Linux when available
if [[ "${UNAME}" == "Linux" ]] && command -v gpgconf >/dev/null 2>&1; then
  GPG_EXTRA_SOCK="$(gpgconf --list-dirs agent-extra-socket 2>/dev/null || true)"
  if [[ -n "${GPG_EXTRA_SOCK}" ]]; then
    gpgconf --launch gpg-agent >/dev/null 2>&1 || true
    if [[ -S "${GPG_EXTRA_SOCK}" ]]; then
      DOCKER_ARGS+=(-v "${GPG_EXTRA_SOCK}:/run/gpg-agent.extra.sock")
    fi
  fi
fi

docker run "${DOCKER_ARGS[@]}" "${IMAGE}" "$@"
