TARGETS += $(patsubst %, $(BUILD)/.%, curlrc gdbinit irbrc pythonrc.py wgetrc)

$(BUILD)/.%: interp/% interp/module.mak | $(BUILD)
	@#echo "- Creating $@"
	@cp -rf $< $@
