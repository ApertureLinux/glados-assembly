# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && sh -c "cd /root/archinstall-git; git config --global pull.rebase false; git pull; cp examples/guided.py ./; python guided.py"
