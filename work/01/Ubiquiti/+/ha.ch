
# Contem funcoes para manipular informacoes;



verifyOption() {

echo "VerifyOption - fazendo leitura de handling.ch" #TODO: remover

option1='Backup Ubiquiti'
option2='Report devices Ubiquiti (MAC+Modelo)'
#option3=
#option4=

	case $1 in
		"$option1") exit 101
			;;
		"$option2") exit 102
			;;
	esac
}



verifyModeExec() {
echo "$1 - Verificando modo de execucao"
#	[ -z $1 ] && selectModeExecution 

option1="Range de IP"
option2="Address list"

	case $1 in
		"$option1") $2
			;;
		"$option2") $3
			;;
	esac

}



checkOcteto() {

echo "HA.CH em execucao"
address=$(echo $1 | cut -d, -f1)
i=0

	for (( x=1; x <= 2; x++ )); do

		for (( j=1; j <= 4; i++, j++ )); do

			if [ "$(echo $address | cut -d. -f$j)" -lt 0 ] && [ "$(echo $address | cut -d. -f$j)" -ge "256" ]; then
				echo "valor valido" 
			else
				addr[$i]=$(echo $address | cut -d. -f$j)
			fi

		done
		address=$(echo $1 | cut -d, -f2)

	done

echo "Todos os valores de addr = ${addr[@]}"

unset address
unset i

}

