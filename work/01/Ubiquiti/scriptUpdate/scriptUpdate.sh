#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 12/2016;
#
# Descrição: Faz atualização de firmware de dispositivos Ubiquiti 5.8 GHz.
#	Alterar linha 43 e arquivo contentMainBlock.part.


source contentExecution.part
source contentMainBlock.part

#	TODO: - esconder saida "nohup";
#	- Saida do arquivo output, colocar IPs em sequencia, nao em linha
#	- Remover arquivos no fim, nohup.out, .process.kill, .script.sh

#	TODO: Aplicar em um unico script alterar nome do arquivo address.txt

# v16 = Incrementando runtime e data e hora da execucao no arq. report.out


#	Verifica IPs ativos na rede e adiciona a um arquivo na
#	pasta temporaria; realizado leitura do arquivo, fazendo chamada
#	da funcao comandoUpdate; Apos update faz a verificacao de IPs com versao
#	do firmware, equipamentos com versao fora da atual sao reiniciados e apos
#	2min e aplicado novamente commandUpdate em cima desses IPs. Por fim
#	gera um relatorio simples de execucao presente em ./ouput.txt;

# Chamada de blocos essenciais para execução.
blocoPrincipal(){

	# chamada da funcao;
	removeFiles

	# chamada da funcao;
	checkSSHPackage

	# Range de IPs
#	for ip in 192.168.2.1 ; do
#	for ip in $oct1.$oct2.$oct3.{10..254} ; do
	for ip in $oct1.{1..254}.{76..79}.{1..254} ; do
#	for ip in $oct1.{1..254}.{1..254}.{1..254} ; do

		# chamada da funcao verifica IPs que respondem
		#	sem retorno em tela;
		verificaRespostaIP > /dev/null &

	done



#TODO: Teste
cp /tmp/address_responding1.txt ./add1.txt
	date=`date +%H:%M" - "%d/%m/%Y`
	pwd=`pwd`
	creatingScript $currentVersion > /tmp/.script.sh

}


# Manipula informações que serão utilizadas no bloco de execução.
blocoDeExecucao(){

	# quantidade de linhas do arquivo /tmp/address_responding;
	qtLinhas=`wc -l "$archive" | cut -d " " -f1`

	# respectivo IP presente na linha;
	for ((linhaAtual=1; "$linhaAtual" <= "$qtLinhas"; linhaAtual++)); do

		delArchiveSSH

		# recebe IP da linha especifica
		ip=`sed -n "$linhaAtual"'p' "$archive"`

		sleep 3
		# Chama função com bloco de comandos a executar;
		$1
#		$currentFunction

	done
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){

	ping -c 2 $ip
	if [ $? = 0 ]; then
		echo $ip >> /tmp/address_responding.txt
	fi

}


# Comando SSH
commandSSH(){
echo "Branco"
	# Necessario passagem do paametro $command - executa no eq.
#	ssh='sshpass -p "$password" ssh "$user"@"$ip" << EXIT
#		$comand
#	EXIT

}


# Finaliza processo SSH local apos 5min da sessao iniciada ou ate equipamento
#	deixar de responder.

#TODO: Alterar para Do While e remover as 2 primeiras linhas
killSession(){
echo 'date=`echo \`date +%s\` + '420' | bc`'
echo '	until [ `date +%s` -eq $date ]; do'
echo "		ping -c2 $ip"

echo '		if [ $? != 0 ]; then'
echo "			killall ssh"
#echo "			rm $pwd/nohup.out"
echo "			exit"
echo "			return 0"
echo "		fi"
echo "	done"

echo "	killall ssh"
#echo "	rm $pwd/nohup.out"
#echo "	return 0"
}


# 1- Bloco execução, envia script e o executa no equipamento.
comandoUpdate(){
	killSession > /tmp/.process.kill
	chmod +x /tmp/.process.kill
# TENTAR CHAMAR SEM NOHUP, PARA EVITAR PROBLEMAS
#	nohup /tmp/.process.kill & > /dev/null
	/tmp/.process.kill 1 > /dev/null&

	echo; echo
	sshpass -p "$password" scp -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" /tmp/.script.sh "$user"@"$ip":/tmp/script.sh
	retorno=$?

	# Verfica erro na transferencia via SCP;
	if [ "$retorno" != 0 ] ; then
		content="Falha ao enviar script, $retorno"

	else
		delArchiveSSH

		sshpass -p "$password" ssh -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$user"@"$ip" 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?
		if [ "$retorno" != 0 ] ; then
			content="Falha conexão SSH, $retorno"
		fi

#	command='chmod +x /tmp/script.sh; /tmp/script.sh'
#	echo "commandSSH
#	commandSSH

	fi

	echo "$ip	$content" >> /tmp/log_update.txt
}



# 1- Bloco execução,
accessVersion(){
	delArchiveSSH

	clear; echo "		Verificando versão dos equipamentos...."
	echo -e "\n\n	$ip"

	version=`sshpass -p "$password" ssh -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$user"@"$ip" 'cat /etc/version | cut -d"v" -f2'`
	echo "$version"

#	command='cat /etc/version | cut -d"v" -f2'
#	version=`commandSSH`
	echo "$ip	$version" >> /tmp/updates.txt
}


# Desuso - introduzido verificacao de restos de arquivos no script
#  enviado ao eq.
#rebootDevices(){
#	sshpass -p "$password" ssh -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$user"@"$ip" 'reboot'
# }


