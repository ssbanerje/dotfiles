                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  )
                                      \__,_/\____/\__/_/   /_/_/\___/____/
                                            JUST THE WAY I LIKE IT


## Dependencies

### Mac OS
* [XCode Tools](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12#)
* Install [homebrew](https://github.com/mxcl/homebrew) and some packages used in the dotfiles
* Install [iTerm2](http://www.iterm2.com/#/section/home), [hammerspoon](http://www.hammerspoon.org)

## Installation

```bash
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
cd dotfiles
make init
make backup
make install
```

## Listing changes
- Find files which will be written by executing `make listfiles`
- Backup all files which will be overwrtiten by executing `make backup`. This will create a backup in `$HOME/old_dotfiles`

