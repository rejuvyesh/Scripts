#!/bin/zsh

echo "Playing "+$1;
unrar p -inul $1 | mplayer -
