#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 19/12/2016;


source general/chkPackSSHPASS.part
source general/answerIP.part


startingBlock(){

	until [ $ANSWER -lt 5 ]; do

		clear; echo " "
		echo "	[ 0 ] Verficar IPs ativos;"
		echo "	[ 1 ] Verificar usuário e senha, conforme o padrão da rede;"
		echo "	[ 2 ] Realizar backup em massa;"
		echo "	[ 3 ] Realizar update em massa;"
		echo "	[ 4 ] Verificar sinal PTPs;"
		echo "	[ 5 ] Adicionar Compilance Test em massa;"
		read -p "Digite a opcao desejada: " ANSWER

	done


#currentFunction = Recebe funcao que ira trabalhar
	if [ "$ANSWER" = 0 ] ; then
		currentFunction=mainBlock
	elif [ "$ANSWER" = 1 ]
		currentFunction=commandAccess
	elif [ "$ANSWER" = 2 ]
		currentFunction=commandBackup
	elif [ "$ANSWER" = 3 ]
#		currentFunction=
	elif [ "$ANSWER" = 4 ]
#		currentFunction=
	elif [ "$ANSWER" = 5 ]
#		currentFunction=
	fi



# Usuario seleciona o modo de execucao, atraves de address list ou tentativa e erro
	ANSWER2=$( zenity --list --title="Select the option you want to" \
		--column="Way" --column="Description" \
			"Address list" "Faz leitura de um arquivo com endereços e realiza função escolhida anteriormente." \
			"Trial and error" "Endereços que responderem a ICMP, será aplicado a função escolhida anteriormente." )

	if [ $ANSWER2 = "Address list" ]; then
		FILE=$(zenity --file-selection --title="Select file with address")

	else
		# ENtrada via teclado do endereco IP ( fun mainBlock)
		#	* arquivo de destino (fun checksAnswerIP)

		ADDR=$( zenity --forms --title "Enter address IP" \
		        --text="ASDA" --separator="-" \
		        --add-entry="Enter the IP initial: " \
		        --add-entry="Enter the IP final: " )
 
		IP=( `echo $ADDR | cut -d. -f1` `echo $ADDR | cut -d. -f2`
			`echo $ADDR | cut -d. -f3` `echo $ADDR | cut -d- -f1 | cut -d. -f4` )

		IPF=( `echo $ADDR | cut -d- -f2 | cut -d. -f1` `echo $ADDR | cut -d. -f5`
			`echo $ADDR | cut -d. -f6` `echo $ADDR | cut -d- -f1 | cut -d. -f7` )

		unset ADDR
	fi

	unset ANSWER2

}



mainBlock(){

	# Chamada funcao, adiciona funcao executada ao log;
	contentLog

#	if [ "$ANSWER" = 2 || "$ANSWER" = 3 || "$ANSWER" = 4 || "$ANSWER" = 5 ]
	if [ "$ANSWER" -ge 2 ]; then

		# Chamada funcao, verifica pacote SSHPASS;
		checkSSHPackage

		# Chamada funcao;
#		deleteFilesGeneral
	fi


	# Range de IPs
	for ((o1="${oct[0]}"; $o1 <= ${octF[0]}; o1++)); do

		for ((o2="${oct[1]}"; $o2 <= ${octF[1]}; o2++)); do

			for ((o3="${oct[2]}"; $o3 <= ${octF[2]}; o3++)); do

				for ((o4="${oct[3]}"; $o4 <= ${octF[3]}; o4++)); do

					IP="$o1.$o2.$o3.$o4"

# TODO: Definir arcAddr via teclado
					 checksAnswerIP $IP $arcAddr > /dev/null &

				done
			done
		done
	done


#TODO: Ver tratativa correta - teste
	unset checksAnswerIP

	# Chama bloco de execucao;
	if [ "$ANSWER" != 0 ]; then
		executionBlock
	fi
}


# Manipula informacoes que serao utilizadas no bloco de execucao.
executionBlock(){

	# quantidade de linhas do arquivo /tmp/addr_responding;
	qtLines=`wc -l /tmp/addr_responding.txt | cut -d " " -f1`


	for ip in `cat $arcAddr`; do 

		# Chama funcao escolhida;
			$currentFunction
	done
}


#TODO: Organizar
# Conteudo do log, linha a ser adicionada juntamente ao log.txt
contentLog(){

	if [ "$ANSWER" = 2 ]; then
		log_content="IPs com senha fora do padrão"
	elif [ "$ANSWER" = 4 ]
		log_content="Update"
	elif [ "$ANSWER" = 5 ]
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
	if [ "$ANSWER" != 1 || "$ANSWER" != 3 ] ; then
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

echo " "; echo "Informe o IP inicial: (será considerado /16) "
read IP

echo " "; echo "Informe o IP final: "
#read IPF


##############################################################################
#############################  DEFINICOES  ###################################
##############################################################################

oct=( $(echo $IP | cut -d. -f1) $(echo $IP | cut -d. -f2) \
	$(echo $IP | cut -d. -f3) $(echo $IP | cut -d. -f4) )

octF=( $(echo $IPF | cut -d. -f1) $(echo $IPF | cut -d. -f2) \
	$(echo $IPF | cut -d. -f3) $(echo $IPF | cut -d. -f4) )




sleep 3; clear; echo " "
echo "	Verificando IPs ativos da faixa especificada na rede, aguarde..."
	mainBlock


sleep 3; clear; echo " "
echo "			Iniciando sessões SSH	"; sleep 3; echo " "
	executionBlock


