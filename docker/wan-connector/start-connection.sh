#!/bin/bash

###
### Top-level script, executed to start all connections in the given dir
###
### Files processed:
###     connection.env         - variables definitions for this connection
###     port_forward_ovpn.txt  - ports to forward by netcat for OpenVPN 
###     port_forward_ssh.txt   - ports to forward by ssh 
###

CONN_NAME="Foo connection"
CONN_OVPN_CFG="./connection.ovpn"

if [ -f "./connection.env" ];
then
    # shellcheck source=/dev/null
    source ./connection.env
fi;

if [ -f "${CONN_OVPN_CFG}" ]
then

    echo "Starting $CONN_NAME - OpenVPN"

# --verb n        : Set output verbosity to n (default=1): 
#                   (Level 3 is recommended if you want a good summary 
#                   of what's happening without being swamped by output). 
#                 : 0 -- no output except fatal errors 
#                 : 1 -- startup info + connection initiated messages + 
#                        non-fatal encryption & net errors 
#                 : 2,3 -- show TLS negotiations & route info 
#                 : 4 -- show parameters 
#                 : 5 -- show 'RrWw' chars on console for each packet sent 
#                        and received from TCP/UDP (caps) or tun/tap (lc) 
#                 : 6 to 11 -- debug messages of increasing verbosity
    openvpn \
        --config "${CONN_OVPN_CFG}" \
        --daemon "${CONN_NAME} - OpenVPN"  \
        --log "./openvpn.log" \
        --writepid "./openvpn.pid" \
        --verb 3

    if [ -f "./port_forward_ovpn.txt" ]
    then
        grep -v '#' < ./port_forward_ovpn.txt | \
        while IFS=: read -r PROTO LOCAL_PORT REMOTE_HOST REMOTE_PORT; do
            start-netcat.sh \
                "${PROTO}" "${LOCAL_PORT}" "${REMOTE_HOST}" "${REMOTE_PORT}" \
                > "${PROTO}_${LOCAL_PORT}_${REMOTE_HOST}_${REMOTE_PORT}.log" \
                2>&1 &
        done 
    fi;
fi;