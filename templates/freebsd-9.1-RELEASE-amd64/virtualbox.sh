#!/usr/local/bin/bash -ux

cd /usr/ports/devel/libtool
make clean
make install -DBATCH

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

cd /usr/ports/emulators/virtualbox-ose-additions
make -DBATCH package clean

# undo our customizations
sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf
sed -i '' -e '/^WITHOUT_X11/d' /etc/make.conf


echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'vboxnet_enable="YES"' >> /etc/rc.conf
echo 'vboxguest_enable="YES"' >> /etc/rc.conf
echo 'vboxservice_enable="YES"' >> /etc/rc.conf

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

#Bash needs to be the shell for tests to validate
pw usermod vagrant -s /usr/local/bin/bash
