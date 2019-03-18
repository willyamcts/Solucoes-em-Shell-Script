#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 22/06/2017;
#
# Descrição: Por meio do ping, verifica qual IP responde 1.20 ou 2.1 
#	e informa no terminal as informações do dispositivo. Funciona em 
#	dispositivos atuando em 5.8GHz e dispositivos Legancy. 
#	* Alterado para executar em derivados do Debian e Arch Linux.


# FUNCAO: Informa na tela qual o modelo do equipamento Ubiquiti, MAC e versão do firmware e usuario PPPoE;
	#	- Caso equipamento responda pelo IP 192.168.2.1 e esteja de acordo com as configurações de cliente USER, é redefinido as configurações para o padrão de fábrica;
	# Caso responda pelo IP 192.168.1.20 é feito a adição de ComplianceTest e alterado a porta de acesso do serviço SSH de 22 para 7722


sshUBNT() {
	sshpass -p 'ubnt' ssh -p$1 -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' ubnt@192.168.1.20 $2
}

sshUBNTDiffieHellman() {
	sshpass -p ubnt ssh -p$1 -o 'KexAlgorithms=+diffie-hellman-group1-sha1' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' ubnt@192.168.1.20 $2
}

sshUSER() {
	sshpass -p MINHASENHA ssh -p22 -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 $1 || sshpass -p MINHASENHA ssh -p7722 -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 $1
}




	#TODO: Em cada execucao vai abrir 2 novos terminais, tratar para serem encerrados ao finalizar a execução
if [ -z $1 ]; then

# Verificar pacote net-tools e sshpass

	(dpkg --get-selections | grep net-tools) || (pacman -Ss net-tools)
	if [ $? != 0 ]; then
		printf "\033[1;32m\n\n\t Necessário pacote net-tools para executar...\033[0m\n\n"
		exit
	fi

	xterm -x bash -c 'ping 192.168.2.1' && xterm -x bash -c 'ping 192.168.1.20' || x-terminal-emulator -x bash -c 'ping 192.168.2.1' && x-terminal-emulator -x bash -c 'ping 192.168.1.20' || xfce4-terminal -x bash -c 'ping 192.168.2.1' && xfce4-terminal -x bash -c 'ping 192.168.1.20' || konsole -x bash -c 'ping 192.168.2.1' && konsole -x bash -c 'ping 192.168.1.20' || lxterminal -e 'ping 192.168.2.1' && lxterminal -e 'ping 192.168.1.20'
# x-terminal-emulator --window -e 'ping 192.168.2.1' || x-terminal-emulator --window -e 'ping 192.168.1.20'
fi


read -p " Deseja executar? [S/n] " answer

	if [[ -z $answer || $answer == "s" || $answer == "S" ]]; then
		unset answer


		ping -s1 -c2 192.168.1.20 1>&2>/dev/null

		if [ $? = 0 ]; then
			mac=$(arp -a 192.168.1.20 | cut -d" " -f4)
			ip='192.168.1.20'

			infos=$(sshUBNT 22 'echo -n $(cat /etc/board.info | grep board.hwaddr | cut -d= -f2):22+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-); (ls -l /etc/persistent/ct > /dev/null && echo "+Presente") || (touch /etc/persistent/ct && sed -i 's/sshd.port=.*/sshd.port=7722/' /tmp/system.cfg && cfgmtd -w -p /etc && echo "+Adicionando..." && reboot)' "ARG1") 1>&2>/dev/null
			out=$(echo $?)

			if [[ $out != 0 && $out != 5 ]]; then
				infos=$(sshUBNT 7722 'echo -n $(cat /etc/board.info | grep board.hwaddr | cut -d= -f2):7722+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-); (ls -l /etc/persistent/ct > /dev/null && echo "+Presente") || (touch /etc/persistent/ct && cfgmtd -w -p /etc && echo "+Adicionando..." && reboot)' "ARG1") 1>&2>/dev/null
				out=$(echo $?)


				if [[ $out != 0 && $out != 5 ]]; then
					infos=$(sshUBNTDiffieHellman 22 'echo -n $(cat /etc/board.info | grep board.hwaddr | cut -d= -f2):22+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-); (ls -l /etc/persistent/ct > /dev/null && echo "+Presente") || (touch /etc/persistent/ct && sed -i 's/sshd.port=.*/sshd.port=7722/' /tmp/system.cfg && cfgmtd -w -p /etc && echo "+Adicionando..." && reboot)') 1>&2>/dev/null
					out=$(echo $?)

					if [[ $out != 0 && $out != 5 ]]; then
					infos=$(sshUBNTDiffieHellman 7722 'echo -n $(cat /etc/board.info | grep board.hwaddr | cut -d= -f2):7722+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-); (ls -l /etc/persistent/ct > /dev/null && echo "+Presente") || (touch /etc/persistent/ct && cfgmtd -w -p /etc && echo "+Adicionando..." && reboot)') 1>&2>/dev/null
						out=$(echo $?)

					fi

				fi

			fi


		else

			ping -s1 -c2 192.168.2.1 1>&2>/dev/null

			if [ $? = 0 ]; then
				mac=$(arp -a 192.168.2.1 | cut -d" " -f4)
				ip='192.168.2.1'

					### SSHAPASS PROPRIETÁRIO - Get user (to report) and reset default conf ###
				infos=$(sshUSER 'echo "$(cat /etc/board.info | grep board.hwaddr | cut -d= -f2)+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-)" && (cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot)' "ARG1") 1>&2>/dev/null
				out=$(echo $?)

