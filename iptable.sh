#!/bin/sh
# simple information-fasting script
# blocks everything external, except during the free-for-all slot
# run as root (real)

# reset everything
iptables -P INPUT ACCEPT # -P:policy
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -F # -F:flush all chains
iptables -X # -X:delete all chains

# behave nicely, accept icmp
iptables -A INPUT -p icmp -j ACCEPT

# the chain that does not imprison, but free your mind
iptables -N open # -new-chain
iptables -A INPUT -j open # -append # jump open
iptables -A OUTPUT -j open

# accept all local traffic
iptables -A open -i lo -j ACCEPT
iptables -A open -s 127.0.0.1 -j ACCEPT

# allow everything within this limit
# iptables -A open -m time --timestart 12:00 --timestop 20:00 -j ACCEPT

# block the rest, in a not-so-rude way :)
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset 
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable 
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

iptables-save > /etc/iptables/iptables.rule
