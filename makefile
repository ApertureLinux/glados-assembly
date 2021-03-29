GIT_URL = https://github.com/ApertureLinux/glados.git
PACKAGES_DIR = packages/
MIRROR_DIR = glados/
DB_NAME = glados
SUBDIRS := $(wildcard packages/*)


all: assemble



clean:
	rm -rf "$(PACKAGES_DIR)"
	rm -rf "$(MIRROR_DIR)"


init:
	git clone $(GIT_URL) $(PACKAGES_DIR)
	mkdir $(MIRROR_DIR)

	cd $(MIRROR_DIR);	\
	repo-add -s "$(DB_NAME).db.tar"

all:
	$(MAKE) fetch
	$(MAKE) assemble
	$(MAKE) link

fetch:
	@echo fetch

	@cd "$(PACKAGES_DIR)"; 	\
	git clean -df;			\
	git reset --hard HEAD;	\
	git pull;				\


assemble: $(SUBDIRS)
	@echo subdirs: '$(SUBDIRS)'

$(SUBDIRS):
	@dir=$(@D) pkg=$(@F) $(MAKE) compile
	@dir=$(@D) pkg=$(@F) $(MAKE) package

compile:
	@echo compile: $(pkg)

	@cd "$(dir)/$(pkg)";		\
	makepkg -f --sign					\

package:
	@echo package: $(pkg)

	cp "$(dir)/$(pkg)/$(pkg)"*".tar"* "$(MIRROR_DIR)"


link:
	@echo Linking Packages
	
	repo-add --verify --sign -n "$(DB_NAME).db.tar" *.zst

.PHONY: $(SUBDIRS)