Check OpenWRT by SSH
====================

The ```template_os_openwrt_ssh.yaml``` file is actually
a collection of dependent templates to monitor an OpenWRT host
by an SSH connection.

- **Check OpenWRT by SSH**  
Main template. It is enough to associate only this template with the host,
the rest of the templates will be pulled as dependency.
No or very little functionality is in this template. If you don't need everything, you can pull the dependent templates manually.  
The functionality was broken up, so their collector scripts can be
independently scheduled to run more frequently if you need faster data,
or run infrequently if you are on tight resources or your environment does not change much.

    - **Check OpenWRT network by SSH** 
    Network interface checks (eg. traffic on WAN)
    
    - **Check OpenWRT resources by SSH**
    Basic resource checks (free ram, cpu load, uptime and reboot warning etc)
    
    - **Check OpenWRT upgrades by SSH** 
    Check for package updates or image updates. For image updates check to work, you need to install the Attended SysUpgrade (ASU) package,
package checks are done by using OPKG and does not require additional software

Setup
-----


  1. import the templates
  1. setup a shared key for passwordless login
  1. test your passwordless login
  1. add the key files and config to the host
  1. enjoy :) 




