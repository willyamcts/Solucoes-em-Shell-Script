source ./command/functions.exe 


# Contem funcoes para manipular informacoes;


checkPackages() {

	(pacman -Ss zenity | grep installed || dpkg --get-selections | grep zenity) 1>&2>/dev/null

	if [[ $? == 0 ]]; then
		(pacman -Ss sshpass | grep installed || dpkg --get-selections | grep sshpass) 1>&2>/dev/null

	else
		clear
		printf "É necessario a instalação de pacotes...\n\n\t Iniciando a instalação...\n\n"
		sudo pacman -Sy sshpass zenity || sudo apt-get install -y sshpass zenity
	fi

}



verifyOption() {

	case $1 in
		"$option1") mainFunction=backupMikroTik
			# Utilizar variavel dstFILES que contem o diretorio a ser salvo os backups.
			dstFILES=$(saveFiles "ARG1")
echo "$dstFILES"
			[[ -e $dstFILES ]] || mkdir $dstFILES
				;;
		"$option2") mainFunction=backupUbiquiti
			# Utilizar variavel dstFILES que contem o diretorio a ser salvo os backups.
			dstFILES=$(saveFiles "ARG1")
			[[ -e $dstFILES ]] || mkdir $dstFILES
				;;
		"$option3") mainFunction=changeChannel
			infoChangeChannels
			channels=$(entryChannels "ARG1")
#			createScChannels "$channels" #Desnecessario pois e criado na funcao 
				;;
		"$option4") mainFunction=changeUserPwd
			handData entryNewData 1 "ARG1"
				;;
		"$option5") mainFunction=servicesPorts
			disableSERVICE=$(disableServices "ARG1")
echo $disableSERVICE
			servicesPORT=$(changePorts "ARG1")
echo $servicesPORT

				;;
		"$option6") mainFunction=massiveCompliance
#			selectOptionCT
#			[[ $? = 1 ]] && echo "asdsdsa" #mainFunction=massiveCompliance
				;;
		"$option7") mainFunction=customCommand
			CMD=$(entryCustomCommand "ARG1")
				;;
		"$option8") mainFunction=activeAddress
			unset handData
				;;
		"$option9") mainFunction=deviceFullReport
				;;
	esac
}


verifyModeExec() {

mode1="Range de IP"
mode2="Address list"

	case $1 in
		"$mode1") $2
			 unset selectFile
			;;
		"$mode2") $3
			 unset addressEntry
			;;
	esac
}



	# Recebe uma range de IPv4, faixa inicial separada da final por virgula (,);
	#  caso octeto for valido e adicionado em um indice do vetor "addr"

	# Verifica se octeto e valido de acordo com IPv4;
		# -Se octeto nao for valido, faz chamada da funcao passada via [ARG2]
checkOcteto() {

i=0

	# Tratamento de IP nulo;
	for (( x=1; x <= 2; x++ )); do
		address=$(echo $1 | cut -d, -f"$x")

		if [[ -z $address ]]; then
			$2 && break
		fi

	done


	for (( x=1; x <= 2; x++ )); do
		address=$(echo $1 | cut -d, -f$x)


		for (( j=1; j <= 4; i++, j++ )); do
			octet=$(echo $address | cut -d. -f$j)


			if [[ -n $octet ]]; then

				if [[ $octet -lt 0 ]]; then
					octet=1
				elif [[ $octet -gt 255 ]]; then
					octet=254
				fi

				addr[$i]=$octet

			else

				index=("${!addr[@]}")
				for y in "${index[@]::8}"; do unset "addr[$y]"; done

				$2 && break	
			fi

		done

	done

unset address i x octet
}



	# Faz chamada da função que recebe usuario e senha de acesso ao dispositivo;
handData() {

	UaP=$($1 "ARG1")

	user=$(echo $UaP | cut -d+ -f1)
	pass=$(echo $UaP | cut -d+ -f2)

	if [ -z $user ] || [ -z $pass ]; then
		handData "$1"
	fi


	if [ $2 = 1 ]; then
		newUser=$user
		newPwd=$pass
		unset user pass
	fi

	unset UaP
}



