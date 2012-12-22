#!/bin/zsh

width=140
font_pixelsize=12
line_height=$((font_pixelsize + 4))
lines=2
height=$((line_height * (lines + 1)))
posshift=280
bottom_gap=15
s_width=1366
s_height=768

INTERFACE=$1

{   echo '^fg(#2c82dd)Network^fg()'
    echo " IP: $(ip addr list $INTERFACE |grep "inet " |cut -d' ' -f6|cut -d/ -f1)"
    echo " GATEWAY: $(ip r | awk '/^def/{print $3}')"
    echo '^uncollapse()'
} | dzen2 -x $((s_width - width -posshift)) -y $((s_height - height - bottom_gap)) -w $width -l $lines -h $line_height -sa 'left' -fn "-xos4-terminus-medium-*-*-*-12-*-*-*-*-*-*-*" -bg "#111111" -e 'leaveslave=exit;button3=exit;button4=scrollup;button5=scrolldown;onstart=scrollhome' -p
