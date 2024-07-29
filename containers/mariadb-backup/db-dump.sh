#!/bin/bash
#CRED_ARGS="--host=$PGBACKUP_HOSTNAME --port=$PGBACKUP_PORT --username=$PGBACKUP_USERNAME";
CMD_DATETIME_FN="date +%Y-%m-%d_%H-%M-%S"

echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Removing old dumps, retention is set to ${BACKUP_RETENTION_DAYS} days"
find ${DATA_DIR} -type f -mtime +${BACKUP_RETENTION_DAYS} -iname '*-sql.txt*' -exec echo '{}' \; -exec rm -f '{}' \;

echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Starting database dump...";
echo -e "\tBackup directory: ${DATA_DIR}\n";

for DB in $(mariadb --defaults-file=${M_CNF_FILE} --host=${MARIADB_HOSTNAME} --port=${MARIADB_PORT} --user=${MARIADB_USERNAME} -e 'show databases' -s --skip-column-names);
do
    [ "$DB" == "information_schema" ] && continue;
    [ "$DB" == "performance_schema" ] && continue;
    [ "$DB" == "staging" ] && continue;
    [ "$DB" == "mysql" ] && continue;
    [ "$DB" == "sys" ] && continue;

    echo -e "\t$(date "+%Y-%m-%d %H:%M:%S") Database: ${DB}"
    DUMP_FILE_TIMESTAMP=$(${CMD_DATETIME_FN})
    mariadb-dump \
        --defaults-file=${M_CNF_FILE} \
        --host=${MARIADB_HOSTNAME} \
        --port=${MARIADB_PORT} \
        --user=${MARIADB_USERNAME} \
        --complete-insert \
        --default-character-set=utf8 \
        --add-locks \
        --events \
        --add-drop-database \
        --add-drop-table \
        --databases $DB  | gzip > ${DATA_DIR}/$DUMP_FILE_TIMESTAMP-db-$DB-sql.txt.gz

done;

echo -e "$(date "+%Y-%m-%d %H:%M:%S") dumping finished\n";
