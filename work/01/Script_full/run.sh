#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 25/04/2017 - 18:54;
#
# Descrição: Pode realizar backup de dispositivos MikroTik e Ubiquiti; 
#	altera credenciais de dispositivos Ubiquiti; gera relatório de 
#	dispositivos Ubiquiti contendo modelo do dispositivo, MAC, usuário
#	PPPOE, AP conectado e seu respectivo sinal; adiciona Compliance 
#	Test e habilita-o em massa, bem como altera canais para enlace em AP 
#	em massa; também é possível verificar dispositivos respondentes a 
#	ICMP. Os endereços utilizados para uso das funções são inseridos via 
#	interface (zenity) ou de um arquivo, onde cada IP deve estar em uma 
#	linha. Está configurado para iniciar sessões SSH nas portas 22 e 
#	7722. Aplicável somente a AirOS atuando em 5.8 GHz.
#
# Requisitos: Zenity e SSHPass.


source ./dialog/dialogs.lxte ./chk/handling.ch

# Tratar caso algum metodo retorne erro para encerrar a aplicação;

checkPackages

selectFunction

selectModeExecution

saveFileReport

$modeFunction

# TODO: Teste 2 linhas xfce
#	xfce4-terminal -x bash -c "echo -ne $UaP; sleep 10"
#	xfce4-terminal -x bash -c "echo -ne $pass; sleep 10"



#######################################################

#DST=$(saveFile "arg1")

#echo " ======= LOG $(date +%d.%m.%y) - $exec ======= " >> $DST



#for i in $(cat $1); do
#	out=$(startAccess $user $pass $i)
#	echo "$out" >> $DST
#		
#done

