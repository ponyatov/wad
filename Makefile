# var
MODULE  = $(notdir $(CURDIR))

# version
JQUERY_VER       = 3.7.1
JQUERY_UI        = 1.13.2
JQUERY_THEME     = dark-hive
JQUERY_THEME_VER = 1.12.1

# dir
CWD = $(CURDIR)
BIN = $(CWD)/bin
DOC = $(CWD)/doc
SRC = $(CWD)/src
TMP = $(CWD)/tmp
GZ  = $(HOME)/gz

# tool
CURL = curl -L -o
DC   = dmd
BLD  = dub build --compiler=$(DC)
RUN  = dub run   --compiler=$(DC)

# src
D += $(wildcard src/*.d)
J += $(wildcard *.json)
T += $(wildcard views/*.dt)
S += $(wildcard static/*.js)

# all
.PHONY: all run
all: bin/$(MODULE)
run: $(D) $(J) $(T)
	$(RUN)

# format
.PHONY: format
format: tmp/format_d tmp/format_js
tmp/format_d: $(D)
	$(RUN) dfmt -- -i $? && touch $@
tmp/format_js: $(S)
	clang-format -style=file -i $? && touch $@

# rule
bin/$(MODULE): $(D) $(J) $(T) Makefile
	$(BLD)

# doc
doc: doc/yazyk_programmirovaniya_d.pdf doc/Programming_in_D.pdf \
     doc/BuildWebAppsinVibe.pdf doc/BuildTimekeepWithVibe.pdf

doc/yazyk_programmirovaniya_d.pdf:
	$(CURL) $@ https://www.k0d.cc/storage/books/D/yazyk_programmirovaniya_d.pdf
doc/Programming_in_D.pdf:
	$(CURL) $@ http://ddili.org/ders/d.en/Programming_in_D.pdf
doc/BuildWebAppsinVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildWebAppsinVibe.pdf
doc/BuildTimekeepWithVibe.pdf:
	$(CURL) $@ https://raw.githubusercontent.com/reyvaleza/vibed/main/BuildTimekeepWithVibe.pdf

# install
.PHONY: install update doc gz
install: doc gz
	$(MAKE) update
	dub fetch dfmt
update:
	sudo apt update
	sudo apt install -uy `cat apt.txt`

gz: \
    static/cdn/jquery.js static/cdn/jquery-ui.js \
    static/cdn/$(JQUERY_THEME).css

static/cdn/jquery.js:
	$(CURL) $@ https://code.jquery.com/jquery-$(JQUERY_VER).min.js

static/cdn/jquery-ui.js: $(GZ)/jquery-ui-$(JQUERY_UI).zip
	unzip $< -d tmp
	cp tmp/jquery-ui-$(JQUERY_UI)/jquery-ui.min.js $@
	touch $@
	rm -r tmp/jquery-ui-$(JQUERY_UI)
static/cdn/$(JQUERY_THEME).css: $(GZ)/jquery-ui-themes-$(JQUERY_UI).zip
	unzip $< -d tmp
	cp tmp/jquery-ui-themes-$(JQUERY_UI)/themes/$(JQUERY_THEME)/jquery-ui.min.css $@
	cp -r tmp/jquery-ui-themes-$(JQUERY_UI)/themes/$(JQUERY_THEME)/images/* static/cdn/images/
	touch $@
	rm -r tmp/jquery-ui-themes-$(JQUERY_UI)

$(GZ)/jquery-ui-$(JQUERY_UI).zip:
	$(CURL) $@ https://jqueryui.com/resources/download/jquery-ui-$(JQUERY_UI).zip
$(GZ)/jquery-ui-themes-$(JQUERY_UI).zip:
	$(CURL) $@ https://jqueryui.com/resources/download/jquery-ui-themes-$(JQUERY_UI).zip

# merge
MERGE += Makefile README.md LICENSE apt.txt $(D) $(J) $(T) $(S)
MERGE += .clang-format .editorconfig .gitattributes .gitignore
MERGE += bin doc lib inc src tmp public views

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
#	$(MAKE) doxy ; git add -f docs

.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) shadow

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip:
	git archive --format zip --output $(ZIP) HEAD
