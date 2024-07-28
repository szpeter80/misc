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

echo -e "\nStarting connections:" && \
cd "${DATA_DIR}" || exit 1
for CONN in *; do
    if [ -d "./${CONN}" ];
    then
        cd "./${CONN}" && \
        start-connection.sh && \
        cd ..
    fi
done;

#tail -f /dev/null

if [ ! -d "${DATA_DIR}/zabbix-proxy/ssh_keys" ]
then
    mkdir -p "${DATA_DIR}/zabbix-proxy/ssh_keys"
fi;

if [ ! -f "${DATA_DIR}/zabbix-proxy/zabbix-proxy.db" ]
then
    echo "Creating Zabbix proxy database ..."
    sqlite3 "${DATA_DIR}/zabbix-proxy/zabbix-proxy.db" \
    < /usr/share/doc/zabbix-sql-scripts/sqlite3/proxy.sql
fi;

X_CFG="${DATA_DIR}/zabbix-proxy/zabbix-proxy.cfg"
{
    echo "Hostname=${ZBX_HOSTNAME}"
    echo "DBName=${DATA_DIR}/zabbix-proxy/zabbix-proxy.db"
    echo "LogType=console"
    echo "DebugLevel=${ZBX_DEBUGLEVEL}"
    echo "EnableRemoteCommands=${ZBX_ENABLEREMOTECOMMANDS}"
    echo "LogRemoteCommands=${ZBX_LOGREMOTECOMMANDS}"
    echo "AllowRoot=1"
    echo "Timeout=${ZBX_TIMEOUT}"
    echo "FpingLocation=/usr/bin/fping"

    # 0 - active mode, 1 - passive mode
    echo "ProxyMode=${ZBX_PROXYMODE}"
    # In active mode this can contain a port number is (ServerPort is deprecated)
    # In passive mode including a port number produces an error
    echo "Server=${ZBX_SERVER_HOST}"

    # For passive mode proxies, these are ignored
    echo "ProxyConfigFrequency=${ZBX_PROXYCONFIGFREQUENCY}"
    echo "DataSenderFrequency=${ZBX_DATASENDERFREQUENCY}"

    # Location of ssh keys used to execute the checks
    echo "SSHKeyLocation=${DATA_DIR}/zabbix-proxy/ssh_keys"
 
    # Stats request accepted from here, can be Zabbix server DNS name also
    echo "StatsAllowedIP=${ZBX_STATSALLOWEDIP}"
} > "${X_CFG}"

# Set this if you need to specify outgoing source address
if [ -n "$ZBX_SOURCEIP" ]
then
    echo "SourceIP=${ZBX_SOURCEIP}" >> "${X_CFG}"
fi

echo "Starting Zabbix proxy: $(zabbix_proxy -V)"
zabbix_proxy --foreground --config "${X_CFG}"
