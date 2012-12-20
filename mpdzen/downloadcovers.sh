#!/bin/zsh

# author: rejuvyesh
# Desc. : Script to fetch cover for the current playing song from last fm

mpdst=( ${(f)"$(mpc -h localhost status -f "%artist%\n%album%\n%title%")"} )
ARTIST=$mpdst[1]
ALBUM=$mpdst[2]
SONG=$mpdst[3]

quote=$'\042'

if [[ "$1" = -d ]]; then
    #debug
    cd ~/.covers
    cover_fetcher ${ARTIST} ${ALBUM}
else
    cd ~/.covers
    cover_fetcher ${ARTIST} ${ALBUM} &> /dev/null
fi
