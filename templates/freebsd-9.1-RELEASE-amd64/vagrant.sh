#!/usr/local/bin/bash -x

# install vagrant insecure ssh key
mkdir /home/vagrant/.ssh
fetch -o /home/vagrant/.ssh/authorized_keys \
    'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
