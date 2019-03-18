#!/bin/bash

##
# Autor: Willyam Castro;
#
# Data: 15/05/2017;
#
# Descrição: Faz atualização de firmware de dispositivos Ubiquiti 5.8 GHz.
#	que utilizam firmware XM, XW, WA e XC.
#		*Necessário fazer alterações a partir da linha 250 do arquivo "command/functions.exe" 

# Adicao de opcoes: handling e dialogs


# Erros: Em scriptUpdate nao esta aceitando um condicional duplo para verificar se a versao corresponde a serie M
#		ou a serie AC - para contornar foi comentado o bloco de tratamento do AC;
	# Verificar clientes apos update, para nao gerar um relatorio incoerente;
	# Tratar caso algum metodo retorne erro para encerrar a aplicação;
	# ERRO: Não esta alterando via sed a linha correta, alteração devem ser feitas em makeReport para resolver
	
	
source ./dialog/dialogs.lxte ./chk/handling.ch


checkPackages

selectFunction

selectModeExecution

saveFileReport

$modeFunction

checkUbiquiti