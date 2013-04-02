PACKAGESITE=ftp://ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/ pkg_add -r compat6x-amd64

cd /tmp
mkdir -p /mnt/cdrom
mdconfig -a -t vnode -f /home/vagrant/freebsd.iso -u 0
mount -t cd9660 /dev/md0 /mnt/cdrom/
tar zxvf /mnt/cdrom/vmware-freebsd-tools.tar.gz -C /tmp/
/tmp/vmware-tools-distrib/vmware-install.pl -d
umount /mnt/cdrom
rm /home/vagrant/freebsd.iso
