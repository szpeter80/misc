#!/bin/bash
# For manual debugging, not integrated with the container / build env


NC_CMD="nc -v -l -k -p ${2}"

case "$1" in

    'TCP')
        # TCP is the default, no action needed
    ;;

    'UDP')
        NC_CMD="${NC_CMD} -u"
    ;;

    *)
        echo "Error: invalid protocol"
        exit 1
    ;;
esac

NC_CMD="${NC_CMD} $3 $4"

while true;
do
    echo "NC connection parameters: proto=$1 lport=$2 dst=$3 dport=$4"
    ${NC_CMD}
    sleep 5
done;