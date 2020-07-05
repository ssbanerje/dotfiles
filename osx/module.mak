ifeq ($(UNAME), Darwin)

PREF := $(BUILD)/Library/Preferences
TARGETS += $(patsubst %, $(BUILD)/.bin/%, lock-screen lyrics)
TARGETS += $(PREF)/com.googlecode.iterm2.plist
TARGETS += $(patsubst %, $(BUILD)/.hammerspoon/%, $(shell find osx/hammerspoon -type f | sed "s/^osx\/hammerspoon\///"))
TARGETS += $(patsubst %, $(BUILD)/.config/%, iterm2_shell_integration.zsh iterm2_shell_integration.bash)

$(BUILD)/.bin/%: osx/% osx/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp -rf $< $@

$(PREF)/com.googlecode.iterm2.plist: osx/com.googlecode.iterm2.plist osx/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(PREF)
	@cp osx/com.googlecode.iterm2.plist $(PREF)/com.googlecode.iterm2.plist

$(BUILD)/.hammerspoon/%: osx/hammerspoon/% osx/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@

$(BUILD)/.config/iterm2_shell_integration.zsh: osx/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@curl -L https://iterm2.com/shell_integration/zsh -o $(BUILD)/.config/iterm2_shell_integration.zsh

$(BUILD)/.config/iterm2_shell_integration.bash: osx/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@curl -L https://iterm2.com/shell_integration/bash -o $(BUILD)/.config/iterm2_shell_integration.bash

endif
