#!/bin/sh
#
# File: youtube-play.sh
#
# Created: Saturday, November  2 2013 by rejuvyesh <rejuvyesh@gmail.com>
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>
#

cookies_dir="/tmp/.youtube-dl_$$"
cookies_file="${cookies_dir}/cookies"
user_agent="$(youtube-dl --dump-user-agent)" # or set whatever you want

rm -rf "$cookies_dir"
mkdir "$cookies_dir" || exit 1
chmod 0700 "$cookies_dir" || exit 1

video_url="$(youtube-dl --quiet\
--user-agent="$user_agent" \
--cookies="$cookies_file" \
--get-url \
"$1")"

# Start in the bottom right corner
mpv \
--quiet \
--geometry="100%:97%" \
--autofit="150x150" \
--cookies \
--cookies-file="$cookies_file" \
--user-agent="$user_agent" \
${@:2} -- "$video_url"

rm -rf "$cookies_dir"")"
