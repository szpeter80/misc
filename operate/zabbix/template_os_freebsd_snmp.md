FreeBSD by SNMP
===============

The functionality of this template was taken from the original "PFSense SNMP" template, with the intention to separate and add back the functionality removed by the commit 803ac56d41c at 2022-06-06 :

https://git.zabbix.com/projects/ZBX/repos/zabbix/commits/803ac56d41c956f4a95de36fce684433136cd0f1#ChangeLog.d/bugfix/ZBX-20628


This template is meant to co-exist with "PFSense by SNMP" to monitor the host OS parameters via SNMP. 

Tested on PFSense 2.6, but should work on lower versions as well, if the mibs are supported by the SNMP agent.
