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
MIRROR_PKGS = $(addprefix $(MIRROR_DIR), $(notdir $(PKGS)))

all: $(MIRROR_DIR)/$(DB_FILE)

$(PKGS):
	@cd "$(@D)" &&				\
	PKGEXT=".pkg.tar.$(CMP)" makepkg -f --sign

.SECONDEXPANSION:
PERCENT := %
$(MIRROR_PKGS): $(MIRROR_DIR)% : $$(filter $$(PERCENT)%, $(PKGS)) $(MIRROR_DIR)
	@ln -f "$<" "$@"
	# @cp --preserve=timestamps "$<" "$@"

$(MIRROR_DIR)/$(DB_FILE): $(MIRROR_PKGS)
	@test ! -f "$@" && repo-add "$@" || true
	@repo-add -R --verify "$@" $?

%/:
	@mkdir -p "$@"

clean: cleanpkgs

disclean: clean cleanpkgs cleanrepo

cleanpkgs:
	@rm -rf "$(PACKAGES_DIR)"

cleanrepo:
	@rm -rf "$(MIRROR_DIR)"

.PHONY: all clean disclean cleanpkgs cleanrepo
