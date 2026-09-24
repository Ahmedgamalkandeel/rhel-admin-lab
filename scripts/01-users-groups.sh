#!/bin/bash
set -e

groupadd sysadmins || echo "Group already exists"
useradd -m -d /home/devops -s /bin/bash -G sysadmins devops || echo "User already exists"
chage -M 90 -W 7 devops

cat <<EOF > /etc/sudoers.d/sysadmins
%sysadmins ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/firewall-cmd
EOF

echo "Module 1 complete. Set password manually with: passwd devops"
