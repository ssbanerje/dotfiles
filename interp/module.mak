TARGETS += $(patsubst %, $(BUILD)/.%, curlrc gdbinit irbrc pyrc wgetrc)

$(BUILD)/.%: interp/% $(BUILD)
	@cp -rf $< $@
