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
- For an Archlinux container use `scritps/shim.sh -archlinux <command>`
- Shim passes `ssh-agent` keys to container.
- Shim mounts host's current working directory to `/cwd`.


## Local Installation
Install the dotfiles and dependencies on the local machine.

Run this:
```bash
git clone --recurse-submodules https://github.com/ssbanerje/dotfiles.git
cd dotfiles
./install_profile <profile>
```

### Details
- Update configuration files for user.
  - `meta/config/git.yaml`
- The installer script can load multiple profiles (located in `meta/profiles/`):
  - `macos`: For MacOS
  - `ubuntu`: For Ubuntu desktop
  - `ubuntu-minimal`: For text-based Ubuntu distributions
  - `archlinux`: For Archlinux desktop
  - `archlinux-minimal`: For text-based Archlinux distributions
- Individual components (from `meta/config/`) can be installed using the `install.sh` script.
- The `scripts/shim.sh` script can be accessed as the `shim` command.


## Setup Development Environment

Install pre-commit hooks:
```bash
pip install pre-commit
pre-commit install
```
