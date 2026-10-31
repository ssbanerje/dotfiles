               __      __  _______ __
          ____/ /___  / /_/ ____(_) /__  _____
         / __  / __ \/ __/ /_  / / / _ \/ ___/
        / /_/ / /_/ / /_/ __/ / / /  __(__  )
        \__,_/\____/\__/_/   /_/_/\___/____/

[![Build](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml)

## Container-based Installation
Use the packaged container to install dotfiles and all dependencies.

Run this:
```bash
git clone https://github.com/ssbanerje/dotfiles.git
./dotfiles/scripts/shim.sh <command>
```

### Details
- Script uses docker to run the container.
- By default, the shim will use an Ubuntu container.
- For an Archlinux container use `scripts/shim.sh -archlinux <command>`
- To use a locally built image without pulling from GHCR, pass `-local` (e.g. `scripts/shim.sh -local <command>`)
- Shim passes `ssh-agent` keys to container.
- Shim mounts host's current working directory to `/cwd`.


## Local Container Builds & Testing
Build and smoke-test the Ubuntu and Arch Linux containers locally (runs the same smoke checks as CI):
```bash
./scripts/test-containers.sh            # Build and test both Ubuntu and Arch Linux
./scripts/test-containers.sh ubuntu     # Build and test Ubuntu only
./scripts/test-containers.sh archlinux  # Build and test Arch Linux only
./scripts/shim.sh -local zsh            # Launch the locally built container
```


## Local Installation
Install the dotfiles and dependencies on the local machine.

Run this:
```bash
git clone --recurse-submodules https://github.com/ssbanerje/dotfiles.git
cd dotfiles
./install_profile <profile>
```

### Details
- Update configuration files for user:
  - `meta/config/git.yaml` (supports inline `params` or machine-local overrides via `params_file`)
- The installer script can load profiles located in `meta/profiles/`:
  - `macos`: For macOS
  - `ubuntu`: For Ubuntu desktop
  - `ubuntu-minimal`: For text-based Ubuntu distributions
  - `archlinux-minimal`: For text-based Arch Linux distributions
- Preview changes safely without modifying the system using `--dry-run` (`-n`):
  ```bash
  ./install_profile --dry-run macos
  ```
- Re-sync only symlinks and templates (skipping package managers and shell hooks):
  ```bash
  ./install_profile macos --only link template
  ```
- To install individual components (from `meta/config/`) use `./install` (e.g. `./install git tmux`).
- Once installed, the `scripts/shim.sh` script is accessible as the `shim` command.


## Setup Development Environment

Install pre-commit hooks:
```bash
uv tool install pre-commit  # or: pipx install pre-commit
pre-commit install
```
