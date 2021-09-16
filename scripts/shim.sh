#!/usr/bin/env bash

# Get the correct image
if [[ "$1" == "-archlinux" ]]; then
  IMAGE="ghcr.io/ssbanerje/dotfiles:archlinux"
  shift
else
  IMAGE="ghcr.io/ssbanerje/dotfiles:latest"
fi

# Get the ssh-agent
if [[ ! -n "$SSH_AUTH_SOCK" ]]; then
  STARTED_SSH_AGENT=1
  eval "$(ssh-agent)" > /dev/null
  ssh-add
fi

# Get GPG socket
export GPG_EXTRA_SOCK="$(gpgconf --list-dirs agent-extra-socket)"
gpgconf --launch gpg-agent

# Run docker
docker pull "$IMAGE"
docker run -it --rm \
  --privileged \
  -u "$(id -u):$(id -g)" \
  --network host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$SSH_AUTH_SOCK":/ssh-auth-socket \
  -e SSH_AUTH_SOCK=/ssh-auth-socket \
  -v "$GPG_EXTRA_SOCK":/gpg-agent-extra-socket \
  -e GPG_EXTRA_SOCK="$GPG_EXTRA_SOCK" \
  -v "$PWD:/cwd/:rw" \
  -w "/cwd" \
  "$IMAGE" "$@"

# Cleanup
if [[ -n "$STARTED_SSH_AGENT" ]]; then
  eval $(ssh-agent -k) > /dev/null
fi
