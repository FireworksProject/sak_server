shared_projects pushing and pulling
-----------------------------------

The SAK server hosts projects that we sometimes work on collaboratively. So, we
have some special scripts in this repository which make it easy to push and
pull files and folders from our shared folder on the SAK server.  To install
the executable scripts on your local machine, run

    cd sak_server
    bin/install_bin

That will install the `push_shared_projects` and `pull_shared_projects` commands on your local system.

Before `push_shared_projects` and `pull_shared_projects` will work, you'll need
to make sure your `~/.ssh/config` file is setup properly to talk to the remote
server (See `examples/.ssh/config` for an example).  You'll also need to create
a directory named `shared_projects` somewhere on your machine.

Once you've installed the commands (see above), you can just `cd` into your `shared_projects` directory and run them.

__!GOTCHA__ Don't ever run these commands outside of your
`shared_projects` folder; you'll end up pushing and pulling all the files from
whichever folder you happen to be in. (you can check full path of your current
directory with the command `pwd`).
