TARGETS += $(BUILD)/.ssh/config

$(BUILD)/.ssh/config: ssh/config ssh/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(BUILD)/.ssh/
	@cp ssh/config $(BUILD)/.ssh/
