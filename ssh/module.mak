TARGETS += $(BUILD)/.ssh/config

$(BUILD)/.ssh/config: ssh/config $(BUILD)
	@mkdir -p $(BUILD)/.ssh/
	@cp ssh/config $(BUILD)/.ssh/
