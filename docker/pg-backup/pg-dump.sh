#!/bin/bash
CRED_ARGS="--host=$PGBACKUP_HOSTNAME --port=$PGBACKUP_PORT --username=$PGBACKUP_USERNAME";
#CMD_DATE="date +%Y-%m-%d"
CMD_DATETIME_FN="date +%Y-%m-%d_%H-%M-%S"

echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Removing old dumps, retention is set to ${PGBACKUP_RETENTION_DAYS} days"
find ${DATA_DIR} -type f -mtime +${PGBACKUP_RETENTION_DAYS} -iname '*-sql.txt*' -exec echo '{}' \; -exec rm -f '{}' \;

echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Starting database dump...";
echo -e "\tBackup directory: ${DATA_DIR}\n";

for DB in $(psql ${CRED_ARGS} --tuples-only --no-align --command "SELECT datname FROM pg_database WHERE datname <> ALL ('{template0,template1,postgres}')"); do
    [ "$DB" == "postgres" ] && continue;
    [ "$DB" == "template0" ] && continue;
    [ "$DB" == "template1" ] && continue;

    echo -e "\t$(date "+%Y-%m-%d %H:%M:%S") Database: ${DB}"
    DUMP_FILE_TIMESTAMP=$(${CMD_DATETIME_FN})
    pg_dump ${CRED_ARGS} --clean --if-exists --create --dbname=$DB | gzip > ${DATA_DIR}/$DUMP_FILE_TIMESTAMP-db-$DB-sql.txt.gz

done;

echo -e "$(date "+%Y-%m-%d %H:%M:%S") dumping finished\n";

