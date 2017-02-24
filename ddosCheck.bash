#! /bin/bash

############
# License : MIT
# Author : Meddy "o_be_one" Brai for OVH Anti-DDoS team (T : @o_b)
# Version : 1.2.2
# Date : 2015-11-12
# Goal : start a TCPDump if there is a DDoS
# HowTo : use it as root, edit vars, set cronjob
# Compatibility : Debian & Ubuntu ; not tested on others
# Exit codes :
#       1: you are not root
#       2: script is already running
#       3: tcpdump is not installed
#       4: Already did a tcpdump before the wait time (LASTTIME) defined in setup
############

### Setup (you can let it by default)
FILENAME="capture-ovh" # name of the file prefix. Suffix will be, by default, .DATE (here capture-ovh.2015-11-10)
TCPFOLDER="/root/ddos-attempt" # where to store TCPDump files
LASTTIME=10 # set time in minute to do a tcpdump after the last logged tcpdump
TRYSITE="google.com duckduckgo.com r0x.fr ovh.com" # domains to try (more you add, more time it takes to check ...)
COUNT=3 # number of pings to check each TRYSITE (useful to get relevant ping average)
LAT=150 # max latency before considering timeout
MAXFAIL=3 # number of fails before tcpdump (max number is the number of defined TRYSITE, by defaut 3)
DATE=$(date +'%y-%m-%d_%H-%M-%S') # date format for saved files
TCPCMD="/usr/sbin/tcpdump -w $TCPFOLDER/$FILENAME.$DATE -c 100000 port not ssh" # command to TCPDump (dont forget to keep $TCPFOLDER/$FILENAME.$DATE)

### Script, edit it at your own risks

# Colors
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtrst='\e[0m'    # Text Reset

# Message management (ok, warn, crit)
msg_warn() {

	WARNMSG="${txtylw}WARNING:${txtrst}"

	[[ $1 == "root" ]] && WARNMSG="$WARNMSG Please run this script as root."
	[[ $1 == "running" ]] && WARNMSG="$WARNMSG This script is already running on $RUNPID ..."
	[[ $1 == "no-tcpdump" ]] && WARNMSG="$WARNMSG Package tcpdump is not installed."
	[[ $1 == "shortlastrun" ]] && WARNMSG="$WARNMSG A TCPDUMP was already made before $LASTTIME minutes ago !"

	echo -e "\n$WARNMSG\n"

}

msg_crit() {

	CRITMSG="${txtred}CRITICAL:${txtrst}"

	[[ $1 == "no-tcpdump" ]] && CRITMSG="$CRITMSG You need tcpdump to run this script."

	echo -e "\n$CRITMSG\n"

}

msg_ok() {

	OKMSG="${txtgrn}OK:${txtrst}"

	[[ $1 == "no-ddos" ]] && OKMSG="$OKMSG The DDoS check has successfully ended with no DDoS detected."
	[[ $1 == "ddos-detected" ]] && OKMSG="$OKMSG DDoS detected ! Recording in $TCPFOLDER/$FILENAME.$DATE ..."

	echo -e "\n$OKMSG\n"

}

# init vars
failcount=0

# check if root
if [[ $EUID -ne 0 ]]; then
	msg_warn root
        exit 1
fi

# check if lock-file exists
if [ -e $TCPFOLDER/.ddosCheck.lck ]; then
        RUNPID=`cat $TCPFOLDER/.ddosCheck.lck`
	msg_warn running
        exit 2
fi

# check if tcpdump is installed
if ! command -v tcpdump >/dev/null 2>&1; then
	msg_warn no-tcpdump
	echo "Do you want to install it ? (works only with apt-get package manager) [Y/n]"
	read -r YESNO

	if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then
        	apt-get --force-yes --yes install tcpdump
	else
		msg_crit no-tcpdump
		exit 3
	fi

fi

# make the folder even if it already exists (cause no error)
mkdir -p $TCPFOLDER

# stop if we have a file before $LASTTIME defined
if test "`find $TCPFOLDER/$FILENAME* -mmin -$LASTTIME 2>/dev/null`"; then
	msg_warn shortlastrun
        exit 4
fi

# create lock-file
echo $$ > $TCPFOLDER/.ddosCheck.lck

# check pings for all TRYSITE
echo "Analysing, please be patient ..."
for myHost in $TRYSITE
do
        getping=$(ping -c $COUNT $myHost 2>/dev/null)
        pingreturn=$?
        count=$(echo "$getping" | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
        avglat=$(echo "$getping" | grep 'min/avg/max' | awk -F'/' '{ print $5 }')
        avglat=${avglat/.*}
        # check if host is known
        if [ $pingreturn -eq 2 ]; then
                let failcount++
        # check if ping timeout
        elif [ $count -eq 0 ]; then
                let failcount++
        # if no timeout, check latency
        elif [ $avglat -gt $LAT ]; then
                let failcount++
        fi
done

# start TCPCMD if we have more timeout than MAXFAIL
if [ $failcount -ge $MAXFAIL ]; then
	msg_ok ddos-detected
        $TCPCMD 2>/dev/null
fi

# remove lock-file when script is ended
rm $TCPFOLDER/.ddosCheck.lck

# tell that checked is done
msg_ok no-ddos
exit 0
