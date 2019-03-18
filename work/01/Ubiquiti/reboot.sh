#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 14/12/2016;
#
# Descrição: Reinicia dispositivos Ubiquiti via SSH,
#	com base na faixa de IP informada abaixo.


reboot() {

	for ip in 10.{76,79,78}.{254..170}.{5..254}; do
		test &
	done
}


test() {
		ping -c2 $ip

		if [ $? = 0]; then
			sshpass -p MINHASENHA ssh -p 22 -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" USER@$ip 'reboot' > /dev/null

			if [ $? = 0 ]; then
				echo " [OK] $ip"
			fi

		fi

}

reboot 
