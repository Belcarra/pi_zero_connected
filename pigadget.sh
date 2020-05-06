#!/bin/bash
#
# Easy pre-flight boot install of Gadget, enable ssh and vnc
#
# 1. Modify /boot/cmdline.txt by replacing 
#       init=/usr/lib/raspi-config/init_resize.sh
# with:
#        modules-load-dwc2 init=/bin/bash -c -- "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; source /boot/pigadget.sh"
#
# 2. Add this pigadget.sh and pigadget.zip script to /boot
#
# 3. Optionally add a different Gadget configuration script to /boot/pigadget-default.sh
# 
#

# pigadget.zip contains
#
#   etc/
#   etc/pigadget/
#   etc/pigadget/default.sh
#   etc/systemd/
#   etc/systemd/system/
#   etc/systemd/system/pigadget.service
#   etc/systemd/system/getty@ttyGS1.service.d/
#   etc/systemd/system/getty@ttyGS1.service.d/override.conf
#   etc/systemd/system/getty@ttyGS0.service.d/
#   etc/systemd/system/getty@ttyGS0.service.d/override.conf
#   usr/
#   usr/lib/
#   usr/lib/pigadget/
#   usr/lib/pigadget/pigadget.stop
#   usr/lib/pigadget/pigadget.start

set -x
# mount /proc, remount root file system as read/write
mount -t proc proc /proc
mount / -o remount,rw

# keep systemd happy
mkdir -p /run/systemd

# unzip pigadget.zip to install pigadget service files
#
if [ -d /boot/pigadget ] ; then
    pushd /boot/pigadget
    cp -var * /
    popd
elif [ -s /boot/pigadget.tgz ] ; then
    tar xvfz /boot/pigadget.tgz
elif [ -s /boot/pigadget.zip ] ; then
    unzip -o /boot/pigadget.zip
fi

# if there is a /boot/pigadget-default.sh file copy it to /etc/pigadget/default.sh
if [ -s /boot/pigadget-default.sh ] ; then
    cp pigadget-default.sh /etc/pigadget/default.sh
fi

# update config.txt - this configures the correct USB Gadget Drivers
egrep "^dtoverlay=dwc2$" /boot/config.txt || echo "dtoverlay=dwc2" >> /boot/config.txt

# update /etc/modules to install libcomposite
egrep "^libcomposite$" /boot/config.txt || echo libcomposite >> /etc/modules


# enable ssh, vnc and pigadget
systemctl enable ssh
systemctl enable vncserver-x11-serviced
systemctl enable pigadget

# enable getty if ACM
systemctl enable getty@ttyGS0
systemctl enable getty@ttyGS1

# update cmdline.txt to revert to normal pre-first boot behaviour by calling init_resize.sh
#
#sed -i -e 's| init=/bin/bash -c --| init=/usr/lib/raspi-config/init_resize.sh|' -e 's|--.*$'||  /boot/cmdline.txt
sed -i -e 's| init=/bin/bash -c --.*||' /boot/cmdline.txt

umount /boot   
mount / -o remount,ro

sleep 10

exec /usr/lib/raspi-config/init_resize.sh

