#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2014
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

# run filterfs.sh script in every repo that has it
for dir in $(cat ~/.git-annex-dirs); do
  repo=$HOME/$dir

  if [[ -x $repo/filterfs.sh ]]; then
    echo $dir...
    cd $repo
    ./filterfs.sh
  fi
done
