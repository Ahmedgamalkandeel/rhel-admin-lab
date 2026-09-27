# 05 — firewalld & Networking (nmcli)

## What I did
Configured firewalld to allow HTTP traffic, set a static IP and hostname via nmcli, 
configured local hostname resolution via /etc/hosts, and set up SSH port forwarding 
- verifying each piece with real external traffic, not just local testing.

## Part 1: firewalld - opening HTTP
firewall-cmd --state
firewall-cmd --get-default-zone
firewall-cmd --zone=public --list-all
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=http --permanent

Verified: curl from Ubuntu (external client) to VM's enp1s0 IP returned 200 OK,
confirming both the runtime AND permanent rule matter - only permanent alone would
require a --reload before working immediately.

## Part 2: Static IP via nmcli
nmcli connection show
nmcli device status
nmcli connection modify enp7s0-lab ipv4.addresses 192.168.50.20/24
nmcli connection modify enp7s0-lab ipv4.gateway 192.168.50.1
nmcli connection modify enp7s0-lab ipv4.dns "8.8.8.8 1.1.1.1"
nmcli connection modify enp7s0-lab ipv4.method manual
nmcli connection up enp7s0-lab

Key lesson: modify only stages changes - nothing applies until `connection up` 
is run. Verified with `ip addr show enp7s0` showing the new static IP live.

## Part 3: Hostname and /etc/hosts
hostnamectl set-hostname node1.lab.local
# Added to /etc/hosts:
192.168.50.20   node1.lab.local   node1

Verified: `ping node1.lab.local` resolved and replied using /etc/hosts, with no
DNS server involved - confirms /etc/hosts is checked before DNS.

## Part 4: Port forwarding
firewall-cmd --zone=public --add-forward-port=port=2222:proto=tcp:toport=22 --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload

## Troubleshooting encountered
Testing `ssh -p 2222 ...` from the VM itself (via localhost AND via its own IP) 
failed with "connection refused," even after enabling masquerade. 
Root cause: port forwarding rules apply to traffic arriving from an external 
source through the firewall - testing from the same machine that owns the rule 
doesn't traverse the forwarding chain the normal way (a known NAT/hairpin 
limitation, not a misconfiguration).
Fix: tested instead from Ubuntu (genuinely external) - succeeded immediately, 
confirming the configuration was correct all along.

## Verification
curl http://192.168.122.47 (from Ubuntu)          -> 200 OK
ping node1.lab.local (local hostname resolution)   -> success
ssh -p 2222 kandeelahmed@192.168.122.47 (from Ubuntu) -> success, logged in as node1

## What I'd improve
Test forwarding rules from an external host as the default first step, rather 
than assuming local testing is a valid proxy - this would have saved troubleshooting 
time.

## Common exam traps (from reference material, confirmed through my own testing)
- Forgetting --permanent means the rule vanishes on reboot; forgetting the 
  live/runtime version means it doesn't apply until --reload
- Confusing zones: a rule added to the wrong zone silently does nothing
- Forgetting `nmcli connection up` after `modify` - I hit this indirectly, 
  since without `up` none of my static IP settings would have taken effect
- Port forwarding needs masquerade enabled, and must be tested from an 
  actual external source, not the local machine
