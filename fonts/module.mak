ifeq ($(UNAME), Darwin)
	FONTDIR := $(BUILD)/Library/Fonts
else ifeq ($(UNAME), Linux)
	FONTDIR := $(BUILD)/.fonts
endif

TARGETS += $(FONTDIR) #$(patsubst %, $(DIR)/%, $(filter-out module.mak, $(wildcard fonts/*)))

$(FONTDIR): | $(BUILD)
	@echo "- Creating $@"
	@mkdir -p $@
	# TODO Fix the depenencies on individual font files
	@cp -f fonts/* $@
	@rm $@/module.mak
