#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 18/04/2017 - 15:50;
#
# Descrição: Faz alteração de canal e/ou habilita Compliance Test em massa.
#	Os endereços utilizados para uso das funções são inseridos via 
#	interface (zenity) ou de um arquivo, onde cada IP deve estar em uma 
#	linha. A tentativa de estabelecer uma sessões SSH está configurado nas 
#	portas 22 e 7722. Aplicável somente a AirOS5 (ou sup.) atuando em 
#	5.8 GHz.
#
# Requisitos: Zenity e SSHPass.


warningReturn() {

	case $1 in
		1 | default) zenity --error --width=200 --height=100 \
				--text="\nEntrada inválida/vazia."
			kill -9 $$
			;;
	esac
}


	# Funcao principal, contendo menu de opcoes;
selectFunction() {

option3='Alterar canal(is) em massa'
option4='Habilitar Compliance Test em massa'

	FSELECT=$(zenity --width=450 --height=400 \
		--list --title="Funções" --text="O que deseja fazer? " \
			--radiolist --column "Check" --column "Function" \
				TRUE "$option3" FALSE "$option4")
#				TRUE "$option1" FALSE "$option2" FALSE "$option3" FALSE "$option4" FALSE "$option5")

	warningReturn $?

	verifyOption "$FSELECT"
}



	# Seleciona o modo de execucao, por address list ou range de IP;
selectModeExecution() {

	MOD=$(zenity --width=200 --height=150 \
		--list --title="Modo exec." --text="Selecione o modo de execução:" \
			--radiolist --column "" --column="Mode" \
				TRUE "Range de IP" FALSE "Address list")

	warningReturn $?

	verifyModeExec "$MOD" "addressEntry" "selectFile" 

	# Chamada de funcao handling para executar dataAccess
	handData "dataAccess"

}



	# Seleciona o arquivo a ser lido por funcoes posteriores;
selectFile() {

FILE=$(zenity --file-selection --title="Selecione o arquivo\
	contendo os enderecos IP")

	case $? in
		0) zenity --info --width=275 --height=130 \
				--text="\nArquivo selecionado: \n\n $FILE\n"
			modeFunction='handFileToAccess "$FILE"'
			;;

		1) zenity --warning \
				--text="\nNenhum arquivo selecionado."
			exit 10
			;;

		-1) zenity --error \
			--text="\nOcorreu algum erro. Reexecute a aplicaçao"
			$0
			;;
	esac
}



saveFiles() {

	dstFILES=$(zenity --file-selection --directory \
		--title="Salvar arquivos de backup em: ")

	case $? in
		1) zenity --warning --width=400 --height=100 \
			--text="\nNenhum diretório de destino criado/selecionado. \n\nSera salvo em /tmp/log.txt"
			dstFILES="~/backup-$(date +%d%m%Y_%H%M)"
			;;
	esac

echo "$dstFILES"
unset dstFILES
}


	# Seleciona/cria um arquivo para salvar um relatorio;
saveFileReport() {

	toFILE=$(zenity --file-selection --filename=/tmp/log.txt --save --confirm-overwrite \
		--title="Salvar relatorio de saida em: ")

	case $? in
		1) zenity --warning --width=400 --height=100 \
			--text="\nNenhum arquivo de destino criado/selecionado. \n\nSera salvo em /tmp/log.txt"
			toFILE='/tmp/log.txt'
			;;
	esac
}



	# Recebe os dados de acesso ao equipamento;
dataAccess() {
	UaP=$(zenity --title="Usuário e senha dos dispositivos" \
		--password --username)

	warningReturn $?

	echo $(echo $UaP | cut -d'|' -f1)+$(echo $UaP | cut -d'|' -f2)
	unset UaP
}



	# Recebe endereco IP inicial e final
function addressEntry {

	modeFunction=handAddressToAccess

IP=$(zenity --forms --title="Defina a range de endereços" --width=320 --height=150 \
	--text="Informe a range de IP" --separator="," \
		--add-entry="IP inicial:" \
		--add-entry="IP final:" )

	warningReturn $?

	checkOcteto "$IP" "addressEntry"
}


infoChangeChannels(){
	zenity --question --width=450 --height=120 --title="WARNING!" \
		--text="Caso o DFS do equipamento esteja ativo, será desativado. A lista de rastreio só vai conter o(s) canal(is) informado(s) na próxima etapa.\
			\n\n Deseja continuar?"

	warningReturn $?
}



