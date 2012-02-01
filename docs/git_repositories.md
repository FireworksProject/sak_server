Remotely Hosted Git Repositories
================================

To create a repository on the host, login to the SAK server as the git user and
then for each desired repository REPO do

    mkdir ~/$REPO.git
    cd ~/$REPO.git/
    git init --bare


Then set up local git repositories with a url like this: `git@saks.fireworksproject.com:$REPO.git`.

    git remote add origin git@saks.fireworksproject.com:$REPO.git

