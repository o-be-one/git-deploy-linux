#!/bin/bash

# Let the script know what is the internet interface
WANINT="eth0"
SSHPORT="22"

echo "Nettoyage des anciennes règles : OK"
iptables -t filter -F
iptables -t mangle -F
iptables -t nat -F

iptables -t filter -X
iptables -t mangle -X
iptables -t nat -X

echo "[IMPORTANT] Fermeture de tous les accés par défaut : OK"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

echo "[IMPORTANT] Autorisation des échanges locaux : OK"
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

echo "[IMPORTANT] Autorisation de la machine a aller sur internet : OK"
iptables -t filter -A OUTPUT -o $WANINT -m state ! --state INVALID -j ACCEPT
iptables -t filter -A INPUT -i $WANINT -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "Réponse aux requêtes de PING : OK"
iptables -A INPUT -p icmp -j ACCEPT

## Deprecated
#echo "[IMPORTANT] Ouverture du port SSH : OK"
#iptables -A INPUT -i $WANINT -p tcp --dport $SSHPORT -m state ! --state INVALID -j ACCEPT

# Fonction pour ouvrir les ports rapidement :
function openp() { # Ouvre un port pour tout le monde
iptables -A INPUT -i $WANINT -p $1 --dport $2 -m state ! --state INVALID -j ACCEPT
}
function openip() { # Ouvre un port a une IP
iptables -A INPUT -i $WANINT -p $1 -s $2 --dport $3 -m state ! --state INVALID -j ACCEPT
}

echo "Mise en place des autres règles : OK"

#########
# Define the following
#########

# Here some example. Please edit this !
openip tcp 88.167.18.222 $SSHPORT # open the port TCP defined in the beginning of the file SSHPORT to the ip 88.167.18.222
openp tcp 80 # open the port TCP 80 (http)
openp udp 27015 # open the port UDP 27015 (CS:GO for example)
openip tcp 88.167.18.222 3306 # open the port TCP 3306 for the ip 88.167.18.222 (mysql)

echo "Affichage des règles initialisés :"
iptables -L

echo "Le firewall est désormais initialisé :)."
