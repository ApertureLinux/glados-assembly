#!/bin/sh

CMP=${2:-zst}


#Because we need to get the new packages before we get the names
#we have the pull stuff here
if [ ! -d packages/.git ] ; then
    [ -e packages ] && rm -rf packages
    git clone https://github.com/ApertureLinux/glados.git packages
fi

if [ "$1" = "pull_new_packages" ]; then
    (
        cd packages
        git pull 
    ) &> /dev/null
fi

for dir in packages/*/ ; do
    [ ! -d "$dir" ] && continue 
    (

        cd "$dir"
        PATH= source PKGBUILD
        if [[ -n "$epoch" ]]; then
            fullver=$epoch:${pkgname}-${pkgver}-${pkgrel}-${arch}.pkg.tar.${CMP}
        else
            fullver=${pkgname}-${pkgver}-${pkgrel}-${arch}.pkg.tar.${CMP}
        fi
        printf %s\\n "$dir$fullver"  

    )
done