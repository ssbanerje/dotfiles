TARGETS += $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random doi2bib)

$(BUILD)/.bin/%: bin/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp -rf $< $@
