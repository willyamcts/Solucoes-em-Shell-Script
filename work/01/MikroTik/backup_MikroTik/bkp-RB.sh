#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: Abril 2017;
#
# Descrição: Faz backup de RB MikroTik informando um único endereço IP
#	por vez. O nome atribuido ao arquivo de backup é o hostname do RB.
#


### Corrigir: ###
## 1- Caso o arquivo de backup esteja em uma subpasta o script nao copia
##  porem gera log;
##
## 2- Trava na sessao SSH, porem copia o arquivo de backup;
##
## 3- Verificar se existe o diretorio na pasta de destino antes de criar;

user="USER"
userpwd="YOURPASSWORD"
port=7722
fileLog=./log-Bkp_RB.txt

clear
echo; cat $fileLog
echo; read -p "Informe o endereço IP: " IP

dstFileDown=/tmp/$IP/



# Comandos do ssh, verifica todos os arquivos e remove os que contem a extensao ".backup"
#	por fim gera um novo backup
sshpass -p $userpwd ssh -o "StrictHostKeyChecking no" -p $port $user@$IP ':foreach i in=[/file find] do={:if ([:typeof [:find [/file get $i name] ".backup"]]!="nil") do={/file remove $i}}; system backup save'


# Gera log;
	out=$(echo $?)
	if [ $out = 1 ]; then
		echo $IP - Port error >> $fileLog
	elif [ $out = 5 ]; then
		echo $IP - User/Password >> $fileLog
	elif [ $out = 255 ]; then
		echo $IP - Conection refused >> $fileLog
	else

		mkdir $dstFileDown

		$(sshpass -p $userpwd scp -o "StrictHostKeyChecking no" \
		-r -P $port $user@$IP:/ $dstFileDown)

# Gera log;
		out=$(echo $?)
		if [ $out != 0 ]; then
			echo $IP - COPY FAILED! >> $fileLog
		fi


	# fileName recebe o primeiro nome do arquivo de backup 
		fileName=$(ls -R $dstFileDown | grep backup \
			| awk -F-20 '{print $1}' | \
				awk '{print $1}')

		dstFiles=~/Downloads/RB/$fileName/

		mkdir -p $dstFiles
		mv $dstFileDown*.backup $dstFiles

	# Gera log e remocao dos arquivos temporarios
			if [ -e $dstFiles*.backup ]; then
				echo $IP - Sucess [$fileName] >> $fileLog
				rm -r -f $dstFileDown
			else
				echo $IP - Failed to copy file to destination >> $fileLog
			fi

	fi

$0
