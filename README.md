git-deploy-linux
================
Deploy your new Linux or update it.

**mep-git.sh**
--------------
mep-git.sh is the main script to deploy or update your linux server (Debian or Ubuntu) basics. You'll need to edit some variables before first start.

__Syntax :__ ./mep-git.sh

*What this script deploys actually :*
* .bashrc for all users, including welcome message, colors, historic
* .vimrc for all users, including syntax, no auto-indent paste, tab indent replaced by spaces. Available too in python dev edition
* atop with logrotate setup to register system stats every 5 minutes
* issue.net for your login prompt
* bug fix about the last important bash issue

This script will ask what to install/update.

### .bashrc

_.bashrc_ is your prompt command configuration. I've enhanced the historic time and space. It adds a welcome screen showing some useful informations about your server, some colors (folders, files) and a timestamp.
It will deploys to all users.

### .vimrc

_.vimrc_ will configure your vim. Syntax color, no more tab but 4 space instead, you can paste some code without the auto-indent inconvenient, etc.
Choose if your need a basic vim or an awesome vim useful to code in Python or other dev language.
It will deploys to all users.

### atop

_atop_ is awesome to monitore your server. Every 5 minutes, it will take a shot of your system stats. You'll be able to navigate in it very easily, like if it was in realtime.

__Syntax :__ atop -r ATOP_LOG_FILE -b hh:mm

### issue.net

_issue.net_ is just your login banner to warn user about their access.

### ddosCheck.bash

_ddosCheck.bash_ is a script to check if your server is under DDoS. The file just try to ping some ip or urls and if it meets the script configuration it considers there's a DDoS and start a tcpdump. This file will be really usefull for OVH VAC/DDoS team ! You'll have to add it in your crontab, each minutes will do the job perfectly.

### blacksync.bash

_blacksync.bash_ is an easy way to share your iptables script from a host to all your other hosts (named like this cause i use it for my iptables blacklists).

### firewall.bash

_firewall.bash_ is a basic iptables script that will close all ports and open ports you define.

### whitelist.bash

_whitelist.bash_ will help you to close your server to public and open it only to defined IPs.

### mysql-backup.bash

_mysql-backup.bash_ will do an export of your MySQL database and will compress it. To finish, it will delete old backups on the defined time in variables.

**License**
--------------
Please read and uderstand MIT Licence before use this script :

https://github.com/o-be-one/git-deploy-linux/blob/master/LICENSE
