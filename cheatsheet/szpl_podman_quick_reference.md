# Podman Quick Reference

This is for Podman 5 on RHEL (Rocky / Alma / Oracle) 9

---
## 01 | Podman commands

- **podman network inspect podman**  
Inspect the default network.
By default there is no name resolution on the default network.

- **podman port my-container**  
Show exposed ports for the given container

- **podman port --all**  
Show exposed ports for all containers


---
## xx | Rootless Podman

Original sources:  
<https://www.it-hure.de/2024/02/podman-compose-and-systemd/>  
<https://www.christiansaga.de/howto/2024/04/17/switching-from-docker-to-podman.html>  
<https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md>  
<https://news.ycombinator.com/item?id=38982805>  

By default, non-root rules are very strict. You can relax some with sysctl's:

```
# vi /etc/sysctl.d/podman-settings.conf
net.ipv4.ip_unprivileged_port_start=0
net.ipv4.ping_group_range=0 429296729
```

Podman can have default settings, eg for setting `net.ipv4.ping_group_range=0 0` directly in `/usr/share/containers/containers.conf`, `/etc/containers/containers.conf` or `~/.config/containers/containers.conf`

You need a directory with podman-compose.yaml.  
This directory name will be your project's name, eg `myproject`

You need to execute podman commands from this project directory (podman-compose lives in EPEL).

`podman compose down`  
`loginctl enable-linger USERNAME`  
`sudo podman-compose systemd -a create-unit`  

The `--in-pod pod_%i` could be missing, and you can add `podman rm` for stopping

`sudo vi /etc/systemd/user/podman-compose@.service`

```
ExecStartPre=-/usr/bin/podman-compose --in-pod pod_%i up --no-start
...
# ExecStopPost=/usr/bin/podman pod rm pod_%i
```

`podman compose systemd`  
`podman compose down`  
`systemctl --user enable --now 'podman-compose@myproject'`  
`systemctl --user status 'podman-compose@myproject'`
                                                                  
This is echoed by podman, but does not work:  
`journalctl --user -xeu 'podman-compose@myproject'`       

This worked for me:  
`journalctl  -xe --user-unit 'podman-compose@myproject'`
