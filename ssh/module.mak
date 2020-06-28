TARGETS += $(BUILD)/.ssh/config

$(BUILD)/.ssh/config: ssh/config
	@#echo "- Creating $@"
	@mkdir -p $(BUILD)/.ssh/
	@cp ssh/config $(BUILD)/.ssh/
