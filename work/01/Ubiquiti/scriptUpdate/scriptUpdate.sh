#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 19/12/2016;
#
# Descrição: Faz atualização de firmware de dispositivos Ubiquiti 5.8 GHz.
#	Alterar linha 64 e arquivo contentMainBlock.part.


source contentExecution.part
source contentMainBlock.part

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
#	da funcao comandoUpdate; Apos update faz a verificacao de IPs com versao
#	do firmware, equipamentos com versao fora da atual sao reiniciados e apos
#	2min e aplicado novamente commandUpdate em cima desses IPs. Por fim
#	gera um relatorio simples de execucao presente em ./ouput.txt;


arcAddress='/tmp/address_responding.txt'
arcReport='./report.out'
arcLog='/tmp/log_update.out'


# Chamada de blocos essenciais para execução.
blocoPrincipal(){

	# chamada da funcao;
	removeFiles

	# chamada da funcao;
	checkSSHPackage

	if [ $? = 11 ]; then
		kill -9 $$
		exit
	fi

	# Range de IPs
	for ip in $oct1.{76,79}.{254..170}.{5..254} ; do
#	for ip in $oct1.{76,79}.{3..70}.{5..254} ; do
#	for ip in $oct1.{76,78,79}.{42,40,74,73,3}.{5..254} ; do
		# chamada da funcao verifica IPs ativos;
		verifyAddressReply > /dev/null &

		# Saida em tela, informando qual faixa esta verificando
		addr=`echo $ip | cut -d. -f4`
		if [ $addr = 0 ]; then
			clear; echo
			echo " 		Verificando IPs da faixa [ $ip/24 ] "
		fi

	done

	date=`date +%H:%M" - "%d/%m/%Y`
	creatingScript $CURRENTVERSION > /tmp/.script.sh

}


