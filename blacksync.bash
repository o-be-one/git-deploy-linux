#! /bin/bash

######################
#
# Author : o_be_one for r0x.fr
# Licence : MIT
# Goal : synchronize iptables file and execute it on all selected nodes using ssh
# Usage : edit vars, chmox +x it, add locale pub key from the host to remote hosts, start it
#
######################

# Where is the iptables file to sync and exec
banlist="/root/banlist.fw"

# Defining remote hosts (if standart ssh port, write only hostname. If it's a custom ssh port, use host:port)
teamspeak="10.0.0.101"
bungee="10.0.0.102"
hh1="hh1.r0x.fr"
hh2="hh2.r0x.fr"
hh3="hh3.r0x.fr"
steam="steam.r0x.fr:31844"
ark="ark.r0x.fr"

# Sync and exec on these remote hosts
syncban="$teamspeak $bungee $hh1 $hh2 $hh3 $steam $ark"

# /!\ Edit following at your own risks /!\

echo
echo "##############################"
echo "### Sending iptables script and executing it on localhost and on following remote hosts :"
echo "### $syncban"
echo "##############################"
echo

# execute iptable script on localhost
$banlist
iptables-save

echo
echo "##############################"
echo "### localhost done !"
echo "##############################"
echo

# send and execute iptable script on defined remote hosts (in $syncban)
for i in $syncban; do

# if remote host var has a ":" to define port
        if [[ $i = *":"* ]]; then

                p=$(echo $i | cut -d':' -f2) # port
                i=$(echo $i | cut -d':' -f1) # ip

                scp -P $p $banlist root@$i:/root
                ssh -p $p root@$i "$banlist"
                ssh -p $p root@$i 'iptables-save'

# if remote host var is just a hostname 
        else

                scp $banlist root@$i:/root
                ssh root@$i "$banlist"
                ssh root@$i 'iptables-save'

        fi

        echo
        echo "##############################"
        echo "### $i done !"
        echo "##############################"
        echo

done

echo "##############################"
echo "### Iptables script sync and running on all hosts :)."
echo "##############################"
echo
