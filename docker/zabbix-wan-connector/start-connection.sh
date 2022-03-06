#!/bin/bash

###
### Top-level script, executed to start all connections in the given dir
###
### Files processed:
###     connection.env         - variables definitions for this connection
###

CONN_NAME="Foo connection"
CONN_OVPN_CFG="./connection.ovpn"

if [ -f "./connection.env" ];
then
    # shellcheck source=/dev/null
    source ./connection.env
else 
    exit 0
fi;

echo -e "\t$CONN_NAME ($(pwd))"

if [ -f "${CONN_OVPN_CFG}" ]
then

    echo -e "\t\tOpenVPN instance"

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

fi;