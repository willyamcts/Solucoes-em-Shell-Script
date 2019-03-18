#!/bin/bash

# Uso: Verificar um arquivo de log, com a finalizadade de gerar um relatório (signals_log.txt) 
#	contendo os clientes/IPs com sinal acima do permitido (-75);


if [ -z $1 ] ; then
	echo "Use: $0 [file]"
else

	for line in $(cat $1); do
		echo $line
sleep 5
#		signal=$(echo $line | cut -d- -f2)

#		if [ $signal -gt 75 ]; then
#			echo $line; sleep 2
#		fi

	done

fi