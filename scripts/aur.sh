#!/usr/bin/env bash

repo_location=$(dirname "$(realpath "$0")")/../glados
repo_name=glados
export AUR_PAGER=true


if [[ "$1" == rm ]] ; then
    shift
    repo-remove "$repo_location/${repo_name}.db.tar.xz" "$@"
    exit 0
elif [[ "$1" == ls ]] ; then
    shift
    repo-remove "$repo_location/${repo_name}.db.tar.xz" "$@"
    aur repo -l --database "$repo_name" --root "$repo_location"
    exit 0
fi

# TODO add some way to rebuild packages with broken deps (like boost)

# Notes:
# - use `--rebuild` to rebuild packages if needed (e.g. boost got upgraded)
# - to get gpg keys automatically, in `~/.gnupg/gpg.conf`, add line:
#   keyserver-options auto-key-retrieve
test -f "$repo_location/${repo_name}.db.tar.xz" || repo-add "$repo_location/${repo_name}.db.tar.xz"
aur sync				\
    --database "$repo_name"		\
    --root "$repo_location"		\
    --upgrades --noview --provides	\
    --force --noconfirm --rmdeps	\
    --sign				\
    "$@"
