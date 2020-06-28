TARGETS += $(patsubst %, $(BUILD)/.%, curlrc gdbinit irbrc pyrc wgetrc)

$(BUILD)/.%: interp/% | $(BUILD)
	@#echo "- Creating $@"
	@cp -rf $< $@
