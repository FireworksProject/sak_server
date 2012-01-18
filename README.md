SAK System Administration and Development
=========================================

This repository contains scripts and admin tools used to deploy and run
[our](http://www.fireworksproject.com) development and support server.  We call
it our SAK server (Swiss Army Knife), and it is a "Jack of all trades". It is
mainly deployed on Rackpace Cloud Servers.

To install the executable (bin) scripts, run

    cd sak_server
    bin/install_bin

That will install the `push_shared_projects` and `pull_shared_projects` commands on your local system.

### shared_projects pushing and pulling

Before `push_shared_projects` and `pull_shared_projects` will work, you'll need
to make sure your `~/.ssh/config` file is setup properly to talk to the remoter
server (See `examples/.ssh/config` for an example).  You'll also need to create
a directory named `shared_projects` somewhere on your machine.

Once you've installed the commands (see above), you can just `cd` into your `shared_projects` directory and run them.

__!README (gotcha)__ Don't ever run these commands outside of your
`shared_projects` folder; you'll end up pushing and pulling all the files from
whichever folder you happen to be in. (you can check full path of your current
directory with the command `pwd`).

Copyright and License
---------------------
Copyright: (c) 2012 by The Fireworks Project (http://www.fireworksproject.com)

Unless otherwise indicated, all source code is licensed under the MIT license. See MIT-LICENSE for details.
