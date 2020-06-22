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
