# 06 — systemd Services & Targets

## What I did
Wrote a custom background service (webapp.sh) and turned it into a real systemd
unit, then deliberately broke it with a wrong ExecStart path and used the proper
diagnosis workflow to identify and fix the failure.

## The script (/usr/local/bin/webapp.sh)
#!/bin/bash
while true; do
  echo "$(date): webapp is running" >> /var/log/webapp.log
  sleep 5
done

## The unit file (/etc/systemd/system/webapp.service)
[Unit]
Description=Sample Web App
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/webapp.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target

## Commands
systemctl daemon-reload
systemctl enable --now webapp
systemctl status webapp
tail -5 /var/log/webapp.log

## Troubleshooting: deliberately broke it
Changed ExecStart to a nonexistent path (webapp-broken.sh) to practice diagnosis.

systemctl status webapp showed:
  Main PID: ... (code=exited, status=203/EXEC)

journalctl -xeu webapp showed:
  "Start request repeated too quickly"
  "Failed with result 'exit-code'"

## Diagnosis
- status=203/EXEC specifically means systemd could not execute the file at all -
  the path is wrong or the file isn't executable. This is different from the
  script running and then crashing (which would show a different exit code).
- "Start request repeated too quickly" is Restart=on-failure trying to restart
  the service automatically, failing immediately again each time, until systemd
  gives up and marks it permanently failed - a protective mechanism against
  infinite restart loops.

## Fix
Corrected ExecStart back to the real path, then:
systemctl daemon-reload
systemctl restart webapp

Verified: back to active (running), log writing again every 5 seconds.

## Key lesson
daemon-reload is required after ANY unit file change - systemd caches unit
definitions and silently ignores edits until reloaded. I didn't hit this as
a bug, but it's the reason I ran daemon-reload every single time before
restart, out of habit from Module 2's UUID lesson (verify before assuming).

## Note
systemctl get-default showed graphical.target, not the typical multi-user.target
for a server - likely installed with a Workstation/GUI profile rather than
minimal server. Left as-is for the lab, but a production server would want
multi-user.target to avoid wasting resources on a GUI.

## What I'd improve
Practice a second failure mode - e.g. a permissions issue (chmod -x on the
script) - to see a different exit code and confirm I can distinguish "wrong
path" from "not executable" from the diagnostic output alone.
