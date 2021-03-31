GIT_URL = https://github.com/ApertureLinux/glados.git
PACKAGES_DIR = packages/
MIRROR_DIR = glados/
DB_NAME = glados
PKGS := $(shell ./scripts/get_pkgbuild_names.sh pull_new_packages zst)

all: $(DB_NAME).db.tar

clean:
	rm -rf "$(PACKAGES_DIR)"
	rm -rf "$(MIRROR_DIR)"


$(DB_NAME).db.tar: $(MIRROR_DIR) local_packages #aur_packages


local_packages:
	$(MAKE) fetch
	$(MAKE) assemble


fetch:
	@echo fetch

	@cd "$(PACKAGES_DIR)"; 	\
	git clean -df;			\
	git reset --hard HEAD;	\
	git pull;				\

%/: 
	@mkdir -p "$@"


assemble: $(PKGS)

$(PKGS): $(MIRROR_DIR)
	@echo $(@D) .  $(@DD) . $(@DF) . $(@F) . $(@FF)
	@dir=$(@D) pkg=$(@F) $(MAKE) compile
	@dir=$(@D) pkg=$(@F) $(MAKE) package

compile:
	@echo compile: $(pkg)

	@cd "$(dir)";		\
	makepkg -f --sign	\

package:
	@echo package: $(pkg)

	cp "$(dir)/$(pkg)" "$(MIRROR_DIR)"


$(MIRROR_DIR)/$(DB_NAME).db.tar: $(MIRROR_DIR) $(PKGS)
	@cd "$(MIRROR_DIR)" && 				\
	repo-add -s "$(DB_NAME).db.tar" && 	\
	repo-add --verify --sign -n "$(DB_NAME).db.tar" *.zst

.PHONY: $(SUBDIRS) assemble compile package link