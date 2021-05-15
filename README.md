# Glados Assembly

This repo builds the `glados` repo and pushes it to a remote server.

Most of this is done in our makefile, with various helper scripts in `/scripts`


### Usage

`make` - Makes the entire repo, and uploads it

`make aur` - will exclusively build the aur repos

`make sync` - runs the sync.sh script

`make iso` - must be run as root, creates the aperture iso.

`make clean / make cleanpkgs` - cleans the packges dir

`make cleanrepo` - cleans the repos dir

`make cleaniso` - cleans the iso working dir

`make distclean` - fully cleans the project
