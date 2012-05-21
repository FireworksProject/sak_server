General Setup for Production and Dev VMs
========================================

System Setup
------------
Login as the fwpusers user and update the machine.

    ssh fwpusers@saks.fireworksproject.com
    wget https://github.com/FireworksProject/web_server/raw/master/toehold
    source toehold

The toehold script will install git, clone a read-only copy of the `sak_server`
repository, and update Ubuntu all at once. Remember to *reboot* after this
step.

Dotfiles
--------
This step is optional, but really nice to have for development purposes. While
logged into the VM do

    cd ~
    git clone git@github.com:FireworksProject/dotfiles.git

Follow the README instructions in the dotfiles repo then:

    source ~/.bashrc

Then, you'll probably want to transfer your .gitconfig file from your local
host machine to the development VM. But, *don't do this on a production VM*.

    scp username@$HOST_IP:~/.gitconfig ~/

where `$HOST_IP` is the IP address of your local host machine.

Setup the Node.js Stack
-----------------------
Check out the `nodejs.md` docs.

fwpusers
--------
The fwpusers account is used for project sharing, collaboration and related
stuff.  To setup the account, login as the fwpusers user and run a simple
script.

    ssh fwpusers@saks.fireworksproject.com
    ~/sak_server/bin/setup_fwpusers

That script will create the `shared_projects/` folder, get the dotfiles
repository, and deploy the dotfiles for the fwpusers.

Git Repositories
----------------
Login as the git user and then for each desired repository REPO do

    mkdir ~/$REPO.git
    cd ~/$REPO.git/
    git init --bare
