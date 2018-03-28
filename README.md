                                             __      __  _______ __
                                        ____/ /___  / /_/ ____(_) /__  _____
                                       / __  / __ \/ __/ /_  / / / _ \/ ___/
                                      / /_/ / /_/ / /_/ __/ / / /  __(__  )
                                      \__,_/\____/\__/_/   /_/_/\___/____/
                                            JUST THE WAY I LIKE IT


This is a compilation of dotfiles from dotfile repos, blogs and projects from across the web, put together to suit my workflow.

## Using these dotfiles
### Dependencies

#### Mac OS
* [XCode Tools](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12#)
* Install [homebrew](https://github.com/mxcl/homebrew) and some packages used in the dotfiles

```bash
ruby <(curl -fsSkL raw.github.com/mxcl/homebrew/go)
brew install ctags coreutils git macvim ack python fasd tmux reattach-to-user-namespace
brew install global --with-pygments --with-ctags
pip install --user flake8 yapf autoflake isort python-language-server
npm -g install remark remark-cli remark-stringify
```

* Install [iTerm2](http://www.iterm2.com/#/section/home), [hammerspoon](http://www.hammerspoon.org)

#### Linux
On Linux you may have to install a few packages before everything starts working well. On a Debian/Ubunutu machine this can be done by runnning

```bash
sudo apt-get install global zsh ruby-dev libclang-dev exuberant-ctags python3-pip vim-nox vim-gnome rake tmux cmake python3-dev xclip psutils python3-pygments
pip install --user flake8 yapf autoflake isort python-language-server
npm -g install remark remark-cli remark-stringify
```



### Installation

```bash
# Install the dotfiles
git clone https://github.com/ssbanerje/dotfiles.git dotfiles
cd dotfiles
git submodule update --init --recursive
make init
make
make install
```

### Update
To update to the latest version, simply update the git repository and submodules. Then run `make` and `make install`. To update all VIM plugins, run `:PlugUpdate`
