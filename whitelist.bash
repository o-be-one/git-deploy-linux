#! /bin/bash

############################
# Author : o_be_one for mcTrophy
# Creation date : 2016-03-30
# Goal : whitelist your server : block everything and allow only ip you want for in or out. Care it will flush all existing iptables rules !
# HowTo : edit the end of the file and start the script
############################

# Flush existing rules
iptables -F

# Set up default DROP rule for eth0
iptables -P OUTPUT DROP
iptables -P INPUT DROP

# Allow existing connections to continue
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow remote ip to contact the server

inip() { # allow remote ip to contact this server
    iptables -A INPUT -i eth0 -s $1 -j ACCEPT
}

# Allow this host to connect defined remote ip

outip() { # allow this server to send requests to defined ip
    iptables -A OUTPUT -o eth0 -d $1 -j ACCEPT
}

outiprelated() { # allow this server to only answer to requests from defined ips
    iptables -A OUTPUT -o eth0 -d $1 -m state --state ESTABLISHED,RELATED -j ACCEPT
}

######
# Define your rules !
######

inip 8.33.12.224 # allow this ip to contact the server
outiprelated 8.33.12.224 # allow the server to answer to the ip (only answer, server couldn't contact ip)
inip 88.182.212.10 # allow this ip to contact the server
outip 88.182.212.10 # allow the server to contact the ip
