#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 12/2016 - 12:49;
#
# Descrição: Faz atualização de firmware de dispositivos Ubiquiti 5.8 GHz.
#	Alterar linha 72 e arquivo contentMainBlock.part.


# v16 = Incrementando runtime e data e hora da execucao no arq. report.out
# v18 = Manipulacao arquivos via variavel; Possivel alterar porta SSH;
#	Informa faixa sendo escaneada;
#	- Corrigido: Script kill SSH executando indevidamente;
# v19 =


#	- Corrigido: Erro de relatorio - numero de equipamentos nao atualizados ou nao
#  alcancados;
#	- Lista sequencial de IPs nao atualizados;
# 	- Kill na sessao SSH executando normalmente, finalizando script
#	  killSession no tempo correto, sem interromper sessoes posteriores;
#	- Erro na instalacao do pacote SSHPass, caso nao realize atualizacao de pacotes
#	  apresneta erro e finaliza execucao;


# Verificar quantos dispositivos respondem, se for maior que 50, remover os sleep;
#	- Remover arquivos no fim, nohup.out, .process.kill, .script.sh;


# Overviewer:
#	Verifica IPs ativos na rede e adiciona a um arquivo na
#	pasta temporaria; realizado leitura do arquivo, fazendo chamada
#	da funcao commandUpdate; Apos update faz a verificacao de IPs com versao
#	do firmware, equipamentos com versao fora da atual sao reiniciados e apos
#	2min e aplicado novamente commandUpdate em cima desses IPs. Por fim
#	gera um relatorio simples de execucao presente em ./ouput.txt;


source contentExecution.part
source contentMainBlock.part


arcAddress='/tmp/address_responding.txt'
arcReport='./report.out'
arcLog='/tmp/log_update.out'
arcVersions='/tmp/updates.txt'

qtDevices=0



# Chamada de blocos essenciais para execução.
mainBlock(){

	# chamada da funcao;
	removeFiles

	# chamada da funcao;
	checkSSHPackage

	if [ $? = 11 ]; then
		kill -9 $$
		exit
	fi

	date=`date +%H:%M" - "%d/%m/%Y`
	creatingScript $CURRENTVERSION > /tmp/.script.sh

	# Range de IPs
	for ip in $oct1.{76,79}.{8..8}.{124..160} ; do
#	for ip in $oct1.{76,79}.{3,8,13,10,73,74,113}.{5..254} ; do

		# chamada da funcao verifica IPs ativos;
		verifyAddressReply $ip #> /dev/null &

		# Saida em tela, informando qual faixa esta verificando
		addr=`echo $ip | cut -d. -f4`
		if [ $addr = 0 ]; then
			clear; echo
			echo " 		Verificando IPs da faixa [ $ip/24 ] "
		fi

	done
}




# Verifica IPs ativos (via ICMP) na rede e executa função de update
verifyAddressReply(){

	ping -c 2 $1 > /dev/null
	if [ $? = 0 ]; then
		echo $1 >> $arcAddress

		commandUpdate $1


		((qtDevices++))
#TODO: Teste
echo $qtDevices
	fi


}




# Finaliza processo SSH local apos 5min da sessao iniciada ou ate equipamento
#	deixar de responder.
killSession(){
date=`echo \`date +%s\` + '540' | bc`
	until [ `date +%s` -eq $date ]; do
		ping -c2 $1

		if [ $? != 0 ]; then
			killall sshpass > /dev/null
			exit 0
		fi
	done

	killall sshpass > /dev/null
	exit 0

}


# Bloco execução, envia script e o executa no equipamento.
commandUpdate(){

	echo; echo
	
		killSession $1 > /dev/null &
		PIDKSSH=$!

		cat /tmp/.script.sh | sshpass -p $PASSWORD ssh -p $PORTSSH \
			-o "ConnectTimeout=5" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null"\
				$USER@$1 'cat >> /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?

		if [ $retorno = 0 ]; then
			content="Update sucess"

#TODO: Temporario - remover linha ssh -p 22
		elif [ $retorno = 255 ]; then
			cat /tmp/.script.sh | sshpass -p $PASSWORD ssh -p 22 \
			-o "ConnectTimeout=5" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null"\
				$USER@$1 'cat >> /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'


		else
			content="Update failed, $retorno"
		fi


		# Kill sessao SSH
		kill -9 $PIDKSSH > /dev/null &

	echo "$1	$content" >> $arcLog
}


