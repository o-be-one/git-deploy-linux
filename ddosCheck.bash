#! /bin/bash

############
# License : MIT
# Author : Meddy "o_be_one" Brai for OVH (T : @o_b)
# Version : 0.1
# Date : 2015-11-10
# Goal : start a TCPDump if there is a DDoS
# HowTo : use it as root, edit vars, set cronjob
# Compatibility : Debian & Ubuntu ; not tested on others
############

### Setup (you can let it by default
FILENAME="capture-ovh" # name of the file prefix. Suffix will be, by default, .DATE (here capture-ovh.2015-11-10)
TCPFOLDER="/home/meddy/ddos-attempt" # where to store TCPDump files
LASTTIME=10 # set time in minute after the last tcpdump
TRYSITE="google.com duckduckgo.com r0x.fr" # domains to try
COUNT=3 # number of pings to check each TRYSITE
LAT=200 # max latency before considering
MAXFAIL=2 # number of fail before considering DDoS (regarding number of TRYSITE) ; here 2 timeout is enough to start tcpdump
MAXLAT=2 # number of more than LAT before considering DDoS (regarding number of TRYSITE) ; here 2 higher latency than LAT is enough to start tcpdump
DATE=$(date +'%y-%m-%d_%H-%M-%S') # date format for saved files
TCPCMD="tcpdump -w $TCPFOLDER/$FILENAME.$DATE -c 10 port not ssh" # command to TCPDump (dont forget to keep $TCPFOLDER/$FILENAME.$DATE)

### Script, edit it at your own risks
# load init functions
. /lib/lsb/init-functions

# init vars
failcount=0
latcount=0

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
                let latcount++
        fi
done

# start TCPCMD if we have more timeout than MAXFAIL or more lantecys than MAXLAT (depending on LAT)
if [ $failcount -ge $MAXFAIL -o $latcount -ge $MAXLAT ]; then
        $TCPCMD
fi
