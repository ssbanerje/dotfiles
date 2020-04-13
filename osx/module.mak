ifeq ($(UNAME), Darwin)

PREF := $(BUILD)/Library/Preferences
TARGETS += $(patsubst %, $(BUILD)/.bin/%, lock-screen lyrics)
TARGETS += $(PREF)/com.googlecode.iterm2.plist
TARGETS += $(BUILD)/.hammerspoon
TARGETS += $(patsubst %, $(BUILD)/.config/%, iterm2_shell_integration.zsh iterm2_shell_integration.bash)

$(BUILD)/.bin/%: osx/% $(BUILD)/.bin
	@cp -rf $< $@

$(PREF)/com.googlecode.iterm2.plist: osx/com.googlecode.iterm2.plist
	@mkdir -p $(PREF)
	@cp osx/com.googlecode.iterm2.plist $(PREF)/com.googlecode.iterm2.plist

$(BUILD)/.hammerspoon: $(shell find osx/hammerspoon)
	@cp -r osx/hammerspoon $(BUILD)/.hammerspoon

$(BUILD)/.config/iterm2_shell_integration.zsh: $(BUILD)/.config
	@curl -L https://iterm2.com/shell_integration/zsh -o $(BUILD)/.config/iterm2_shell_integration.zsh

$(BUILD)/.config/iterm2_shell_integration.bash: $(BUILD)/.config
	@curl -L https://iterm2.com/shell_integration/bash -o $(BUILD)/.config/iterm2_shell_integration.bash
endif
