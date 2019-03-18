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
		"$option1") mainFunction=updateMK
			;;
		"$option2") mainFunction=updateUbiquiti
			currentVersion
			URLFirmwares
			scriptUpdateUbiquiti "$buildM" "$buildAC" "$xm" "$xw" "$wa" "$xc"
			unset buildAC xm xw wa xc
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



	# Faz chamada da função (dialog) que recebe usuario e senha de acesso ao dispositivo;
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
			0) out='Atualizado com sucesso'
				;;
			1|255) out='Host inalcançável/Conexão recusada'
				;;
			5) out='Usuário e/ou senha inválido'
				;;
			10) out='Aguardando status...'
				;;
			11) out='Dispositivo atualizado'
				;;
			12) out='Dispositivo reiniciado'
				;;
			*) out="Error cod. $2"
				;;
		esac	
		
		case $FSELECT in
		# Update MikroTik
			"$option1") 
					if [ "$2" = 0 ]; then
						content=$(printf "%s\t%s" "$1" "$3")
					else
						content=$(printf "%s\t%s" "$1" "$out")
					fi
					;;

		# Update Ubiquiti
			"$option2") 
					if [ -n "$2" ]; then
						content=$(printf "%s\t%s" "$1" "$out")
					else
						content=$(printf "%s" "$1")
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

#		if [[ $(echo $mainFunction | grep update) && $2 = 1 ]]; then
		if [ $2 = 1 ]; then
echo LASNTHAND 2
			return=$($mainFunction "$user" "$pass" "$1" "ARG1")
#			makeReport "$1" "$return" 1
			sed -i "s/$1.*/$1\t$return/" $toFILE

		else
			return=$($mainFunction "$user" "$pass" "$1" "ARG1")
			makeReport "$1" "$return"
		fi

unset value
}



handAddressToAccess() {
	makeReport
	startLines=$(wc -l "$toFILE" | cut -d" " -f1)

	for ((o1="${addr[0]}"; $o1 <= ${addr[4]}; o1++)); do

		for ((o2="${addr[1]}"; $o2 <= ${addr[5]}; o2++)); do

			for ((o3="${addr[2]}"; $o3 <= ${addr[6]}; o3++)); do

				for ((o4="${addr[3]}"; $o4 <= ${addr[7]}; o4++)); do

					ip="$o1.$o2.$o3.$o4"

					# TODO: Apresentando que esta verificando, caso contrario a tela fica presa;
#					clear; printf "\n\t%s" "Verificando $ip"

					ping -s1 -c2 $ip 1>&2>/dev/null 

					if (( $? == 0 )); then
						lastHandFunction "$ip"
						tail -n1 $toFILE
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




checkUbiquiti() {
	mainFunction=$(checkVersion "$buildM")

	finishLines=$(wc -l "$toFILE" | cut -d" " -f1)
	lines=$((finishLines-startLines))
	lines=$((lines-$(cat "$toFILE" | tail -n $lines | grep "atualizado" | wc -l | cut -d" " -f1)))

echo $startLines $finishLines $lines
	unset startLines finishLines

	if [ $lines -gt 0 ]; then
echo INFOR
#cat $toFILE | tail -n $lines | grep -v "atualizado"
		for ip in $(cat "$toFILE" | tail -n "$lines" | grep -v "atualizado"); do
echo FOR=$ip
			lastHandFunction "$ip" "1"
		done
else
echo "NAO"
	fi


}