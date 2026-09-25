# 02 — Storage: Partitions, LVM, Swap

## What I did
Added a second 5G virtual disk (`vdb`), built the full LVM stack on it (partition → PV → VG → LV), formatted with XFS, mounted persistently via UUID in `/etc/fstab`, then demonstrated a live extend from 2G to 3G with zero downtime.

## Commands
parted /dev/vdb --script mklabel gpt mkpart primary 0% 100%
pvcreate /dev/vdb1
vgcreate vg_data /dev/vdb1
lvcreate -L 2G -n lv_app vg_data
mkfs.xfs /dev/vg_data/lv_app
mkdir -p /app
mount /dev/vg_data/lv_app /app
blkid /dev/vg_data/lv_app
echo 'UUID=577861bf-45dc-40d0-9dda-7e4803b2ab73  /app  xfs  defaults  0 0' >> /etc/fstab
mount -a

## Live extend (no downtime)
lvextend -L +1G /dev/vg_data/lv_app
xfs_growfs /app

## Verification
df -hT /app
findmnt /app
lvs

## Output
df -hT /app
/dev/mapper/vg_data-lv_app xfs 3.0G 54M 2.9G 2% /app

## What I'd improve
Use a script (see scripts/02-lvm-setup.sh) to pull the UUID automatically via `blkid` instead of manual copy-paste — during this module I made a typo manually retyping a UUID into fstab, which taught me why automation matters for anything security- or boot-critical.
