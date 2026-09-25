#!/bin/bash
set -e

DISK=${1:-/dev/vdb}

parted "$DISK" --script mklabel gpt mkpart primary 0% 100%
pvcreate "${DISK}1"
vgcreate vg_data "${DISK}1"
lvcreate -L 2G -n lv_app vg_data
mkfs.xfs /dev/vg_data/lv_app
mkdir -p /app
mount /dev/vg_data/lv_app /app

UUID=$(blkid -s UUID -o value /dev/vg_data/lv_app)
echo "UUID=${UUID}  /app  xfs  defaults  0 0" >> /etc/fstab
systemctl daemon-reload
mount -a

echo "Module 2 complete. /app mounted on vg_data/lv_app."
