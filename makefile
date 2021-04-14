GIT_URL = https://github.com/ApertureLinux/glados.git
PACKAGES_DIR = packages/
MIRROR_DIR = glados/
DB_NAME = glados
DB_FILE = glados.db.tar.xz
ISO_DIR = iso/
CMP=zst

AUR_PACKAGES = yay aurutils

PERCENT := %
FILTER = $(foreach v,$(2),$(if $(findstring $(1),$(v)),$(v),))
ADD_DEP = $(call FILTER,$(1),$(PKGS)): $(call FILTER,$(2),$(MIRROR_PKGS))

#Due to the structure of our makefile, it is imperitive
#that we pull the new packages before we get the pkgbuild names.
#Because of this the following script has a few side effects that are
#only enabled by passing in various arguments in the format:
#script pull_new_packages||null compression_format
PKGS := $(shell ./scripts/get_pkgbuild_names.sh pull_new_packages $(CMP))
MIRROR_PKGS = $(addprefix $(MIRROR_DIR), $(notdir $(PKGS)))

all: sync
# all: $(MIRROR_DIR)/$(DB_FILE)
# 	$(MAKE) aur
# 	$(MAKE) sync

iso:
	cd "$(ISO_DIR)" && 								\
	sudo mkarchiso -v -w work/ -o out/ . &&	\
	sudo rm -rf "work"

aur:
	@./scripts/aur.sh $(AUR_PACKAGES)

sync: $(MIRROR_DIR)/$(DB_FILE)
	./scripts/sync.sh

$(PKGS):
	echo make - $(call FILTER,aperture-hooks,$(PKGS))
	@cd "$(@D)" &&				\
	PKGEXT=".pkg.tar.$(CMP)" makepkg -f --sign

.SECONDEXPANSION:
$(MIRROR_PKGS): $(MIRROR_DIR)% : $$(filter $$(PERCENT)%, $(PKGS)) $(MIRROR_DIR)
	@ln -f "$<" "$@"
	@ln -f "$<.sig" "$@.sig"
	@repo-add -R "$(MIRROR_DIR)/$(DB_FILE)" "$@"
	# @cp --preserve=timestamps "$<" "$@"

$(MIRROR_DIR)/$(DB_FILE): $(MIRROR_PKGS) aur
	# @test ! -f "$@" && repo-add "$@"
	# @test -f "$@" || repo-add "$@"
	@repo-add -R "$@" $(filter-out aur, $?)
	@rm -f $(MIRROR_DIR)/$(DB_FILE)*.sig

%/:
	@mkdir -p "$@"

clean: cleanpkgs cleanisoworking

distclean: clean cleanpkgs cleanrepo cleaniso

cleanpkgs:
	@rm -rf "$(PACKAGES_DIR)"

cleanrepo:
	@rm -rf "$(MIRROR_DIR)"

cleanisoworking:
	@sudo rm -rf "$(ISO_DIR)/working"

cleaniso: cleanisoworking
	@rm -rf "$(ISO_DIR)/out"

# Dependencies
$(call ADD_DEP,aperture-hooks,glados-keyring)

.PHONY: all aur iso sync clean disclean cleanpkgs cleanrepo
