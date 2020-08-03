TARGETS += $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random doi2bib ftwind)

$(BUILD)/.bin/%: bin/% bin/module.mak
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp -rf $< $@
