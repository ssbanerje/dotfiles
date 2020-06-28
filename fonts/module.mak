ifeq ($(UNAME), Darwin)
	FONTDIR := $(BUILD)/Library/Fonts
else ifeq ($(UNAME), Linux)
	FONTDIR := $(BUILD)/.fonts
endif

TARGETS += $(patsubst %, $(FONTDIR)/%, fontawesome-webfont.ttf Monaco-Powerline.otf)

$(FONTDIR)/%: fonts/%
	@#echo "- Creating $@"
	@mkdir -p $(@D)
	@cp $< $@
