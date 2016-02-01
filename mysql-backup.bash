#! /bin/bash

#============================#
# Author : o_be_one for r0x.fr
# What it does : create mysql backup folder, backup selected dbs, compress backups and delete old backups
# Howto : Edit vars, run in crontab each day (or 2 or 3 .. when you want your backup)
# Tested and working on : Ubuntu & Debian
# Licencing : MIT
#============================#

DATE=$(date +'%y-%m-%d') # date format for saved files
BACKUPFOLDER="/backups/mysql" # where to keep backups ?
DBTOBACKUP="awesomedb mybestdb" # name of db to backup (separated by space)
MAXDAYS="15" # how mutch days we have to keep backups ?
PASSWD="MySQL_P@sSW0rD" # mysql password with read access to db you want to backup

echo "Backup in progress ..."

for i in $DBTOBACKUP; do
    echo
    echo "======================="
    echo ">> Doing $i ..."
    
    /bin/mkdir -p $BACKUPFOLDER/$i
    /usr/bin/mysqldump -u root -p$PASSWD $i > $BACKUPFOLDER/$i/${i}_$DATE.sql
    /bin/gzip $BACKUPFOLDER/$i/${i}_$DATE.sql

    /usr/bin/find $BACKUPFOLDER/$i -type f -mtime +$MAXDAYS -delete

    echo ">> Done in $BACKUPFOLDER/$i/${i}_$DATE.sql.gz"
    echo "======================="
done

echo
echo "Done."
