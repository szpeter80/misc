#!/bin/bash
export PATH="${PATH}:${INSTALL_DIR}"

cd "${DATA_DIR}" || exit 1
if [ -f "./NO_PERMANENT_STORAGE" ];
then
    echo "You need to mount a permanent storage volume on \"${DATA_DIR}\" in order to avoid data loss"
    pwd
    ls -la .
    exit 1
fi


if [ ! -d "/dev/net" ];
then
    echo "Creating /dev/net"
    mkdir -p /dev/net
fi

if [ ! -f "/dev/net/tun" ];
then
    echo "Creating /dev/net/tun"
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

cd "${DATA_DIR}" || exit 1
for CONN in *; do
    if [ -d "./${CONN}" ];
    then
        cd "./${CONN}" && \
        pwd && \
        start-connection.sh && \
        cd ..
    fi
done;

# Nothing gonna stop me now .... 
tail -f /dev/null

