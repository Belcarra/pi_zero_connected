# Raspberry Pi Zero Connected
## Overview

The *Raspberry Pi Zero* running Raspbian can use *Networking over USB* to connect to the Internet via a Windows or Mac OS system.
This allows for very low cost use of the a headless Pi Zero, effectively the cost othe Pi Zero, SD card and USB cable. 

The use of the Gadget USB Device is not difficult to configure, but Gadget configuration is not normally supported by the
initial Raspbian install without modification to the ext filesystem created on the SD card, and that is
difficult to do in Windows or Mac OS.

This project implements a preflight configuration step done via the boot file system
(which is accessible to Windows and Mac OS) to setup a configuration script that will 
configure the Gadget Device Definition during the initial (aka first boot) of the 
Raspbery Pi.

The goal is to automatically set up *Networking over USB* using a Gadget Device.

This allows a Pi Zero (for example) to be used for headless operation with a network connection
through a desktop system without having to modify the Pi Zero system configuration after booting.
Additionally a USB Composite configuration is implemented that includes both an networking
(CDC EEM, ECM, NCM, or RNDIS) and Serial over USB (CDC ACM). This implements a serial console
to the Pi.

This project utilizes the same method as the default Raspbian file system resize script
to run a configuration script during the first boot. This is done by passing the name 
of the required script in the kernel command line as specified in the */boot/cmdline.txt* file.
In this case by replacing the existing first boot script (which the pigadget script will
call after completing its configuration tasks.)

This photo shows a Pi Zero connected to a Windows laptop. Note the use of VNC
to view the desktop, as well as an SSH shell connection and serial port connection
using ACM (aka Serial over USB.)


| | |
| --- | --- |
|![test](/img/IMG_2229.jpg)||



## Implementation Overview

The default installation for Raspbian implements a first-boot mechanism to fix the SSD
file system size. It does this be running a configuration script on first boot that performs
the necessary changes, changes the boot environment to the normal configuration (i.e. don't
call the configuration script) and reboots. On subsequent boots the system runs normally.

This project uses the same mechanism. A configuration script is run at first-boot that
performs specific configuration changes. It then calls the normal first-boot configuration script.

Specifically it will:
- add dtoverlay=dwc2 to /boot/config.txt if not already present
- add licomposite to /etc/modules if not already present
- copy in a Gadget Device Definition script to /etc/pigadget/default.sh
- copy in pigadget systemd unit definition file to /etc/systemd/system/pigadget.service
- copy in ttyGS0/ttyGS1 service helper files to /etc/systemd/system/getty@ttyGS[01]/
- use systemctl to enable ssh, vnc, pigadget and ttyGS0/ttyGS1 services.
- restore the cmdline.txt file to normal
- call the standard first boot script to resize the file system

This assumes a newly created SD card with a Raspbian image as created (for example)
with the *raspberry-pi-imager*. This will have two partions:
1. boot
2. extfs

The *boot* partition is formatted as FAT32 and can be easily modified from Windows or Mac OS.
No changes are required in the extfs partition (which is not easily modified from Windows or Mac OS).

A small *zip file* and *script* are copied to the */boot* partition of the newly imaged SD card.

With a minor change to */boot/cmdline.txt* file the script will be used on the first boot of the SD
card. 

When the Pi is booted the script will unzip the files into the correct locations in the *ext* filesystem
and then run the standard
*Raspbian* first time init script to finish the installation. That script normally resizes the ext
partition to the full size of the SD card and then reboots the Pi.