entryChannels() {

	zenity --entry --title="" \
		--text="Entre com o canal desejado, caso seja mais de um separe-os por vírgula, sem espaçamentos: "

	warningReturn $?

}



#####################################################################
#####################################################################
##################        HANDLING         ##########################
#####################################################################


checkPackages() {

	(pacman -Ss zenity || dpkg --get-selections | grep zenity) > /dev/null

	if [[ $? == 0 ]]; then
		(pacman -Ss sshpass || dpkg --get-selections | grep sshpass) > /dev/null

	else
		clear
		printf "É necessario a instalação de pacotes...\n\n\t Iniciando a instalação...\n\n"
		sudo pacman -Sy sshpass zenity || sudo apt-get install sshpass zenity
	fi

}



verifyOption() {

	case $1 in
		"$option3") mainFunction=changeChannel
			infoChangeChannels
			channels=$(entryChannels "ARG1")
			;;
		"$option4") mainFunction=massiveCompliance
			;;
	esac
}



verifyModeExec() {

mode1="Range de IP"
mode2="Address list"

	case $1 in
		"$mode1") $2
			;;
		"$mode2") $3
			;;
	esac

}



	# Recebe uma range de IPv4, faixa inicial separada da final por virgula (,);
	#  caso octeto for valido e adicionado em um indice do vetor "addr"

	# Verifica se octeto e valido de acordo com IPv4;
		# -Se octeto nao for valido, faz chamada da funcao passada via [ARG2]
checkOcteto() {

address=$(echo $1 | cut -d, -f1)
i=0

	for (( x=1; x <= 2; x++ )); do

		for (( j=1; j <= 4; i++, j++ )); do

			if [ $(echo $address | cut -d. -f$j) -ge 0 ] && [ $(echo $address | cut -d. -f$j) -lt 256 ]; then
				addr[$i]=$(echo $address | cut -d. -f$j)
			else
				$2				
			fi

		done

		address=$(echo $1 | cut -d, -f2)
	done


unset address i x
}



	# Faz chamada da função que recebe usuario e senha de acesso ao dispositivo;
handData() {

	UaP=$($1 "ARG1")

	user=$(echo $UaP | cut -d+ -f1)
	pass=$(echo $UaP | cut -d+ -f2)

	if [ -z $user ] || [ -z $pass ]; then
		handData "$1"
	fi

	unset UaP
}



makeReport() {
	
	if [ -z "$1" ]; then
		content=$(echo -e "\n ===== LOG: "$FSELECT" ===== $(date +%d.%m.%y-%H:%M) === \n\n")
	else

		case $2 in 
			0) out='Sucesso'
				;;
			1|255) out='Host inalcançável/Conexão recusada'
				;;
			5) out='Usuário e/ou senha inválido'
				;;
			10) out='Modificação já existe no dispositivo'
				;;
			default) out="Error cod. $2"
				;;
		esac	
		
		case $FSELECT in
		# Backup MK e Ubiquiti
			"$option1"|"$option2") 
					if [ "$2" = 0 ]; then
						content=$(printf "%s\t%s" "$1" "$3")
					else
						content=$(printf "%s\t%s" "$1" "$out")
					fi
					;;

		# Para deviceFullReport
			"$option6")
					if [ "$2" = 0 ]; then
						content=$(printf "%s\t%s\t%s\t%s\t%s" "$3" "$4" "$5" "$6" "$7")
					else
						content=$(printf "%s\t%s" "$1" "$out")
					fi
					;;

			*) content=$(printf "%s\t%s" "$1" "$out")
					;;
		esac

	fi

	printf "%s\n" "$content" >> $toFILE

unset out content
}



lastHandFunction() {

		if [ $(echo $mainFunction | grep changeChannel) ]; then
			return=$($mainFunction "$user" "$pass" "$1" "$channels" "ARG1")
			makeReport "$1" "$return"

		else
			return=$($mainFunction "$user" "$pass" "$1" "ARG1")
			makeReport "$1" "$return"
		fi

unset return
}



handAddressToAccess() {
	makeReport

	for ((o1="${addr[0]}"; $o1 <= ${addr[4]}; o1++)); do

		for ((o2="${addr[1]}"; $o2 <= ${addr[5]}; o2++)); do

			for ((o3="${addr[2]}"; $o3 <= ${addr[6]}; o3++)); do

				for ((o4="${addr[3]}"; $o4 <= ${addr[7]}; o4++)); do

						ip="$o1.$o2.$o3.$o4"

						ping -s1 -c2 $ip > /dev/null 

						if (( $? == 0 )); then
							clear; printf "\n\t%s" "Aplicando a $ip"
							lastHandFunction "$ip"
						else
							clear; printf "\n\t%s" "Verificando $ip"
						fi
				done

			done
		done
	done
}



