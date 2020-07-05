TARGETS += $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random)

$(BUILD)/.bin/%: bin/% bin/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp -rf $< $@
