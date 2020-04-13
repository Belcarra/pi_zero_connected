# Raspberry Pi Zero Connected
## Overview

This project implements a preflight boot configuration for Rasberry Pi using Raspbian.
The goal is to provide enough configuration to set up *Networking over USB* using a Gadget Device.
This allows a Pi Zero (for example) to be used for headless operation with a network connection
through a desktop system.

Raspberry Pi boards running Raspbian support Networking over USB with the Gadget USB Device support.

For some boards, such as the *Pi Zero* it can be difficult to configure the correct Gadget Device
Definition etc without accessing the board after it has booted the first time. The Pi Zero for
example would require use of a keyboard, mouse and an HDMI monitor to do the configuration changes.

This project implements a method to install and run a configuration script during the first
boot that will install the systemd service to start the Gadget Device Definition when the system is booted.

This allows, for example, to use a Raspberry Pi Zero via the network from the Windows or
Mac OS system it is plugged into. With the low power requirements of the Pi Zero it can
be used with a single USB cable providing both networking and power.

![Pi Zero Connected][pizconnected]
[pizconnected]: /img/IMG_2229.jpg "Pi Zero Connected"


## Strategy

The default installation for Raspbian implements a first-boot mechanism to fix the SSD
file system size. It does this be running a configuration script on first boot that performs
the necessary changes, changes the boot environment to the normal configuration (i.e. don't
call the configuration script) and reboots. On subsequent boots the system runs normally.

This project uses the same mechanism. A configuration script is run at first-boot that
performs specific configuration changes. It then calls the normal first-boot configuration script.


Specifically it will:
- copy in a Gadget Device Definition script 
- copy in pigadget systemd unit definition file 
- copy in ttyGS0/ttyGS1 service helper files
- copy in start/stop scripts 
- use systemctl to enable ssh, vnc, pigadget and ttyGS0 services.


## Implmenetation

This assumes a newly created SD card with a Raspbian image. This will have two partions:
1. boot
2. extfs

The *boot* partition is formatted as FAT32 and can be modified from Windows or MacOS.

A small zip file and script are copied to the */boot* partition of a newly created SD card.
With a minor change to /boot/cmdline.txt file the script will be used on the first boot of the SD
card. That will copy unzip the files into the correct locations and then run the standard
*Raspbian* first time init script to finish the installation.

The *pigadget.sh* script will:

1. unzip the contents of pigadget.zip into the root file system, aka "/"
2. add dtoverlay=dwc2 to the /boot/config.txt file if not there
3. add libcomposite to the /etc/modules file if not there
4. enable the ssh, vnc, pigadget and getty services
5. restore the cmdline.txt
6. exec /usr/lib/raspi-config/init_resize.sh


## Install
1. Image the SD card, e.g. using Raspberry Pi Imager
2. Copy pigadget.sh and pigadget.zip to boot partition
2. Edit cmdline.txt in the boot partition (see below)

## Use
1. Insert SD Card into Raspberry Pi
2. Plug in video (if available)
3. Plug in power

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


## Windows Internet Connection Sharing

The simplest way to connect the Raspberry Pi to the Internet via a Windows system is to use
*Internet Connection Sharing* (aka ICS).

1. Open Network Adapter Settings
2. Find the network adapter for your Internet Connection (Ethernet or WiFi)
3. Click on that and then click on Properties
4. Click on Sharing Tab
5. Enable sharing and select the adapter that will share


## Raspbian Gadget Setup

To use the Gadget USB driver with configs setup the following needs to be done

1. add dtoverlay=dwc2 to /boot/config.txt - this gets the correct USB Driver configured
2. add module-load=dwc2 to cmdline.txt - this gets the dwc2 module loaded
3. add libcomposite to /etc/modules - this gets the libcomposite driver loaded





## See also:

- [**pigadget**](https://github.com/Belcarra/pigadget)
- [**gadgetconfig**](https://github.com/Belcarra/gadgetconfig)


