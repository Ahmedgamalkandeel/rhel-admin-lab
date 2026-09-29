#!/bin/bash
set -e

cat <<'EOF' > /usr/local/bin/webapp.sh
#!/bin/bash
while true; do
  echo "$(date): webapp is running" >> /var/log/webapp.log
  sleep 5
done
EOF
chmod +x /usr/local/bin/webapp.sh

cat <<EOF > /etc/systemd/system/webapp.service
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
EOF

systemctl daemon-reload
systemctl enable --now webapp

echo "Module 6 complete. webapp.service running and logging to /var/log/webapp.log"
