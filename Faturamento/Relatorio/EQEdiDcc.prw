#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#Include 'fileio.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EQEdiDcc � Autor �      � Data �   ���
�������������������������������������������������������������������������͹��
���Descricao �    ���
���          �                                     ���
���          �                                     ���
���          �                                     ���
�������������������������������������������������������������������������͹��
���Uso       �                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

----------------------------------------------------------------------------
Atera��o: Paulo Rog�rio
Data....: 06/06/2023
Projeto.: Politicas Comerciais QUALY
Objetivo: Ao Inv�s de gravar Pedido de Venda a rotina passa a gravar
          o Or�emento de Vendas, a fim de submeter o pedido as regras
		  da policita comercial Qualy.
-----------------------------------------------------------------------------
/*/

User Function EQEdiDcc()

Private lPreparado 	:= SELECT("SX6") == 0  	                          // Verifica se ambiente ja esta preparado
Private lProcessa  	:= .F.
Private lShow       := .T.
Private lHide       := .T.

Private cQuery     	:= ""
Private cIPFTP     	:= '186.202.119.87'                               // IP de conex�o com o FTP...
Private nPortFTP   	:= 21                                             // Porta de conex�o com o FTP...
Private cUsrFTP    	:= 'Qualyvinil'                                   // Usu�rio para conex�o com o FTP...
Private cPwdFTP    	:= 'QsWdxv2C'                                     // Senha de conex�o com o FTP...

Private aErros	   	:= {}
Private aProcs		:= {}
Private aAlert		:= {}

Private cTipoDoc    := 'SCJ'

// Prepara o ambiente para processamento...
If lPreparado
	RpcClearEnv()
	PREPARE ENVIRONMENT EMPRESA "10" FILIAL "0803"
EndIf

//��������������������������������������������������������������Ŀ
//� Se houver conex�o com FTP Ok...                              �
//����������������������������������������������������������������
If IsFTP( { cIPFTP, nPortFTP, cUsrFTP, cPwdFTP} )
	fMensagem(.T.,  "Iniciando a Conex�o FTP do Integrador por XML!")

	// Executa a rotina de Importa��o do XML via FTP
	ImpFTP( '\EDI\Dicico\Entrada\', { cIPFTP, nPortFTP, cUsrFTP, cPwdFTP} )

	fMensagem(.T.,  "Finalizando a Conex�o FTP do Integrador por XML!")
	
	// Disconecta o FTP
	FTPDisconnect()
Else
	fMensagem(lPreparado,  "Erro na Conex�o FTP do Integrador por XML!", 2)
EndIf

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o      � ImpFTP   � Autor �          � Data � 03/08/14 ���
���������������������������������������������������������������������������Ĵ��
���Descricao   � Importa arquivo de pasta FTP para Integra��o               ���
���������������������������������������������������������������������������Ĵ��
���Parametros  � cPasta == Pasta do RootPatch \...                          ���
���            � aConexao[1] Informe o IP do FTP                            ���
���            � aConexao[2] Informe a Porta                                ���
���            � aConexao[3] Informe o Usu�rio                              ���
���            � aConexao[4] Informe a Senha                                ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ImpFTP( cPasta, aConexao )

//Local lOk        := .F.
//Local lRetorno   := .T.
Local nArqs      := 0
Local aRetDir    := {}
//Local cEndFtp    := aConexao[1]
//Local nPorFtp    := aConexao[2]
//Local cUsuFtp    := aConexao[3]
//Local cSenFtp    := aConexao[4]

//�����������������������������������������������������������������������Ŀ
//� Retorna arquivos conforme filtro do diret�rio IN no servidor FTP      �
//�������������������������������������������������������������������������
FTPDirChange( '/IN/' )
aRetDir := FTPDIRECTORY( "*.xml" )

If Len(aRetDir) > 0
	For nArqs := 1 To Len( aRetDir )

		// Seleciona a pasta de origem do arquivo XML no FTP
		FTPDirChange( '/IN/' )

		// Faz Download do Arquivo XML via FTP
		If !FtpDownload( cPasta + aRetDir[nArqs][1], aRetDir[nArqs][1])
			fMensagem(lPreparado,  "Erro no Download do Arquivo: "+Alltrim(aRetDir[nArqs][1])+", no FTP do Integrador por XML!", 2)			
		Else
			fMensagem(lHide,  "Sucesso no Download do Arquivo "+Alltrim(aRetDir[nArqs][1])+", no FTP do Integrador por XML!", 1)

			// Apaga o arquivo XML na pasta IN do Servidor FTP
			FtpErase( AllTrim(aRetDir[nArqs][1]) )

			fMensagem(lHide,  "Exclus�o do Arquivo "+Alltrim(aRetDir[nArqs][1])+", na pasta IN do FTP do Integrador por XML!", 1)


			//=========================================================
			// Chama a rotina de Inclus�o do pedido de Venda no SC5/SC6
			//=========================================================
			If U_EQPVDcc(cPasta + aRetDir[nArqs][1], "SCJ")
				fMensagem(lPreparado,  "Pedido de Venda Incluido pelo arquivo "+Alltrim(aRetDir[nArqs][1])+", do FTP do Integrador por XML!", 2)	
			
				// Transfere arquivo para pasta processados...    			                
				Copy File &(cPasta + aRetDir[nArqs][1]) TO &('\EDI\Dicico\Processado\' +  aRetDir[nArqs][1])
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" foi movido para a pasta processados no FTP do Integrador por XML!", 2)	
			Else
				//ConOut( "**** ERRO NA INCLUS�O DO PEDIDO DE VENDA DO ARQUIVO "+Alltrim(aRetDir[nArqs][1])+" EM "+DtoC(MsDate())+" "+Time()+" ****")
				fMensagem(lPreparado,  "Erro na Inclusao do Pedido de Venda pelo Arquivo "+Alltrim(aRetDir[nArqs][1])+".", 2)	

				// Transfere arquivo para pasta de erros    			               
				Copy File &(cPasta + aRetDir[nArqs][1]) TO &('\EDI\Dicico\Erros\' +  aRetDir[nArqs][1])
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" foi movido para a pasta erros no FTP do Integrador por XML!", 2)	
			EndIf

			// Configura a pasta de importados no FTP
			FTPDirChange( '/Importados/' )
			If FTPUpload(cPasta + aRetDir[nArqs][1] , aRetDir[nArqs][1] )
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+"foi movido para a pasta importados no FTP do Integrador por XML!", 2)	
			Else
				fMensagem(lHide,  "Erro ao mover o Arquivo "+Alltrim(aRetDir[nArqs][1])+" para a pasta importados no FTP do Integrador por XML!", 2)	
			EndIf
			
			// Exclus�o do arquivo da pasta de entrada do protheus.
			IF FErase(cPasta + aRetDir[nArqs][1]) == -1
				fMensagem(lHide,  "Erro na exclusao do Arquivo "+Alltrim(aRetDir[nArqs][1])+" do diretorio de entrada "+cPasta + aRetDir[nArqs][1], 2)	
			Else
				fMensagem(lHide,  "Arquivo "+Alltrim(aRetDir[nArqs][1])+" Ecluido do diretorio de entrada "+cPasta + aRetDir[nArqs][1], 2)	
			EndIf
		EndIf
	Next
Else
	//ConOut( "**** NENHUM ARQUIVO ENCONTRADO FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")
	fMensagem(lPreparado,  "Nenhum arquivo foi encontrado no FTP INTEGRATOR DICICO.", 2)	
EndIf

//ConOut( "**** FTP INTEGRATOR DICICO DESCONECTADO EM "+DtoC(MsDate())+" "+Time()+" ****")
//fMensagem(lHide,  "Finalizando o processo no FTP INTEGRATOR DICICO.", 2)	
//FTPDisconnect()

If Len(aErros) > 0 .Or. Len(aProcs) > 0 
	EnvRel()
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EQEdiDcc � Autor �      � Data �   ���
�������������������������������������������������������������������������͹��
���Descricao �    ���
���          �                                     ���
���          �                                     ���
���          �                                     ���
�������������������������������������������������������������������������͹��
���Uso       �                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function IsFTP(aConn)
      
Local lRet := .F.

If FTPConnect(aConn[1],aConn[2],aConn[3],aConn[4],.T.)           
	ConOut( "**** FTP INTEGRATOR DICICO CONECTADO EM "+DtoC(MsDate())+" "+Time()+" ****")
	lRet := .T.
Else
	ConOut( "**** FALHA CONEX�O FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EnvRel	� Autor � Rodrigo Sousa         � Data � 16/10/12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para envio de relat�rio via email 				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EnvRel()

Local oProc
Local oHtml
Local nX := 0

oProc 	:= TWFProcess():New("100100","Notifica��o Integra��o Dicico")
oProc:NewTask('Inicio',"\workflow\html\EQNotDcc.html")
oHtml	:= oProc:oHtml

oHtml:valbyname( "cEmpresa"	, "Qualyvinil" )
oHtml:valbyname( "cCodFil"	, "10 - Filial 0803" )
oHtml:valbyname( "dDtProc"	, DtoC(dDatabase))
oHtml:valbyname( "cHora"	, Time())

If Len(aProcs) > 0
	For nX := 1 to Len(aProcs)
		aAdd( (oHtml:valbyname( "it.cArquivo" 		)), aProcs[nX][01] 	) 
		aAdd( (oHtml:valbyname( "it.cCliente" 		)), aProcs[nX][02] 	) 
		aAdd( (oHtml:valbyname( "it.cPCCliente"		)), aProcs[nX][03] 	) 
		aAdd( (oHtml:valbyname( "it.cPedVen" 		)), aProcs[nX][04] 	) 

		EqVPrcTb(aProcs[nX][01], aProcs[nX][04])

	Next nX
Else
	aAdd( (oHtml:valbyname( "it.cArquivo" 		)), "N�o h� Pedidos Processados" 	) 
	aAdd( (oHtml:valbyname( "it.cCliente" 		)), "" 	) 
	aAdd( (oHtml:valbyname( "it.cPCCliente"		)), "" 	) 
	aAdd( (oHtml:valbyname( "it.cPedVen" 		)), "" 	) 
EndIf


If Len(aAlert) > 0
	For nX := 1 to Len(aAlert)
		aAdd( (oHtml:valbyname( "itA.cArqAlert" 	)), aAlert[nX][01] 	) 
		aAdd( (oHtml:valbyname( "itA.cMsgAlert" 	)), aAlert[nX][02] 	) 
		aAdd( (oHtml:valbyname( "itA.cPCAlert"		)), aAlert[nX][03] 	) 
		aAdd( (oHtml:valbyname( "itA.cPedVenAlert"	)), aAlert[nX][04] 	) 
	Next nX
Else
	aAdd( (oHtml:valbyname( "itA.cArqAlert" 	)), "N�o h� alertas" 	) 
	aAdd( (oHtml:valbyname( "itA.cMsgAlert" 	)), "" 	) 
	aAdd( (oHtml:valbyname( "itA.cPCAlert"		)), "" 	) 
	aAdd( (oHtml:valbyname( "itA.cPedVenAlert"	)), "" 	) 
EndIf


If Len(aErros) > 0
	For nX := 1 to Len(aErros)
		aAdd( (oHtml:valbyname( "it2.cArqErro" 		)), aErros[nX][01] 	) 
		aAdd( (oHtml:valbyname( "it2.cMsgErro" 		)), aErros[nX][02] 	) 
		aAdd( (oHtml:valbyname( "it2.cPCErro"		)), aErros[nX][03] 	) 
		aAdd( (oHtml:valbyname( "it2.cPCItem" 		)), aErros[nX][04] 	) 
	Next nX
Else
	aAdd( (oHtml:valbyname( "it2.cArqErro" 		)), "N�o h� erros" 	) 
	aAdd( (oHtml:valbyname( "it2.cMsgErro" 		)), "" 	) 
	aAdd( (oHtml:valbyname( "it2.cPCErro"		)), "" 	) 
	aAdd( (oHtml:valbyname( "it2.cPCItem" 		)), "" 	) 
EndIf

ConOut('Envio de E-Mail Automatico - Integra��o Dicico'  )

oProc:cTo 	:= GETMV("ES_EMSOD") //Alltrim("ellen.ataide@qualyvinil.com.br;eristeu.junior@qualyvinil.com.br;ti@euroamerican.com.br") Paulo lenzi 13/08/2024

oProc:cSubject := "Protheus | Notifica��o Integra��o Dicico"
oProc:Start()
oProc:Finish()
wfsendmail()

ConOut( "**** ENVIO DE EMAIL INTEGRA��O FTP INTEGRATOR DICICO EM "+DtoC(MsDate())+" "+Time()+" ****")

Return


Static Function EqVPrcTb(cArqProc, cPedVld)

Local cQuery 	:= ""
Local cAlias	:= GetNextAlias()

IF cTipoDoc == "SC5"
	cQuery := "SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, "+CRLF
	cQuery += "       C6_PRCVEN, C6_PRUNIT, C6_NUMPCOM, C6_ITEMPC"+CRLF
	cQuery += "  FROM "+RetSqlName("SC6")+" SC6"+CRLF
	cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
	cQuery += "   AND C6_NUM = '"+cPedVld+"' "+CRLF
	cQuery += "   AND C6_QTDLIB = 0"+CRLF
	cQuery += "   AND C6_PRCVEN <> C6_PRUNIT"+CRLF
	cQuery += "   AND SC6.D_E_K_E_T_ = ''"+CRLF
Else
	cQuery := "SELECT CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, "+CRLF
	cQuery += "       CK_PRCVEN, CK_PRUNIT, CK_PEDCLI, CK_ITECLI"+CRLF
	cQuery += "  FROM "+RetSqlName("SCK")+" SCK"+CRLF
	cQuery += " WHERE CK_FILIAL = '"+xFilial("SCK")+"'"+CRLF
	cQuery += "   AND CK_NUM = '"+cPedVld+"' "+CRLF
	//cQuery += "   AND C6_QTDLIB = 0"+CRLF
	cQuery += "   AND CK_PRCVEN <> CK_PRUNIT"+CRLF
	cQuery += "   AND SCK.D_E_L_E_T_ = ''"+CRLF
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

TcQuery cQuery New Alias (cAlias)

While !(cAlias)->(Eof())
	IF cTipoDoc == "SC5"

		cMsg := "O Valor do Produto "+Alltrim((cAlias)->C6_PRODUTO)+" est� divergente com o valor da Tabela de Pre�o. Valor Pedido R$ "+Transform((cAlias)->C6_PRCVEN,PesqPict("SC6","C6_PRCVEN"))+;
				" Valor Tabela de Pre�o R$ "+Transform((cAlias)->C6_PRUNIT,PesqPict("SC6","C6_PRUNIT"))

		aAdd(aAlert,{cArqProc,cMsg,(cAlias)->C6_NUMPCOM,(cAlias)->C6_NUM})	
	else
		cMsg := "O Valor do Produto "+Alltrim((cAlias)->CK_PRODUTO)+" est� divergente com o valor da Tabela de Pre�o. Valor Pedido R$ "+Transform((cAlias)->CK_PRCVEN,PesqPict("SC6","C6_PRCVEN"))+;
				" Valor Tabela de Pre�o R$ "+Transform((cAlias)->CK_PRUNIT,PesqPict("SC6","C6_PRUNIT"))

		aAdd(aAlert,{cArqProc,cMsg,(cAlias)->CK_PEDCLI,(cAlias)->CK_NUM})	
	Endif


	(cAlias)->(dbSkip())
End

(cAlias)->(dbCloseArea())

Return



User Function EQEdiMn()

If MsgYesNo("Importa��o do arquivo XML ," + Chr(13) + Chr(10) + "da DICICO " + Time(), "Confirma?")

	If Left(cFilAnt,2) == '08' //.And. Left(cFilAnt,2) == '03'
		Msgrun("Processando Importa��o Dicico. Aguarde...","Aguarde",{|| u_EQEdiDcc()})
	Else
		MsgStop("Empresa n�o autorizada a utilizar essa rotina.", "Aten��o")
	EndIf

Endif

Return


Static Function fMensagem(lOculta, cMsg, nTipo)
	IF lOculta
		ConOut("Data / Hora:"+DtoC(MsDate())+" / "+Time() + " *** "+UPPER(cMsg)+ " ***")
	Else
		IF nTipo == 1
			MsgInfo(cMsg,"Importa��o de PV")
		Else
			MsgAlert(cMsg,"Importa��o de Or�amento")
		Endif
	Endif
Return
