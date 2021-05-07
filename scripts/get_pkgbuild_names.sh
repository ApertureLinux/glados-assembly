#!/bin/sh

PULL_PKGS=false
CMP=zst

log() {
    : echo >&2 "$@"
}

setup_pkgs() {
    # TODO: merge glados and glados-assembly, remove this hack

    #Because we need to get the new packages before we get the names
    #we have the pull stuff here
    if [ ! -d packages/.git ] ; then
        [ ! -e packages ] || rm -rf packages
        git clone https://github.com/ApertureLinux/glados.git packages
    fi

    if [ "$PULL_PKGS" = true ]; then
        (
            cd packages
            git pull
        ) > /dev/null
    fi
}

parse_args() {
    # TODO: might want to switch to getopt if this grows
    if [ "$1" = pull_new_packages ] ; then
        PULL_PKGS=true
        shift
    fi
    CMP=${1:-$CMP} ; shift
    MIRROR_DIR=${1:-glados} ; shift
    AUR="$@"

    MIRROR_DIR=$(realpath -ms --relative-base=. "$MIRROR_DIR")
}

contains() {
    local search=$1 ; shift
    for val in $* ; do
        [ "$search" = "$val" ] && return 0
    done
    return 1
}

get_versioned_name() {
    (
        cd "$1"
        PATH= source PKGBUILD
        version="${epoch}${epoch:+:}${pkgver}-${pkgrel}"
        echo "${pkgbase:-$pkgname}-$version-${arch}.pkg.tar.${CMP}"
    )
}

get_all_deps() {
    (
        cd "$1"
        PATH= source PKGBUILD
        printf '%s\n'			\
            "${checkdepends[@]}"	\
            "${makedepends[@]}"		\
            "${depends[@]}"		\
            # "${optdepends[@]}"  # opt deps don't get installed
    ) | sort -u
}

get_local_deps() {
    local found=1

    while read -r pkg ; do
        if [ -f "packages/$pkg/PKGBUILD" ] ; then
            log glados dep: $pkg
            found=0
            echo -n $MIRROR_DIR/
            get_versioned_name "packages/$pkg" | tr '\n' ' '
        elif contains "$pkg" "${AUR[@]}" ; then
            log aur dep: $pkg
            found=0
            echo -n "aur "
        else
            log ignore: $pkg
        fi
    done < <(get_all_deps "$1")
    echo

    return $found
}

main() {
    local pkg
    local deps

    # switch to 1 dir up
    cd $(dirname "$(realpath "$0")")/..

    parse_args "$@"
    setup_pkgs

    # reset deps
    echo -n > .deps

    for dir in packages/*/ ; do
        [ ! -d "$dir" ] && continue

        # output for make package list
        pkg=$dir/$(get_versioned_name "$dir")
        echo $pkg

        log -e "\n\nfor pkg $dir:"

        # output to .deps file
        deps=$(get_local_deps "$dir")
        if deps=$(get_local_deps "$dir") ; then
            echo $pkg: $deps >> .deps
        fi
    done
}

main "$@"
