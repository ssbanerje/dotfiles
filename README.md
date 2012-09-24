                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  ) 
                                      \__,_/\____/\__/_/   /_/_/\___/____/  
                                            JUST THE WAY I LIKE IT 


This is a compilation of dotfiles from dotfile repos, blogs and projects from across the web, put together to suit my workflow.

## Screenshot(s)
![Vim](https://raw.github.com/subszero/dotfiles/master/vim_screenshot.png)


##Using these dotfiles
###Dependencies
* [XCode Tools](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12#)
* Install [homebrew](https://github.com/mxcl/homebrew) and some packages used in the dotfiles
* Install BetterTouchTool... You will thank me later!

```bash
ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
brew install ctags coreutils git macvim ack python fasd
```

* Install [iTerm2](http://www.iterm2.com/#/section/home) - This is by no means _required_ for these configuration files, but a welcome replacement of `Terminal.app`

###Installation

```bash
# Install the dotfiles
git clone https://github.com/subszero/dotfiles.git dotfiles
dotfiles/install.sh --init
```

###Update

```bash
dotfiles/install.sh --update
```