makeReport() {
	
	if [ -z "$1" ]; then

		if [ -z ${addr[0]} ]; then
			content=$(printf "\n====== LOG: %s ===== %s ===== \n Address list: %s\n Tempo de execução:\n\n" "$FSELECT" "$(date +%d.%m.%y-%H:%M)" "$FILE")

		else 
			content=$(printf "\n====== LOG: %s ===== %s ===== \n Range IP: %i.%i.%i.%i - %i.%i.%i.%i\n Tempo de execução:\n\n" "$FSELECT" "$(date +%d.%m.%y-%H:%M)" "${addr[0]}" "${addr[1]}" "${addr[2]}" "${addr[3]}" "${addr[4]}" "${addr[5]}" "${addr[6]}" "${addr[7]}")
		fi

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
			127) out='Necessário intervenção manual'
				;;
			*) out="Error cod. $2"
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
			"$option9")
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

		if [ $(echo $mainFunction | grep backup) ]; then
			return=$($mainFunction "$user" "$pass" "$1" "$dstFILES" "ARG1")

			deviceName=$(echo "$return" | cut -d+ -f1 | cut -d- -f1)
			return=$(echo "$return" | cut -d+ -f2)

			makeReport "$1" "$return" "$deviceName"


		elif [ $(echo $mainFunction | grep deviceFullReport) ]; then
			value=$($mainFunction "$user" "$pass" "$1" "ARG1")
			
			if [ -z "$(echo $value | cut -d+ -f1)" ]; then
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

		elif [ $(echo $mainFunction | grep changeUserPwd) ]; then
			return=$($mainFunction "$user" "$pass" "$1" "$newUser" "$newPwd" "ARG1")
			makeReport "$1" "$return"


		elif [ $(echo $mainFunction | grep servicesPort) ]; then
#			$mainFunction "$user" "$pass" "$1" "$disableSERVICE" "$servicesPORT" "ARG1"
#			tail -n2 $toFILE | grep "Tempo" && printf
			(return=$($mainFunction "$user" "$pass" "$1" "$disableSERVICE" "$servicesPORT" "ARG1") && makeReport "$1" "$return") &

		elif [ $(echo $mainFunction | grep custom) ]; then
echo "CustomCommand"
			$mainFunction "$user" "$pass" "$1" "$CMD"
echo "CustomCommand \$? = $?" && sleep 2
			makeReport "$1" "$?"

		else
echo "Padrao" && sleep 10
			return=$($mainFunction "$user" "$pass" "$1" "ARG1")
			makeReport "$1" "$return"
		fi

unset value
}



handAddressToAccess() {
	makeReport
#	clear; printf "\n\n Arquivo de log:\n"

	for ((o1="${addr[0]}"; $o1 <= ${addr[4]}; o1++)); do

		for ((o2="${addr[1]}"; $o2 <= ${addr[5]}; o2++)); do

			for ((o3="${addr[2]}"; $o3 <= ${addr[6]}; o3++)); do

				clear && printf "\n\n\n\tVerificando $o1.$o2.$o3.0/24 \n\n"

				for ((o4="${addr[3]}"; $o4 <= ${addr[7]}; o4++)); do

					ip="$o1.$o2.$o3.$o4"

					# TODO: Apresentando que esta verificando, caso contrario a tela fica presa;
					clear && tail -n1 $toFILE && printf "\n\n \tTentativa em $ip \n\n"

					ping -s1 -c2 $ip 1>&2>/dev/null

					if (( $? == 0 )); then
						(lastHandFunction "$ip") #1>&2>/dev/null #TODO: Descomentar
					fi

#						xfce4-terminal -x bash -c 'echo "$IP"; sleep 5'
#						xfce4-terminal -x bash -c '$mainFunction "$pass" "$user" "$ip"; sleep 5'


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
