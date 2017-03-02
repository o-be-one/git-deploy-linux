#! /bin/bash

#############################################
#
# Author: o_be_one for r0x.fr
# Goal: deploy things in a Linux system
# Error codes :
#		0: done
#		1: missing argument
#		2: temp folder issue
#		3: git not available
#
# Syntax: just call the script it will let you choose.
#
#############################################

### Please edit following

GITREPO="github.com/o-be-one/git-deploy-linux.git" # github repositery to use
GITSSH="git@github.com:o-be-one/git-deploy-linux.git" # adresse SSH du dépôt ?
TMPFOLDER="/tmp/mep-git" # temp folder wheres to work

### Edit following at your own risk

## Messages

# Colors
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtrst='\e[0m'    # Text Reset

# Message management (ok, warn, crit)
msg_warn() {

	WARNMSG="${txtylw}WARNING:${txtrst}"

	case $1 in

		root) WARNMSG="$WARNMSG Please run this script as root.";;
		apt) WARNMSG="$WARNMSG This script can install packages for you only on systems with apt-get installed.";;
		git) WARNMSG="$WARNMSG git is not installed.";;
		missing_pkg) WARNMSG="$WARNMSG package $2 is required but is missing ...";;
		*) WARNMSG="$WARNMSG ${@:1}";;

	esac

	echo -e "$WARNMSG"

}

msg_crit() {

	CRITMSG="${txtred}CRITICAL:${txtrst}"

	case $1 in

		tmpfolder) CRITMSG="$CRITMSG Change temp folder defined in the script or accept to delete it.";;
		git) CRITMSG="$CRITMSG `basename $0` requires git.";;
		*) CRITMSG="$CRITMSG ${@:1}";;

	esac

	echo -e "$CRITMSG"

}

msg_ok() {

	OKMSG="${txtgrn}OK:${txtrst}"

	case $1 in

		tmpfolder) OKMSG="$OKMSG Temp folder sucessfully created ($(dirname $TMPFOLDER)).";;
		bashrc) OKMSG="$OKMSG .bashrc deployed to whole system.";;
		vimrc) OKMSG="$OKMSG .vimrc deployed to whole system.";;
		atop) OKMSG="$OKMSG setup of atop donee";;
		loginbaner) OKMSG="$OKMSG setup of login banner done.";;
		*) OKMSG="$OKMSG ${@:1}";;

	esac

	echo -e "$OKMSG"

}

## root check
if [[ $EUID -ne 0 ]];
then

    msg_warn "root"
    exit 1

fi

## Vars init
SELECTION=
apt=1

## Main menu - support 1 to 9 and a to z
# check if apt-get exists, else warn that it will not autoinstall
! command -v apt-get >/dev/null 2>&1 && msg_warn apt && apt=0 || echo

# Menu
echo "What do you want to do today? [all]"
cat <<EOF
    1- push .bashrc to all users
    2- push .vimrc to all users
    3- install atop
    4- push the login banner
    5- update bash and ssh
    all- do everything
    0- exit
EOF

read -r SELECTION
echo

[[ $SELECTION == *0* ]] && exit 0

## do all options
# if no choice or all, select all possible options
[[ -z $SELECTION ]] || [ $SELECTION == "all" ] && SELECTION="0123456789abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

## Create folder if it doesnt exist, or ask to remove it
if [[ ! -d $TMPFOLDER ]]; then

	mkdir -p $(dirname $TMPFOLDER)

else

	# Delete the temp folder if it already exists.
	echo -e "\nThis folder already exists. Delete $TMPFOLDER ? [y/N]"
	read -r YESNO

	if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then

		rm -rf $TMPFOLDER

	else

		msg_crit tmpfolder
		exit 2

	fi

fi

## Install git if needed
if ! command -v git >/dev/null 2>&1; then

	msg_warn git
	echo "Do you want to install it ? (works only with apt-get package manager) [y/N]"
	read -r YESNO

	if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then
        	apt-get --force-yes --yes install git
	else
		msg_crit git
		exit 3
	fi


fi

## Git clone the repo
until [[ ! `git clone https://$GITREPO $TMPFOLDER 2>&1` == *failed* ]]; do

	echo
	echo "Error ... Try with SSH (public SSH key must be on an allowed GitHub account)? [y/N]"
	read -r YESNO

	if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then

		git clone $GITSSH $TMPFOLDER

	fi

done

