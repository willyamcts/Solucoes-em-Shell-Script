#!/bin/sh

# Ativa porta 443 e 80
# Altera porta ssh para 7722

chkResult() {
	if [ $? = 0 ]; then

		rm -f $0
		size=`du -hsk /tmp/ | awk '{print $1}'`

		if [ $size -gt 100 ]; then
			reboot
			return 10
		else

			fullver=`cat /etc/version | cut -d"v" -f2`
			if [ "'$fullver'" != $1 ]; then
				versao=`cat /etc/version | cut -d'.' -f1`
				cd /tmp

				if [ "$versao" == "XM" ]; then
					URL='http://meuftp.com/down.php?id=23'
					wget -c $URL
					mv /tmp/down.php?id=23 /tmp/v$1.bin
				else
					URL='http://meuftp.com/down.php?id=24'
					wget -c $URL
					mv /tmp/down.php?id=24 /tmp/v$1.bin
				fi
			ubntbox fwupdate.real -m /tmp/v$1.bin && exit
			fi
		fi
	fi
}

cd /etc/persistent
#Remove the virus
rm mf.tar
	chkResult
rm -Rf .mf
	chkResult
rm -Rf mcuser
	chkResult
rm rc.poststart
rm rc.prestart
rm cardlist.txt
sed -ir '/mcad/ c ' /etc/inittab
	chkResult
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
