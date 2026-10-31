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
./dotfiles/scripts/shim.sh [command [args...]]
```

### Details
- Launches `zsh` by default when no command is specified.
- By default, `shim.sh` runs the Ubuntu image with `--pull=missing` (instant startup once cached locally).
- For an Arch Linux container use `--archlinux` / `-archlinux` (e.g. `scripts/shim.sh --archlinux`).
- To force pulling the latest image from GHCR pass `--pull` / `-pull`.
- To forbid pulling and use a locally built image (`dotfiles:<distro>` or `ghcr.io/ssbanerje/dotfiles:<distro>`) pass `--local` / `-l`.
- Forwards `ssh-agent` keys (including Docker Desktop / OrbStack on macOS) and mounts the host's current working directory to `/cwd`.


## Local Container Builds & Testing
Build and test the Ubuntu and Arch Linux containers locally (runs the full parameterized `pytest` + `pytest-testinfra` verification suite used in CI):
```bash
./scripts/test-containers.sh            # Build and test both Ubuntu and Arch Linux
./scripts/test-containers.sh ubuntu     # Build and test Ubuntu only
./scripts/test-containers.sh archlinux  # Build and test Arch Linux only
./scripts/shim.sh --local               # Launch zsh in the locally built container
```

You can also run the test tiers directly via `uv`:
```bash
uv run --frozen --only-group dev pytest tests/unit
uv run --frozen --only-group dev pytest tests/environment --profile macos
uv run --frozen --only-group dev pytest tests/environment tests/container \
  --docker-image ghcr.io/ssbanerje/dotfiles:ubuntu
```


## Local Installation
Install the dotfiles and dependencies on the local machine.

Run this:
```bash
git clone --recurse-submodules https://github.com/ssbanerje/dotfiles.git
cd dotfiles
./install                     # Auto-detects host OS profile (macos / ubuntu-minimal / archlinux-minimal)
./install -P <profile>        # Or explicitly select a profile
```

### Details
- Update configuration files for user:
  - `meta/config/git.yaml` (supports inline `params` or machine-local overrides via `params_file`)
- Discover all profiles (`meta/profiles/`) and standalone modules (`meta/config/`):
  ```bash
  ./install --list
  ```
- Available profiles in `meta/profiles/`:
  - `macos`: For macOS
  - `ubuntu`: For Ubuntu desktop
  - `ubuntu-minimal`: For text-based Ubuntu distributions
  - `archlinux-minimal`: For text-based Arch Linux distributions
- Preview changes safely without modifying the system using `--dry-run` (`-n`):
  ```bash
  ./install --dry-run
  ./install --dry-run -P macos
  ```
- Re-sync only symlinks and templates (skipping package managers and shell hooks):
  ```bash
  ./install -P macos --only link template
  ```
- To install individual components (from `meta/config/`), pass module names directly (e.g. `./install git tmux`).
- Once installed, `shim` launches containerized workflows and `dot` manages your local installation:
  ```bash
  dot status    # Check repo & submodule status
  dot sync      # Fast symlink + template refresh
  dot update    # Pull repo/submodules and upgrade shell/uv/Neovim tools
  dot clean     # Purge regenerable caches
  dot doctor    # Check symlinks, submodules, tools, and local hooks
  dot bench     # Benchmark Zsh, Bash, and headless Neovim startup time
  dot edit      # Open the dotfiles repo in $EDITOR
  ```


## Machine-Local Overrides (Untracked)
Keep work/corporate hosts, tokens, proxy settings, and machine-specific tweaks out of Git using optional local override files:
- `~/.gitconfig.local` — included last by `~/.gitconfig` (overrides `[user]`, signing keys, proxies, URL rewrites)
- `~/.ssh/config.local` and `~/.ssh/config.d/*.conf` — included first by `~/.ssh/config` (first-match-wins over `Host *`)
- `~/.config/env.local.sh` — sourced by `~/.config/env.sh` (can call `PREPEND_PATH` / `APPEND_PATH`)
- `~/.zshrc.local` and `~/.bashrc.local` — sourced at the end of `~/.zshrc` and `~/.bashrc`
- `~/.tmux.conf.local` — sourced by `~/.tmux.conf` immediately before TPM initialization


## Setup Development Environment

Install pre-commit hooks and run static + unit checks:
```bash
uv tool install pre-commit
pre-commit install
uv run --frozen --only-group dev pytest tests/unit
```
