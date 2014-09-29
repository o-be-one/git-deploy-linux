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

**Licence**
--------------
Please read and uderstand MIT Licence before use this script :
https://github.com/o-be-one/git-deploy-linux/blob/master/LICENSE
