#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 30/05/2017;
#
# Descrição: Registra MAC do dispositivo ao selecionar o modelo, para fins de 
#	teste de bom funcionamento do dispositivo. Funciona em dispositivos 
#	atuando em 5.8GHz e dispositivos Legancy.	
#	- Por meio do ping, verifica qual IP responde 1.20 ou 2.1 e verifica o MAC
#	- Verificado o MAC, o modelo selecionado na lista e o MAC sao adicionados ao 
#		arquivo "testadados_[DIA-MES]" do diretório atual.
#	Adiciona Compliance Test ao equipamento.



sshUBNT() {
	sshpass -p 'ubnt' ssh -p22 -o 'StrictHostKeyChecking no' ubnt@192.168.1.20 $1
}


## Em cada execucao vai abrir 2 novos terminais, tratar para serem encerrados ao finalizar a execução
#if [ -z $1 ]; then
#	xterm -x bash -c 'ping 192.168.1.20' && xterm -x bash -c 'ping 192.168.2.1' || x-terminal-emulator -x bash -c 'ping 192.168.1.20' && x-terminal-emulator -x bash -c 'ping 192.168.2.1' || xfce4-terminal -x bash -c 'ping 192.168.1.20' && xfce4-terminal -x bash -c 'ping 192.168.2.1' || konsole -x bash -c 'ping 192.168.1.20' && konsole -x bash -c 'ping 192.168.2.1' || lxterminal -x bash -c 'ping 192.168.1.20' && lxterminal -x bash -c 'ping 192.168.2.1'
#fi


DEVICE=$(zenity --width=450 --height=300 \
	--list --text="O que deseja fazer? " \
		--radiolist --column "Check" --column "Função" \
			TRUE "AirGrid M5 HP" FALSE "AP Router" FLASE "Bullet M2" FALSE "Bullet M5" FALSE "LiteBeam M5" FALSE "LiteBeam 5AC" \
			FALSE "NanoBeamM2 400" FALSE "NanoBeam M5 16" FALSE "NanoBeam M5 300" FALSE "Nano Bridge M5" FALSE "Nano Bridge M900" \
			FALSE "Nano Station2" FALSE "Nano Station5" FALSE "NanoStation5 Loco"  FALSE "NanoStation Loco M5" FALSE "NanoStation M5" \
			FALSE "PowerBeam M5 300" FALSE "PowerBeam M2 400" FALSE "PowerBeam 5AC 300" FALSE "PowerBeam 5AC 400" FALSE "PowerBeam 5AC 500" FALSE "PowerBeam 5AC 620" \
			FALSE "PicoStation M2" FALSE "PowerBridge M10" FALSE "Rocket 5AC Lite" FALSE "Rocket M3" FALSE "Rocket M5" FALSE "Rocket Titanium") 1>&2>/dev/null

case $? in 
	1) kill -9 $$
		;;
esac


dstFile="testados_$(date +%d-%m)"



ping -s1 -c2 192.168.1.20 1>&2>/dev/null

if [ $? = 0 ]; then
	mac=$(arp -a 192.168.1.20 | cut -d" " -f4)

TODO: Se o MAC existir no arquivo deve ser feito acesso SSH e dar aviso na tela se foi criado compliance ou nao;
	grep $mac $dstFile &
#	if [[ $? = 0 && -n $(grep $mac $dstFile | cut -f3) ]]; then
	if [[ $? = 0 ]]; then
#		sshpass -p 'ubnt' ssh -p22 -o 'StrictHostKeyChecking no' ubnt@192.168.1.20 'ls -l /etc/persistent/ct || touch /etc/persistent/ct && cfgmtd -w -p /etc && reboot'
		sshUBNT 'ls -l /etc/persistent/ct || (touch /etc/persistent/ct && cfgmtd -w -p /etc && reboot)'
		out=$(echo $?)

grep $mac $dstFile
echo "MAC existe no arquivo" && exit
		# Report screen 192.168.1.20;
			if [ $out = 0 ]; then
				printf "\033[1;30m\t Compliance adicionado em $DEVICE\t$mac\033[0m\n"
			else
				printf "\033[1;31m Falha ao adicionar CT em $DEVICE\t$mac\n"
			fi
	else

grep $mac $dstFile
echo "MAC nao está no arquivo" && exit

#		sshUBNT 'ls -l /etc/persistent/ct || touch /etc/persistent/ct && cfgmtd -w -p /etc && reboot'
#		sshpass -p 'ubnt' ssh -p22 -o 'StrictHostKeyChecking no' ubnt@192.168.1.20 'ls -l /etc/persistent/ct || touch /etc/persistent/ct && cfgmtd -w -p /etc && reboot'
		out=$(echo $?)

		# Make report 192.168.1.20;
			if [ $out = 0 ]; then
				printf "$DEVICE\t$mac\n" >> "$dstFile"
				printf "\033[1;30m\t Compliance adicionado em $DEVICE\t$mac\033[0m\n"
			else
				printf "\033[1;31m Falha ao adicionar CT em $DEVICE\t$mac\n"
			fi





#		clear && printf "\t Este dispositivo já está incluso no log \n\n"
	fi



else

	ping -s1 -c2 192.168.2.1 1>&2>/dev/null

	if [ $? = 0 ]; then
		mac=$(arp -a 192.168.2.1 | cut -d" " -f4)

		
		client=$(sshpass -p MINHASENHA ssh -p22 -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2 && cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot') 1>&2>/dev/null
		out=$(echo $?)

		if [[ $out != 0 && $out != 5 ]]; then
			client=$(sshpass -p MINHASENHA ssh -p7722 -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2 && cp /usr/etc/system.cfg /tmp/system.cfg && cfgmtd -w -p /etc && reboot') 1>&2>/dev/null
			out=$(echo $?)


			if [[ $out != 0 && $out != 5 ]]; then
				client=$(sshpass -p MINHASENHA ssh -p22 -o 'KexAlgorithms=+diffie-hellman-group1-sha1' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2') 1>&2>/dev/null
				out=$(echo $?)

				if [[ $out != 0 && $out != 5 ]]; then
					client=$(sshpass -p MINHASENHA ssh -p7722 -o 'KexAlgorithms=+diffie-hellman-group1-sha1' -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking no' USER@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2') 1>&2>/dev/null
					out=$(echo $?)

				fi
			fi
		fi

		# Make report 192.168.2.1;
			if [ $out = 0 ]; then
				printf "$DEVICE\t$mac\t$client\n" >> "$dstFile"
				clear && tail -n1 "$dstFile" && (echo; echo)
			elif [ $out = 5 ]; then
				clear && printf "\t\t\**** \033[1;31mATENÇÂO:\033[0m Usuário e/ou senha inválido(s) **** \n\n"
			else
				echo
			fi

	else 
		clear && printf "\tNenhum dispositivo disponível em 192.168.1.20 e 192.168.2.1\n\n"
	fi
fi

$0 0