runtime(){
	finalDate=`date +%s`
	addition=`expr $finalDate - $initialDate`
	result=`expr 10800 + $addition`
	runtime=`date -d @$result +%H:%M:%S` #tempo
	echo " Tempo gasto: $runtime"
}


buildReport() {
	archive="/tmp/address_responding.txt"
	blocoDeExecucao accessVersion

	# Info eq. fora da versão atual;
#	manualUpdate=`grep -v "$currentVersion" /tmp/address_responding.txt | cut -f1 | wc -l`
	manualUpdate=`grep -v "$currentVersion" /tmp/updates.txt | cut -f1 | wc -l`

	if [ -e ./report.out ] ; then
		echo >> ./report.out
		echo "	=============== $date ================== " >> ./report.out
	fi

	clear; echo "			REPORT FINAL:	" >> ./report.out
	echo " $manualUpdate equipamento(s) não atualizado(s) de $qtDevices.	" >> ./report.out
	cat /tmp/address_responding.txt >> ./report.out
	runtime >> ./report.out
}


# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear
initialDate=`date +%s`

echo "Informe nome do usuario padrao de acesso aos equipamentos: "
read user

echo; echo "Informe a senha de acesso aos equipamentos: "
read -s password; echo

echo; echo "Informe o IP: (será considerado /16) "
read ip

echo; echo "Informe a versão atual do firmware: "
read currentVersion

echo; echo "Informe o link completo para download do firmware $currentVersion: "
read addressFirmwareDown


oct1=`echo $ip | cut -d. -f1`; oct2=`echo $ip | cut -d. -f2`
oct3=`echo $ip | cut -d. -f3`; oct4=`echo $ip | cut -d. -f4`

sleep 3; clear; echo
echo "	Verificando IPs ativos da faixa especificada na rede, aguarde..."
	blocoPrincipal

	# Verifica existencia de IPs ativos e inicia Upgrade;
	sleep 3; clear; echo
	if [ -e /tmp/address_responding.txt ]; then
		echo "			Iniciando sessões SSH	"; sleep 3; echo
		archive="/tmp/address_responding.txt"
		blocoDeExecucao comandoUpdate
		qtDevices=$qtLinhas
#TODO: Teste
cp /tmp/log_update.txt ./log1
	else
		echo "		Nenhum IP da faixa especificada está ativo."
		exit
	fi


# Tratamento de equipamentos que nao foram atualizados no primeiro
#  comando, inicia aqui!;


# Time 30s
	for temp in {30..1}; do
#		echo; echo; echo "	Iniciando segunda tentativa de update, aguarde... $temp"s""
		echo; echo; echo "			Aguarde... $temp"s""
		sleep 1; clear
	done


# 2.1 - Verifica a versao dos equipamentos;
	archive="/tmp/address_responding.txt"
# TODO: Estava duplicando IPs no fim - para executar a 2a vez, introduzido com abaixo
	if [ -e /tmp/updates.txt ]; then
		rm /tmp/updates.txt
	fi
	blocoDeExecucao accessVersion

#TODO: Teste
cp /tmp/updates.txt ./up1.txt



#TODO: Teste
		grep -v "$currentVersion" /tmp/updates.txt | cut -f1 > /tmp/address_responding.txt
#TODO: Teste
cp /tmp/updates.txt ./up2.txt
cp /tmp/address_responding.txt ./add2.txt
		rm /tmp/updates.txt; sleep 5

	# 2.2 - Se conteudo do arquivo address nao for vazio;
	if [ -n "`cat /tmp/address_responding.txt`" ]; then

		for temp in {90..1}; do
			clear; echo; echo
			echo "			Aguarde $temp"s""
			sleep 1
		done

		# 2.2.2 - Se o arquivo address possuir conteudo ira chamar blockExecution para
		#  executar bloco commandUpdate;
		if [ -e /tmp/address_responding.txt ]; then
# TODO: colocar quantidade $x;
			clear; echo "		Iniciando atualizacoes dos $x eq. restantes"
			archive="/tmp/address_responding.txt"
			blocoDeExecucao comandoUpdate
#TODO :Teste
cp /tmp/log_update.txt ./log2
		fi


		# 2.2.3 - Aguarda 2min ate voltar ultimo equipamento atualizado;
		for temp in {120..1}; do
			echo; echo
			echo "			Gerando relatório, aguarde $temp"s""
			sleep 1; clear
		done
	fi


	# Removendo arquivos
	rm /tmp/.script.sh /tmp/.process.kill;


# 2.3 - Verifica a versao dos equipamentos - 2a vez;
	if [ -e /tmp/updates.txt ]; then
# TODO: Teste2
cp /tmp/updates.txt ./up3
		rm /tmp/updates.txt
	fi

# TODO: Teste2
cp /tmp/updates.txt ./up4

	archive="/tmp/address_responding.txt"
	blocoDeExecucao accessVersion #& > /dev/null
# TODO: Teste2
cp /tmp/updates.txt ./up5
echo " Em segundo plano" >> ./up5

# 3 - Gera relatorio e exibe o mesmo
buildReport
cat ./report.out


# Apos verificacao, pega IPs que nao foram atualizados e
# 1- FAZ CHAMADA BLOCO DE EXECUCAO
# 1.2- Substitui o arquivo de leitura, criar uma var para isso
# 2- CHAMA BLOCO DE ACESSO SSH > REBOOT;
# 3- AGUARDA UM TEMPO ANTES DE REEXECUTAR SCRIPT DE UPDATE
