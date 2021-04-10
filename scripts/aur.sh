#!/usr/bin/env bash

user=aur
group=mirror
repo_location=`pwd`/glados
repo_name=glados
export AUR_PAGER=true

# if [[ "$(id -ng)" != "$group" ]] || [[ "$(id -nu)" != "$user" ]] ; then
#     sudo -u "$user" -g "$group" "$0" "$@"
#     exit $?
# fi

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

# yay has a `--pgp-fetch` flag, aur sync does not
# this is the workaround recomended by the man page (but automated)
# if ! grep -q '^\s*keyserver-options' ~/.gnupg/gpg.conf 2>/dev/null; then
#     # TODO doesn't actually work anymore
#     mkdir -p ~/.gnupg/
#     printf '\nkeyserver-options auto-key-retrieve\n' >> ~/.gnupg/gpg.conf
# fi

# Notes:
# - use `--rebuild` to rebuild packages if needed (e.g. boost got upgraded)
# - to get gpg keys automatically, in `~/.gnupg/gpg.conf`, add line:
#   keyserver-options auto-key-retrieve
aur sync				\
    --database "$repo_name"		\
    --root "$repo_location"		\
    --upgrades --noview --provides	\
    --force --noconfirm --rmdeps 	\
    --sign				\
    "$@"
