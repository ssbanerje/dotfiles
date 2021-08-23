                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  )
                                      \__,_/\____/\__/_/   /_/_/\___/____/
                                            JUST THE WAY I LIKE IT

[![Build](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml)

## Docker
Use the packaged docker image to not install any dependecies on the host.

```bash
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
<path to dotfiles>/scripts/shim.sh bash # or zsh
```

The shim will pass the `ssh-agent` into the container and map the current working directory as `/cwd`
in the container.

## Local Installation

1. Get dotfiles
```bash
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
cd dotfiles
git submodule init --update --recursive
```
2. Update the configuration files in the `meta/config/` folder
  - `meta/config/git.yaml`
3. Install dependencies
  - Python3
  - Packages `pyyaml`, `jinja2`, `distro`
4. Install dotfiles based on profiles in `meta/profiles/` folder
```bash
./install_profile ubuntu # On ubuntu machines
./install_profile macos # On macos machines
```

## Setup Dev Environment

Setup the git hooks.
```bash
pip install pre-commit
pre-commit install
```
