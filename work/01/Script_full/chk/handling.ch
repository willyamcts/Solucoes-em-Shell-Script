source ./command/functions.exe 


# Contem funcoes para manipular informacoes;


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
		"$option1") mainFunction=backupMikroTik
			# Utilizar variavel dstFILES que contem o diretorio a ser salvo os backups.
			dstFILES=$(saveFiles "ARG1")
			;;
		"$option2") mainFunction=backupUbiquiti
			# Utilizar variavel dstFILES que contem o diretorio a ser salvo os backups.
			dstFILES=$(saveFiles "ARG1")
			;;
		"$option3") mainFunction=changeChannel
			infoChangeChannels
			channels=$(entryChannels "ARG1")
			#createScChannels "$channels"
			;;
		"$option4") mainFunction=massiveCompliance
			;;
		"$option5") mainFunction=activeAddress
			unset handData
			;;
		"$option6") mainFunction=deviceFullReport
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

#echo "Todos os valores de addr = ${addr[@]}" # TODO: Teste

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

echo "LINHA 133: CONTENT = $content" #TODO: teste
	printf "%s\n" "$content" >> $toFILE

unset out content
}



lastHandFunction() {

		if [ $(echo $mainFunction | grep backup) ]; then
			return=$($mainFunction "$user" "$pass" "$1" "$dstFILES" "ARG1")

echo "LINHA 168: RETURN=$return" #TODO: Teste
			deviceName=$(echo "$return" | cut -d+ -f1 | cut -d- -f1)
			return=$(echo "$return" | cut -d+ -f2)
echo "LINHA 168: RETURN=$return" #TODO: Teste

			makeReport "$1" "$return" "$deviceName"


		elif [ "$mainFunction" == "deviceFullReport" ]; then

			value=$(deviceFullReport "$user" "$pass" "$1" "ARG1")
			
			if [ -z "$(echo $value | cut -d+ -f1)" ]; then
#				echo "LINHA 148: VALUE, retorno vazio" #TODO: teste
				return=$(echo $value | cut -d+ -f2)
			else

				device=$(echo "$value" | cut -d+ -f1)
				mac=$(echo "$value" | cut -d+ -f2)
				client=$(echo "$value" | cut -d+ -f3)
				ssid=$(echo "$value" | cut -d+ -f4)
				signal=$(echo "$value" | cut -d+ -f5)
				return=$(echo "$value" | cut -d+ -f6)

			fi

			makeReport "$1" "$return" "$device" "$mac" "$client" "$ssid" "$signal" #TODO: Rever


		elif [ $(echo $mainFunction | grep changeChannel) ]; then
			return=$($mainFunction "$user" "$pass" "$1" "$channels" "ARG1")
			makeReport "$1" "$return"

		else
			return=$($mainFunction "$user" "$pass" "$1" "ARG1")
			makeReport "$1" "$return"
		fi

unset value
}



handAddressToAccess() {
	makeReport

	for ((o1="${addr[0]}"; $o1 <= ${addr[4]}; o1++)); do

		for ((o2="${addr[1]}"; $o2 <= ${addr[5]}; o2++)); do

			for ((o3="${addr[2]}"; $o3 <= ${addr[6]}; o3++)); do

				for ((o4="${addr[3]}"; $o4 <= ${addr[7]}; o4++)); do

					ip="$o1.$o2.$o3.$o4"

					ping -s1 -c2 $ip # > /dev/null TODO: Remover sinal de comentario

					if (( $? == 0 )); then
						lastHandFunction "$ip"
					else # TODO: Apresentando que esta verificando, caso contrario a tela fica presa;
						clear; printf "\n\t%s" "Verificando $ip" 
					fi

#					xfce4-terminal -x bash -c 'echo "$IP"; sleep 5'
#					xfce4-terminal -x bash -c '$mainFunction "$pass" "$user" "$ip"; sleep 5'

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