#!/usr/bin/env bash

set -e

# Get the ssh-agent
eval "$(ssh-agent)" > /dev/null
ssh-add

# Run docker
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
  ghcr.io/ssbanerje/dotfiles:archlinux "$@"

# Cleanup
kill $SSH_AGENT_PID
