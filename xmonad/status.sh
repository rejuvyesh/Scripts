#!/bin/zsh
# Requires dzen2 and dmplex.
# Battery widget       requires acpi
# Wireless widget      requires wireless_tools
# Volume widget        requires alsa-utils and inotify-tools
# CPU Frequency widget requires cpufrequtils and bc

# dzen2 options
FG='#8a8a8a'
BG='#000000'
SCREEN_WIDTH=1366
BAR_WIDTH=600
HEIGHT=768
E="sigusr1=raise;sigusr2=lower"
H="13"
FONT='-*-terminus-*-r-normal-*-12-*-*-*-*-*-iso8859-*'
# make 2 pipes - one for xmonad's output and one for the status bar

fume_db=$(ruby -ryaml << EOF
c = YAML.load_file(File.join(ENV['HOME'], '.fumerc'))
puts File.join(c['fume_dir'], 'fume_db.yaml')
EOF
)

# icons
ICON_PATH="/home/rejuvyesh/src/scripts/xmonad/icons"
ICON_WIRED="^i(${ICON_PATH}/net_wired.xbm)"
ICON_WIRELESS="^i(${ICON_PATH}/wifi_01.xbm)"
ICON_AC="^fg(#008060)^i(${ICON_PATH}/ac_01.xbm)^fg()"
ICON_BATTERY="^i(${ICON_PATH}/bat_full_01.xbm)"
ICON_VOLUME="^fg(#007070)^i(${ICON_PATH}/spkr_01.xbm)^fg()"
ICON_MUTED="^fg(#540000)^i(${ICON_PATH}/spkr_02.xbm)^fg()"
ICON_CPU="^i(${ICON_PATH}/cpu.xbm)"
ICON_TIME="^i(${ICON_PATH}/clock.xbm)"
ICON_MEM="^i(${ICON_PATH}/mem.xbm)"
ICON_UP="^fg(orange3)^i(${ICON_PATH}/net_up_03.xbm)^fg()"
ICON_DOWN="^fg(#80AA83)^i(${ICON_PATH}/net_down_03.xbm)^fg()"

# Usage: update_bar position icon text
update_bar () {
	  echo $1 "  $2 $3" 
}


update_time () {
	  while true; do
		    update_bar $1 "^ca(1,calendar.sh)$ICON_TIME^ca()" "$(date '+%a %-d %b %Y ^ca(1, fuzzydate.sh)^fg(white)%H:%M^fg():%S^ca()')"
		    sleep 1
	  done
}

update_battery() {
	  local bat_text
	  local bat_icon
	  while true; do
		    bat_text="$(acpi -b)"
		    if acpi -a | grep -q on-line; then
			      bat_icon="$ICON_AC"
		    else
			      bat_icon="$ICON_BATTERY"
		    fi

		    if echo $bat_text | grep -q remaining || echo $bat_text | grep -q 'until charged'; then
			      bat_text="$(echo $bat_text | sed -rn 's/.* ([0-9]+%), ([0-9]{2}:[0-9]{2}).*/\1 (\2)/p')"
		    elif echo $bat_text | grep -q unavailable; then
			      bat_text="$(echo $bat_text | sed -rn 's/.* ([0-9]+%), .*/\1 (unknown)/p')"
		    elif echo $bat_text | grep -q Full; then
			      bat_text='100% (Full)'
		    else
			      bat_text='AC'
		    fi

		    update_bar $1 "$bat_icon" "$bat_text"
		    sleep 20
	  done
}

update_wired () {
    local ifx=eth0 n_rxb n_txb
	  while true; do
        read n_rxb < /sys/class/net/$ifx/statistics/rx_bytes
        read n_txb < /sys/class/net/$ifx/statistics/tx_bytes
        rx_rate=$(((n_rxb - rxb) / 1024))
        tx_rate=$(((n_txb - txb) / 1024))
        rxb=$n_rxb
        txb=$n_txb
		    update_bar $1 "^ca(1, net.sh eth0)${ICON_WIRED}^ca()" "$ICON_UP $tx_rate $ICON_DOWN $rx_rate "
		    sleep 2
	  done
}

