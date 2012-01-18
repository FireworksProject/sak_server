SAK System Administration and Development
=========================================

This repository contains scripts and admin tools used to deploy and run [our](http://www.fireworksproject.com) development and support server.  We call it our SAK server (Swiss Army Knife), and it is a "Jack of all trades". It is mainly deployed on Rackpace Cloud Servers.

To install the executable (bin) scripts, run

    cd sak_server
    bin/install_bin

That will install the `push_shared_projects` and `pull_shared_projects` commands on your local system.

Before these commands will work, you'll need to make sure your `~/.ssh/config` file is setup properly to talk to the remoter server. See `examples/.ssh/config` for an example.

Copyright and License
---------------------
Copyright: (c) 2012 by The Fireworks Project (http://www.fireworksproject.com)

Unless otherwise indicated, all source code is licensed under the MIT license. See MIT-LICENSE for details.
