#!/usr/bin/env bash

set -e

SSH_AGENT=$("$(which ssh-agent)")
eval "${SSH_AGENT}"


docker run -it --rm \
  --privileged \
  -u "$(id -u):$(id -g)" \
  --network host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "/run/user/$(id -u)/:/run/user/$(id -u)/:ro" \
  -v "${SSH_AUTH_SOCK}":/ssh-auth-sock \
  -e SSH_AUTH_SOCK=/ssh-auth-sock \
  -v "${PWD}:/cwd/:rw" \
  -w "/cwd" \
  ghcr.io/ssbanerje/dotfiles:latest "$@"
