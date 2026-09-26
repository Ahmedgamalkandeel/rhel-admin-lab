# 03 — Permissions, ACLs, and Special Bits

## What I did
Built a shared `/shared/reports` directory for a `finance` group with setgid (group inheritance) and sticky bit (safe multi-user deletion). Used ACLs to grant a non-group user (`bob`) read access to a specific file and directory traversal, plus a default ACL so future files automatically inherit his access.

## Commands
groupadd finance
mkdir -p /shared/reports
chown root:finance /shared/reports
chmod 2770 /shared/reports
chmod +t /shared/reports

setfacl -m u:bob:--x /shared/reports
setfacl -m u:bob:r-- /shared/reports/q3.txt
setfacl -d -m u:bob:r-- /shared/reports

## Verification
ls -ld /shared/reports
getfacl /shared/reports
getfacl /shared/reports/q3.txt

## Output
drwxrws--T. 2 root finance /shared/reports
user:bob:--x  (directory traversal)
default:user:bob:r--  (auto-applies to new files)

New file test: alice created q4.txt -> inherited group `finance` (setgid) 
and bob could read it immediately via the default ACL, no manual setfacl needed.

## Troubleshooting encountered
Granted bob read access to a file via ACL, but he still got "Permission denied."
Root cause: the directory itself blocked "other" users from traversing it 
(no execute bit for others) — file-level ACLs don't bypass directory-level 
traversal restrictions. Fixed by adding `setfacl -m u:bob:--x` on the 
directory itself, separate from the file's own permissions.

## What I'd improve
Automate this whole setup in a script (see scripts/03-permissions-acl.sh) 
rather than manual step-by-step, to avoid the su/exit session-tracking 
confusion I ran into while testing as different users.
