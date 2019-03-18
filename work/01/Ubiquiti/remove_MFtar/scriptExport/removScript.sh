#!/bin/sh

# Ativa porta 443 e 80
# Altera porta ssh para 7722

cd /etc/persistent
#Remove the virus
rm mf.tar
rm -Rf .mf
rm -Rf mcuser
rm rc.poststart
rm rc.prestart
rm cardlist.txt
sed -ir '/mcad/ c ' /etc/inittab
sed -ir '/mcuser/ c ' /etc/passwd
sed -ir '/mother/ c ' /etc/passwd
#Change HTTP port for xxxx | Need access http://IP:xxxx
cat /tmp/system.cfg | grep -v http > /tmp/system2.cfg
cat /tmp/system.cfg | grep -v sshd >> /tmp/system2.cfg
echo "httpd.https.status=enabled" >> /tmp/system2.cfg
echo "httpd.port=80" >> /tmp/system2.cfg
echo "sshd.port=7722" >> /tmp/system2.cfg
echo "httpd.session.timeout=900" >> /tmp/system2.cfg
echo "httpd.status=enabled" >> /tmp/system2.cfg
cat /tmp/system2.cfg > /tmp/system.cfg
rm /tmp/system2.cfg

#Remove equals line
cat /tmp/system.cfg | sort | uniq > /tmp/sys
cat /tmp/sys > /tmp/system.cfg; rm /tmp/sys

#Write new config
cfgmtd -w -p /etc/
cfgmtd -f /tmp/system.cfg -w
#Kill process
kill -HUP `/bin/pidof init`
kill -9 `/bin/pidof mcad`
kill -9 `/bin/pidof init`
kill -9 `/bin/pidof search`
kill -9 `/bin/pidof mother`
kill -9 `/bin/pidof sleep`
reboot
