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
# - pulls new packages if needed
# - generates dependency list in `.deps`
# usage: script [pull_new_packages] compression_format
PKGS := $(shell scripts/get_pkgbuild_names.sh pull_new_packages $(CMP) "$(MIRROR_DIR)" $(AUR_PKGS))
MIRROR_PKGS := $(addprefix $(MIRROR_DIR), $(notdir $(PKGS)))

all: sync

include $(wildcard .deps)

iso:
	cd "$(ISO_DIR)" && 			\
	sudo mkarchiso -v -w work/ -o out/ . # &&	\
	# sudo rm -rf "work"

isoinit:
	@mkdir iso
	@cp -r ./repos/archiso/configs/releng/* ./iso
	@rm iso/pacman.conf
	@cp ./resources/pacman-iso.conf ./iso/pacman.conf
	@rm iso/profiledef.sh
	@cp ./resources/profiledef.sh ./iso/profiledef.sh
	@cat ./resources/packages.x86_64 >> ./iso/packages.x86_64
	@rm iso/airootfs/etc/hostname
	@cp ./resources/hostname iso/airootfs/etc/hostname
	@rm iso/airootfs/etc/motd
	@cp ./resources/motd iso/airootfs/etc/motd
	@cp ./resources/pacman-glados-keyring.service ./iso/airootfs/etc/systemd/system/pacman-glados-keyring.service
	@mkdir -p ./iso/airootfs/etc/sddm.conf.d
	@cp ./resources/auto-login.conf ./iso/airootfs/etc/sddm.conf.d/
	@ln -s ../pacman-glados-keyring.service ./iso/airootfs/etc/systemd/system/multi-user.target.wants/pacman-glados-keyring.service
	@ln -s ../sddm.service ./iso/airootfs/etc/systemd/system/multi-user.target.wants/sddm.service
	@mkdir -p ./iso/airootfs/root/.config/autostart/
	@ln -s /usr/share/applications/calamares.desktop ./iso/airootfs/root/.config/autostart/calamares.desktop

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

distclean: clean cleanpkgs cleanrepo cleaniso cleanworkiso

cleanpkgs:
	@rm -rf $(PACKAGES_DIR)

cleanrepo:
	@rm -rf $(MIRROR_DIR)

cleaniso: cleanworkiso
	@sudo rm -rf $(ISO_DIR)

cleanworkiso:
	@sudo rm -rf $(ISO_DIR)/work

.PHONY: all aur iso sync clean distclean cleanpkgs cleanrepo cleaniso cleanworkiso
