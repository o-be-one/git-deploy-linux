#! /bin/bash

############
# License : MIT
# Author : Meddy "o_be_one" Brai for OVH Anti-DDoS team (T : @o_b)
# Version : 0.2
# Date : 2015-11-12
# Goal : start a TCPDump if there is a DDoS
# HowTo : use it as root, edit vars, set cronjob
# Compatibility : Debian & Ubuntu ; not tested on others
############

### Setup (you can let it by default)
FILENAME="capture-ovh" # name of the file prefix. Suffix will be, by default, .DATE (here capture-ovh.2015-11-10)
TCPFOLDER="/home/o_be_one/ddos-attempt" # where to store TCPDump files
LASTTIME=10 # set time in minute to tcpdump after the last tcpdump
TRYSITE="google.com duckduckgo.com r0x.fr ovh.com" # domains to try (more you add, more time it takes to check ...)
COUNT=3 # number of pings to check each TRYSITE (useful to get relevant ping average)
LAT=200 # max latency before considering timeout
MAXFAIL=3 # number of fails before tcpdump (max number is the number of defined TRYSITE, by defaut 4)
DATE=$(date +'%y-%m-%d_%H-%M-%S') # date format for saved files
TCPCMD="tcpdump -w $TCPFOLDER/$FILENAME.$DATE -c 100000 port not ssh" # command to TCPDump (dont forget to keep $TCPFOLDER/$FILENAME.$DATE)

### Script, edit it at your own risks
# load init functions
. /lib/lsb/init-functions

# init vars
failcount=0

# check if root
if [[ $EUID -ne 0 ]]; then
        log_daemon_msg "This script must be run as root" 1>&2
        log_end_msg 1
        exit 1
fi

# make the folder even if it already exists (cause no error)
mkdir -p $TCPFOLDER

# stop if we have a file before $LASTTIME defined
if test "`find $TCPFOLDER/$FILENAME* -mmin -$LASTTIME`"; then
        exit 0
fi

# check pings for all TRYSITE
for myHost in $TRYSITE
do
        getping=$(ping -c $COUNT $myHost)
        count=$(echo "$getping" | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
        avglat=$(echo "$getping" | grep 'rtt ' | awk -F'/' '{ print $5 }')
        avglat=${avglat/.*}
        # check if ping timeout
        if [ $count -eq 0 ]; then
                let failcount++
        # if no timeout, check latency
        elif [ $avglat -gt $LAT ]; then
                let failcount++
        fi
done

# start TCPCMD if we have more timeout than MAXFAIL
[[ $failcount -ge $MAXFAIL ]] && $TCPCMD
