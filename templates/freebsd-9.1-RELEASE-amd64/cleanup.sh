#!/bin/sh -x

# Remove all packages since we have a full set of build tools installed
pkg_delete -af

# Reinstall a minimal package set
cd /usr/ports/packages/Latest
pkg_add sudo.tbz bash-static.tbz virtualbox-ose-additions.tbz

# Purge files we don't need any longer
rm -rf /tmp/chef*
rm -rf /home/vagrant/VBox*.iso
find /usr/ports -not -path '/usr/ports/packages*' -and -not -path '/usr/ports/distfiles*' -depth -exec rm -rf '{}' \;
rm -rf /usr/ports/distfiles/*
rm -rf /var/db/freebsd-update/files
mkdir /var/db/freebsd-update/files
rm -rf /var/db/freebsd-update/*-rollback
rm -rf /var/db/freebsd-update/install.*
rm -rf /boot/kernel.old
rm -rf /usr/src/*
rm -rf /*.core

# Scrub the root pool just for good measure
zpool scrub zroot