#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 25/05/2017;
#
# Descrição: O objetivo é fazer o upload do firmware para equipamentos
#	Ubiquiti;


DEVICE=$(zenity --width=450 --height=300 \
	--list --text="O que deseja fazer? " \
		--radiolist --column "Check" --column "Modelo equipamento" \
			TRUE "AirGrid M5 HP" FALSE "AP Router" FLASE "Bullet M2" FALSE "Bullet M5" FALSE "LiteBeam M5" FALSE "LiteBeam 5AC" \
			FALSE "NanoBeamM2 400" FALSE "NanoBeam M5 16" FALSE "NanoBeam M5 300" FALSE "Nano Bridge M5" FALSE "Nano Bridge M900" \
			FALSE "Nano Station2" FALSE "Nano Station5" FALSE "NanoStation5 Loco"  FALSE "NanoStation Loco M5" FALSE "NanoStation M5" \
			FALSE "PowerBeam M5 300" FALSE "PowerBeam M2 400" FALSE "PowerBeam 5AC 300" FALSE "PowerBeam 5AC 400" FALSE "PowerBeam 5AC 500" FALSE "PowerBeam 5AC 620" \
			FALSE "PicoStation M2" FALSE "PowerBridge M10" FALSE "Rocket 5AC Lite" FALSE "Rocket M3" FALSE "Rocket M5" FALSE "Rocket Titanium") 1>&2>/dev/null



Selecione o arquivo XM e XW



	case $DEVICE in
		xx|xx|xx|xx) file=$(echo "$buildXM" | cut -d. -f1)
			;;
		xx) file=$(echo "$buildXW" | cut -d. -f1)
			;;
		*) exit 10
			;;
	esac


tftp 192.168.1.20 << OEF
binary
put $file
OEF