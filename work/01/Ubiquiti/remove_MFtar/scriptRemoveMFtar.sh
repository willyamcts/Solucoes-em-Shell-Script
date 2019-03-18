#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 12/04/2017;
#
# Descrição: Remove virus MF.tar criado para dispostivos Ubiquiti.
#	Ativa a porta 443 e altera a porta de acesso HTTP para 80 
#	novamente e troca a SSH para 7722.

# Erros: Nenhum
# Incrementado: Removido funcoes inuteis, cada IP ativo ja executa funcao
#		sem necessidade de ler um arquivo;


source contentExecution.part
#source contentMainBlock.part

# Variaveis para facilitar a manipulacao;
#arcAddress='/tmp/address_10.txt'
arcScript='/tmp/.scriptRem.sh'
arcReport='/tmp/report.out'

# Chamada de blocos essenciais para execução.
blocoPrincipal(){

	# chamada da funcao;
	checkSSHPackage

	cat contentMainBlock.part > $arcScript


	# Range de IPs
	for IP in 10.{76,79}.{42..42}.{200..254}; do
		x=`echo $IP | cut -d. -f3`
		oct2=`echo $IP | cut -d. -f2`; oct3=`echo $IP | cut -d. -f3`

			clear; echo "		Verificando faixa [ $oct1.$oct2.`echo $IP | cut -d. -f3`.0/24 ]"

			# chamada da funcao verifica IPs que respondem
			#	sem retorno em tela;
			verificaRespostaIP 1> /dev/null &

	done



#	date=`date +%H:%M" - "%d/%m/%Y`
#	creatingScript $currentVersion > $arcScript
}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){

	ping -c 2 $IP
	if [ $? = 0 ]; then
		motherFuckerRemove
sleep 2
	fi
}


# Finaliza processo SSH local apos 5min da sessao iniciada ou ate equipamento
#	deixar de responder.

killSession(){
echo 'date=`echo \`date +%s\` + '40' | bc`'
echo '	until [ `date +%s` -eq $date ]; do'
echo "		ping -c2 $ip"

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
	sshpass -p "$password" scp -P $port -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $arcScript $user@$IP:/tmp/script.sh
	retorno=$?

	# Verfica erro na transferencia via SCP;
	if [ "$retorno" = 0 ] ; then
		delArchiveSSH

		sshpass -p $password ssh -p $port -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $user@$IP 'chmod +x /tmp/script.sh; /tmp/script.sh'
		retorno=$?

	else
		echo "$IP:$port	$retorno" >> $arcReport
	fi
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

echo "Usuario: "
read user

echo; echo "Senha ja definida no codigo: "
read -s password

echo; echo "Informe o IP: (será considerado /16) "
#read ip

echo; echo "SSH port [22]: "
read port

oct1=`echo $ip | cut -d. -f1`; oct2=`echo $ip | cut -d. -f2`
oct3=`echo $ip | cut -d. -f3`; oct4=`echo $ip | cut -d. -f4`

clear; echo
	blocoPrincipal

echo; echo ; runtime
