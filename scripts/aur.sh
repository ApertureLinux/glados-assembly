#!/usr/bin/env bash

repo_location=$(dirname "$(realpath "$0")")/../glados
package_location=$(dirname "$(realpath "$0")")/../aur
repo_name=glados



if [ ! -d "$package_location" ]; then
    mkdir $package_location
fi


for pkg in $@; do 

    cd $package_location 
    
    echo $pkg

    if [ -d "$pkg" ]; then
        (
            cd "$pkg"
            git pull -f
        )
    else
        git clone "https://aur.archlinux.org/$pkg.git"

    fi

    cd $pkg
    makepkg -s -c --sign --noprogressbar --nocolor
    cp "$pkg"*".pkg.tar.zst" "$repo_location/"
done

