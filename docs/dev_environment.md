Web Server Development Environment
==================================


Virtual Machine (on VirtualBox)
-------------------------------
### Create Machine
* Use 64 bit Ubuntu
* Set it up with 256MB memory
* And create an 10GB HDD (flex)

These are the system settings, per tab, on VirtualBox, for this machine.

### System
* 256MB memory
* Shut off absolute pointing device

### Audio
* Disable audio

### Network
* Select bridged adapter
* Advanced::Promiscuous Mode: allow all (requires strong user passwords)

### USB
* Disable USB


Install Ubuntu 10.04.3 Server Edition
-------------------------------------
Download an Ubuntu install disk image (.iso file) for 10.04.3 server edition
(64bit/amd64) if you don't already have it. There is no need to burn an actual
CDROM, you can simply mount the iso image to the CDROM drive on the virtual
machine (in the Storage tab on the machine settings).  Make sure the boot
device priority order is set start with CD/DVD-ROM (in the System tab on the
machine settings) and then start the machine.

### Ubuntu Install Notes
* Partitioning: Guided - use entire disk (no need for Logical Volume Management)
* Use "fwpusers" as the username.
* Create a strong password since the machine is going to make itself available on the Internet.
* Only select the SSH Server software package during installation and leave the rest unchecked.
* Do *not* allow automatic updates.

Let the VM reboot after Ubuntu installation and then log into it.


SSH Setup
---------
Lockdown SSH to match the production server. Edit the `/etc/ssh/sshd_config`
file to change or add following entries.

    Port 2575
    PermitRootLogin no
    AllowUsers git fwpusers

While logged into the VM, create the .ssh dir, and get the IP address of the VM
on the local network with

    mkdir ~/.ssh
    hostname -I

With the IP address in hand, you can copy over your private key and ssh config
file used to access GitHub, which will be needed to clone the `web_server`
repository onto the VM.  So, back on your local host machine, use scp to copy
your private key to the VM.

    scp ~/.ssh/$YOUR_KEY* ubuntu@$VM_IP:~/.ssh/
    scp ~/.ssh/config ubuntu@$VM_IP:~/.ssh/

where `$YOUR_KEY` is probably something like `id_rsa` and `$VM_IP` is the IP
address of the VM. Make sure both the private and public keys are copied.
You'll probably want to make some changes to your personal ssh config file
after it is copied over; use the config file in `examples/.ssh/` as a guide to
what should be there.

General Setup
-------------
Follow the instructions in `docs/setup.md` to complete the setup process.
