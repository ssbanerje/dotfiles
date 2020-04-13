BINS := $(patsubst %, $(BUILD)/.bin/%, diffconflicts gzball ports random)
TARGETS += $(BINS)

$(BUILD)/.bin:
	@mkdir -p $(BUILD)/.bin

$(BUILD)/.bin/%: bin/% $(BUILD)/.bin
	@cp -rf $< $@
