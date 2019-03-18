#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 02/12/2016;
#
# Descrição: Gera um arquivo contendo os IPs que respondem a
#	ICMP de uma range /16 do IP informado.


blocoPrincipal(){

	excluirArquivos

	# Range de IPs
	for ip in 10.{76,79}.{20..49}.{1..254} ; do

		# chamada da funcao verifica IPs que respondem;
		verificaRespostaIP > /dev/null &

		# informa qual faixa esta verificando
		addr=`echo $ip | cut -d. -f4`
		if [ $addr = 1 ]; then
			clear
			echo "		Verificando IPs ativos da faixa: "
			echo "$ip/24"
		fi

	done

}


# Verifica IPs ativos na rede e envia-os ao arquivo /tmp/addr_responding.txt
verificaRespostaIP(){

	ping -c 2 $ip
	if [ $? = 0 ]; then
		echo $ip >> /tmp/addr_responding.txt
	fi
}


excluirArquivos(){

	# Remover arquivo contem os enderecos ativos;
	if [ -e /tmp/addr_responding.txt ]; then
		rm /tmp/addr_responding.txt
	fi

}


# ===========================================================================#
# ======================	EXECUCAO DO SCRIPT	=====================#
# ===========================================================================#
clear

echo " "; echo "Informe o IP:  (será considerado /16)"
#read ip

oct1=`echo $ip | cut -d. -f1`
oct2=`echo $ip | cut -d. -f2`
#oct3=`echo $ip | cut -d. -f3`
#oct4=`echo $ip | cut -d. -f4`

echo " "; echo "	Verificando IPs ativos da faixa especificada, aguarde..."
blocoPrincipal


