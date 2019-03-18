#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: Dezembro 2016;
#
# Descrição: Remove virus MF.tar criado para dispostivos Ubiquiti.
#	Ativa a porta 443 e altera a porta de acesso HTTP para 80 
#	novamente e troca a SSH para 7722.
#
#	Obs.: Adicionado uma segunda porta para tentativa de SSH
#

# Erros: Nenhum identificado
# Incrementado: Removido funcoes inuteis, cada IP ativo ja executa funcao
#		sem necessidade de ler um arquivo;


source contentExecution.part
#source contentMainBlock.part

# Variaveis para facilitar a manipulacao;
arcScript='/tmp/.scriptRem.sh'
arcReport='/tmp/report.out'

# Chamada de blocos essenciais para execução.
blocoPrincipal(){

	# chamada da funcao;
	checkSSHPackage

	cat contentMainBlock.part > $arcScript


	# Range de IPs
	for IP in 10.79.{42..42}.{97..97}; do
		x=`echo $IP | cut -d. -f3`;

			clear; echo "		Verificando faixa [ `echo $IP | cut -d. -f3`.0/24 ]"

			# chamada da funcao verifica IPs que respondem
#			verificaRespostaIP 1> /dev/null &
echo "			A $IP"
			verificaRespostaIP
	done
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){

	# Nao executar em segundo plano; funcao e chamada antes de verificar resposta IP
	ping -c2 $IP > /dev/null
	if [ $? = 0 ]; then
		motherFuckerRemove
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
#$USER - Porta SSH
	sshpass -p $PASSWORD scp -P $PORTSSH -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $arcScript $USER@$IP:/tmp/script.sh > /dev/null&

echo $?; sleep 2
	retorno=$?

	if [ $retorno = 5 ]; then
content="$userMF $PORTSSH"
#$userMF & passMF - Porta SSH
		sshpass -p $passMF scp -P $PORTSSH -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" /tmp/.script.sh $userMF@$IP:/tmp/script.sh > /dev/null&
		sshpass -p $passMF ssh -p $PORTSSH -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $userMF@$IP 'chmod +x /tmp/script.sh; /tmp/script.sh'
# $USER - Porta SSH2
	elif [ $retorno != 0 ]; then
content="$USER $PORTSSHSecond"
		sshpass -p $PASSWORD scp -P $PORTSSHSecond -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" /tmp/.script.sh $USER@$IP:/tmp/script.sh > /dev/null&
		retorno=$?

		sshpass -p $PASSWORD ssh -p $PORTSSHSecond -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER@$IP 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?

# $userMF  - PORT SSH2
		if [ $retorno != 0 ]; then
content="$userMF $PORTSSHSecond"
			sshpass -p $passMF scp -P $PORTSSHSecond -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" /tmp/.script.sh $userMF@$IP:/tmp/script.sh > /dev/null&
			retorno=$?

			sshpass -p $passMF ssh -p $PORTSSHSecond -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $userMF@$IP 'chmod +x /tmp/script.sh; /tmp/script.sh'
			retorno=$?
#echo "$IP	$retorno	PORTA 7722" >> 7722
		fi

	else

# $USER - Porta SSH
		sshpass -p $PASSWORD ssh -p $PORTSSH -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER@$IP 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?
content="$USER $PORTSSH"

	fi

#	echo "$IP:$PORTSSH	$retorno" >> /tmp/report.out
sleep 1
echo $content >> /tmp/report.out
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
clear; unset killSessionSSH; sleep 5
initialDate=`date +%s`

userMF="mother"
passMF="fucker"

read -p "Informe o nome do usuário: " USER

echo; read -s "Informe a senha para $USER: " PASSWORD

echo; read -p "Informe o IP: (será considerado /16) " IP

echo; read -p "Porta SSH: " PORTSSH
PORTSSHSecond='7722'

oct1=`echo $ip | cut -d. -f1`; oct2=`echo $ip | cut -d. -f2`
oct3=`echo $ip | cut -d. -f3`; oct4=`echo $ip | cut -d. -f4`

clear; echo
	blocoPrincipal

echo; echo ; runtime
