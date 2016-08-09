                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  )
                                      \__,_/\____/\__/_/   /_/_/\___/____/
                                            JUST THE WAY I LIKE IT


This is a compilation of dotfiles from dotfile repos, blogs and projects from across the web, put together to suit my workflow.

## Screenshot(s)
![Vim](https://raw.github.com/ssbanerje/dotfiles/master/vim_screenshot.png)


##Using these dotfiles
###Dependencies
* [XCode Tools](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12#)
* Install [homebrew](https://github.com/mxcl/homebrew) and some packages used in the dotfiles
* Install BetterTouchTool

```bash
ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
brew install ctags coreutils git macvim ack python fasd tmux
```

* Install [iTerm2](http://www.iterm2.com/#/section/home) - Not _required_ for these configuration files, but a welcome replacement of `Terminal.app`


On Linux you may have to install a few packages before everything starts working well. On a Debian/Ubunutu machine this can be done by runnning
```bash
sudo apt-get install zsh ruby-dev libclang-dev exuberant-ctags python-pip vim-nox vim-gnome rake tmux cmake python-dev
```

###Installation

```bash
# Install the dotfiles
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
cd dotfiles
git submodule update --init --recursive
make init
make
make install
```

`Note:` You would also need to change the `.gitconfig` file. So that you do not end up commiting as me.

###Update
To update to the latest version, simply update the git repository and submodules. Then run `make` and `make install`. To update all VIM plugins, run `:PlugUpdate`
