# 07 — SSH Key-Only Hardening

## What I did
Generated a dedicated SSH key pair for VM access (separate from my GitHub key),
copied it to the VM, then hardened sshd: moved off the default port, disabled
root login and password authentication entirely, and restricted logins to one
named user.

## Commands (client side - Ubuntu)
ssh-keygen -t ed25519 -C "ahmed-vm-access" -f ~/.ssh/vm_lab_key
ssh-copy-id -i ~/.ssh/vm_lab_key.pub kandeelahmed@192.168.122.47
ssh -i ~/.ssh/vm_lab_key kandeelahmed@192.168.122.47   # confirmed BEFORE hardening anything

## Commands (server side - VM, via sudo -i)
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
# Edited /etc/ssh/sshd_config:
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
AllowUsers kandeelahmed

sshd -t                          # syntax check BEFORE restarting - critical safety step
firewall-cmd --add-port=2222/tcp --permanent
firewall-cmd --reload
semanage port -a -t ssh_port_t -p tcp 2222
systemctl restart sshd

## Troubleshooting encountered
After restarting sshd on the new port, connections were refused even though 
`ss -tnl` confirmed sshd was correctly listening on 2222. 

Root cause: a leftover port-forwarding rule from Module 5 
(port=2222:proto=tcp:toport=22) was still active - it was redirecting all 
traffic arriving on 2222 to port 22, where sshd was no longer listening after 
the port change. The rule made sense when it was created (forwarding TO ssh's 
old port), but became a silent conflict once ssh itself moved onto that same 
port number.

Diagnosed using `ss -tnl` (confirmed sshd's own binding was correct) and 
`firewall-cmd --list-all` (revealed the stale forward-port rule) rather than 
guessing.

## Fix
firewall-cmd --remove-forward-port=port=2222:proto=tcp:toport=22 --permanent
firewall-cmd --reload

## Verification
ssh -i ~/.ssh/vm_lab_key -p 2222 kandeelahmed@192.168.122.47
  -> succeeded, no password prompt

ssh -p 2222 -o PreferredAuthentications=password kandeelahmed@192.168.122.47
  -> Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
  -> confirms password auth is genuinely disabled, not just bypassed by the key

## Key lesson
Infrastructure changes can silently conflict with earlier configuration from 
a previous module. A port-forwarding rule that made sense in Module 5 became 
a hidden bug in Module 7 once the underlying service moved ports. This is 
exactly why documenting each module (and being able to look back at what was 
configured earlier) matters in real infrastructure work - the conflict was 
diagnosable specifically because I had a record of what I'd set up before.

## What I'd improve
Before changing SSH's port in the future, first audit existing firewalld rules 
(forward-ports, port ranges) for anything already referencing that port number, 
rather than discovering the conflict after the fact.
