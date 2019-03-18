#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 09/05/2017;
#
# Descrição: Realiza backup de dispositivos MikroTik e  Ubiquiti; gera 
#	relatório de dispositivos Ubiquiti contendo modelo do dispositivo, 
#	MAC, usuário PPPOE, AP conectado e seu respectivo sinal; ativação 
#	de Compliance Teste, altera de canal(is) de atuação, atualiza 
#	dispositivos Ubiquiti e altera as credenciais em massa (de 
#	dispositivos Legancy); também é possível verificar dispositivos 
#	respondentes a ICMP. Os endereços utilizados para uso das funções 
#	são inseridos via interface (zenity) ou de um arquivo, onde cada 
#	IP deve estar em uma linha. Está configurado para iniciar sessões 
#	SSH nas portas 22 e 7722.
#
# Requisitos: Zenity e SSHPass.


# Adicao de opcoes: handling e dialogs

# Adaptação CT (Somente adicionar CT ou também setar CT;
# Acrescentar tempo de execução no relatório - ao fim, alterar
#  linha com sed;


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

