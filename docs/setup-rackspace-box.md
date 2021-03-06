Setup the SAK Server Box on Rackspace
=====================================

Ubuntu
------
Using Ubuntu 10.04 LTS

After starting the box on Rackspace, get the IP address and put it into the A
record on the zone file for kristo.us at DynDNS. Then put the new root password
and IP address into the Rackspace entries in KeePassX.

Login as root using the big password issued by Rackspace when the machine was created.

    ssh root@saks.fireworksproject.com

Users
-----
Then, while still logged in as root, create a named user and a git user.  Use
KeePass to generate the password and save it.

    adduser fwpusers
    adduser git

Add the named user to the sudo group.

    adduser fwpusers sudo

SSH
---
Lockdown SSH. Edit the `/etc/ssh/sshd_config` file with

    Port 2575
    PermitRootLogin no
    AllowUsers git fwpusers

Restart the server, then back on the local box (the development VM); add the
SSH keys. But, check the local .ssh/conf first to make sure entries exist for
these users on the saks.fireworksproject.com domain.

    ssh-copy-id fwpusers@saks.fireworksproject.com
    ssh-copy-id git@saks.fireworksproject.com

General Setup
-------------
Follow the instructions in `docs/setup.md` to complete the setup process.

Snapshot Image
--------------
Run the general setup instructions in `/docs/setup.md` and check to make sure
the users can login (except the root user), then
[create an image](http://www.rackspace.com/knowledge_center/index.php/Creating_a_Cloud_Server_from_a_Backup_Image)
