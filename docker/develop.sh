#!/bin/bash

#############################################################################
#
# This script can be invoked from the docker project's directory 
# by calling '../develop.sh'. It will source './develop.env', if present.
# 
# Usage:
#
# Prune ALL images which has no containers, then exits (no build happens)
# ../develop.sh image-prune   
#
#
# Calling without parameters:
#
# ../develop.sh   
#
# It will try to:
# - build the image
# - run it in the background
# - display its logs (to see if it even starts)
# - execute a bash shell inside the container
# - stop the container
# 
#
# If it is called with the "transfer" parameter, it will do the build 
# just as without parameters, then it will upload the built image
# by ssh to the remote server's docker
# 
# ../develop.sh transfer   


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
if [[ $# -eq 1  && "$1" == "image-prune-all" ]]; then
    echo -e "\n\nCleaning up ALL unused images";
    yes | podman image prune --all

    echo -e "\n\Container images:\n"
    podman images
    echo -e "\n\nContainers:\n"
    podman ps -a

    exit 0
fi;

podman build . --tag "$TAG" --tag "$TAG_LATEST" | tee > last_build.log


if [ ! -d "${DATADIR_ON_HOST}" ];
then
    mkdir -p "${DATADIR_ON_HOST}"
fi
CONTAINER_ID=$( \
    # shellcheck disable=SC2086 # Spaces should break up the ARGS string to multiple arguments
    podman run \
        $RUN_ARGS_BG \
        --mount type=bind,source="${DATADIR_ON_HOST}",target="${DATADIR_IN_CONTAINER}" \
        --env-file ./container-dev.env \
        ${RUN_ARGS_EXTRA} \
        "${TAG_LATEST}" \
);

echo "Displaying logs ..."
podman logs "${CONTAINER_ID}"

echo "Executing shell ..."
# shellcheck disable=SC2086 # Spaces should break up the ARGS string to multiple arguments
podman exec ${RUN_ARGS_INT} "${CONTAINER_ID}" /bin/bash 
echo "Stopping container ..."
podman stop "${CONTAINER_ID}"


EXPORT_FN=$(echo "$TAG" | sed 's/\//_/g; s/\:/_/g')
echo -e "\n\nThe image created can be exported by executing this command:";
echo -e "podman save ${TAG} --output="${EXPORT_FN}.tar"";


# Transfer the image
TRANSFER_CMD="podman save ${TAG} | pv | ssh ${REMOTE_DOCKERUSER}@${REMOTE_DOCKERHOST} -p ${REMOTE_DOCKERPORT} ${REMOTE_DOCKERPATH} -D load;"

if [[ $# -eq 1  && "$1" == "transfer" ]]; then
    echo -e "\n\nTransferring the image to remote host";
    # pipes are escaped by the shell and given args to the 1st program
    bash -c "${TRANSFER_CMD}"
fi;

echo -e "\n\n"
podman ps -a