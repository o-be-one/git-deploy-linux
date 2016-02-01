#! /bin/bash

#=======================#
# Author : o_be_one for r0x.fr
# Usage : edit vars, add the script ton contrab each days you want to run it (1 day, 3 days, etc.)
# Tested&Work : Ubuntu & Debian
#=======================#

DATE=$(date +'%y-%m-%d') # date format for saved files
BACKUPFOLDER="/backups/mysql" # where to keep backups ?
DBTOBACKUP="mydb1 my_database_2" # name of dbs to backup (separated by space)
MAXDAYS="15" # how mutch days we have to keep backups ?

echo "Backup in progress ..."

for i in $DBTOBACKUP; do
    echo
    echo "======================="
    echo ">> Doing $i ..."

    /bin/mkdir -p $BACKUPFOLDER/$i
    /usr/bin/mysqldump -u root -pLap1nUX $i > $BACKUPFOLDER/$i/${i}_$DATE.sql
    /bin/gzip $BACKUPFOLDER/$i/${i}_$DATE.sql

    /usr/bin/find $BACKUPFOLDER/$i -type f -mtime +$MAXDAYS -delete

    echo ">> Done in $BACKUPFOLDER/$i/${i}_$DATE.sql.gz"
    echo "======================="
done

echo
echo "Done."
