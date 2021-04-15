GIT_URL = https://github.com/ApertureLinux/glados.git
PACKAGES_DIR = packages/
MIRROR_DIR = glados/
DB_NAME = glados
DB_FILE = glados.db.tar.xz
ISO_DIR = iso/
CMP=zst

AUR_PKGS =  aurutils	\
	    yay

PERCENT := %

#Due to the structure of our makefile, it is imperitive
#that we pull the new packages before we get the pkgbuild names.
#Because of this the following script has a few side effects that are
#only enabled by passing in various arguments in the format:
#script pull_new_packages||null compression_format
PKGS := $(shell ./scripts/get_pkgbuild_names.sh pull_new_packages $(CMP))
MIRROR_PKGS := $(addprefix $(MIRROR_DIR), $(notdir $(PKGS)))

all: sync

iso:
	cd $(ISO_DIR) &&			\
	sudo mkarchiso -v -w work/ -o out/ . &&	\
	sudo rm -rf work

aur:
	@scripts/aur.sh $(AUR_PKGS)

sync: $(MIRROR_DIR)/$(DB_FILE)
	scripts/sync.sh

$(PKGS):
	@cd $(@D) && PKGEXT=.pkg.tar.$(CMP) makepkg -f --sign

.SECONDEXPANSION:
$(MIRROR_PKGS): $(MIRROR_DIR)% : $$(filter $$(PERCENT)%, $(PKGS)) | $(MIRROR_DIR)
	@test ! -f $<.sig || ln -f $<.sig $@.sig
	@ln -f $< $@
	@repo-add -R $(MIRROR_DIR)/$(DB_FILE) $@

$(MIRROR_DIR)/$(DB_FILE): $(MIRROR_PKGS) aur
	@repo-add -R $@ $(filter-out aur, $?)
	@rm -f $(MIRROR_DIR)/$(DB_FILE)*.sig

%/:
	@mkdir -p $@

clean: cleanpkgs cleanworkiso

distclean: clean cleanpkgs cleanrepo cleanworkiso cleaniso

cleanpkgs:
	@rm -rf $(PACKAGES_DIR)

cleanrepo:
	@rm -rf $(MIRROR_DIR)

cleaniso: cleanworkiso
	@rm -rf $(ISO_DIR)/out

cleanworkiso:
	@rm -rf $(ISO_DIR)/work

.PHONY: all aur iso sync clean distclean cleanpkgs cleanrepo cleaniso cleanworkiso
