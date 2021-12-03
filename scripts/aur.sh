#!/usr/bin/env bash

repo_location=$(dirname "$(realpath "$0")")/../glados
package_location=$(dirname "$(realpath "$0")")/../packages
repo_name=glados



for pkg in $@; do 
    cd $package_location
    
    echo $pkg

    curl -L -0"https://aur.archlinux.org/cgit/aur.git/snapshot/$pkg.tar.gz"


    tar xvf "$pkg.tar.gz"
    cd $pkg
    makepkg -s -c --sign --noprogressbar --nocolor || true
    cp "$pkg"*".pkg.tar.zst" "$repo_location/"
done