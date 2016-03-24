#! /bin/bash

#########
# Author : Meddy "o_be_one" Brai
# Creation date : 31/07/2014
# Source : https://github.com/o-be-one/git-deploy-linux
#
# Goal : Deploy or update main configurations of a server running Linux Ubuntu or Debian.
# Syntax : ./mep-git.sh
#########

# Please edit following :

GITREPO="github.com/o-be-one/git-deploy-linux.git" # github repositery to use
GITSSH="git@github.com:o-be-one/git-deploy-linux.git" # adresse SSH du dépôt ?
TMPFOLDER="/tmp/mep-git" # temp folder wheres to work

######
# Edit who's following at your own risks !
######

DESTSCRIPT=`dirname $0`
SCRIPT=`basename $0`
. /lib/lsb/init-functions

# Is the script launched as root user ?
if [[ $EUID -ne 0 ]];
then

    log_daemon_msg "Please use this script as root." 1>&2
    log_end_msg 1
    echo
    exit 1

fi

clear
echo -e "Warning ! This script is for Debian and Ubuntu."
echo -e "Do you want to continue ? [y/N]"
read -r GOGO
echo

if [[ $GOGO =~ ^([yY][eE][sS]|[yY])$ ]]
then

    # What to do ? You can use 0 to 9, a to z and A to Z.
    echo -e "What to setup or update ? [all]"
    select UPDT in ".bashrc for all users" ".vimrc for all users" "atop monitoring (edit /etc/init.d/atop after)" "Login banner (you can edit /etc/issue.net after)" "all" ; do
    case $UPDT in
        ".bashrc for all users" ) UPDT=1 break ;;
        
        ".virmrc for all users" ) UPDT=2 break ;;
        
        "atop monitoring (edit /etc/init.d/atop after)" ) UPDT=3 break ;;
        
        "Login banner (you can edit /etc/issue.net after)" ) UPDT=4 break ;;
        
        "Bash Issue fix" ) UPTD=5 break ;;
        
        "ddosCheck script (you ll had to conf and add it in cron)" ) UPDT=6 break ;;
        
        "all" ) UPDT=all break ;;
    esac
 done
   
    # If nothing or all
    [[ -z $UPDT ]] || [ $UPDT == "all" ] && UPDT="0123456789abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
   
   
    # We have 2 version of .vimrc. Which one use ?
    if [[ $UPDT == *2* ]]
    then
   
        echo -e "What you'll do on this server ? [1]"
             select VIMRC in ".vimrc normal" ".virmrc phyton"; do
     case $VIMRC in
        ".vimrc normal" ) VIMRC=1
                     break ;;
        ".vimrc phyton" ) VIMRC=2
                      break ;;
    esac
 done
 
      
    fi
   
    # If temp folder doesn't exit, make parent dir.
   
    if [ ! -d $TMPFOLDER ]
    then
        mkdir -p $(dirname $TMPFOLDER)
    
    else
        # Delete the temp folder if it already exists.
        echo -e "\nThis folder already exists. Delete $TMPFOLDER ? [y/N]"
        read -r GOGO
        if [[ $GOGO =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            rm -rf $TMPFOLDER
        else
            echo
            log_daemon_msg "Maybe you need to edit this script ..."
            log_end_msg 1
            echo
            exit 1
        fi
    fi
    echo
    
    # Install git needed ?
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' git-core|grep "install ok installed")
    if [ "" == "$PKG_OK" ]; then
        log_warning_msg "git isn't installed. Starting installation ..."
        apt-get --force-yes --yes install git-core
    fi
   
    # Clone the repositery
    until [[ ! `git clone https://$GITREPO $TMPFOLDER 2>&1` == *failed* ]]
    do
   
        echo
        echo "Error ... Try with SSH (server SSH key must be on your GitHub account) ? [y/N]"
        read -r GOGO
      
        if [[ $GOGO =~ ^([yY][eE][sS]|[yY])$ ]]
        then
      
            git clone $GITSSH $TMPFOLDER
      
        fi
    done
   
        echo
   
    # Check updates
    diff --brief <(sort $TMPFOLDER/$SCRIPT) <(sort $DESTSCRIPT/$SCRIPT) >/dev/null
    comp_value=$?
 
    if [ $comp_value -eq 1 ]
    then
        echo -e "An update of this script is available. Update it ? [Y/n]"
        read -r GOGO
       
        if [[ ! $GOGO =~ ^([nN][oO]|[nN])$ ]]
        then
      
            cp $TMPFOLDER/$SCRIPT $DESTSCRIPT/$SCRIPT
            echo -e "\nUpdate finished. Can we delete folder $TMPFOLDER ? [Y/n]"
            read -r GOGO
            [[ ! $GOGO =~ ^([nN][oO]|[nN])$ ]] && rm -rf $TMPFOLDER
   
            $DESTSCRIPT/$SCRIPT && exit 0
            
      fi
      
   fi
   
    ##### Where to deploy files ?
    ## .bashrc
   if [[ $UPDT == *1* ]]; then
      # bc is used by my bashrc header ...
      PKG_OK=$(dpkg-query -W --showformat='${Status}\n' bc|grep "install ok installed")
      if [ "" == "$PKG_OK" ]; then
         log_warning_msg "bc isn't installed. Starting installation ..."
         apt-get --force-yes --yes install bc
      fi
      cp $TMPFOLDER/.bashrc /etc/skel
      cp $TMPFOLDER/.bashrc /root/
      for i in `ls /home/`; do cp $TMPFOLDER/.bashrc /home/$i; done
      source ~/.bashrc
      log_daemon_msg "bashrc update"
      log_end_msg 0
   fi
    ## .vimrc
   if [[ $UPDT == *2* ]]; then
      
      # Is vim installed ? Else install it !
      PKG_OK=$(dpkg-query -W --showformat='${Status}\n' vim|grep "install ok installed")
      if [ "" == "$PKG_OK" ]; then
         log_warning_msg "vim is not installed. Install is starting ..."
         apt-get --force-yes --yes install vim
      fi
      
      if [[ $VIMRC == "2" ]]
      then
      
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
         
      else
      
         cp $TMPFOLDER/.vimrc /etc/skel
         cp $TMPFOLDER/.vimrc /root/
         for i in `ls /home/`; do cp $TMPFOLDER/.vimrc /home/$i; done
      fi
      
      log_daemon_msg "vimrc update"
      log_end_msg 0
   fi
   ## atop
   # is atop installed ? If not, install it.
   if [[ $UPDT == *3* ]]; then
      PKG_OK=$(dpkg-query -W --showformat='${Status}\n' atop|grep "install ok installed")
      if [ "" == "$PKG_OK" ]; then
         log_warning_msg "atop is not installed. Install is starting ..."
         apt-get --force-yes --yes install atop
      fi
      cp $TMPFOLDER/atop /etc/logrotate.d/atop
      sed -i -e 's/600/300/g' /etc/init.d/atop
      log_daemon_msg "Installation and/or configuration ATOP"
      log_end_msg 0
   fi
    
   ## login banner
   if [[ $UPDT == *4* ]]; then
      cp $TMPFOLDER/issue.net /etc/issue.net
      sed -i -e 's/#Banner/Banner/g' /etc/ssh/sshd_config
      service ssh restart
      log_daemon_msg "Login banner update"
      log_end_msg 0
   fi
   
   ## Bash issue fix
   if [[ $UPDT == *5* ]]; then
      
      if [[ `env x='() { :;}; echo vulnerable' bash -c "echo this is a test" 2>/dev/null` == *vulnerable* ]]
      then
         apt-get --force-yes --yes install bash
         log_daemon_msg "Bash issue fixed"
         log_end_msg 0
      else
         log_daemon_msg "Bash issue is already fixed"
         log_end_msg 0
      fi
   
   fi
   
   ## ddosCheck
   if [[ $UPPDT == *6* ]]; then
      cp $TMPFOLDER/ddosCheck.bash /root/
      log_daemon_msg "ddosCheck.bash deployed in /root"
      log_end_msg 0
   fi
   #####
   echo -e "\nSetup complete. Can we delete the temp folder $TMPFOLDER ? [Y/n]"
   read -r GOGO
   [[ ! $GOGO =~ ^([nN][oO]|[nN])$ ]] && rm -rf $TMPFOLDER
   
   log_daemon_msg "System is deployed. See ya !"
   log_end_msg 0
   echo
   exit 0
else
   log_warning_msg "Nothing changed. Bye !"
   echo
   exit 0
fi
