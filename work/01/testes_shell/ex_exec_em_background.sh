#!/bin/bash

exec 4<&1

printf "Executando em BG....\n"

exec 1<&4
exec tail -f /tmp/log.txt

for (( i=0; i < 5; i++ )); do
	echo "$i $(date)" >> /tmp/log.txt
	sleep 5
done

printf "Apos o tail...." >> /tmp/log.txt
