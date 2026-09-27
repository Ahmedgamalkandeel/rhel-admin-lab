#!/bin/bash
set -e

# Part 1: firewalld - HTTP
firewall-cmd --zone=public --add-service=http
firewall-cmd --zone=public --add-service=http --permanent

# Part 4: Port forwarding (SSH on 2222 -> 22)
firewall-cmd --zone=public --add-forward-port=port=2222:proto=tcp:toport=22 --permanent
firewall-cmd --zone=public --add-masquerade --permanent
firewall-cmd --reload

echo "Module 5 complete. HTTP allowed, SSH forwarded from 2222->22."
echo "Note: static IP (nmcli) and hostname changes are environment-specific and left manual."
