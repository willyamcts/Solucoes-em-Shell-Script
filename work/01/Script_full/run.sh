#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 07/04/2017;
#
# Descrição: Realiza backup de dispositivos Ubiquiti; gera relatório de 
#	dispositivos Ubiquiti contendo modelo do dispositivo, MAC, usuário
#	PPPOE, AP conectado e seu respectivo sinal; ativação de Compliance 
#	Test em massa; também é possível verificar dispositivos respondentes
#	a ICMP. Os endereços utilizados para uso das funções são inseridos 
#	via interface (zenity) ou de um arquivo, onde #	cada IP deve estar 
#	em uma linha. Está configurado para iniciar sessões SSH nas portas 
#	22 e 7722.
#
# Requisitos: Zenity e SSHPass.


# Adicao de opcoes: incluir em handling e dialogs

### 29/03: Criar função para gerar relatorio, utilizar a função saveFile; ###
### 30/03: Resolver função de relatorio e testar com demais funcoes alem da 2;
### 03/04: Ver como receber o retorno do server nas outras função (alem do report);
	### Ao fazer o backup do arquivo do server, alterar o nome do arquivo para $deviceNAME+$IP
	### Alterar timeout do SSH e estipular limite para execução de lastHand


source ./dialog/dialogs.lxte ./chk/handling.ch


#sed '/$pass/ s/^$mainFunction/#$mainFunction/'

#sed '/$pass/ s/#$mainFunction/$mainFunction/'


# Tratar caso algum metodo retorne erro para encerrar a aplicação;

#exec=$(selectFunction)
#zenity --info --text="$exec" # TODO: teste, verf. retorno

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