# Manipula informações que serão utilizadas no bloco de execução.
blocoDeExecucao(){

	# quantidade de linhas do arquivo /tmp/address_responding;
	qtLines=`wc -l $2 | cut -d " " -f1`

	# respectivo IP presente na linha;
	for ((linhaAtual=1; $linhaAtual <= $qtLines; linhaAtual++)); do

		delArchiveSSH

		# recebe IP da linha especifica
		ip=`sed -n $linhaAtual'p' $2`

		sleep 3
		# Chama função com bloco de comandos a executar;
		$1
#		$currentFunction

	done
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verifyAddressReply(){

	ping -c 2 $ip
	if [ $? = 0 ]; then
		echo $ip >> $arcAddress
	fi

}


# Finaliza processo SSH local apos 5min da sessao iniciada ou ate equipamento
#	deixar de responder.

killSession(){
date=`echo \`date +%s\` + '540' | bc`
	until [ `date +%s` -eq $date ]; do
		ping -c2 $ip

		if [ $? != 0 ]; then
			killall sshpass > /dev/null
			exit 0
		fi
	done

	killall sshpass > /dev/null
	exit 0

}


# 1- Bloco execução, envia script e o executa no equipamento.
comandoUpdate(){

	echo; echo
	sshpass -p $PASSWORD scp -P $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" /tmp/.script.sh $USER@$ip:/tmp/script.sh > /dev/null
	retorno=$?

	# Verfica erro na transferencia via SCP;
	if [ $retorno != 0 ] ; then
		content="Falha ao enviar script, $retorno"

	else

		killSession > /dev/null &
		PIDKSSH=$!

		delArchiveSSH; sleep 1

		sshpass -p $PASSWORD ssh -p $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER@$ip 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?

		content="Falha conexão SSH, $retorno"
#		content=$retorno

		# Kill sessao SSH
		kill -9 $PIDKSSH > /dev/null &

	fi

	echo "$ip	$content" >> $arcLog
}


# 1- Bloco execução,
accessVersion(){
	delArchiveSSH

	clear; echo; echo
	echo "		Verificando versão de $ip"

	version=`sshpass -p $PASSWORD ssh -p $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER@$ip 'cat /etc/version | cut -d"v" -f2'` > /dev/null

	echo "$ip	$version" >> /tmp/updates.txt
}



runtime(){
	finalDate=`date +%s`
	addition=`expr $finalDate - $initialDate`
	result=`expr 10800 + $addition`
	runtime=`date -d @$result +%H:%M:%S` #tempo
	echo "  Tempo gasto: $runtime"
}


buildReport() {
	blocoDeExecucao accessVersion $arcAddress

	# Info eq. fora da versão atual;
	manualUpdate=`grep -v $CURRENTVERSION /tmp/updates.txt | cut -f1 | wc -l`

	if [ -e $arcReport ] ; then
		echo >> $arcReport
		echo -e "	\n=============== $date ================== " >> $arcReport
	fi

	clear; echo -e "\n			REPORT FINAL:	\n  $manualUpdate equipamento(s) não atualizado(s) de $qtDevices.	" >> $arcReport

	for i in `cat $arcAddress`; do
			echo -n "$i " >> $arcReport
	done

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

echo; echo "Informe a versão atual do firmware: [ex. 5.6.8] "
read CURRENTVERSION
#CURRENTVERSION='5.6.9'

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
echo "	Verificando IPs ativos da faixa especificada na rede, aguarde..."
	blocoPrincipal

sleep 60
	# Verifica existencia de IPs ativos e inicia Upgrade;
	sleep 3; clear; echo
	if [ -e $arcAddress ]; then
		echo "			Iniciando sessões SSH	"; sleep 3; echo
		blocoDeExecucao comandoUpdate $arcAddress
		qtDevices=$qtLines # Quantidade dispositivos
	else
		echo "		Nenhum IP da faixa especificada está ativo."
		exit
	fi


# Tratamento de equipamentos que nao foram atualizados no primeiro
#  comando, inicia aqui!;

# Time 30s
	for temp in {30..1}; do
		echo; echo; echo "			Aguarde... $temp"s""
		sleep 1; clear
	done


# 2.1 - Verifica a versao dos equipamentos;
	if [ -e /tmp/updates.txt ]; then
		rm /tmp/updates.txt
	fi



	blocoDeExecucao accessVersion $arcAddress


echo "GREP -V " >> $arcLog
		grep -v $CURRENTVERSION /tmp/updates.txt | cut -f1 > $arcAddress
		rm /tmp/updates.txt

echo "IF abaixo de GREP -V" >> $arcLog
	# 2.2 - Se conteudo do arquivo address nao for vazio;
	if [ -n `cat $arcAddress` ]; then

		for temp in {90..1}; do
			clear; echo; echo
			echo "			Aguarde $temp"s""
			sleep 1
		done

		# 2.2.2 - Se o arquivo address possuir conteudo ira chamar blockExecution para
		#  executar bloco commandUpdate;
		if [ -e $arcAddress ]; then
# TODO: colocar quantidade $x;
			clear; echo "		Iniciando atualizacoes dos x eq. restantes"
			blocoDeExecucao comandoUpdate $arcAddress
		fi


		# 2.2.3 - Aguarda 2min ate voltar ultimo equipamento atualizado;
		for temp in {120..1}; do
			echo; echo
			echo "			Gerando relatório, aguarde $temp"s""
			sleep 1; clear
		done
	fi


	# Removendo arquivos
	rm /tmp/.script.sh


# 2.3 - Verifica a versao dos equipamentos - 2a vez;
	if [ -e /tmp/updates.txt ]; then
		rm /tmp/updates.txt
	fi

#TODO: redundandte - exitente em buildReport
#	blocoDeExecucao accessVersion $arcAddress #& > /dev/null

# 3 - Gera relatorio e exibe o mesmo
buildReport
cat $arcReport


# Apos verificacao, pega IPs que nao foram atualizados e
# 1- FAZ CHAMADA BLOCO DE EXECUCAO
# 1.2- Substitui o arquivo de leitura, criar uma var para isso
# 2- CHAMA BLOCO DE ACESSO SSH > REBOOT;
# 3- AGUARDA UM TEMPO ANTES DE REEXECUTAR SCRIPT DE UPDATE
