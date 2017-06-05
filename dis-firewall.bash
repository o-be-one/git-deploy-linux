#!/usr/bin/env bash
# intented to open iptables

echo "[IMPORTANT] Ouverture de tous les accés par défaut : OK"
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

echo "Nettoyage des anciennes règles : OK"
iptables -t filter -F
iptables -t mangle -F
iptables -t nat -F

iptables -t filter -X
iptables -t mangle -X
iptables -t nat -X

echo -e "\n\n############## Affichage des règles initialisées :"
iptables -L

echo -e "\nLe firewall est OUVERT :)."
