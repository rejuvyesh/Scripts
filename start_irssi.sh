#!/bin/bash
#Thanks to https://gist.github.com/3298818
IRSSI_PATH=.irssi
if [ -z "$IRSSI_PATH" ]
then
echo "Environment variable IRSSI_PATH not set."
    exit
fi

tmux new-session -d -s ircuser
tmux split-window -t ircuser -h -l 20

tmux send-keys -t ircuser "tmux send-keys -t0 \"irssi\" C-m; \
tmux send-keys -t0 \"/set nicklist_height \$(stty size | cut -f1 -d' ' -)\" C-m; \
tmux send-keys -t0 \"/set nicklist_width \$(stty size | cut -f2 -d' ' -)\" C-m; \
tmux send-keys -t0 \"/nicklist fifo\" C-m; \
tmux send-keys -t1 \"cat $IRSSI_PATH/nicklistfifo\" C-m; \
tmux select-pane -t0" C-m

tmux attach-session -t ircuser
