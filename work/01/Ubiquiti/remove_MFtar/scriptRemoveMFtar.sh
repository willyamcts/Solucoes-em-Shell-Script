#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 14:05 - 15/12/2016;
#
# Descrição: Remove virus MF.tar criado para dispostivos Ubiquiti.
#	Ativa a porta 443 e altera a porta de acesso HTTP para 80 
#	novamente e troca a SSH para 7722.
#


# 	Erros: 
#		- Algumas sessoes SSH podem travar, esse erro não foi tratado;
#
# 	Incrementado: 
#		- Removido funcoes inuteis, cada IP ativo ja executa funcao
#		   sem necessidade de ler um arquivo;
#		- Trata erro de porta e/ou de autenticacao;
#		- Gerando log de facil compreensao e informacoes uteis;


source contentExecution.part
#source scriptExport/removScript.sh #Utilizado mesmo sem realizar declaracao

# Variaveis para facilitar a manipulacao;
arcScript='/tmp/.scriptRem.sh'
arcReport='/tmp/report.out'

initialDate=`date +%s`

# Chamada de blocos essenciais para execução.
mainBlock(){
	checkSSHPackage

	if [ $? = 11 ]; then
		kill -9 $$
		exit
	fi

	cat scriptExport/removScript.sh > $arcScript


	# Range de IPs
	for ((o1="$oct1"; $o1 <= ${octF[0]}; o1++)); do

		for ((o2="$oct2"; $o2 <= ${octF[1]}; o2++)); do

			for ((o3="$oct3"; $o3 <= ${octF[2]}; o3++)); do
				clear; echo -e "		Verificando faixa [ $o1.$o2.$o3.0/24 ]\n\n"


				for ((o4="$oct4"; $o4 <= ${octF[3]}; o4++)); do
					IP="$o1.$o2.$o3.$o4"					

					# chamada da funcao verifica IPs que respondem
					verificaRespostaIP $IP > /dev/null &

				done
			sleep 10
			done
		done
	done
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){
	# Nao executar em segundo plano; funcao e chamada antes de verificar resposta IP
	ping -c2 $IP #> /dev/null
	if [ $? = 0 ]; then
		motherFuckerRemove
	fi
}


# Check error equal 5 or other;
checkUserAndOrPass() {

	if [ $retorno = 5 ]; then
		content="$IP:$PORTSSH - ERROR User and/or Password"
	else
		content="$USER $IP:$PORTSSH	$retorno"
	fi

}


# Export and run script from IP;
motherFuckerRemove(){
# TODO: Tratar tempo, finalizando ssh depois de ter fechado a sessao
#	killSession > /tmp/.process.kill
#	chmod +x /tmp/.process.kill
#	/tmp/.process.kill 1 > /dev/null&

	echo; echo

# USER - PORTA1
	cat $arcScript | sshpass -p $PASSWORD ssh -p $PORTSSH \
		-o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" \
			-o "StrictHostKeyChecking no" $USER@$IP \
				'cat > /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'
	retorno=$?

	content="$USER $IP:$PORTSSH"


	if [ $retorno = 5 ]; then

		#$userMF & passMF - Porta SSH

		USER="$userMF"
		PASSWORD="$passMF"
		cat $arcScript | sshpass -p $PASSWORD ssh -p $PORTSSH \
			-o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" \
				-o "StrictHostKeyChecking no" $USER@$IP \
					'cat > /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'

		# Verificacao de sucesso para report;
		checkUserAndOrPass

# $USER & $PASS - Porta SSH secundaria
	elif [ $retorno = 255 ]; then

		PORTSSH=$PORTSSHSecond
		cat $arcScript | sshpass -p $PASSWORD ssh -p $PORTSSH \
		-o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" \
		-o "StrictHostKeyChecking no" $USER@$IP \
		'cat > /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?

		content="$USER $IP:$PORTSSH"

		if [ $retorno = 255 ]; then
			content="$IP - ERROR Port Access"
		fi


# $userMF & $passMF  - PORT SSH Secundaria;
		if [ $retorno = 5 ]; then

			USER="$userMF"
			PASSWORD="$passMF"
			PORTSSH=$PORTSSHSecond
			cat $arcScript | sshpass -p $PASSWORD ssh \
			-p $PORTSSH -o "UserKnownHostsFile=/dev/null" \
			-o "ConnectTimeout=5" -o "StrictHostKeyChecking no" \
			$USER@$IP 'cat > /tmp/script.sh; chmod +x /tmp/script.sh; /tmp/script.sh'
			retorno=$?

			checkUserAndOrPass

		fi
	fi

# Arquivo de saida/ Report;
	echo "$content" >> $arcReport
}


# Tempo de execucao
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
clear; unset killSessionSSH

userMF="mother"
passMF="fucker"

echo "Enter with user: "
read USER

echo; echo "Enter with password for $USER: "
read -s PASSWORD

echo; echo "Sign in with IP initial: "
read IP

echo; echo "Sign in with IP final: "
read IPFinal

echo; echo "SSH port [22]: "
read PORTSSH

echo; echo "SSH secondary port [XXXXX]: "
read PORTSSHSecond

oct1=`echo $IP | cut -d. -f1`; oct2=`echo $IP | cut -d. -f2`
oct3=`echo $IP | cut -d. -f3`; oct4=`echo $IP | cut -d. -f4`

octF=( $(echo $IPFinal | cut -d. -f1) $(echo $IPFinal | cut -d. -f2) \
	$(echo $IPFinal | cut -d. -f3) $(echo $IPFinal | cut -d. -f4) )

clear; echo
	mainBlock

sleep 20; clear; echo; echo ; runtime >> $arcReport

echo "	Relatorio encontra-se em: $arcReport"
#cat $arcReport | more
