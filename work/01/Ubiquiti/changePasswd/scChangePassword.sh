#!/bin/bash
## Change password for Ubiquiti Devices
## Leandro Fabris Milani May/2015

# current user
USER="USERNAME"
# current password
PWD="YOURPASSWORD"
# new crypt password
NEW_PWD="$1$obOErU0r$s9qwbmp7zfpsF4u.GLb2E/"
# path file that contains IP
FILE="file_ips.txt"

FILEIPS=`cat $FILE`

for IP in $FILEIPS
do
  echo "Connecting to $IP"
  # connect using sshpass
  /usr/bin/sshpass -p $PWD ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $USER@$IP << EXIT
    # remove all users created on device
    sed -i "/users./d" /tmp/system.cfg

    # add new user and password crypted
    echo users.status=enabled >> /tmp/system.cfg
    echo users.1.status=enabled >> /tmp/system.cfg
    echo users.1.password=$NEW_PWD >> /tmp/system.cfg
    echo users.1.name=$USER >> /tmp/system.cfg

    # save all changes and roboot the device
    cfgmtd -w -p /etc
    reboot
EXIT
  echo "Device rebooting..."
done