## Check if there is an update of the script
if [[ -e $TMPFOLDER/`basename $0` ]]; then

	diff --brief <(sort $TMPFOLDER/`basename $0`) <(sort `dirname $0`/`basename $0`) >/dev/null
	comp_value=$?

	if [ $comp_value -eq 1 ]; then

		echo "An update of this script is available. Update it ? [Y/n]"
		read -r YESNO

		if [[ ! $YESNO =~ ^([nN][oO]|[nN])$ ]]; then

			cp $TMPFOLDER/`basename $0` `dirname $0`/`basename $0`
			echo -e "\nUpdate finished. Can we delete folder $TMPFOLDER (required)? [Y/n]"
			read -r YESNO

			[[ ! $YESNO =~ ^([nN][oO]|[nN])$ ]] && rm -rf $TMPFOLDER

			# not sure about this ...
		`	dirname $0`/`basename $0` && exit 0

		fi

	fi

fi

## function to install missing packages - $1 : package name.
require_pkg() {

    if ! command -v $1 >/dev/null; then

        msg_warn missing_pkg $1
        echo "Do you want to install $1 ? (works only with apt-get package manager) [y/N]"
        read -r YESNO

        if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get --force-yes --yes install $1
        fi

		echo "$1 will not be installed. This package is required so considere to install it ..."

    fi

}

## all functions about the menu starts here

setup_bashrc() {

	echo "Pushing .bashrc to all users ..."

	# required by my .bashrc file
	require_pkg "bc"
	require_pkg "toilet"

	# copy .bashrc to skel for new users
	cp $TMPFOLDER/.bashrc /etc/skel
	# copy .bashrc to for root
	cp $TMPFOLDER/.bashrc /root/
	# copy .bashrc to all existing users
	for i in `ls /home/`; do cp $TMPFOLDER/.bashrc /home/$i; done
	# load new .bashrc
	source ~/.bashrc

	msg_ok "bashrc"
	echo

}

setup_vimrc() {

	echo "Pushing .vimrc to all users ..."

	# checking if vim is installed
	require_pkg "vim"

	echo "Do you want to setup vim for python use? [y/N]"
	read -r YESNO

	if [[ $YESNO =~ ^([yY][eE][sS]|[yY])$ ]]; then

		# python vimrc
        apt-get --force-yes --yes install git pep8 exuberant-ctags
        easy_install -U pytest
        rm -rf ~/.vim
        git clone git://github.com/wjeanneau/dotvim.git ~/.vim
        rm -f ~/.vimrc
        ln -s ~/.vim/vimrc ~/.vimrc
        cp -rf ~/.vim /etc/skel
        cp /etc/skel/.vim/vimrc /etc/skel/.vimrc
        for i in `ls /home/`; do cp -rf ~/.vim /home/$i; done
        cd ~/.vim
        git submodule init
        git submodule update
        git submodule foreach git submodule init
        git submodule foreach git submodule update
        cd /etc/skel/.vim
        git submodule init
        git submodule update
        git submodule foreach git submodule init
        git submodule foreach git submodule update

        for i in `ls /home/`
	    do

        	cd /home/$i/.vim
        	git submodule init
        	git submodule update
			git submodule foreach git submodule init
			git submodule foreach git submodule update

		done

		cd $DESTSCRIPT

	else # normal vimrc

		cp $TMPFOLDER/.vimrc /etc/skel
		cp $TMPFOLDER/.vimrc /root/
		for i in `ls /home/`; do cp $TMPFOLDER/.vimrc /home/$i; done

	fi

	msg_ok "vim"
	echo

}

setup_atop() {

	echo "Setting atop ..."

	# checking if atop is installed
	require_pkg "atop"

	cp $TMPFOLDER/atop /etc/logrotate.d/atop
	sed -i -e 's/600/300/g' /etc/init.d/atop

	msg_ok "atop"
	echo

}

setup_loginbanner() {

	echo "Setting login banner ..."

	cp $TMPFOLDER/issue.net /etc/issue.net
	sed -i -e 's/#Banner/Banner/g' /etc/ssh/sshd_config
	service ssh restart

	msg_ok "loginbanner"

}

do_secupdates() {

	echo "Installing updates for OpenSSH server and bash ..."

	# TOFIX
	apt-get install openssh-server bash

	msg_ok "Updates installed."
	echo

}

# call function for each selection (don't name a function like a command ...)
[[ $SELECTION == *1* ]] && setup_bashrc
[[ $SELECTION == *2* ]] && setup_vimrc
[[ $SELECTION == *3* ]] && setup_atop
[[ $SELECTION == *4* ]] && setup_loginbanner
[[ $SELECTION == *5* ]] && do_secupdates

rm -rf $TMPFOLDER

exit 0
