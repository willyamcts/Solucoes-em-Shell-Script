#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 12/2016;
#
#	Verifica IPs ativos na rede e adiciona a um arquivo na
#	pasta temporaria, posteriormente realiza a leitura do arquivo, fazendo 
#	chamada da funcao comandoUpdate; Apos update faz a verificacao de IPs com 
#	versao do firmware, equipamentos com versao fora da atual sao reiniciados 
#	e apos 2min e aplicado novamente commandUpdate em cima desses IPs. Por fim
#	gera um relatorio simples de execucao presente em ./ouput.txt;
#	Solicita 2 credenciais, caso tenha mais de uma, se não, utilize a mesma;


# TODO: Nao rerifica se arquivos de execucao anteriores existem
#
#	* Possivel manipular arquivo via var arcAddress

#	FUTURAS CORRECOES:
# * Ver possibilidade trocar criacao script kill ssh para /bin/pidof- PIDOF
# * Adicionar -o UserKnownHostsFile=/dev/null: adicionar ao acesso SSH e remover funcao
#   para deletar arquivo SSH;
# * 


#source contentMain.part


# COMMENT:
#	Ao selecionar opcao 1, e realizado a opcao 0 tambem, saida gerada em ./output.txt, 
#	/tmp/address_version e /tmp/log_passwords
arcAddress='/tmp/address.txt'

# TODO: Menu nao funcional  = modular
# 1_ A executar
startingBlock(){

	date=`date +%H:%M" - "%d/%m/%Y`
answer=5
	until [ $answer -lt 5 ]; do

		clear; echo " "
		echo "	Deseja realizar o inventário de: "
		echo "		[ 0 ] endereços com USER e pass padrão;"
		echo "		[ 1 ] IPs com usuario e/ou senha padrão & versão dos equipamentos;"
#		echo "		[ 2 ] Realizar backup em massa;"
#		echo "		[ 3 ] Realizar update em massa;"
#		echo "		[ X ] Alterar porta de serviços em massa;"
#		echo "		[ 4 ] Verificar sinal PTPs;"
#		echo "		[ 5 ] Adicionar Compilance Test em massa;"
		read -p "Digite a opção desejada: " answer
	done


# currentFunction = Recebe funcao que ira trabalhar
	case $answer in
		0) currentFunction=verifyPasswordDefault ;;
		1) currentFunction=verifyVersion ;;
	esac

	# Reset no valor da variavel answer para reutiliza-la posteriormente;
	answer=0


	mainBlock
}


# Chamada de blocos essenciais para execucao.
mainBlock(){

	# chamada da funcao;
	excluirArquivos

	# chamada da funcao;
#	verificaPacoteSSHPass

	verifyActiveAddress

}


# Verifica enderecos ativos, manipulando 3o octeto;
verifyActiveAddress() {

#	until [ $oct3 -gt $oct3F ]; do
echo EM UNTIL
		if [ -e $arcAddress ]; then
			rm $arcAddress
#		if [ -e /tmp/address_responding.txt ]; then
#			rm /tmp/address_responding.txt
		fi


		# Range de IPs
		for ip in $oct1.$oct2.$oct3.{5..254} ; do

#TODO: Mostrar qual faixa esta escaneando
			if [ `echo $ip | cut -d. -f4` = 5 ]; then
				clear; echo
				echo "	Verificando IPs da faixa [ $oct1.$oct2.$oct3.1/24 ]"
			fi

			# chamada da funcao verifica IPs que respondem
			#	sem retorno em tela;
			verificaRespostaIP > /dev/null &
		done

		# time, caso contrario executa remocao antes da condicional;
		sleep 15

#		((oct3++))

#	done
}


# Manipula informacoes de arquivo, que serao utilizadas no bloco de execucao.
executionBlock(){

		delArchiveSSH 1>&2>/dev/null

		# Chama funcao com bloco de comandos a executar;
		$currentFunction > /dev/null

}

#	TODO: No fim da execucao verificacao de versao: pega quantidade de IPs,
#		incrementando e grep -v versao atual retornando quantidade fora
#		da versao atual


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/address_responding.txt
#	 via ICMP, 2 pacotes somente.
verificaRespostaIP(){

	ping -s1 -c2 $ip
	if [ $? = 0 ]; then
		$currentFunction > /dev/null

#		echo $ip >> $arcAddress
	fi
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

#TODO: Necessario permissao usuario, erro pois nao tera
		apt-get install sshpass -y > /dev/null &
	fi
}


delArchiveSSH(){
	# Remove arquivo SSH profile atual;
	if [ -e ~/.ssh/known_hosts ] ; then
		rm ~/.ssh/known_hosts
	fi
}


# Exclui arquivos criados da execução anterior e restrição de acesso SSH
excluirArquivos(){

	delArchiveSSH

	# Remove arquivo de enderecos;
	if [ -e $arcAddress ] ; then
		rm -f $arcAddress
	fi

	if [ -e /tmp/address_version.txt ]; then
		rm -f /tmp/address_version.txt
	fi

	# Remover arquivo contem os IP e ID das RBs;
	if [ -e /tmp/log_passwords.txt ]; then
		echo " " >> /tmp/log_passwords.txt
		echo "	==== `date +%D" "%H:%M` ====	" >> /tmp/log_passwords.txt
	fi

	# Remove script criado;
#	if [ -e /tmp/.script.sh ]; then
#		rm /tmp/.script.sh
#	fi
}



