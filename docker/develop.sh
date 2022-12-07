#!/bin/bash
set -eu

RUN_ARGS_INT="--tty --interactive"
RUN_ARGS_BG="--detach"
RUN_ARGS_EXTRA=""

REMOTE_DOCKERUSER='foo'
REMOTE_DOCKERHOST='dummy'
REMOTE_DOCKERPORT='22'

if [ -f "./develop.env" ];
then
    # shellcheck disable=SC1091 # The env file is not traced
    source "./develop.env"
fi



# Purge dev images
if [[ $# -eq 1  && "$1" == "cleanup" ]]; then
    echo -e "\n\nCleaning up ALL unused images";
    yes | docker image prune --all

    echo -e "\n\nDocker images:\n"
    docker images
    echo -e "\n\nDocker containers:\n"
    docker ps -a

    exit 0
fi;


docker build . --tag "$TAG" --tag "$TAG_LATEST"


if [ ! -d "${DATADIR_ON_HOST}" ];
then
    mkdir -p "${DATADIR_ON_HOST}"
fi
CONTAINER_ID=$( \
    # shellcheck disable=SC2086 # Spaces should break up the ARGS string to multiple arguments
    docker run \
        $RUN_ARGS_BG \
        --mount type=bind,source="${DATADIR_ON_HOST}",target="${DATADIR_IN_CONTAINER}" \
        --env-file ./docker-dev.env \
        ${RUN_ARGS_EXTRA} \
        "${TAG_LATEST}" \
);

echo "Displaying logs ..."
docker logs "${CONTAINER_ID}"

echo "Executing shell ..."
# shellcheck disable=SC2086 # Spaces should break up the ARGS string to multiple arguments
docker exec ${RUN_ARGS_INT} "${CONTAINER_ID}" /bin/bash 
echo "Stopping container ..."
docker stop "${CONTAINER_ID}"


# Export the image
DOCKER_CMD="docker save ${TAG} | pv | ssh ${REMOTE_DOCKERUSER}@${REMOTE_DOCKERHOST} -p ${REMOTE_DOCKERPORT} ${REMOTE_DOCKERPATH} -D load;"
if [[ $# -eq 1  && "$1" == "export" ]]; then
    echo -e "\n\nExporting the image to remote host";
    # pipes are escaped by the shell and given args to the 1st program
    bash -c "${DOCKER_CMD}"
else
    echo -e "\n\nThe image can be exported by executing";
    echo -e "${DOCKER_CMD}";
fi;

echo -e "\n\n"
docker ps -a