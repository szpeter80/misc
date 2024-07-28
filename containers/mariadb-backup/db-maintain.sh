#!/bin/bash


echo -e "\n$(date "+%Y-%m-%d %H:%M:%S") Starting database maintenance ...";

mariadb-check --defaults-file=${M_CNF_FILE} --silent --optimize --all-databases -uroot >/dev/null

echo -e "$(date "+%Y-%m-%d %H:%M:%S") Maintenance finished\n";

