Setup the Kristoffer (cayuga) Box on Rackspace
==============================================


Ubuntu
------

Using Ubuntu 10.04 LTS

After starting the box on Rackspace, get the IP address and put it into the A
record on the zone file for kristo.us at DynDNS. Then put the new root password
and IP address into the Rackspace entries in KeePassX.

Login as root, update the instance, and install dependencies.

    ssh -p 22 root@kristo.us

    sudo apt-get update
    sudo apt-get dist-upgrade -m -y
    sudo apt-get autoremove -m -y

    sudo apt-get install \
        openssh-server \
        openssh-client \
        build-essential \
        screen \
        curl \
        vim \
        git-core \
        tree


Users
-----

Then, while still logged in as root, create a named user and a git user.  Use
KeePass to generate the password and save it.

    adduser kris
    adduser git

Add the named user to the sudo group.

    adduser kris sudo


SSH
---

Lockdown SSH. Edit the `/etc/ssh/sshd_config` file with

    Port 2575
    PermitRootLogin no
    AllowUsers git kris

Restart the server, then back on the local box (the development VM); add the
SSH keys. But, check the local .ssh/conf first to make sure entries exist for
these users.

    ssh-copy-id kris@kristo.us
    ssh-copy-id git@kristo.us


Snapshot Image
--------------

Check to make sure the users can login (except the root user), then [create an image](http://www.rackspace.com/knowledge_center/index.php/Creating_a_Cloud_Server_from_a_Backup_Image)

It would probably be a good idea to do the Home Sync Directory (below) while
logged in as the kris user.


Home Sync Directory
-------------------

We need to create a directory specifically for the rysnc scripts which sync
HOME between machines. While in the SSH term, do this:

    mkdir /home/kris/Homesync


Git Repositories
----------------

Set up the remote git repositories [(article)](http://tumblr.intranation.com/post/766290565/how-set-up-your-own-private-git-server-linux).
First, make sure the repositories listed in `cayuga/conf/git_repos.list` is
correct.  Then run:

    cayuga/bin/create_remote_git_repos

Then set up local git repositories with a url like this: `git@kristo.us:myrepo.git`.

    git remote add origin git@kristo.us:myrepo.git
