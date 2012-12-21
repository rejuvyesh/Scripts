#!/bin/bash

width=420
font_pixelsize=12
line_height=$((font_pixelsize + 4))
lines=8
height=$((line_height * (lines + 1)))

bottom_gap=15
s_width=1366
s_height=768

{
    echo '^fg(#008080)Calendar^fg()'
    cal -3s
    echo '^uncollapse()'
} | dzen2 -x $((s_width - width)) -y $((s_height - height - bottom_gap)) -w $width -l $lines -h $line_height -sa center -fn "-xos4-terminus-medium-*-*-*-12-*-*-*-*-*-*-*" -e 'leaveslave=exit;button3=exit;button4=scrollup;button5=scrolldown;onstart=scrollhome' -p
