#!/bin/bash
set -e

sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
echo "AllowUsers kandeelahmed" >> /etc/ssh/sshd_config

sshd -t

firewall-cmd --add-port=2222/tcp --permanent
semanage port -a -t ssh_port_t -p tcp 2222 2>/dev/null || true
firewall-cmd --reload

systemctl restart sshd

echo "Module 7 complete. SSH hardened on port 2222, key-only auth."
echo "WARNING: verify key-based login works BEFORE closing your current session."
