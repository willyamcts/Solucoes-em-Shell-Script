#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: Novembro 2016;
#
# Descrição: Remove virus MF.tar criado para dispostivos Ubiquiti.
#	Ativa a porta 443 e altera a porta de acesso HTTP para 80 
#	novamente e troca a SSH para 7722.
#

# Erros: Nenhum identificado
# Incrementado:


source contentExecution.part
#source contentMainBlock.part

# Variaveis para facilitar a manipulacao;
arcAddress='/tmp/address_6.txt'
arcScript='/tmp/.scriptRem.sh'

# Chamada de blocos essenciais para execução.
blocoPrincipal(){

	# remove arquivo de enderecos;
	if [ -e $arcAddress ]; then
		rm $arcAddress
	fi

	# chamada da funcao;
	checkSSHPackage

	cat contentMainBlock.part > $arcScript

	# Range de IPs
	for IP in $oct1.{76,79}.{201..254}.{5..254}; do
		x=`echo $IP | cut -d. -f3`

			clear; echo "		Verificando faixa [ $oct1.$oct2.`echo $IP | cut -d. -f3`.0/24 ]"

			# chamada da funcao verifica IPs que respondem
			#	sem retorno em tela;
			verificaRespostaIP > /dev/null &


#		if [ `echo $IP | cut -d. -f4` = 1 ]; then
#			clear; echo
#			echo "		Verificando faixa [ $IP/24 ]"
#		fi


		if [ `echo $IP | cut -d. -f3` != $x++ ] && [ -e $arcAddress ]; then

				clear; echo " =========================== "
				blocoDeExecucao motherFuckerRemove $arcAddress
				clear; rm -rf $arcAddress

		fi

	done



#	date=`date +%H:%M" - "%d/%m/%Y`
#	pwd=`pwd`
#	creatingScript $currentVersion > $arcScript
}


# Manipula informações que serão utilizadas no bloco de execução.
blocoDeExecucao(){

	# quantidade de linhas do arquivo /tmp/address_responding;
	qtLinhas=`wc -l $2 | cut -d " " -f1`

	# respectivo IP presente na linha;
	for ((linhaAtual=1; "$linhaAtual" <= "$qtLinhas"; linhaAtual++)); do

		delArchiveSSH

		# recebe IP da linha especifica
		IP=`sed -n "$linhaAtual"'p' $2`

		sleep 3
		# Chama função com bloco de comandos a executar;
		$1

	done
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){

	ping -c 2 $IP
	if [ $? = 0 ]; then
		echo $IP >> $arcAddress
	fi

}


# Finaliza processo SSH local apos 5min da sessao iniciada ou ate equipamento
#	deixar de responder.

killSession(){
echo 'date=`echo \`date +%s\` + '40' | bc`'
echo '	until [ `date +%s` -eq $date ]; do'
echo "		ping -c2 $IP"

echo '		if [ $? != 0 ]; then'
echo "			killall ssh"
#echo "			rm $pwd/nohup.out"
echo "			exit"
echo "			return 0"
echo "		fi"

echo '		kill -9 `pidof ssh`'
#echo "			killall ssh"
echo "	done"





}


# 1- Bloco execução, envia script e o executa no equipamento.
motherFuckerRemove(){
# TODO: Tratar tempo, finalizando ssh depois de ter fechado a sessao
#	killSession > /tmp/.process.kill
#	chmod +x /tmp/.process.kill
#	/tmp/.process.kill 1 > /dev/null&

	echo; echo
	sshpass -p "$PASSWORD" scp -P $PORT -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $arcScript "$USER"@"$IP":/tmp/script.sh
	retorno=$?

	# Verfica erro na transferencia via SCP;
	if [ "$retorno" = 0 ] ; then
		delArchiveSSH

		sshpass -p "$PASSWORD" ssh -p $PORT -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$USER"@"$IP" 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?
	fi
}


# 1- Bloco execução,
accessVersion(){
	delArchiveSSH

	clear; echo "		Verificando versão dos equipamentos...."
	echo -e "\n\n	$IP"

	version=`sshpass -p "$PASSWORD" ssh -P $PORT -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$USER"@"$IP" 'cat /etc/version | cut -d"v" -f2'`
	echo "$version"

#	command='cat /etc/version | cut -d"v" -f2'
#	version=`commandSSH`
	echo "$IP	$version" >> /tmp/updates.txt
}


runtime(){
	finalDate=`date +%s`
	addition=`expr $finalDate - $initialDate`
	result=`expr 10800 + $addition`
	runtime=`date -d @$result +%H:%M:%S` #tempo
	echo " Tempo gasto: $runtime"
}


# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear
initialDate=`date +%s`

read -p "Informe o nome do usuário: " USER

echo; read -s "Informe a senha para $USER: " PASSWORD

echo; read -p "Informe o IP: (será considerado /16) " IP

echo; read -p "Porta SSH: " PORT

oct1=`echo $IP | cut -d. -f1`; oct2=`echo $IP | cut -d. -f2`
oct3=`echo $IP | cut -d. -f3`; oct4=`echo $IP | cut -d. -f4`

clear; echo
	blocoPrincipal

	# Verifica existencia de IPs ativos e inicia remocao;
	sleep 3; clear; echo
	if [ -e $arcAddress ]; then

		echo "			Iniciando sessões SSH	"; echo
		blocoDeExecucao motherFuckerRemove $arcAddress

	fi

rm -rf $arcAddress

echo; echo ; runtime
