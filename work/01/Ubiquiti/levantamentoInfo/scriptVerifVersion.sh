#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 02/12/2016;
#
# Descrição: Faz o levantamento de dispositivos desatualizados gerando um 
#	log com IP e versão do firmware do equipamento.


blocoPrincipal(){

	# chamada da funcao;
#	excluirArquivos

	# chamada da funcao;
	verificaPacoteSSHPass


}


# Manipula informações que serão utilizadas no bloco de execução.
blocoDeExecucao(){

	# quantidade de linhas do arquivo /tmp/address_responding;
	qtLinhas=`wc -l /tmp/address_responding.txt | cut -d " " -f1`

	# respectivo IP presente na linha;
	for ((linhaAtual=1; "$linhaAtual" <= "$qtLinhas"; linhaAtual++)); do


	# Remove arquivo SSH profile atual;
	if [ -e ~/.ssh/known_hosts ] ; then
		rm ~/.ssh/known_hosts
	fi

		# recebe IP da linha especifica
		ip=`(sed -n "$linhaAtual"'p' /tmp/address_responding.txt)`

		sleep 3
		# Chama função com bloco de comandos a executar;
		accessVersion

	done

}



# Verifica existencia pacote sshpass, instala-o se necessario.
verificaPacoteSSHPass(){
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


# Exclui arquivos criados da execução anterior e restrição de acesso SSH
excluirArquivos(){

	# Remove arquivo de enderecos;
	if [ -e /tmp/address_responding.txt ] ; then
		rm /tmp/address_responding.txt
	fi

	# Remover arquivo contem os IP e ID das RBs;
	if [ -e /tmp/updates.txt ]; then
		echo " " >> /tmp/updates.txt
		echo "	==== `date +%D" "%H:%M` ====	" >> /tmp/updates.txt
	fi

	# Remove script criado;
	if [ -e /tmp/.script.sh ]; then
		rm /tmp/.script.sh
	fi

}

# 1- Bloco execução, envia script e o executa no equipamento.
accessVersion(){

		# Remove arquivo SSH profile atual;
		if [ -e ~/.ssh/known_hosts ] ; then
			rm ~/.ssh/known_hosts
		fi

clear; echo "		Verificando versão dos equipamentos...."
echo -e "\n\n	$ip"
		version=`sshpass -p "$password" ssh -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$usuario"@"$ip" 'cat /etc/version | cut -d"v" -f2'`
		echo "$ip	$version" >> /tmp/updates.txt

}


# Apos verificacao, pega IPs que nao foram atualizados e 

# 1- FAZ CHAMADA BLOCO DE EXECUCAO
# 1.2- Substitui o arquivo de leitura, criar uma var para isso
# 2- CHAMA BLOCO DE ACESSO SSH > REBOOT;
# 3- AGUARDA UM TEMPO ANTES DE REEXECUTAR SCRIPT DE UPDATE
a(){
	grep -v "$currentVersion" /tmp/updates.txt | cut -f1 > /tmp/updates.txt
}


# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
clear

echo "Informe nome do usuario padrao de acesso aos equipamentos: "
read usuario

echo " "; echo "Informe a senha de acesso aos equipamentos: "
read -s password; echo " "

echo " "; echo "Informe o IP: (será considerado /16) "
read ip

echo " "; echo -n "Informe a versão atual do firmware: "
read currentVersion
#currentVersion="5.6.9"


oct1=`echo $ip | cut -d. -f1`
oct2=`echo $ip | cut -d. -f2`
#oct3=`echo $ip | cut -d. -f3`
#oct4=`echo $ip | cut -d. -f4`

clear
	blocoPrincipal


sleep 3; clear; echo " "
echo "			Iniciando sessões SSH	"; sleep 3; echo " "
	blocoDeExecucao

