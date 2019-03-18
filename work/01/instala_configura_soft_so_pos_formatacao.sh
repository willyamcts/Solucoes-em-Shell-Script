#!/bin/bash

#
# Autor: Willyam Castro;
#
# Data: Julho 2017;
#
# Descrição: Instalação e configuração de determinados pacotes básicos a serem 
#	alterados em caso de formatação da minha máquina de trabalho - Debian;


#Add: Retorno final com todas as mudanças realizadas;

entryKey(){
	printf("Pressione <ENTER> para prosseguir")
	read
}


clear

printf "\n\tSuper user previlegies required."

local_user=$USER


sudo dpkg --add-architecture i386
	test1=$(echo $?)

sudo apt-get update
	if [ $? = 0 ]; then
		sudo apt-get install wine nmap tcpdump ssh sshpass tftp -y 1>&2>/dev/null
			test2=$(echo $?)
		sudo apt-get install icedtea-netx xfburn -y 1>&2>/dev/null
			test3=$(echo $?)
		sudo apt-get install -f
	else
		printf "\n\n\t \033[1;31m Erro ao atualizar lista de pacotes... \033[0m\n"
		break
	fi


if [ $test1 -eq 0 ]; then
	printf "\n\n\t[ \033[1;32mX\033[0m ] Add support architecture i386;\n"
fi

if [ $test2 -eq 0 ]; then
	printf "\t[ \033[1;032mX\033[0m ] Install Wine, NMAP, TCPDUMP, SSH, SSHPASS and TFTP;\n"
else
	printf "\t[ \033[1;31m-\033[0m ] Install Wine, NMAP, TCPDUMP, SSHPASS, SSH and TFTP;\n"
fi

if [ $test3 -eq 0 ]; then
	printf "\t[ \033[1;32mX\033[0m ] Install Icedtea-netx and XfBurn;\n"
else
	printf "\t[ \033[1;31m-\033[0m ] Install Icedtea-netx and XfBurn;\n"
fi



# Download install java - Baixa o arquivo e o extrai em /usr/java

(uname -a | grep amd64) || (uname -a | grep x64)
	out=$?

	mkdir /usr/java
	cd /usr/java

		if [ $out = 0]; then
			wget -c -O "java-x64-gnu.tar.gz" http://javadl.oracle.com/webapps/download/AutoDL?BundleId=220305_d54c1d3a095b4ff2b6607d096fa80163 
			tar zxvf java-x64-gnu.tar.gz && rm java-x64-gnu.tar.gz
		else
			wget -c -O "java-x86-gnu.tar.gz" http://javadl.oracle.com/webapps/download/AutoDL?BundleId=220303_d54c1d3a095b4ff2b6607d096fa80163
			tar zxvf java-x86-gnu.tar.gz && rm java-x86-gnu.tar.gz
		fi


#apt-get install default-jdk default-jre






entryKey && clear; echo
PORT_SSH=22
read -p "	Deseja alterar a porta de serviço do SSH? [S/n] " answer
	if [[ -z $answer ||  $answer = y || $answer = Y || $answer = S || $answer = s ]]; then
#		nano /etc/ssh/sshd_config

		read -p " Informe a porta: " PORT_SSH

		printf "Super user previlegies required."
			sed -i "s/.*Port.*/Port $PORT_SSH/" /etc/ssh/sshd_config
			service ssh restart
			service ssh status | grep $PORT_SSH 1>&2>/dev/null

			if [ $? != 0 ]; then
				clear && entryKey && printf "\t Falha ao alterar a porta de serviço do SSH\n\t
					Altere manualmente em /etc/ssh/sshd_config"
			fi

	fi

entryKey
clear && printf "Removendo serviço exim4 (MTA) da inicialização..."
update-rc.d exim4 remove



# Adicionando regras de firewall, filtragem de porta etc.

