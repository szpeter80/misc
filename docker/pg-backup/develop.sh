#!/bin/bash
set -eux

DEV_TAG=$(date +"%Y%m%d_%H%M%S")
TAG="szpeter80/pg-backup:alpine--$DEV_TAG"
TAG_LATEST="szpeter80/pg-backup"
RUN_ARGS_INT="--tty --interactive"
RUN_ARGS_BG="--detach"

docker build . --tag "$TAG" --tag "$TAG_LATEST"


TMP_DATADIR="/tmp/pg-backup"
if [ ! -d "$TMP_DATADIR" ];
then
    mkdir -p "$TMP_DATADIR"
fi
CONTAINER_ID=$( \
    docker run "$RUN_ARGS_BG"  \
        --mount type=bind,source="$TMP_DATADIR",target="/mnt/postgres-backups" \
        --env-file ./develop.env \
        "$TAG_LATEST" \
);

docker exec -ti $CONTAINER_ID /bin/bash - 
docker stop $CONTAINER_ID
docker images
docker ps -a


### TODO
# docker images | awk '{print $1 ":" $2}'| grep "pg-backup"  | xargs -n1 echo


