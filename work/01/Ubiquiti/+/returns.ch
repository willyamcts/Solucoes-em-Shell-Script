# Contem todas as funcoes para verificar erros como:
	# - Variável = null;
	# - Retorno inesperado


	# Verificacao generica, verifica se o comando teve sucesso, caso cotrario, faz a chamada da funcao recebida [arg1];
verifyGenericReturn() {

	if [ $? = 0 ]; then
		exit 0
	else
		$1
	fi

}


	# Finaliza a aplicacao caso retorne erro;
genReturnKill() {

echo "Funcao genReturnKill"

	if [ $? != 0 ];then 
		killall run.sh
	fi

}