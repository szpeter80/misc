#!/bin/bash


echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Starting database maintenance ...";

mariadb-check \
    --defaults-file=${M_CNF_FILE} \
    --host=${MARIADB_HOSTNAME} \
    --port=${MARIADB_PORT} \
    --user=${MARIADB_USERNAME} \
    --silent --optimize --all-databases >/dev/null

echo -e "$(date "+%Y-%m-%d %H:%M:%S") Maintenance finished\n";

