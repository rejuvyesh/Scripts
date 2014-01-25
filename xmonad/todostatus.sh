#!/bin/zsh

width=300
font_pixelsize=12
line_height=$((font_pixelsize + 4))
lines=8
height=$((line_height * (lines + 1)))

bottom_gap=15
s_width=1366
s_height=768

todo='/home/rejuvyesh/.todo/todo.txt'

{   echo '^fg(#661222)TODO^fg()'
    cat $todo |  sed -e "s|\(([A-Z])\)|~\1|" | sort -k2 -f | sed -e "s|~\(([A-Z])\)|\1|" 


    echo '^uncollapse()'
} | dzen2 -x $((s_width - width)) -y $((s_height - height - bottom_gap)) -w $width -l $lines -h $line_height -sa left -fn "-xos4-terminus-medium-*-*-*-12-*-*-*-*-*-*-*" -bg '#222' -e 'leaveslave=exit;button3=exit;button4=scrollup;button5=scrolldown;onstart=scrollhome' -p
