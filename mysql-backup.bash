#! /bin/bash

#============================#
# Author : o_be_one for r0x.fr
# What it does : create mysql backup folder, backup selected dbs, compress backups and delete old backups
# Howto : Edit vars, run in crontab each day (or 2 or 3 .. when you want your backup)
# Tested and working on : Ubuntu & Debian
# Licencing : MIT
#============================#

## Edit following :

DATE=$(date +'%y-%m-%d') # date format for saved files
BACKUPFOLDER="/backups/mysql" # where to keep backups ?
DBTOBACKUP="awesomedb mybestdb" # name of db to backup (separated by space)
MAXDAYS="15" # how mutch days we have to keep backups ?
PASSWD="MySQL_P@sSW0rD" # mysql password with read access to db you want to backup

## Edit following at your own risk /!\

echo "Backup in progress ..."

# loop to do all dbs
for i in $DBTOBACKUP; do
    echo
    echo "======================="
    echo ">> Doing $i ..."
    
    # make folder (no problem if it exists), dump db, compess db
    /bin/mkdir -p $BACKUPFOLDER/$i
    /usr/bin/mysqldump -u root -p$PASSWD $i > $BACKUPFOLDER/$i/${i}_$DATE.sql
    /bin/gzip $BACKUPFOLDER/$i/${i}_$DATE.sql

    # delete all found files after $MAXDAY
    /usr/bin/find $BACKUPFOLDER/$i -type f -mtime +$MAXDAYS -delete

    echo ">> Done in $BACKUPFOLDER/$i/${i}_$DATE.sql.gz"
    echo "======================="
done

echo
echo "Done."
