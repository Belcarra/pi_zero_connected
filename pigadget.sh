#!/bin/bash
#
# Quick and dirty pre-first boot install of Gadget, enable ssh and vnc
#
# Modify /boot/cmdline.txt by replacing 
#       init=/usr/lib/raspi-config/init_resize.sh
# with:
#        modules-load-dwc2 init=/bin/bash -c -- "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; source /boot/pigadget.sh"
#
# Add this pigadget.sh and pigadget.zip script to /boot
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
mount / -o remount,rw
mkdir -p /run/systemd

# unzip pigadget.zip to install pigadget service files
#
if [ -s /boot/pigadget.zip ] ; then
    unzip -o /boot/pigadget.zip
fi

# update config.txt
egrep "^dtoverlay=dwc2$" /boot/config.txt || echo "dtoverlay=dwc2" >> /boot/config.txt

# update /etc/modules to install libcomposite
egrep "^libcomposite$" config.txt || echo libcomposite >> /etc/modules


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

