TARGETS += $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random)

$(BUILD)/.bin:
	@echo "- Creating $@"
	@mkdir -p $(BUILD)/.bin

$(BUILD)/.bin/%: bin/% | $(BUILD)/.bin
	@echo "- Creating $@"
	@cp -rf $< $@
