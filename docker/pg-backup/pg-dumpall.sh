#!/bin/bash
CRED_ARGS="--host=$PGBACKUP_HOSTNAME --port=$PGBACKUP_PORT --username=$PGBACKUP_USERNAME";
#CMD_DATE="date +%Y-%m-%d"
CMD_DATETIME_FN="date +%Y-%m-%d_%H-%M-%S"

echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Starting database maintenance ...";

# https://www.postgresql.org/docs/current/app-vacuumdb.html
echo "$(date "+%Y-%m-%d %H:%M:%S") Vacuuming ...";
vacuumdb ${CRED_ARGS} --all --full --quiet --analyze

DUMP_FN=${DATA_DIR}/$(${CMD_DATETIME_FN})-globals-sql.txt
echo "$(date "+%Y-%m-%d %H:%M:%S") Dumping global objects to ${DUMP_FN} ...";
pg_dumpall ${CRED_ARGS} --clean --if-exists --globals-only > ${DUMP_FN}

echo -e "$(date "+%Y-%m-%d %H:%M:%S") Maintenance finished\n";

