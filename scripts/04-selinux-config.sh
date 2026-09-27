#!/bin/bash
set -e

dnf install -y httpd
systemctl enable --now httpd

mkdir -p /web/mysite
echo "<h1>Test Page</h1>" > /web/mysite/index.html

sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/web/mysite"|' /etc/httpd/conf/httpd.conf
sed -i 's|<Directory "/var/www/html">|<Directory "/web/mysite">|' /etc/httpd/conf/httpd.conf

semanage fcontext -a -t httpd_sys_content_t "/web/mysite(/.*)?"
restorecon -Rv /web/mysite

systemctl restart httpd

echo "Module 4 complete. Serving /web/mysite with correct SELinux context."
