# Raspberry Pi Zero Connected
## Overview

The *Raspberry Pi Zero* can use *Networking over USB* to connect to the Internet via a Windows or Mac OS system.
This allows for very low cost use of the Pi Zero, effectively the cost othe Pi Zero, SD card and USB cable. 

The use of the Gadget USB Device is not difficult to configure, but is not supported by the
initial Raspbian install without modification to the ext filesystem created on the SD card, and that is
difficult to do in Windows or Mac OS.

This project implements a preflight boot setup for Rasberry Pi using Raspbian.

The goal is to automatically set up *Networking over USB* using a Gadget Device.
This allows a Pi Zero (for example) to be used for headless operation with a network connection
through a desktop system without having to modify the Pi Zero system configuration after booting.

This project uses the same method as the default Raspbian file system resize script
to install and run a configuration script during the first
boot. 

This photo shows a Pi Zero connected to a Windows laptop. Note the use of VNC
to view the desktop, as well as an SSH shell connection and serial port connection
using ACM (aka Serial over USB.)

<img src="/img/IMG_2229.jpg" width=300 >


## Implementation Overview

The default installation for Raspbian implements a first-boot mechanism to fix the SSD
file system size. It does this be running a configuration script on first boot that performs
the necessary changes, changes the boot environment to the normal configuration (i.e. don't
call the configuration script) and reboots. On subsequent boots the system runs normally.

This project uses the same mechanism. A configuration script is run at first-boot that
performs specific configuration changes. It then calls the normal first-boot configuration script.

Specifically it will:
- add dtoverlay=dwc2 to /boot/config if not present
- add licomposite to /etc/modules if not present
- copy in a Gadget Device Definition script to /etc/pigadget/default.sh
- copy in pigadget systemd unit definition file to /etc/systemd/system/pigadget.service
- copy in ttyGS0/ttyGS1 service helper files to /etc/systemd/system/getty@ttyGS[01]/
- use systemctl to enable ssh, vnc, pigadget and ttyGS0/ttyGS1 services.
- restore the cmdline.txt file to normal
- call the standard first boot script to resize the file system

This assumes a newly created SD card with a Raspbian image. This will have two partions:
1. boot
2. extfs

The *boot* partition is formatted as FAT32 and can be modified from Windows or MacOS.
No changes are required in the extfs partition.

A small zip file and script are copied to the */boot* partition of the newly created SD card.
With a minor change to /boot/cmdline.txt file the script will be used on the first boot of the SD
card. That will copy unzip the files into the correct locations and then run the standard
*Raspbian* first time init script to finish the installation.

## Install
1. Image the SD card, e.g. using Raspberry Pi Imager
2. Copy pigadget.sh and pigadget.zip to boot partition
2. Edit cmdline.txt in the boot partition (see below)

## Use
1. Insert SD Card into Raspberry Pi
2. Insert USB cable into USB port and then into Windows or Mac system
3. From command line ping raspberrypi.local



## Debugging with monitor
If you have a monitor and appropriate HDMI cable you can use that to see what is
happening during the boot.

You should see the following:
1. Blue screen
2. Boot information
    - pigadget will run, copy files and do configuration
    - init_resize.sh will run
3. System will reboot
4. Blue screen
5. Boot information
6. System boot complete

When it is booted for the second time the network should be available when plugged into Windows or MacOS.

N.B. for more information remove quiet and splash from cmdline.txt (see below)


### Cmdline.txt

The *cmdline.txt* file will contain a single line similar to:
```
console=serial0,115200 console=tty1 root=PARTUUID=ea7d04d6-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet init=/usr/lib/raspi-config/init_resize.sh splash plymouth.ignore-serial-consoles
```
Edit the file and delete the following
```
    init=/usr/lib/raspi-config/init_resize.sh
```
Add the following to *the end of the line*:
```
modules-load-dwc2 init=/bin/bash -c -- "mount -t proc proc /proc; mount -t sysfs sys /sys; mount /boot; source /boot/pigadget.sh"
```

Save the file and eject the SD card. Use that to reboot your Raspberry Pi.

N.B. if you want to see more information during the boot process you can remove the following from the cmdline.txt file:
- splash
- quiet

## pigadget.zip

*pigadget.zip* contains:
```
    etc/
    etc/pigadget/
    etc/pigadget/default.sh
    etc/systemd/
    etc/systemd/system/
    etc/systemd/system/pigadget.service
    etc/systemd/system/getty@ttyGS1.service.d/
    etc/systemd/system/getty@ttyGS1.service.d/override.conf
    etc/systemd/system/getty@ttyGS0.service.d/
    etc/systemd/system/getty@ttyGS0.service.d/override.conf
    usr/
    usr/lib/
    usr/lib/pigadget/
    usr/lib/pigadget/pigadget.stop
    usr/lib/pigadget/pigadget.start
```

## Sample default.sh

The sample gadget definition setup script is based on belcarra-acm-eem.json.
```
    gadgetconfig --sh-auto belcarra-acm-eem.json > belcarra-acm-eem.sh
```

## Windows Setup
Currently this is using the Belcarra IOTdemo driver which supports EEM, ECM, NCM and RNDIS. An RNDIS configuration
can also be used with the builtin Windows driver.

## Windows Internet Connection Sharing

The simplest way to connect the Raspberry Pi to the Internet via a Windows system is to use
*Internet Connection Sharing* (aka ICS).

1. Open Network Adapter Settings
2. Find the network adapter for your Internet Connection (Ethernet or WiFi)
3. Click on that and then click on Properties
4. Click on Sharing Tab
5. Enable sharing and select the adapter that will share

## MDNS - Multicast DNS

Until recently the best way to get MDNS in Windows was to install [Bonjour from Apple](https://support.apple.com/kb/DL999?locale=en_US)

Recent Windows 10 releases appear to have some MDNS (aka LLMNR) support built-in. 


## VNC Screen Sharing

To view the Raspbian desktop use one of the free VNC viewers.

The RealVNC viewer works well. [*Download RealVNC*](https://www.realvnc.com/en/connect/download/viewer/windows/)

## Serial Over USB

To use the Serial over USB connection you will need to have a terminal program.

Putty works reasonably well. [*Download Putty*](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)


## Raspbian Gadget Setup Summary

To use the Gadget USB driver with configs setup the following needs to be done

1. add module-load=dwc2 to cmdline.txt - this gets the dwc2 module loaded
2. add dtoverlay=dwc2 to /boot/config.txt - this gets the correct USB Driver configured
3. add libcomposite to /etc/modules - this gets the libcomposite driver loaded

The pigadget.sh setup script implements stpes 2 and 3. 



## See also:

- [**pigadget**](https://github.com/Belcarra/pigadget)
- [**gadgetconfig**](https://github.com/Belcarra/gadgetconfig)


