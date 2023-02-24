#!/bin/sh
set -e

date_backup=$(date +'%d_%h_%y_%H_%M')


if [ -z "$DBNAME" ]
then
    exec "$@"
else
    if [ "$DBNAME" == "ALL" ]
    then
        databases=`mysql --host=$HOST --port=$PORT -u $USER  -e "SHOW DATABASES;"`
        for db in $databases; do
            if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "sys" ]] && [[ "$db" != "Database" ]] && [[ "$db" != "xtrabackup_backupfiles" ]]; then
                    echo "verion modified bu fakhri ......."
                    echo "running mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $db > $db.sql"

                    mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u $USER $db > $db.sql.$date_backup
            fi
        done

    else
        echo "verion modified bu fakhri"
        echo "running mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u$USER -p$PASSWORD $DBNAME > $DBNAME.sql"

        exec mysqldump --max_allowed_packet=1073741824 --host $HOST --port $PORT -u $USER  $DBNAME > $DBNAME.sql.$date_backup
        echo "done"
    fi
fi
MAXBACKUPS=10
echo $MAXBACKUPS
TOTBACKUPS=`ls -l *.sql*  | wc -l`
echo $TOTBACKUPS
if [ $TOTBACKUPS > $MAXBACKUPS ]
then
   TBREMOVED=$(( $TOTBACKUPS - $MAXBACKUPS ))
   echo $TBREMOVED
   REMLIST=`ls -ctr *.sql.*  | head -n ${TBREMOVED}`
   for i in $REMLIST
   do
      echo "remove file : $i"
      rm -rf $i
       
   done
fi
