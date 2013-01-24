#!/bin/zsh
SESSION=ncmpcpp

tmux has-session -t $SESSION
if [ $? -eq 0 ]; then
	  tmux attach -t $SESSION
	  exit 0;
fi

tmux  new-session -d -s $SESSION 'ncmpcpp -s playlist'
tmux  split-window -d -t $SESSION:1 -p 45 'ncmpcpp -s visualizer'
tmux  select-pane -t $SESSION:1.1
tmux  split-window -d -t $SESSION:1 -h -p 50 'ncmpcpp'
tmux  select-pane -t $SESSION:1.0
tmux  select-pane -t $SESSION:1.2

#  -----------------
# |                 |
# |        0        |
# |                 | 
#  -----------------
# |        |        |
# |    1   |   2    |
# |        |        |
#  -----------------

for i in "\\" "l"
do tmux send-keys -t $SESSION:1.2 "$i"
done

for i in "\\" 
do tmux send-keys -t $SESSION:1.1 "$i"
done

tmux set -t $SESSION -g status off

tmux attach-session -t $SESSION
