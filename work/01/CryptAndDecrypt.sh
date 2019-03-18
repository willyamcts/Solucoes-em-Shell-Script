#!/bin/bash

# Name: Willyam Castro
# 
# Date: 30/05/2017
#
# Descryption: Convert word in MD5; Crypt and decrypt files with openssl in aes 256 key;

clear

echo -en "\033[1;32m[0] Convert word \n[1] Crypt or Decrypt : \033[0m"
read ANSWER

clear

# Checking
case $ANSWER in
	# Convert text to MD5
	0) read -p "Informe o texto: " PHRASE
		content=$(echo -n $PHRASE | openssl dgst -md5)
		content=${content:9}
		echo $content
		# encode em base64: echo -n $PHRASE | base64
		# decode em base64: echo -n $PHRASE | base64 -d
			;;

	1) echo -en "\033[1;32m[0] Crypto \n[1] Decrypt : \033[0m "
		read ANSWER

		echo

		case $ANSWER in

			# Crypt;
			0)
				clear

				read -p "  Full Path dir/archive for crypt: " Path

				if [ -d "$Path" ]; then
							cd $(dirname $Path)
							Path=$(basename $Path)

					zip -rT $Path.zip $Path

						if [ $? = 0 ]; then
							output="$Path.czip"
							Path="$Path.zip"
							openssl enc -aes-256-cbc -in $Path -out $output && rm $Path

						else					
							echo -e "\033[1;31m	Erro ao encriptar $Path \033[0m"
							exit 10
						fi

				else
					openssl enc -aes-256-cbc -in $Path -out $Path.czip
				fi
					;;

			# Decrypt;
			1)
				echo
				echo -en "\033[1;32m Full Path file encrypted: \033[0m "
				read Path

				# $OUTPUT vazio;
				if [ -n $Path ]; then
					output="$(echo $Path | cut -d. -f1).zip" #"$Path-dcry.zip"
				fi

				# Decrypt;
				openssl enc -aes-256-cbc -d -in $Path > $output
					;;

			*) printf "\033[1;31m \t\tValor inválido...\n \033[0m"
			esac
				;;
		
	*) printf "\033[1;31m \n\t\tValor inválido...\n\n \033[0m"
		exit
esac
