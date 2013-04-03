#!/bin/sh -xe

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/

NAME=$1

DISK_DEV=ada0
BOOTPMBR_FILE=/boot/pmbr
BOOTCODE_FILE=/boot/gptzfsboot
DIST_DIR=/usr/freebsd-dist

# create disks
gpart create -s gpt ${DISK_DEV}
gpart add -b 34 -s 94 -t freebsd-boot ${DISK_DEV}
gpart add -t freebsd-zfs -l disk0 ${DISK_DEV}
gpart bootcode -b ${BOOTPMBR_FILE} -p ${BOOTCODE_FILE} -i 1 ${DISK_DEV}

# align disks
gnop create -S 4096 /dev/gpt/disk0
zpool create -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot /dev/gpt/disk0.nop
zpool export zroot
gnop destroy /dev/gpt/disk0.nop
zpool import -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot

zpool set bootfs=zroot zroot
zfs set checksum=fletcher4 zroot

# set up zfs pools
zfs create zroot/usr
zfs create zroot/usr/home
zfs create zroot/var
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/tmp
zfs create -o compression=lzjb             -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/usr/src
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/tmp

# fixup ]
chmod 1777 /mnt/tmp
cd /mnt ; ln -s usr/home home
sleep 10
chmod 1777 /mnt/var/tmp

# set up swap
zfs create -V 2G zroot/swap
zfs set org.freebsd:swap=on zroot/swap
zfs set checksum=off zroot/swap

# Install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt
cat kernel.txz | tar --unlink -xpJf - -C /mnt
cat src.txz | tar --unlink -xpJf - -C /mnt
cat lib32.txz | tar --unlink -xpJf - -C /mnt

cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache

sleep 10
# Enable required services
cat >> /mnt/etc/rc.conf << EOT
zfs_enable="YES"
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
# 64-bit platform tuning for performance on low-mem instances.
KMEMSIZE="200M"
KMEMMAX="200M"
ARCMAX="40M"

cat >> /mnt/boot/loader.conf << EOT
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot"
vm.kmem_size="${KMEMSIZE}"
vm.kmem_size_max="${KMEMMAX}"
vfs.zfs.arc_max="${ARCMAX}"
vfs.zfs.vdev.cache.size="5M"
EOT

# Enable swap
echo '/dev/gpt/swap0 none swap sw 0 0' > /mnt/etc/fstab

# Install a few requirements
echo 'nameserver 8.8.8.8' > /mnt/etc/resolv.conf
export PACKAGESITE="http://ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/"
pkg_add -C /mnt -r bash-static || /usr/bin/true
(
  cd /mnt/bin
  ln -s /usr/local/bin/bash bash
  pkg_add -C /mnt -r sudo || /usr/bin/true
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /mnt/usr/local/etc/sudoers
  rm /mnt/etc/resolv.conf
)

# Set up user accounts
zfs create zroot/usr/home/vagrant
chroot /mnt /bin/sh -c 'echo "vagrant" | pw useradd vagrant -h 0 -s /bin/csh -G wheel -d /home/vagrant -c "Vagrant User"'
chroot /mnt /bin/sh -c 'echo "vagrant" | pw usermod root'
chroot /mnt /bin/sh -c 'chown 1001:1001 /home/vagrant'

# unmount zfs
zfs unmount -f zroot

# Reboot
reboot
