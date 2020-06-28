TARGETS += $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random)

$(BUILD)/.bin/%: bin/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp -rf $< $@
