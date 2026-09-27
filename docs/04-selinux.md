# 04 — SELinux

## What I did
Installed httpd, pointed DocumentRoot at a custom directory (/web/mysite) instead of the default /var/www/html, and hit a real SELinux denial when Apache couldn't read the content — despite correct standard Unix permissions.

## Commands
dnf install -y httpd
systemctl enable --now httpd
mkdir -p /web/mysite
echo "<h1>Test Page</h1>" > /web/mysite/index.html
# edited /etc/httpd/conf/httpd.conf: DocumentRoot and <Directory> both -> /web/mysite
systemctl restart httpd

## The failure
curl http://localhost -> 403 Forbidden
tail /var/log/httpd/error_log showed:
"Permission denied ... search permissions are missing on a component of the path"

## Troubleshooting process
1. Checked standard Unix permissions first: ls -ld /web /web/mysite /web/mysite/index.html
   -> all correct (drwxr-xr-x, root:root) - ruled out a normal permissions issue
2. Checked for an actual SELinux denial: ausearch -m avc -ts recent
   -> confirmed: avc: denied { getattr } scontext=httpd_t tcontext=default_t
   -> the file had the generic "default_t" label instead of a proper web-content type,
      because SELinux doesn't automatically know a custom directory is meant for web content

## The fix (persistent, not setenforce 0)
semanage fcontext -a -t httpd_sys_content_t "/web/mysite(/.*)?"
restorecon -Rv /web/mysite

## Verification
ls -Z /web/mysite/index.html
curl -I http://localhost  -> 200 OK
curl http://localhost     -> <h1>Test Page</h1>

## What I'd improve
Wrap this into a script that checks for and fixes SELinux context automatically 
whenever a new DocumentRoot is configured, instead of doing it as a manual 
follow-up step after hitting a real error.
