GIT_URL = https://github.com/ApertureLinux/glados.git
PACKAGES_DIR = packages/
MIRROR_DIR = glados/
DB_NAME = glados
DB_FILE = glados.db.tar.xz
CMP=zst

#Due to the structure of our makefile, it is imperitive 
#that we pull the new packages before we get the pkgbuild names.
#Because of this the following script has a few side effects that are 
#only enabled by passing in various arguments in the format:
#script pull_new_packages||null compression_format
PKGS := $(shell ./scripts/get_pkgbuild_names.sh pull_new_packages $(CMP))

all: $(MIRROR_DIR)/$(DB_FILE)

clean:
	rm -rf "$(PACKAGES_DIR)"
	rm -rf "$(MIRROR_DIR)"


# $(MIRROR_DIR)/$(DB_FILE): $(MIRROR_DIR) local_packages #aur_packages


# local_packages: $(PKGS)


%/: 
	@mkdir -p "$@"


$(PKGS):
	@dir=$(@D) pkg=$(@F) $(MAKE) compile
	@dir=$(@D) pkg=$(@F) $(MAKE) package

compile: $(MIRROR_DIR)
	@echo compile: $(pkg)

	@cd "$(dir)" &&								\
	PKGEXT=".pkg.tar.$(CMP)" makepkg -f

package:
	@echo package: $(pkg)

	cp "$(dir)/$(pkg)" "$(MIRROR_DIR)"


$(MIRROR_DIR)/$(DB_FILE): $(MIRROR_DIR) $(PKGS)
	@cd "$(MIRROR_DIR)" && 				\
	repo-add -s "$(DB_FILE)" && 	\
	repo-add --verify --sign -n "$(DB_FILE)" *.$(CMP)

.PHONY: $(SUBDIRS) assemble compile package link