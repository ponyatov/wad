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
D += $(wildcard src/*.d) $(wildcard kicad/src/*.d)
J += $(wildcard *.json)
T += $(wildcard views/*.dt)
S += $(wildcard static/*.js)

# all
.PHONY: all run
all: bin/$(MODULE)
run: $(D) $(J) $(T)
	$(RUN)

.PHONY: kicad
kicad: $(D)
	$(RUN) :kicad -- kicad/pcb/board.kicad_pcb > tmp/board.gerber

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
install: doc gz mongo
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

.PHONY: mongo
# https://nspeaks.com/install-mongodb-on-debian-12/
MONGO_VER = 6.0
MONGO_GPG = /usr/share/keyrings/mongodb-server-$(MONGO_VER).gpg
MONGO_APT = /etc/apt/sources.list.d/mongodb-org-$(MONGO_VER).list
MONGO_SSL = /usr/lib/x86_64-linux-gnu/libssl.so.1.1
mongo: $(MONGO_APT) $(MONGO_SSL)
	sudo apt update
	sudo apt install -uy mongodb-org
	sudo systemctl enable mongod --now
$(MONGO_GPG):
	curl -fsSL https://pgp.mongodb.com/server-$(MONGO_VER).asc | \
		sudo gpg --dearmor -o $(MONGO_GPG)
$(MONGO_APT): $(MONGO_GPG)
	echo "deb [signed-by=$<] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/$(MONGO_VER) main" | \
		sudo tee $@
$(MONGO_SSL): $(GZ)/libssl1.deb
	sudo dpkg -i $< && sudo touch $@
$(GZ)/libssl1.deb:
	$(CURL) $@ https://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb11u5_amd64.deb
