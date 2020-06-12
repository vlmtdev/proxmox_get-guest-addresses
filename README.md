# proxmox_get-guest-addresses
Scripts for retrieving all addresses from VM and LXC guests in Proxmox 
Output example:
```
TASK [debug] *********************************************************************************************
ok: [10.10.10.50] => {
    "ipreport.stdout_lines": [
        "vm 100 centos7-vm-tmpl-v1 notrunning",
        "vm 109 centos7-vm-tmpl-v2     127.0.0.1 10.20.30.11 172.17.0.1",
        "vm 300 synology agentnotfound",
        "lxc 101 centos7-cnt-tmpl lxc-attach: 101: attach.c: lxc_attach: 993 Failed to get init pid",
        "lxc 103 container1 10.20.30.13 172.17.0.1 ",
        "lxc 104 container2 10.20.30.15 172.17.0.1 ",
    ]
}
```
# How to use
Just execute playbook with inventory file argument, like this:
```
ansible-playbook -i inventory.yml -u root playbook.yml
```
*default proxmox user is root