N.B. This project is compatible with the standard 
[Raspbian Imager](https://www.raspberrypi.org/blog/raspberry-pi-imager-imaging-utility/)
but not NOOBS.

## Install
1. Image the SD card, e.g. using Raspberry Pi Imager
2. Copy pigadget.sh and pigadget.zip to boot partition
2. Edit cmdline.txt in the boot partition (see below)

### Install notes
The new Raspian imager is great when it works but has a number of drawbacks. These are minor but there are alternatives.
####Possible drawbacks

- It won't run on your version of Windows or Linux or MacOS (they've tried to make it multi-platform but not every corner case is covered.
- It downloads the latest image, unpacks it, and writes it to the SD card in one step. This is fine as long as you always use the latest image, and you have the network bandwidth to download a huge file every time
- You need a USB 3.0 or preferably USB 3.1 port on the machine or the process will take literally forever, and the machine may go to sleep while completing the process.

#### Low-level install
- ZIP files of the RaspOS images are still available. These contain a single IMG file.  If the final IMG file is less than 4 GB in size, then the Windows built-in UNZIP tool can unpack it. Otherwise you'll new the 7zip tool.
Once you have the IMG file, you can write it to the SD card using the 
[win32diskimager](https://sourceforge.net/projects/win32diskimager/)
tool.  With a fast USB port and a cached IMG file, this is far faster than the Imager program.
## Use
1. Insert SD Card into Raspberry Pi
2. Insert USB cable into USB port and then into Windows or Mac system
3. From command line ping raspberrypi.local





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

Recent Windows 10 releases appear to have some MDNS (aka LLMNR) support built-in. *YMMV*


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

The pigadget.sh setup script implements steps 2 and 3. Step 1 is done when editing the cmdline.txt file.

## Debugging with monitor
If you have a monitor and the correct HDMI cable you can use that to see what is
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

## Other Gadget Configuration Tools

### Sysfstree

Sysfstree is a Python3 script and module that can be used to view information in the *Linux ConfigFS*.
The current best practice for Gadget Device setup is to use the *libcomposite* module which allows
for the Gadget Device Definitions to be done via the ConfigFS. Sysfstree allows the current status of
the Gadget configurations (and other parts of the ConfigFS) to be viewed.

```
sysfstree --gadget
[/sys/kernel/config/usb_gadget]
└──[belcarra-acm-eem]
    ├──bcdDevice: 0x0001
    ├──bcdUSB: 0x0200
    ├──bDeviceClass: 0x00
    ├──bDeviceProtocol: 0x00
    ├──bDeviceSubClass: 0x00
    ├──bMaxPacketSize0: 0x40
    ├──idProduct: 0xf102
    ├──idVendor: 0x15ec
    ├──UDC: fe980000.usb
    ├──[configs]
    │   └──[config.1]
    │       ├──acm.GS0 -> /sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS0
    │       ├──acm.GS1 -> /sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS1
    │       ├──bmAttributes: 0x80
    │       ├──eem.usb0 -> /sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0
    │       ├──MaxPower: 2
    │       └──[strings]
    │           └──[0x409]
    │               ├──configuration: CDC 2xACM+EEM
    ├──[functions]
    │   ├──[acm.GS0]
    │   │   ├──port_num: 0
    │   ├──[acm.GS1]
    │   │   ├──port_num: 1
    │   └──[eem.usb0]
    │       ├──dev_addr: 0e:6a:8a:85:db:76
    │       ├──host_addr: c6:34:7c:45:a6:c5
    │       ├──ifname: usb0
    │       ├──qmult: 5
    ├──[os_desc]
    │   ├──b_vendor_code: 0x00
    │   ├──qw_sign: 
    │   ├──use: 0
    ├──[strings]
    │   └──[0x409]
    │       ├──manufacturer: Belcarra Technologies Corp
    │       ├──product: ACMx2-EEM Gadget
    │       ├──serialnumber: 0123456789
```

### GadgetConfig

*gadgetconfig* is a Python3 script that simplifies testing and maintaining Gadget Device Definitions. 
The definitions are stored as JSON files, they can be loaded and unloaded into the Gadget ConfigFS. 
Also, specific definitions can be enabled or disabled, and the UDC soft-connect and soft-disconnect 
can be used. 

gadgetconfig can also convert a JSON definition file into the equivalent shell script. This is
useful to implement projects (like pigadget) that require a simple script to Gadget configuration
prior to being able to install additional software such as gadgetconfig.

The Belcarra ACM-EEM Gadget Device Definition file:
```
# Gadget Device Definition File
# 2020-04-07
{
    "belcarra-acm-eem": {
        # USB Device Descriptor Fields
        "idVendor": "0x15ec",
        "idProduct": "0xf102",
        "bcdDevice": "0x0001",
        "bDeviceClass": "0x00",
        "bDeviceSubClass": "0x00",
        "bDeviceProtocol": "0x00",
        "bcdUSB": "0x0200",
        "bMaxPacketSize0": "0x40",
        # USB Device Strings
        "strings": {
            "0x409": {
                "serialnumber": "0123456789",
                "product": "ACMx2-EEM Gadget",
                "manufacturer": "Belcarra Technologies Corp"
            }
        },
        # Gadget Functions list: see /sys/module/usb_f*,
        # E.g.: usb_f_acm, usb_f_ecm, usb_f_eem, usb_f_hid, usb_f_mass_storage
        #       usb_f_midi, usb_f_ncm, usb_f_obex, usb_f_rndis, usb_f_serial
        # Use: The function name (without prefix) is used with instantion name, e.g. eem.usb0 or acm.GS0
        "functions": {
            "acm.GS0": {},
            "acm.GS1": {},
            "eem.usb0": {
                "qmult": "5",
                "host_addr": "c6:34:7c:45:a6:c5",
                "dev_addr": "0e:6a:8a:85:db:76"
            }
        },
        # Gadget Configurations list
        "configs": {
            "config.1": {
                # Configuration Descriptor
                # bmAttributes: bit 5 support remote wakeup
                # bmAttributes: bit 6 self-powered
                # bmAttributes: bit 7 bus-powered
                # MaxPower: Power requirements in two-milliampere units, only valid of bit 7 is set
                "bmAttributes": "0x80",
                "MaxPower": "2",
                "strings": {
                    # USB Device Configuration Strings
                    "0x409": {
                        "configuration": "CDC 2xACM+EEM"
                    }
                },
                # This determines the order in the Configuration descriptor
                "functions": [
                    {
                        # Host Match USB\VID_15EC&PID_F102&MI_00
                        "name": "acm.GS0",
                        "function": "acm.GS0"
                    },
                    {
                        # Host Match USB\VID_15EC&PID_F102&MI_02
                        "name": "eem.usb0",
                        "function": "eem.usb0"
                    },
                    {
                        # Host Match USB\VID_15EC&PID_F102&MI_03
                        "name": "acm.GS1",
                        "function": "acm.GS1"
                    }
                ]
            }
        }
    }
}
```
We use this equivalent (but harder to maintain) shell script so that the Python based
gadgetconfig tools do not need to be installed.

N.B. the script has various configurable fields, e.g. *idVendor* and *idProduct* that can
be provided when calling it.

For example:
```
EXPORT idVendor="0x1234" default.sh
```
Sample script:

```
#!/bin/sh
# Created from belcarra-acm-eem.json

# Usage: manufacturer=$1 scriptname.sh

mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem"
echo "${idVendor:-0x15ec}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/idVendor"
echo "${idProduct:-0xf102}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/idProduct"
echo "${bcdDevice:-0x0001}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bcdDevice"
echo "${bDeviceClass:-0x00}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bDeviceClass"
echo "${bDeviceSubClass:-0x00}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bDeviceSubClass"
echo "${bDeviceProtocol:-0x00}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bDeviceProtocol"
echo "${bcdUSB:-0x0200}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bcdUSB"
echo "${bMaxPacketSize0:-0x40}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/bMaxPacketSize0"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/strings/0x409"
echo "${serialnumber:-0123456789}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/strings/0x409/serialnumber"
echo "${product:-ACMx2-EEM Gadget}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/strings/0x409/product"
echo "${manufacturer:-Belcarra Technologies Corp}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/strings/0x409/manufacturer"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS0"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS1"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0"
echo "${qmult:-5}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0/qmult"
echo "${host_addr:-c6:34:7c:45:a6:c5}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0/host_addr"
echo "${dev_addr:-0e:6a:8a:85:db:76}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0/dev_addr"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1"
echo "${bmAttributes:-0x80}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/bmAttributes"
echo "${MaxPower:-2}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/MaxPower"
mkdir -p "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/strings/0x409"
echo "${configuration:-CDC 2xACM+EEM}" > "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/strings/0x409/configuration"
ln -s "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS0" "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/acm.GS0"
ln -s "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/eem.usb0" "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/eem.usb0"
ln -s "/sys/kernel/config/usb_gadget/belcarra-acm-eem/functions/acm.GS1" "/sys/kernel/config/usb_gadget/belcarra-acm-eem/configs/config.1/acm.GS1"

basename /sys/class/udc/* > /sys/kernel/config/usb_gadget/belcarra-acm-eem/UDC

```

### GadgetApp
For some testing having a GUI application is simpler. *gadgetapp* is a GUI
application that allows access to most of the *gadgetconfig* functionality.

## See also:

- [**pigadget**](https://github.com/Belcarra/pigadget)
- [**gadgetconfig**](https://github.com/Belcarra/gadgetconfig)


