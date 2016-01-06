#! /bin/bash

############
# License : MIT
# Author : Meddy "o_be_one" Brai for OVH Anti-DDoS team (T : @o_b)
# Version : 1.2.2
# Date : 2015-11-12
# Goal : start a TCPDump if there is a DDoS
# HowTo : use it as root, edit vars, set cronjob
# Compatibility : CentOS
############

### Setup (you can let it by default)
FILENAME="capture-ovh" # name of the file prefix. Suffix will be, by default, .DATE (here capture-ovh.2015-11-10)
TCPFOLDER="/root/ddos-attempt" # where to store TCPDump files
LASTTIME=10 # set time in minute to tcpdump after the last tcpdump
TRYSITE="google.com duckduckgo.com r0x.fr ovh.com" # domains to try (more you add, more time it takes to check ...)
COUNT=3 # number of pings to check each TRYSITE (useful to get relevant ping average)
LAT=150 # max latency before considering timeout
MAXFAIL=3 # number of fails before tcpdump (max number is the number of defined TRYSITE, by defaut 3)
DATE=$(date +'%y-%m-%d_%H-%M-%S') # date format for saved files
TCPCMD="/usr/sbin/tcpdump -w $TCPFOLDER/$FILENAME.$DATE -c 100000 port not ssh" # command to TCPDump (dont forget to keep $TCPFOLDER/$FILENAME.$DATE)

### Script, edit it at your own risks
# init vars
failcount=0

# colors
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtrst='\e[0m'    # Text Reset

log_daemon_msg() {

        daemon_msg="$1"

}

log_warning_msg() {

        echo -e "${txtylw}$1${txtrst}"

}

log_end_msg() {

        [[ $1 == 0 ]] && echo -e "${txtgrn}$daemon_msg"
        [[ $1 == 1 ]] && echo -e "${txtred}$daemon_msg"
        [[ $1 == 2 ]] && echo -e "${txtylw}$daemon_msg"
        [[ $1 == 3 ]] && echo -e "${txtylw}$daemon_msg"

        echo -e $txtrst

}

# check if root
if [[ $EUID -ne 0 ]]; then
        log_daemon_msg "This script must be run as root"
        log_end_msg 1
        exit 1
fi


# make the folder even if it already exists (cause no error)
mkdir -p $TCPFOLDER

# stop if we have a file before $LASTTIME defined
if test "`find $TCPFOLDER/$FILENAME* -mmin -$LASTTIME 2>/dev/null`"; then
        log_daemon_msg "A TCPDUMP was already made before $LASTTIME minutes ago"
        log_end_msg 3
        exit 3
fi

# create lock-file
echo $$ > $TCPFOLDER/.ddosCheck.lck

# check pings for all TRYSITE
for myHost in $TRYSITE
do
        log_warning_msg "Checking ping to $myHost ..."
        getping=$(ping -c $COUNT $myHost 2>/dev/null)
        pingreturn=$?
        count=$(echo "$getping" | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
        avglat=$(echo "$getping" | grep 'rtt ' | awk -F'/' '{ print $5 }')
        avglat=${avglat/.*}
        # check if host is known
        if [ $pingreturn -eq 2 ]; then
                let failcount++
                log_daemon_msg "Host not known."
                log_end_msg 1
        # check if ping timeout
        elif [ $count -eq 0 ]; then
                let failcount++
                log_daemon_msg "Host timeout."
                log_end_msg 1
        # if no timeout, check latency
        elif [ $avglat -gt $LAT ]; then
                let failcount++
                log_daemon_msg "Host ping >$LAT."
                log_end_msg 1
        else
                log_daemon_msg "OK"
                log_end_msg 0
        fi
done

# start TCPCMD if we have more timeout than MAXFAIL
if [ $failcount -ge $MAXFAIL ]; then
        log_warning_msg "DDoS detected ! Recording in $TCPFOLDER/$FILENAME.$DATE"
        $TCPCMD 2>/dev/null
fi

# remove lock-file when script is ended
rm $TCPFOLDER/.ddosCheck.lck

# tell that checked is done
log_daemon_msg "The DDoS check has successfully ended"
log_end_msg 0
exit 0
