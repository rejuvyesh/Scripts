#!/bin/bash
# 
# Adds current playing song to the mpd playlist corresponding to the
# rating assigned. Any previous rating is removed. If 0 is given, the
# songs rating will be removed.
# 
# From: https://bbs.archlinux.org/viewtopic.php?id=116113

## Usage: songrating.sh [0..5]

## USER CONFIGURATION------------------------------------------------

playlists="$HOME/.mpd/playlists"
## Prefix and suffix strings for the playlist file name
pl_prefix=''
pl_suffix='.m3u'

## Get current song from ncmpcpp or throw an error
song=`ncmpcpp --now-playing '%D/%f' 2>/dev/null` || \
    { echo "Error: you need either ncmpcpp or cmus installed to run this script. Aborting." >&2; exit 1; }

## Error cases
if [[ -z "$song" ]]; then
	echo 'No song is playing.'
	exit 1
elif [[ "$1" -lt 0 || "$1" -gt 5 ]]; then
	echo "Rating must be between 1 and 5. Or zero to delete the current song's rating."
	exit 1
fi

## Path to lock file
lock="/tmp/songrating.lock"

## Lock the file
exec 9>"$lock"
if ! flock -n 9; then
	notify-send "Rating failed: Another instance is running."
	exit 1
fi

## Strip "file " from the output
song=${song/file \///}

## Temporary file for grepping and sorting
tmp="$playlists/tmp.m3u"

## Remove the song from all rating playlists
for n in {1..5}; do
	f="$playlists/${pl_prefix}$n${pl_suffix}"
	if [[ -f "$f" ]]; then
		grep -vF "$song" "$f" > "$tmp"
		mv -f $tmp $f
	fi
done

## Append the song to the new rating playlist
if [[ $1 -ne 0 ]]; then
	f="$playlists/${pl_prefix}$1${pl_suffix}"
	mkdir -p "$playlists"
	echo "$song" >> "$f"
	sort -u "$f" -o "$tmp"
	mv -f $tmp $f
fi

## The lock file will be unlocked when the script ends
