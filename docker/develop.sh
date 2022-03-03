#!/bin/bash
set -eux

RUN_ARGS_INT="--tty --interactive"
RUN_ARGS_BG="--detach"
RUN_ARGS_EXTRA=""

if [ -f "./develop.env" ];
then
    source "./develop.env"
fi


docker build . --tag "$TAG" --tag "$TAG_LATEST"



if [ ! -d "${DATADIR_ON_HOST}" ];
then
    mkdir -p "${DATADIR_ON_HOST}"
fi
CONTAINER_ID=$( \
    docker run $RUN_ARGS_BG  \
        --mount type=bind,source="${DATADIR_ON_HOST}",target="${DATADIR_IN_CONTAINER}" \
        --env-file ./docker-dev.env \
        ${RUN_ARGS_EXTRA} \
        "${TAG_LATEST}" \
);

docker logs ${CONTAINER_ID}
 
docker exec ${RUN_ARGS_INT} ${CONTAINER_ID} /bin/bash - 
docker stop ${CONTAINER_ID}

docker images
docker ps -a


### TODO
# docker images | awk '{print $1 ":" $2}'| grep "pg-backup"  | xargs -n1 echo


