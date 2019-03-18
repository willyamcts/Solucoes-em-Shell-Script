#!/bin/bash


if [ -z $1 ] ;then
	echo "Use: $0 [Faixa IP]"
else

	octeto1=$(echo $1 | cut -d. -f1)
	octeto2=$(echo $1 | cut -d. -f2)
	octeto3=$(echo $1 | cut -d. -f3)

	clear
	for ip in $octeto1.$octeto2.$octeto3.{10..254}; do

		ping -c2 -s1 $ip 1>&2>/dev/null

		if [ $? = 0 ]; then
			echo "$ip" >> ./ativos.txt
			tail -n1 ./ativos.txt
		fi

	done
fi