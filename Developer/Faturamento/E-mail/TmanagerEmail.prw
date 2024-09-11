//Bibliotecas
#Include "Protheus.ch"

/*/{Protheus.doc} TManagerEmail
Fun��o para disparo do e-mail utilizando TMailMessage e tMailManager com op��o de m�ltiplos anexos
@author Paulo Lenzi
@since 26/05/2017
@version 1.0
@type function
@param cPara, characters, Destinat�rio que ir� receber o e-Mail
@param cAssunto, characters, Assunto do e-Mail
@param cCorpo, characters, Corpo do e-Mail (com suporte � html)
@param aAnexos, array, Anexos que estar�o no e-mail (devem estar na mesma pasta da protheus data)
@param lMostraLog, logical, Define se ser� mostrado mensagem de log ao usu�rio (uma tela de aviso)
@param lUsaTLS, logical, Define se ir� utilizar o protocolo criptogr�fico TLS
@return lRet, Retorna se houve falha ou n�o no disparo do e-Mail
@example Exemplos:
-----
1 - Mensagem Simples de envio
u_TManagerEmaill("teste@servidor.com.br", "Teste", "Teste TMailMessage - Protheus", , .T.)

-----
2 - Mensagem com anexos (devem estar dentro da Protheus Data)
aAnexos := {}
aAdd(aAnexos, "\pasta\arquivo1.pdf")
aAdd(aAnexos, "\pasta\arquivo2.pdf")
aAdd(aAnexos, "\pasta\arquivo3.pdf")
u_TManagerEmaill("teste@servidor.com.br", "Teste", "Teste TMailMessage com anexos - Protheus", aAnexos)
u_TManagerEmail("informatica@patral.com.br", "Teste", "Teste TMailMessage", , .T.)

@obs Deve-se configurar os par�metros:
* MV_RELACNT - Conta de login do e-Mail    - Ex.: email@servidor.com.br
* MV_RELPSW  - Senha de login do e-Mail    - Ex.: senha
* MV_RELSERV - Servidor SMTP do e-Mail     - Ex.: smtp.servidor.com.br:587
* MV_RELTIME - TimeOut do e-Mail           - Ex.: 120
/*/
User Function TManagerEmail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS, lNovo)
	Local aArea        := GetArea()
	Local cGuardaLoc   := "C:\relato\"
    Local cGuardaServ  := "\workflow\email\"
	Local lRet         := .T.
	Local oMsg         := Nil
	Local oSrv         := Nil
	Local nRet         := 0
	Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
	Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
	Local cPass        := Alltrim(GetMV("MV_RELPSW"))
	Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
	Local cServer      := ""
	Local nPort        := 0
	Local nTimeOut     := GetMV("MV_RELTIME")
	Local cLog         := ""
	Local cContaAuth   := ""
	Local cPassAuth    := ""
	Local nAtu         := 0
	Local cProcessos   := ""
	Local cEmailTeste  := AllTrim(SuperGetMV("ES_EMTEST",.F.,"paulo.lenzi@euroamerican.com.br"))
    
	Default cPara      := "ti@euroamerican.com.br"
	Default cAssunto   := "Envio do Email de Notifica��o"
	Default cCorpo     := "Envio do Email de Notifica��o"
	Default aAnexos    := {}
	Default lMostraLog := .F.
	Default lUsaTLS    := .T.
	Default lNovo      := .F.

	//Se tiver em branco o destinat�rio, o assunto ou o corpo do email
	If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
		cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
		lRet := .F.
	EndIf
	
	IF !Empty(cEmailTeste)
       cPara := cEmailTeste
	endif
	
	If !ExistDir(cGuardaServ)
        MakeDir(cGuardaServ)
        FWAlertSuccess("Pasta '" + cGuardaServ + "' criada", "Pasta criada")
	EndIf
    if len(aAnexos)>0
		CpyT2S(cGuardaLoc+aAnexos,cGuardaServ , .T. )
	endif	

	If lRet
		If lNovo
			cContaAuth := Alltrim(GetMV("MV_X_NCNT"))
			cPassAuth  := Alltrim(GetMV("MV_X_NPSW"))
			cSrvFull   := Alltrim(GetMV("MV_X_NSRV"))
		Else
			cContaAuth := cFrom
			cPassAuth  := cPass
		EndIf
		cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
		nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)

		//Cria a nova mensagem
		oMsg := TMailMessage():New()
        oMsg:Clear()
		//Define os atributos da mensagem
		oMsg:cDate    := cValToChar(Date())
		oMsg:cFrom    := cFrom
		oMsg:cTo      := cPara
		oMsg:cSubject := cAssunto
		oMsg:cBody    := cCorpo
        if len(aAnexos)>0
			If File(cGuardaServ+aAnexos)
						//Anexa o arquivo na mensagem de e-Mail
						nRet := oMsg:AttachFile(cGuardaServ+aAnexos)
						If nRet < 0
							cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos+"'!" + CRLF
						EndIf
						//Senao, acrescenta no log
			Else
						cLog += "003 - Arquivo '"+aAnexos+"' nao encontrado!" + CRLF
			EndIf
        endif   
		//Cria servidor para disparo do e-Mail
		oSrv := tMailManager():New()
		//oSrv:SetUseTLS( .T. )
        //oSrv:SetUseSSL( .F. )
		//Define se ir� utilizar o TLS
		If lUsaTLS
			oSrv:SetUseTLS(.T.)
		EndIf

		//Inicializa conex�o
		nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
		If nRet != 0
			cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
			lRet := .F.
		EndIf

		If lRet
			//Define o time out
			nRet := oSrv:SetSMTPTimeout(nTimeOut)
			If nRet != 0
				cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
			EndIf

			//Conecta no servidor
			nRet := oSrv:SMTPConnect()
			If nRet <> 0
				cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				lRet := .F.
			EndIf

			If lRet
				//Realiza a autentica��o do usu�rio e senha
				nRet := oSrv:SmtpAuth(cContaAuth, cPassAuth)
				If nRet <> 0
					cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
					lRet := .F.
				EndIf

				If lRet
					//Envia a mensagem
					nRet := oMsg:Send(oSrv)
					If nRet <> 0
						cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
						lRet := .F.
					EndIf
				EndIf

				//Disconecta do servidor
				nRet := oSrv:SMTPDisconnect()
				If nRet <> 0
					cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
				EndIf
			EndIf
		EndIf
	EndIf

	//Se tiver log de avisos/erros
	If !Empty(cLog)
		//Busca todas as fun��es
		nAtu := 0
		cProcessos := ""
		
		cLog := "+======================= TManagerEmail =======================+" + CRLF + ;
			"TManagerEmail  - "+dToC(Date())+ " " + Time() + CRLF + ;
			"Funcao    - " + FunName() + CRLF + ;
			"Processos - " + cProcessos + CRLF + ;
			"Para      - " + cPara + CRLF + ;
			"Assunto   - " + cAssunto + CRLF + ;
			"Existem mensagens de aviso: "+ CRLF +;
			cLog + CRLF +;
			"+======================= TManagerEmail ============================+"
		//ConOut(cLog)

		//Se for para mostrar o log visualmente e for processo com interface com o usu�rio, mostra uma mensagem na tela
		If lMostraLog .And. ! IsBlind()
			 ShowHelpDlg("ATEN��O", {cLog},5, {"Entrar em contato com a Infra"},1)
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