# Check version devices by $arcAddress
accessVersion(){

	for ip in `cat $arcAddress`; do
		
		clear; echo; echo
		echo "		Verificando versão de $ip"

		version=`sshpass -p $PASSWORD ssh -p $PORTSSH \
				-o "ConnectTimeout=5" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" \
					$USER@$ip 'cat /etc/version | cut -d"v" -f2'` > /dev/null

		if [ $? = 255 ]; then
					version=`sshpass -p $PASSWORD ssh -p 22 \
				-o "ConnectTimeout=5" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" \
					$USER@$ip 'cat /etc/version | cut -d"v" -f2'` > /dev/null
		fi

		echo "$ip	$version" >> $arcVersions

	done
}


# Does the count runtime;
runtime(){
	finalDate=`date +%s`
	addition=`expr $finalDate - $initialDate`
	result=`expr 10800 + $addition`
	runtime=`date -d @$result +%H:%M:%S` #tempo
	echo "  Tempo gasto: $runtime"
}


# Build file report using checkVersion function;
buildReport() {
	accessVersion

	# Info eq. fora da versão atual;
	manualUpdate=`grep -v $CURRENTVERSION $arcVersions | cut -f1 | wc -l`

		echo >> $arcReport
		echo -e "\n	=============== $date - REPORT FINAL ============== \
					\n  $manualUpdate equipamento(s) não atualizado(s) de $qtDevices." >> $arcReport

	for i in `cat $arcAddress`; do
			echo -n "$i " >> $arcReport
	done

	rm -f $arcAddress

	echo >> $arcReport
	runtime >> $arcReport
}




# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear
initialDate=`date +%s`

echo "Informe nome do usuario padrao de acesso aos equipamentos: "
read USER

echo; echo "Informe a senha de acesso aos equipamentos: "
read -s PASSWORD

echo; echo "Informe o IP: "
read IP

echo; echo "Informe a versão atual do firmware: [5.6.8] "
read CURRENTVERSION
#CURRENTVERSION='5.6.8'

echo; echo "SSH port[22]: "
PORTSSH='22'
read PORTSSH

#echo; echo "Informe o link completo para download do firmware $currentVersion: "

#echo "Versao XM: "
#read URLFIRMXM

#echo "Versao XW: "
#read URLFIRMXW

oct1=`echo $IP | cut -d. -f1`; oct2=`echo $IP | cut -d. -f2`
oct3=`echo $IP | cut -d. -f3`; oct4=`echo $IP | cut -d. -f4`



sleep 3; clear; echo
echo "	Verificando IPs ativos e atualizando, aguarde..."
	mainBlock


# Tratamento de equipamentos que nao foram atualizados no primeiro
#  comando, inicia aqui!;

# 2- Verifica a versao dos equipamentos;
	if [ -e $arcVersions ]; then
		rm $arcVersions
	fi

	accessVersion

	# Devices not updated 
	grep -v $CURRENTVERSION $arcVersions | cut -f1 > $arcAddress
	rm -f $arcVersions



	# 2.1- Se conteudo do arquivo address nao for vazio (-n);
	if [ ! -z `cat $arcAddress` ]; then
			clear; echo "		Iniciando atualizacoes dos x eq. restantes"
			for ip in `cat $arcAddress`; do
				verifyAddressReply $ip
			done
	fi

	# Removendo arquivos
	rm -f /tmp/.script.sh

	# 2.2 - Verifica a versao dos equipamentos - 2a vez;
	if [ -e $arcVersions ]; then
		rm $arcVersions
	fi

# 3 - Gera relatorio e exibe o mesmo
buildReport
cat $arcReport


# Apos verificacao, pega IPs que nao foram atualizados e
# 1- FAZ CHAMADA BLOCO DE EXECUCAO
# 1.2- Substitui o arquivo de leitura, criar uma var para isso
# 2- CHAMA BLOCO DE ACESSO SSH > REBOOT;
# 3- AGUARDA UM TEMPO ANTES DE REEXECUTAR SCRIPT DE UPDATE
