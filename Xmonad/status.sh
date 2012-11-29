#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

# Shows some nice status bar.

# global variables
hostname=$(hostname)
#fumetrap_db=$(ruby -ryaml << EOF
#c = YAML.load_file(File.join(ENV['HOME'], '.fumetrap.yml'))
#puts c['database_file']
#EOF
#)
export last_mod_time=0

# processes with >= 30% cpu load
cpu_hogs() {
  ps -eo pcpu,ucmd --sort -pcpu | grep -vP "migration/\d+" | tail -n +2 | while read proc
  do
if [[ $proc[(w)1] -ge 30.0 ]] then
echo -n " $proc[(w)1] ${${proc[(w)2]}[1,10]}"
    fi
done
}

status() {
  # widgets are output in order
  integer dzen_number=200

  # processes with >= 50% cpu load
  echo "$dzen_number P$(cpu_hogs)"
  dzen_number+=1

  # laptop specific
#  if [[ $hostname == "nyarlathotep" || $hostname == "typhus" ]] then
    # battery status
    echo "$dzen_number B ${$(acpi)[(w)3,-1]}"
    dzen_number+=1
#  fi

  # current load
  load=($(cat /proc/loadavg))
  echo "$dzen_number L $load[1,3]"
  dzen_number+=1
  
  # memory usage
  mem=(${$(free -m | grep "Mem:")[2,7]})
  printf "$dzen_number M %4d\n" $(($mem[2] - $mem[5] - $mem[6]))
  dzen_number+=1

  # volume
  mixer="Master"
  echo "$dzen_number V $(amixer get $mixer | grep -oP '\d+%' | tail -1)"
  dzen_number+=1

  # current date
#  us_time=$(TZ="America/Los_Angeles" date "+%H時")
  local_time=$(date)
  echo "$dzen_number $local_time"
  Dzen_number+=1
}


if [[ $1 != "debug" ]]; then
while true
do
    { status; sleep 0.9s } &
    wait
done | dmplex
else
status | dmplex
fi
