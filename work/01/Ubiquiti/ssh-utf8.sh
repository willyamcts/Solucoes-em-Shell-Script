#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 05/06/2017;
#
# Descrição: Altera as configurações de equipamentos Ubiquiti 
#	(AirOS 5 ou superior) para o padrão de fabrica, ou, se o
#	equipamento já estiver resetado, é liberado Compliance 
#	Test no mesmo. Após conectar o equipamento Ubiquiti na 
#	rede basta autorizar a execução, esse script é executado 
#	em loop, por conta disso é necessário autorizar a execução.


printf "\n\t Deseja executar? [Y/n]"
	read INPUT

	if [[ $INPUT != y || $INPUT != Y || $INPUT != s || $INPUT != S || ! -z $INPUT ]]; then
		exit
	fi	


ping -s1 -c3 192.168.2.1 1>&2>/dev/null

if [ $? = 0 ]; then
	sshpass -p 'MINHASENHA' ssh -p22 USER@192.168.2.1 'cp /etc/default.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot' || sshpass -p 'MINHASENHA' ssh -p7722 USER@192.168.2.1 'cp /etc/default.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot'

	if [ $? = 0 ]; then
		clear && printf "\n\t\033[0;31m Equipamento resetado com sucesso... \033[0m"
	else
		clear && printf "\n\t\033[0;31m Necessário intervenção manual \033[0m"
	fi


else
	ping -s1 -c3 192.168.1.20 1>&2>/dev/null

	if [ $? = 0 ]; then
		sshpass -p 'ubnt' ssh -p22 ubnt@192.168.1.20 'ls -l /etc/persistent/ct && exit 0 || touch /etc/persistent/ct && cftmtd -w -p /etc && reboot'

		if [ $? = 0 ]; then
			clear && printf "\n\t Compliance Teste criado em 192.168.1.20"
		fi
		
	fi

fi 


$0 0