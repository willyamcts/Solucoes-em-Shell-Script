#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 10/04/2017;
#
# Descrição: Registra MAC do dispositivo ao selecionar o modelo, para fins de 
#	teste de bom funcionamento do dispositivo;
#	- Por meio do ping, verifica qual IP responde 1.20 ou 2.1 e verifica o MAC
#	- Verificado o MAC, o modelo selecionado na lista e o MAC sao adicionados ao 
#		arquivo "testadados_[DIA-MES]" do diretório atual.

user="USER"
password="YOURPASSWORD"

DEVICE=$(zenity --width=450 --height=300 \
	--list --text="O que deseja fazer? " \
		--radiolist --column "Check" --column "Função" \
			TRUE "Air Grid" FALSE "AP Router" FLASE "Bullet M2" FALSE "Bullet M5" FALSE "LiteBeam M5" FALSE "LiteBeam 5AC" \
			FALSE "NanoBeamM2 400" FALSE "NanoBeam M5 16" FALSE "NanoBeam M5 300" FALSE "Nano Bridge M5" FALSE "Nano Bridge M900" \
			FALSE "Nano Station2" FALSE "Nano Station5" FALSE "NanoStation5 Loco"  FALSE "NanoStation Loco M5" FALSE "NanoStation M5" \
			FALSE "PowerBeam M5 300" FALSE "PowerBeam M2 400" FALSE "PowerBeam 5AC 300" FALSE "PowerBeam 5AC 400" FALSE "PowerBeam 5AC 500" FALSE "PowerBeam 5AC 620" \
			FALSE "PicoStation M2" FALSE "PowerBridge M10" FALSE "Rocket 5AC Lite" FALSE "Rocket M3" FALSE "Rocket M5" FALSE "Rocket Titanium")

case $? in 
	1) kill -9 $$
		;;
esac



ping -s1 -c2 192.168.1.20 > /dev/null

if [ $? = 0 ]; then
	mac=$(arp -a 192.168.1.20 | cut -d" " -f4)
	printf "%s\t%s\n" "$DEVICE" "$mac" >> "testados_$(date +%d-%m)"

else	
	mac=$(arp -a 192.168.2.1 | cut -d" " -f4)
	client=$(sshpass -p "$password" ssh -p22 -o 'StrictHostKeyChecking no' "$user"@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2') || $(sshpass -p7722 -o 'StrictHostKeyChecking no' "$user"@192.168.2.1 'cat /tmp/system.cfg | grep ppp.1.name= | cut -d= -f2') 

	printf "%s\t%s\t%s\n" "$DEVICE" "$mac" "$client" >> "testados_$(date +%d-%m)"

fi

$0