#				if [[ $out != 0 && $out != 5 ]]; then
#					infos=$(sshUSER 'echo "$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-)" && (cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot)' "ARG1") 1>&2>/dev/null
#					out=$(echo $?)

					if [[ $out != 0 && $out != 5 ]]; then
						infos=$(sshpass -p MINHASENHA ssh -p22 -o 'KexAlgorithms=+diffie-hellman-group1-sha1' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'echo "$(cat /etc/board.info | grep board.hwaddr | cut -d= -f2)+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-)" && (cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot)') 1>&2>/dev/null
						out=$(echo $?)

						if [[ $out != 0 && $out != 5 ]]; then
							infos=$(sshpass -p MINHASENHA ssh -p7722 -o 'KexAlgorithms=+diffie-hellman-group1-sha1' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'echo "$(cat /etc/board.info | grep board.hwaddr | cut -d= -f2)+$(cat /etc/board.info | grep board.name | cut -d= -f2)+$(cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2)+$(cat /etc/version | cut -d. -f2-)" && (cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot)') 1>&2>/dev/null
							out=$(echo $?)

						fi

					fi
##				fi


			else

				clear && printf "\033[1;33m\tNenhum dispositivo disponível em 192.168.1.20 e 192.168.2.1\n\n \033[0m" && $0 0
			fi

		fi




		 # Make screen report
			clear

			if [[ $out -eq 0 && $ip = '192.168.1.20' ]]; then
				mac=$(echo "$infos" | cut -d+ -f1)
				device=$(echo "$infos" | cut -d+ -f2)
				version=$(echo "$infos" | cut -d+ -f3)
				statusCT=$(echo "$infos" | cut -d+ -f4)
				printf "\033[1;32m\n $device\t$mac\n   Versão: $version \n   Compliance Test: $statusCT \033[0m\n\n"

			elif [[ $out -eq 0 && $ip = '192.168.2.1' ]]; then
				mac=$(echo "$infos" | cut -d+ -f1)
				device=$(echo "$infos" | cut -d+ -f2)
				client=$(echo "$infos" | cut -d+ -f3)
				version=$(echo "$infos" | cut -d+ -f4)
				printf "\033[1;32m\n $device\t$mac\n   Cliente: $client\n   Versão: $version \033[0m\n\n"

			elif [ $out = 5 ]; then
				printf "\033[1;31m\n\t $ip: Credenciais inválidas \033[0m\n\n"
				printf "\033[1;32m MAC LAN: $mac\n\n \033[0m \033[0m\n\n"

			else
				printf "\033[1;32m\n MAC LAN: $mac\n $version \033[0m\n\n"

			fi


		$0 0

	fi
