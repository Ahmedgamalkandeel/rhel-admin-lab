#!/bin/bash
set -e

groupadd finance || echo "Group already exists"
mkdir -p /shared/reports
chown root:finance /shared/reports
chmod 2770 /shared/reports
chmod +t /shared/reports

setfacl -m u:bob:--x /shared/reports
setfacl -d -m u:bob:r-- /shared/reports

echo "Module 3 complete. /shared/reports configured with setgid, sticky bit, and default ACL for bob."