echo "iptables -A INPUT -s 127.0.0.1/32 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 177.xx.xx.xx/22 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 10.0.0.0/8 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 172.16.0.0/16 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 192.168.0.0/16 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 194.170.100.0/24 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -s 194.170.200.0/24 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT ! -s 177.xx.xx.xx/22 -p tcp -m tcp --dport 111 -j DROP
iptables -A INPUT ! -s 177.xx.xx.xx/22 -p udp -m udp --dport 111 -j DROP
iptables -A INPUT ! -s 177.xx.xx.xx/22 -p tcp -m tcp --dport 631 -j DROP
iptables -A INPUT ! -s 177.xx.xx.xx/22 -p udp -m udp --dport 631 -j DROP
iptables -A INPUT -p tcp -m tcp --dport $PORT_SSH -m state --state NEW -m recent --update --seconds 300 --hitcount 2 --name DEFAULT --mask 255.255.255.255 --rsource -j LOG --log-prefix "Tentativas SSH "
iptables -A INPUT -p tcp -m tcp --dport $PORT_SSH -m state --state NEW -m recent --set --name DEFAULT --mask 255.255.255.255 --rsource
iptables -A INPUT -p tcp -m tcp --dport $PORT_SSH -m state --state NEW -m recent --update --seconds 300 --hitcount 2 --name DEFAULT --mask 255.255.255.255 --rsource -j DROP
iptables -A INPUT -s 233.89.188.1/32 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT ! -s 177.xx.xx.xx/32 -p tcp -m tcp --dport 2210 -j DROP
iptables -A INPUT ! -s 177.xx.xx.xx/32 -p tcp -m tcp --dport 2211 -j DROP
iptables -A INPUT -s 233.89.188.1/32 -p tcp -m multiport --dports 5432,9081,9082 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 5432,9081,9082 -j DROP" > /etc/init.d/iptbd

update-rc.d iptbd defaults



printf "\n\tAlterar execucao de arquivos *.jnlp para javaws"



## Anotações ##

	#nano /etc/apt/sources.list
	#apt-get update
#
## Additing support architecture x86
	#dpkg --add-architecture i386
	#apt-get update
#
#
##Install SSHPASS
	#apt-get install sshpass -y
#
## Install Wine
	#apt-get install wine32 -y
#
## Install NMAP
	#apt-get install nmap -y
#
#
## Install Office package
	#firefox http://wps-community.org/downloads
	#cd Downloads
	#dpkg -i [package WPS OFFICE]
#
#
## Update package list and install dependency
	#apt-get update; apt-get install -f
#
#
## Install winbox and Dude
	#wget -c 'https://download2.mikrotik.com/routeros/winbox/3.11/winbox.exe'
	#wget -c 'https://download2.mikrotik.com/routeros/6.38.1/dude-install-6.38.1.exe'
	#chown willyam:willyam *; su willyam -c 'wine32 winbox.exe; wine32 dude-install-6.38.1.exe'
#
## Downloading Google Chrome
	#firefox https://www.google.com/chrome/browser/desktop/
#
#
## Install driver HP
	#clear; lsb release -a
	#firefox http://hplipopensource.com/hplip-web/install_wizard/index.html
#
#
## Add new user, USER
	#useradd -m -p MyPassword USER
	#(echo MyPassword; sleep2; echo MyPassword) | passwd USER
#
#
## Change time GRUB sleep
	#sed 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub || sed 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=0/' /etc/default/grub
#
#
## Install HPLIP
	#wget -c 'http://prdownloads.sourceforge.net/hplip/hplip-3.16.11.run'
	#sh hplip-3.16.11.run
#
## Install Java
	##	Ao fazer o download adicionar parametro para alterar o nome do arquivo e seguir com os comandos abaixo;
	##wget -c 'http://javadl.oracle.com/webapps/download/AutoDL?BundleId=218823_e9e7ea248e2c4826b92b3f075a80e441'
	## cp [nome_arquivo] /var/run/
	## tar -xvf /var/run/[nome_arquivo]
#
## Chehck version SO
	##uname
	##lsb_release -a
#



