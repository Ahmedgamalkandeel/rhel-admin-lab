# 01 — User & Group Management

## What I did
Created a user `devops`, added them to a `sysadmins` group, set password aging (90 days, 7-day warning), and gave the group limited (not full-root) sudo access to `systemctl` and `firewall-cmd`.

## Commands
groupadd sysadmins
useradd -m -d /home/devops -s /bin/bash -G sysadmins devops
passwd devops
chage -M 90 -W 7 devops
visudo -f /etc/sudoers.d/sysadmins
    %sysadmins ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/firewall-cmd

## Verification
id devops
groups devops
chage -l devops
sudo -l -U devops

## Output
id devops
uid=1001(devops) gid=1002(devops) groups=1002(devops),1001(sysadmins)

chage -l devops
Maximum number of days between password change: 90
Number of days of warning before password expires: 7

sudo -l -U devops
User devops may run the following commands on server:
    (ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/firewall-cmd

## What I'd improve
Scope sudo to specific subcommands (e.g. `systemctl restart httpd` only) instead of the whole `systemctl` binary — tighter least-privilege, since right now `devops` could stop critical services, not just manage the intended one.
