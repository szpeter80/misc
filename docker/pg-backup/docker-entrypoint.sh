#!/bin/bash

cd "${DATA_DIR}"
if [ -f "./NO_PERMANENT_STORAGE" ];
then
    echo "You need to mount a permanent storage volume on "${DATA_DIR}" in order to avoid data loss"
    pwd
    ls -la .
    exit 1
fi


cp "${INSTALL_DIR}/pgpass.txt.example" $PGPASSFILE
echo "$PGBACKUP_HOSTNAME:$PGBACKUP_PORT:$PGBACKUP_DATABASE:$PGBACKUP_USERNAME:$PGBACKUP_PASSWORD" >>  $PGPASSFILE
chmod 600 $PGPASSFILE

### # crond --help                                                                                                                       
### BusyBox v1.32.1 () multi-call binary.                                                                                                                       
###                                                                                                                                                             
### Usage: crond -fbS -l N -d N -L LOGFILE -c DIR                                                                                                               
###                                                                                                                                                             
###         -f      Foreground                                                                                                                                  
###         -b      Background (default)                                                                                                                        
###         -S      Log to syslog (default)                                                                                                                     
###         -l N    Set log level. Most verbose 0, default 8                                                                                                    
###         -d N    Set log level, log to stderr                                                                                                                
###         -L FILE Log to FILE                                                                                                                                 
###         -c DIR  Cron dir. Default:/var/spool/cron/crontabs

crond -f -l 8 -d 8 -L /dev/stdout