update_wireless () {
    local ifx=wlan0 n_rxb n_txb
	  while true; do
        read n_rxb < /sys/class/net/$ifx/statistics/rx_bytes
        read n_txb < /sys/class/net/$ifx/statistics/tx_bytes
        rx_rate=$(((n_rxb - rxb) / 1024))
        tx_rate=$(((n_txb - txb) / 1024))
        rxb=$n_rxb
        txb=$n_txb
		    update_bar $1 "^ca(1, net.sh wlan0)${ICON_WIRELESS}^ca()" "$(iwconfig wlan0 | awk '/Quality/{print $2}' | cut -d'=' -f2 | awk -F'/' '{printf("%.0f%%", $1/$2*100)}') $ICON_UP $tx_rate $ICON_DOWN $rx_rate"
	      sleep 2
	  done
}

update_network(){
    local net="$(ip link show wlan0 | grep 'state UP')"
    if [[ -z $net ]]; then
        update_wired 4 &
        sleep 2
    else
        update_wireless 4 &
        sleep 2
    fi

}

update_volume() {
	  local vol
	  local vol_icon
	  while true; do
		    vol="$(amixer get Master | grep Mono:)"
		    if echo $vol | grep -q off; then
			      vol_icon="$ICON_MUTED"
		    else
			      vol_icon="$ICON_VOLUME"
		    fi
        V="$(amixer get Master | grep -oP '\d+%' | tail -1)"
		# clickable areas for muting, increasing, and decreasing volume
		    vol_icon="^ca(1, amixer set Master toggle)^ca(4, amixer set Master 5+ unmute)^ca(5, amixer set Master 5-)$vol_icon $V"
		    vol="$(echo $vol | sed -r 's/.*[0-9] \[([0-9]+)%.*/\1/' | gdbar -h 10 -w 30 -fg '#61a0b9' -bg '#565656')^ca()^ca()^ca()"

		    update_bar $1 "$vol_icon" "$vol"
		    inotifywait -t 30 -qq /src/snd/controlC0
	  done
}

# processes with >= 30% cpu load
cpu_hogs() {
    ps -eo pcpu,ucmd --sort -pcpu | grep -vP "migration/\d+" | tail -n +2 | while read proc
    do
        if [[ $proc[(w)1] -ge 30.0 ]] then
            echo -n " $proc[(w)1] ${${proc[(w)2]}[1,10]}"
        fi
    done
}

update_cpuload () {
	  while true; do
		    # update_bar $1 "$ICON_CPUFREQ" "$(printf '%3.2f GHz' $(echo 2k$(cpufreq-info -f) 1000000/p | dc))"
        update_bar $1 "$ICON_CPU" "$(cpu_hogs)"
		    sleep 2
	  done
}

# memory usage
memory(){
    while true; do
        mem=(${$(free -m | grep "Mem:")[2,7]})
        update_bar $1 "$ICON_MEM" "$(($mem[2] - $mem[5] - $mem[6]))"
        sleep 2
    done    
}

# fume
watch_fume() {
    while true; do
        mod_time=$(stat -c "%Y" $fume_db)
        now=$(date "+%s")
    
        if [[ $mod_time -gt $last_mod_time ]]; then
            last_mod_time=$mod_time
            echo $1 "$(ti display --start 'today 0:00' -f status | sed -r 's/^.{3}//')"
        elif [[ $now -gt $(( $last_mod_time + 600 )) ]]; then
            last_mod_time=$now
            echo $1 "$(ti display --start 'today 0:00' -f status | sed -r 's/^.{3}//')"
        fi
        sleep 10
    done
}

mypid=$$
pgrep "$(basename $0)" | grep -v $mypid | xargs kill >>~/log 2>&1

{update_cpuload 2 &
memory 3 &
update_network
update_battery 5 &
update_volume 6 &
update_time 7 &
watch_fume 1 &
# I like to have a space at the end
echo "1023  "} | dmplex
