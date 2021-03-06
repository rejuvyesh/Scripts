#!/bin/zsh

term=$@
foo=''
#search with surfraw
sr google $term >& /dev/null
## wait until the window exists and registers with the WM
while [ -z "$foo" ]; do
    foo=$(wmctrl -l |grep -i "$term - Google Search")
    sleep .5
done
#could use wmctrl -a, but it's not always reliable in awesome with dual screens
wmctrl -r "$term - Google Search" -b add,demands_attention
#echo "awful.client.urgent.jumpto()" |awesome-client
