# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+:}ignoredups
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth
# History lengh
HISTSIZE=10000
# History timestamp
HISTTIMEFORMAT="%Y-%m-%d @ %T - "

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# defining some colors (uppercase = light)
red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
green='\e[0;32m'
GREEN='\e[1;32m'
yellow='\e[0;33m'
YELLOW='\e[1;33m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
purple='\e[0;35m'
PURPLE='\e[1;35m'
gray='\e[0;37m'
GRAY='\e[1;30m'
black='\e[0;30m'
WHITE='\e[1;37m'
NC='\e[0m'

spin ()
{
echo -ne "${RED}-"
echo -ne "${WHITE}\b|"
echo -ne "${BLUE}\bx"
echo -ne "${RED}\b+${NC}"
}

#function my_ip() # Get IP adress on ethernet.
#{
#    MY_IP=$(/sbin/ifconfig eth0 | awk '/inet/ { print $2 } ' |
#      sed -e s/addr://)
#    echo ${MY_IP:-"Not connected"}
#}

clear
cores=$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
[ "$cores" -eq "0" ] && cores=1
threshold="${cores:-1}.0"
if [ $(echo "`cut -f1 -d ' ' /proc/loadavg` < $threshold" | bc) -eq 1 ]; then

    for i in `seq 1 15` ; do spin; done ;echo -ne "${WHITE} ! Serveur r0x.fr (${PURPLE}${HOSTNAME%%.*}${WHITE}) ! ${NC}"; for i in `seq 1 15` ; do spin; done ;echo -e "\n";
    echo -e "${BLUE}Linux : "`cat /etc/issue | grep Debian | awk '{print $1,$2,$3}'` ;
    echo -e "Kernel : "`uname -smr`; echo "";
    echo -ne "Votre dernier login :\n  ${YELLOW}`lastlog | grep $USER | awk '{print $4" "$6" "$5" "$9}'`${BLUE},${YELLOW} `lastlog | grep $USER | awk '{print $7}'`\n  ${YELLOW}`lastlog | grep $USER | awk '{print $3}'`${BLUE}\n";
    echo -ne "\nBienvenue ${RED}$USER${BLUE}, nous sommes le "; date  +%A" "%d" "%B" et il est "%H"h"%M"."; echo "";
    echo -ne "${BLUE}Serveur en ligne depuis ";uptime | awk /'up/ {gsub(",",""); print $3,"jours."}'; echo "";
#   echo -ne "Load : "; cat /proc/loadavg | awk '{print $1,$2,$3}';
#   echo -ne "${BLUE}Adresse IP locale : "; my_ip; echo "";
    echo -ne "Informations techniques : ${YELLOW}\n";
    /usr/bin/landscape-sysinfo | head -n -2; echo -ne "${NC}";
    if [ -x /usr/lib/update-notifier/update-motd-updates-available ]; then
        /usr/lib/update-notifier/update-motd-updates-available | head -n -1;
    fi
    if [ -x /usr/lib/ubuntu-release-upgrader/release-upgrade-motd ]; then
        /usr/lib/ubuntu-release-upgrader/release-upgrade-motd;
    fi
    if [ -x /usr/lib/update-notifier/update-motd-reboot-required ]; then
        /usr/lib/update-notifier/update-motd-reboot-required;
    fi
    for i in `seq 1 15` ; do spin; done ;echo -ne "${WHITE} http://r0x.fr/ ${NC}"; for i in `seq 1 15` ; do spin; done ;echo "";
    
    else
    echo
    echo " System information disabled due to load higher than $threshold"
fi
echo ""; echo ""

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Promp design
if [ "$color_prompt" = yes ]; then
    if [[ ${USER} != "root" ]]; then
        export PS1="[\t] ${debian_chroot:+($debian_chroot)}\[${GREEN}\]\u\[${NC}\]@\[${GREEN}\]\h\[${NC}\]:\[${BLUE}\]\w\[${NC}\]\\$ "
    else
        export PS1="[\t] ${debian_chroot:+($debian_chroot)}\[${RED}\]\u\[${NC}\]@\[${RED}\]\h\[${NC}\]:\[${BLUE}\]\w\[${NC}\]\\$ "
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
#alias l='ls -CF'
alias clean='sudo apt-get autoclean && sudo apt-get autoremove && sudo deborphan -Z && sudo apt-get clean'

# secured commands (not stored in history)
alias reboot=' reboot'
alias halt=' halt'

# Add an "alert" alias for long running commands.  Use like so:                 
#   sleep 10; alert                                                             
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
