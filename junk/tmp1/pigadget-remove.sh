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

# disable ssh, vnc and pigadget
systemctl disable ssh
systemctl disable vncserver-x11-serviced
systemctl disable pigadget

# disable getty if ACM
systemctl disable getty@ttyGS0
systemctl disable getty@ttyGS1

rm -vrf /etc/pigadget /etc/systemd/system/pigadget.service /etc/systemd/system/getty@ttyGS*
rm -vrf /usr/lib/pigadget


