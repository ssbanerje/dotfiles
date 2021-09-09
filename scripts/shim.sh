#!/usr/bin/env bash

set -e

# Get the correct image
if [[ -n "$ARCHLINUX" ]]; then
  IMAGE="ghcr.io/ssbanerje/dotfiles:archlinux"
else
  IMAGE="ghcr.io/ssbanerje/dotfiles:latest"
fi

# Get the ssh-agent
if [[ ! -n "${SSH_AUTH_SOCK}" ]]; then
  STARTED_SSH_AGENT=1
  eval "$(ssh-agent)" > /dev/null
  ssh-add
fi

# Run docker
docker pull "$IMAGE"

docker run -it --rm \
  --privileged \
  -u "$(id -u):$(id -g)" \
  --network host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "/run/user/$(id -u)/:/run/user/$(id -u)/:ro" \
  -v "${SSH_AUTH_SOCK}":/ssh-auth-socket \
  -e SSH_AUTH_SOCK=/ssh-auth-socket \
  -v "${PWD}:/cwd/:rw" \
  -w "/cwd" \
  "$IMAGE" "$@"

# Cleanup
if [[ -n "${STARTED_SSH_AGENT}" ]]; then
  eval $(ssh-agent -k) > /dev/null
fi