# Bloco execução,
verifyVersion(){
	delArchiveSSH

	clear; echo "		Verificando versão dos equipamentos...."
	echo -e "\n\n	$ip"

	version=`sshpass -p $PASSWORD ssh -p $PORTSSH -o 'ServerAliveCountMax=2' \
			-o 'ServerAliveInterval=10' -o 'ConnectTimeout=10' -o 'UserKnownHostsFile=/dev/null' \
				-o 'StrictHostKeyChecking no' $USER@$ip 'cat /etc/version | cut -d"v" -f2'`
	out=$?

	if [[ $out = 1 || $out = 255 ]]; then
		version=`sshpass -p $PASSWORD ssh -p $PORTSSH2 -o 'ServerAliveCountMax=2' \
			-o 'ServerAliveInterval=10' -o 'ConnectTimeout=10' -o 'UserKnownHostsFile=/dev/null' \
				-o 'StrictHostKeyChecking no' $USER@$ip 'cat /etc/version | cut -d"v" -f2'`
		out=$?
	fi


	if [ $out = 5 ]; then
		echo "$ip	Senha invalida" >> /tmp/log_passwords.txt
	fi

	echo "$ip	$version" >> /tmp/address_version.txt
}


# TODO: COrrigir explicacao
# Opcao 0 - Verifica 2 possibilidades de senhas para acessar equipamentos, caso
#  nenhum USER e pass introduzido com sucesso, gera log informando IPs
#  que estao com a senha fora do especificado;
verifyPasswordDefault() {

	sshpass -p $PASSWORD ssh -p $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER@$ip 'exit'
	if [ $? != 0 ]; then

		sshpass -p $PASSWORD2 ssh -p $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" $USER2@$ip 'exit'
		result=$?
		if [ "$result" = 5 ]; then
			echo "$ip	ERROR - User and/or Password. $result" >> /tmp/log_passwords.txt
		elif [ $result = 255 ]; then
			echo "$ip	ERROR - Port Access." >> /tmp/log_passwords.txt
		fi
	fi
}


runtime(){
	finalDate=`date +%s`
	addition=`expr $finalDate - $initialDate`
	result=`expr 10800 + $addition`
	runtime=`date -d @$result +%H:%M:%S` #tempo
	echo " Tempo gasto: $runtime"
}

# Cria relatorio final, imprimindo em tela e arquivo ./output.txt
buildReport() {
#	archive="/tmp/address_responding.txt"
#	currentFunction=verifyVersion
#	executionBlock

	# Info eq. fora da versão atual;
	manualUpdate=`grep -v "$currentVersion" /tmp/address_version.txt | cut -f1 | wc -l`
# TODO: Declarar variavel
	defaultPassword=`grep -v 255 /tmp/log_passwords.txt | wc -l`

	if [ -e ./output.txt ]; then
		echo >> ./output.txt
		echo " ==================== $date ==================" >> ./output.txt
	fi

	clear; echo "			REPORT FINAL:	" >> ./output.txt
	echo "		Varredura de $oct1.$oct2.$oct3i.1 a $oct1F.$oct2F.$oct3.254" >> ./output.txt
	echo "	$answer dispositivos verificados, $manualUpdate estão desatualizados	" >> ./output.txt
	echo " 	$answer dispositivos verificados, $defaultPassword estão com usuario e/ou senha incorreta	" >> ./output.txt
	runtime >> ./output.txt
}



##################################################################
#################	FUNCAO DES USO	##########################
##################################################################


rebootDevices(){
echo "	reboot para $ip" # TODO: Comentar

#	command="reboot"
#	commandSSH
	sshpass -p "$PASSWORD" ssh -p $PORTSSH -o "ConnectTimeout=5" -o "StrictHostKeyChecking no" "$USER"@"$ip" 'reboot'

}



# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear
initialDate=`date +%s`

echo "Informe o usuario padrao de acesso aos equipamentos: "
read USER

echo " "; echo "Informe a senha de acesso para $USER: "
read -s PASSWORD; echo " "


echo "Informe um segundo usuario padrao de acesso aos equipamentos: "
read USER2

echo " "; echo "Informe a senha de acesso para $USER2: "
read -s PASSWORD2; echo " "


echo " "; echo "Informe o IP inicial: (será considerado /16) "
#read ip
ip="10.79.139.10"

echo " "; echo "Informe o IP final: (será considerado /16) "
#read ipFinal
ipFinal="10.79.215.250"

echo " "; echo "Porta SSH: "
#read PORTSSH
PORTSSH=22

echo " "; echo "Porta secundária SSH: "
#read PORTSSH2
PORTSSH2=7722

echo " "; echo "Informe a versão atual do firmware: (ex: 5.6.9)"
read currentVersion

#TODO: Criar funcao para chamar e formar octetos isolados;
oct1=`echo $ip | cut -d. -f1`; oct2=`echo $ip | cut -d. -f2`
oct3=`echo $ip | cut -d. -f3`; oct3i=$oct3; oct4=`echo $ip | cut -d. -f4`

oct1F=`echo $ipFinal | cut -d. -f1`; oct2F=`echo $ipFinal | cut -d. -f2`
oct3F=`echo $ipFinal | cut -d. -f3`; oct4F=`echo $ipFinal | cut -d. -f4`


clear; echo " "
	startingBlock

sleep 600

answer=$(wc -l /tmp/address_version.txt | cut -d" " -f1)
# Chamada funcao para gerar relatorio
	buildReport
cat ./output.txt
