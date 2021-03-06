#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 09/05/2017;
#
# Descrição: Faz backup de equipamentos Ubiquiti com o intuito de
#	fazer varredura na rede por dispositivos com a configuração 
#	de fábrica, respondendo pelo IP padrão e implementar a 
#	restauração do backup no equipamento, caso exista o backup do
#	mesmo no diretório de backups.
#
# Requisitos: Zenity e SSHPass.


# Adicao de opcoes: handling e dialogs

# 17/04: Mesmo dia 15 + adaptação CT (Somente adicionar CT ou também 
#	setar CT;
# 19/04: Acrescentar tempo de execução no relatório;


source ./dialog/dialogs.lxte ./chk/handling.ch


# Tratar caso algum metodo retorne erro para encerrar a aplicação;

checkPackages

infoUsage

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

