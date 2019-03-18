#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 02/12/2016;


startingBlock(){

	until [ $answer -lt 5 ]; do

		clear; echo " "
		echo "	[ 0 ] Verficar IPs ativos somente;"
		echo "	[ 1 ] Verificar se a senha está conforme o padrão da rede;"
		echo "	[ 2 ] Realizar backup em massa;"
		echo "	[ 3 ] Realizar update em massa;"
		echo "	[ 4 ] Verificar sinal PTPs;"
		echo "	[ 5 ] Adicionar Compilance Test em massa;"
		read -p "Digite a opcao desejada: " answer

	done


#currentFunction = Recebe funcao que ira trabalhar
	if [ "$answer" = 0 ] ; then
		currentFunction=mainBlock
	elif [ "$answer" = 1 ]
		currentFunction=commandAccess
	elif [ "$answer" = 2 ]
		currentFunction=commandBackup
	elif [ "$answer" = 3 ]
#		currentFunction=
	elif [ "$answer" = 4 ]
#		currentFunction=
	elif [ "$answer" = 5 ]
#		currentFunction=
	fi

}



mainBlock(){

	# Chamada funcao, adiciona conteudo correspondente ao log;
	contentLog

#	if [ "$answer" = 2 || "$answer" = 3 || "$answer" = 4 || "$answer" = 5 ]
	if [ "$answer" -ge 2 ]
	then

		# Chamada funcao, verifica pacote;
		checkPackageSSHPass

		# Chamada funcao;
		deleteFilesGeneral
	fi


	# Percorre range de IPs
#	for ip in $oct1.$oct2.{248..254}.{1..254} ; do
	for ip in $oct1.{76..78}.{248..254}.{1..254} ; do

		# chamada da funcao verifica IPs ativos,
			# sem retorno em tela;
		checksAnswerIP > /dev/null &

	done

	# Chama bloco de execucao;
	if [ "$answer" != 0 ]; then
		executionBlock
	fi


}


# Manipula informacoes que serao utilizadas no bloco de execucao.
executionBlock(){

	# quantidade de linhas do arquivo /tmp/addr_responding;
	qtLines=`wc -l /tmp/addr_responding.txt | cut -d " " -f1`

	# respectivo IP presente na linha;
	for ((currentLine=1; "$currentLine" <= "$qtLines"; currentLine++)); do


	# Remove arquivo SSH profile atual;
	if [ -e ~/.ssh/known_hosts ] ; then
		rm ~/.ssh/known_hosts
	fi

		# recebe IP da linha especifica
		ip=`(sed -n "$currentLine"'p' /tmp/addr_responding.txt)`

		sleep 3
		# Chama funcao escolhida;
			$currentFunction

	done

}


# Conteudo do log, linha a ser adicionada juntamente ao log.txt
contentLog(){

	if [ "$answer" = 2 ]; then
		log_content="IPs com senha fora do padrão"
	elif [ "$answer" = 4 ]
		log_content="Realização update"
	elif [ "$answer" = 5 ]
		log_content="Sinais de PTPs"
	fi

}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/enderecos.txt
checksAnswerIP(){

	ping -c 2 $ip
	if [ $? = 0 ]; then
		echo $ip >> /tmp/addr_responding.txt
	fi

}


# Verifica existencia pacote sshpass, instala-o se necessario.
checkPackageSSHPass(){
	status=`dpkg --get-selections sshpass | cut -f 7`

	if [ "$status" != "install" ] ;then

		clear
		echo " "; echo "Instalando pacote SSHPass..."
		apt-get update > /dev/null &
		sleep 5

		# caso ocorra erro na atualizacao dos pacotes,
		#  finaliza execucao do script;
		if [ $? != 0 ]; then
			clear
			echo "Verifique a conexao com a internet e atualize"
			echo "	sua lista de pacotes..."
			exit
		fi

		apt-get install sshpass -y > /dev/null &
	fi
}



# Exclui e particiona arquivos criados da execução anterior
#	e restrição de acesso SSH
deleteFilesGeneral(){

	# Remove arquivo SSH profile atual;
	if [ -e ~/.ssh/known_hosts ] ; then
		rm ~/.ssh/known_hosts
	fi

	# Remove arquivo de enderecos;
	if [ -e /tmp/addr_responding.txt ] ; then
		rm /tmp/addr_responding.txt
	fi

	# Adiciona divisão novas linhas do log;
	if [ "$answer" != 1 || "$answer" != 3 ] ; then
		if [ -e /tmp/log.txt ]; then
			echo " " >> /tmp/log.txt
			echo "	==== `date +%D" "%H:%M` - $log_content ====	" >> /tmp/log.txt
		fi
	fi

	# Remove script criado;
	if [ -e /tmp/.script.sh ]; then
		rm /tmp/.script.sh
	fi

}


# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#

	# TODO:
	# ENCERRAR SESSÃO SSH, tentativas excessivas de fechar conexão

#	Verifica IPs ativos na rede e adiciona a um arquivo na
#		pasta temporária com IP e respectiva identificação da RB

# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/addr_responding.txt
#	 via ICMP, 2 pacotes somente.

# Exclui arquivos criados da execução anterior e restrição de acesso SSH



# 1- Bloco execução, envia script e o executa no equipamento.
commandAccess(){

	sshpass -p "$senha" ssh -o "ConnectTimeout=7" -o "StrictHostKeyChecking no" "$usuario"@"$ip" 'exit'
	retorno=$?

	if [ "$retorno" != 0 ] ; then
		echo "$ip	Senha incorreta. $retorno" >> /tmp/log_update.txt
	fi

}


# 2 -
commandBackup(){



}

# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear

echo "Informe nome do usuario padrao de acesso aos equipamentos: "
read usuario

echo " "; echo "Informe a senha de acesso aos equipamentos: "
read -s senha; echo " "

echo " "; echo "Informe o IP: (será considerado /16) "
read ip

oct1=`echo $ip | cut -d. -f1`
oct2=`echo $ip | cut -d. -f2`
#oct3=`echo $ip | cut -d. -f3`
#oct4=`echo $ip | cut -d. -f4`

sleep 3; clear; echo " "
echo "	Verificando IPs ativos da faixa especificada na rede, aguarde..."
	mainBlock


sleep 3; clear; echo " "
echo "			Iniciando sessões SSH	"; sleep 3; echo " "
	executionBlock


