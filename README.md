                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  )
                                      \__,_/\____/\__/_/   /_/_/\___/____/
                                            JUST THE WAY I LIKE IT

[![Build](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/ssbanerje/dotfiles/actions/workflows/build.yml)

## Installation

1. Get dotfiles
```bash
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
cd dotfiles
```
2. Update config/*.json to reflect local configuration
3. Build the configuration files
```bash
make init
make backup
make install -j
```

## Listing changes
- Find files which will be written by executing `make listfiles`
- Backup all files which will be overwrtiten by executing `make backup`. This will create a backup in `$HOME/old_dotfiles`