handFileToAccess() {
	makeReport

	for ip in $(cat $FILE); do
		lastHandFunction "$ip"
	done
}


#####################################################################
#####################################################################
##################        FUNCTIONS         #########################
#####################################################################

# Padrao conexao SSH na porta 22
connectSSHp22() {
	sshpass -p "$2" ssh -p22 -o 'UserKnownHostsFile=/dev/null' -o 'ServerAliveCountMax=2' \
		-o 'ServerAliveInterval=10' \
			-o 'ConnectTimeout=10' \
				-o 'StrictHostKeyChecking no' $1@$3 $4 1>/dev/null 2>/dev/null
}

# Padrao conexao SSH na porta 7722
connectSSHp7722() {
	sshpass -p "$2" ssh -p7722 -o 'UserKnownHostsFile=/dev/null' \
		-o 'ServerAliveCountMax=2' -o 'ServerAliveInterval=10' \
			-o 'ConnectTimeout=10' \
				-o 'StrictHostKeyChecking no' $1@$3 $4 1>/dev/null 2>/dev/null
}

#######################################################

changeChannel(){

	$(connectSSHp22 "$1" "$2" "$3" << OEF
	[ \$(cat /tmp/system.cfg | grep radio.1.dfs | cut -d= -f2) = "enabled" ] && sed -i 's/radio.1.dfs.status=.*/radio.1.dfs.status=disabled/' /tmp/system.cfg
	cat /tmp/system.cfg | grep wireless.1.scan_list.status; [ $? = 0 ] && sed -i 's/scan_list.status.*/scan_list.status=enabled/' /tmp/system.cfg || echo "wireless.1.scan_list.status=enabled" >> /tmp/system.cfg
	cat /tmp/system.cfg | grep wireless.1.scan_list.channels; [ $? = 0 ] && sed -i "s/wireless.1.scan_list.channels=.*/wireless.1.scan_list.channels=$4/" /tmp/system.cfg || echo "wireless.1.scan_list.channels=$4" >> /tmp/system.cfg
	cfgmtd -w -p /etc/; reboot
OEF
)
	out=$(echo $?)

		if [ $out -eq 255 ] || [ $out -eq 1 ]; then

			$(connectSSHp7722 "$1" "$2" "$3" << OEF
				[ \$(cat /tmp/system.cfg | grep radio.1.dfs | cut -d= -f2) = "enabled" ] && sed -i 's/radio.1.dfs.status=.*/radio.1.dfs.status=disabled/' /tmp/system.cfg
				cat /tmp/system.cfg | grep wireless.1.scan_list.status; [ $? = 0 ] && sed -i 's/scan_list.status.*/scan_list.status=enabled/' /tmp/system.cfg || echo "wireless.1.scan_list.status=enabled" >> /tmp/system.cfg
			cat /tmp/system.cfg | grep wireless.1.scan_list.channels; [ $? = 0 ] && sed -i "s/wireless.1.scan_list.channels=.*/wireless.1.scan_list.channels=$4/" /tmp/system.cfg && echo "existe" || echo "wireless.1.scan_list.channels=$4" >> /tmp/system.cfg
			cfgmtd -w -p /etc/; reboot
OEF
) 
			out=$(echo $?)
		fi

	echo $out
unset out
}



massiveCompliance() {

	$(connectSSHp22 "$1" "$2" "$3" 'cat /etc/persistent/ct && exit 10 || (touch /etc/persistent/ct; cfgmtd -w -p /etc/; reboot)') > /dev/null
	out=$(echo $?)

	if [ $out = 255 ] || [ $out = 1 ]; then

		$(connectSSHp7722 "$1" "$2" "$3" 'cat /etc/persistent/ct && exit 10 || (touch /etc/persistent/ct; cfgmtd -w -p /etc/; reboot)') > /dev/null
		out=$(echo $?)
	fi

	echo $out
unset out
}


#####################################################################
#####################################################################

selectFunction

selectModeExecution

saveFileReport

$modeFunction

clear
mousepad $toFILE || notepad $toFILE || gedit $toFILE