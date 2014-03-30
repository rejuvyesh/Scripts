#!/bin/sh
#
# File: mail-cron.sh
#
# Created: Sunday, March 30 2014 by rejuvyesh <mail@rejuvyesh.com>
# From: https://github.com/fmap/vi-bin/blob/master/cron/courier
#

export PATH=/usr/bin:$HOME/local/bin:$HOME/dev/scripts

log() {
    ( date "+$0: %c" &&
        $@
    ) >> "$HOME/.offlineimap.log"
};

running() {
    pgrep offlineimap &>/dev/null
}

crashed() {
    started=$(psgrep offlineimap | awk '{print $9}' | sort | head -1)
    started=$(date --date=$started +%s) # [^1]
    current=$(date +%s)
    return $((($current-$started) < 60*5)); # [^2]
};

if running && crashed; then
    log echo 'Process older than five minutes, restarting..'
    psgrep offlineimap | awk '{print $2}' | xargs kill -9
fi


if ! running; then
    log offlineimap -o -u basic &
fi

# [^1]: If there's no running offlineimap process, or at least one
# running process started before midnight, `$started` will be
# empty, and date will return 12PM on the current day; in the first
# case, this'll have no effect, owing to the second conditional; in the
# second, we'll get dodgy results before 00:05.. which I can live with.

# [^2]: `zsh` uses 0 to represent truth in return codes, but 1 in
# arithmetic operations, so we flip the expected operator.
