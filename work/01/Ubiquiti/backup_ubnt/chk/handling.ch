source ./command/functions.exe

# Contem funcoes para manipular informacoes;



verifyOption() {

echo $1 #TODO: teste
	case $1 in
		"$option1") mainFunction=backupUbiquiti
			# Utilizar variavel dstFILES que contem o diretorio a ser salvo os backups.
			dstFILES=$(saveFiles "ARG1")
			;;
		"$option2") mainFunction=reportDeviceAndMAC
			;;
		"$option3") mainFunction=activeAddress
			unset handData
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

#	saveFileReport
	
	if [ -z "$1" ]; then
		content=$(echo -e "\n ===== LOG: "$FSELECT" ===== $(date +%d.%m.%y-%H:%M) === \n\n")
	else

		case $2 in 
			0) out='Sucesso'
				;;
			1) out='Host inalcançável'
				;;
			5) out='Usuário e/ou senha inválido'
				;;
			255) out='Inalcançável/Conexão recusada'
				;;
			default) out="Error code $2"
				;;
		esac	
		
		case $FSELECT in
			"$option1") content=$(printf "%s\t%s" "$1" "$out")
				;;
			"$option2") 
#echo "LINHA 115: Entrou no case makeReport:"
echo "LINHA 116: FSELECT = $FSELECT e out = $out" #TODO: teste

					if [ "$2" = 0 ]; then
						content=$(printf "%s\t%s\t%s" "$3" "$4" "$5")
					else
						content=$(printf "%s\t%s" "$1" "$out")
					fi
				;;
			"$option3") content=$(printf "%s %s" "$1" "$out")
				;;
		esac

	fi

echo "LINHA 133: CONTENT = $content" #TODO: teste
	printf "%s\n" "$content" >> $toFILE

unset out content
}



lastHandFunction() {

		if [ "$mainFunction" == "reportDeviceAndMAC" ]; then

			value=$(reportDeviceAndMAC "$user" "$pass" "$ip" "ARG1")
			
			if [ -z "$(echo $value | cut -d+ -f1)" ]; then
#				echo "LINHA 148: vazio" #TODO: teste
				return=$(echo $value | cut -d+ -f2)
			else

				device=$(echo "$value" | cut -d+ -f1)
				mac=$(echo "$value" | cut -d+ -f2)
				client=$(echo "$value" | cut -d+ -f3)
#				ssid=$(echo "$value" | cut -d+ -f4)
#				signal=$(echo "$value" | cut -d+ -f5)
				return=$(echo $value | cut -d+ -f4)
#				return=$(echo "$value" | cut -d+ -f6)

			fi

echo "LINHA 152: VALUE =$value" #TODO: teste
echo "LINHA 153: DEV = $device, MAC = $mac, CLIENT = $client" #TODO: teste
echo "LINHA 155: f4 = $return" #TODO: teste


			makeReport "$ip" "$return" "$device" "$mac" "$client" #TODO: Rever
#			makeReport "$ip" "$return" "$device" "$mac" "$client" "$ssid" "$signal" #TODO: Rever

		elif [ $(echo $mainFunction | grep backup) ]; then
echo "LINHA 166: Iniciando com BACKUP" #TODO: Teste
echo "LINHA 169: Destino dos arquivos: $dstFILES"
			return=$($mainFunction "$user" "$pass" "$ip" "$dstFILES" "ARG1") #TODO: Ver necessidade de ARG1
echo "LINHA 168: RETURN=$return" #TODO: Teste

			makeReport "$ip" "$return"

		else
			$mainFunction "$user" "$pass" "$ip"
echo "LINHA 173: Retorno da funcao de execucao: $?" #TODO: Teste

			makeReport "$ip" "$?"
		fi

unset value
}



handAddressToAccess() {

	makeReport 
#echo "LINHA 171: OPTION = $FSELECT" #TODO: Teste

	for ((o1="${addr[0]}"; $o1 <= ${addr[4]}; o1++)); do

		for ((o2="${addr[1]}"; $o2 <= ${addr[5]}; o2++)); do

			for ((o3="${addr[2]}"; $o3 <= ${addr[6]}; o3++)); do

				for ((o4="${addr[3]}"; $o4 <= ${addr[7]}; o4++)); do

					ip="$o1.$o2.$o3.$o4"

					ping -c2 $ip

					if (( $? == 0 )); then
#echo "LINHA 183: $ip" #TODO: teste
						lastHandFunction
					fi

#echo "VALUE = $value" #TODO: teste


#					xfce4-terminal -x bash -c 'echo "$IP"; sleep 5'
#					xfce4-terminal -x bash -c '$mainFunction "$pass" "$user" "$ip"; sleep 5'

				done
			done
		done
	done
}



handFileToAccess() {

	for i in $(cat $FILE); do

		lastHandFunction		
	done
}