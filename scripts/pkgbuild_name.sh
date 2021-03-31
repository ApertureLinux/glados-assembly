#!/bin/bash

cd "$1"
PATH= source PKGBUILD
CMP="zst"
if [[ -n "$epoch" ]]; then
    fullver=$epoch:${pkgname}-${pkgver}-${pkgrel}.pkg.tar.${CMP}
else
    fullver=${pkgname}-${pkgver}-${pkgrel}.pkg.tar.${CMP}
fi
printf %s\\n "$1/$fullver"  
