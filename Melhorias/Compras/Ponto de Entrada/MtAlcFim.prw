#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

// FS - Ponto de entrada no processo de controle de al�adas...

User Function MtAlcFim()

Local aArea      := GetArea()
//Local aAreaSC7   := SC7->( GetArea() )
//Local aAreaSCR   := SCR->( GetArea() )
Local aDocto     := ParamIXB[1] // {1-N�mero Documento, 2-Tipo Documento, 3-Valor Documento, 4-C�digo Aprovador, 5-C�digo do Usu�rio, 6-Grupo Aprovador, 7-Aprovador Superior, 8-Moeda Documento, 9-Taxa Moeda, 10-Data Emiss�o, 11-Grupo Compras}
Local dDataRef   := ParamIXB[2] // Data de refer�ncia para o saldo
Local nOper      := ParamIXB[3] // 1-Inclus�o Documento, 2-Transfer�ncia Al�ada Superior, 3-Exclus�o Documento, 4-Aprova��o Documento, 5-Estorno Aprova��o, 6-Bloqueio Manual, 7-Rejei��o Documento
Local cDocSF1    := ParamIXB[4] // Chave(Alternativa) do SF1 para exclus�o SCR.
Local lResiduo   := ParamIXB[5] // Elimina��o de Residuos.
Local lRetorno   := .T.         // Customiza��es do usu�rio
Local lValido    := .T.
Local cCodProc   := GetMv("MV_EQ_PRWF",, "190001") // Processo recebimento...
Local aWFIDs     := {}
Local nPosWS     := 0
Local nLin       := 0
Local nPosPedido := 0

Private cNumPC   := ""
Private aAreaSC7 := {}
Private aAreaSD1 := {}

If AllTrim( aDocto[02] ) == "PC" // Caso Pedido de Compras...
	cNumPC := AllTrim( aDocto[01] )

    dbSelectArea("SC7")
    dbSetOrder(1)
    dbSeek( xFilial("SC7") + cNumPC )

	aAreaSC7 := SC7->( GetArea() )

	If !Empty( SC7->C7_EUWFID ) .And. lValido
		Do Case
			Case nOper == 1 // Inclus�o Documento
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " enviado para aprova��o",;
 					         "100200",;
					         "PEDIDO AGUARDANDO APROVACAO",;
		                     "1",;
					         "Pedido de Compras Aguardando Aprova��o" )
							U_STATUSCOMP(nOper)	

			Case nOper == 2 //Transfer�ncia Al�ada Superior
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " com al�ada transferida para n�vel superior",;
 					         "100205",;
					         "ALCADA TRANSFERIDA SUPERIOR",;
		                     "1",;
					         "Al�ada Transferida N�vel Superior" )
							U_STATUSCOMP(nOper)	
							
			Case nOper == 3 //Exclus�o Documento
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " com al�ada exclu�da",;
 					         "100290",;
					         "ALCADA DO PEDIDO EXCLUIDA",;
		                     "1",;
					         "Al�ada do Pedido Exclu�da" )
							U_STATUSCOMP(nOper)		

			Case nOper == 4 // Aprova��o Documento
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aprovado",;
 					         "200001",;
					         "PEDIDO DE COMPRAS APROVADO",;
		                     "1",;
					         "Pedido de Compras Aprovado" )
							 U_STATUSCOMP(nOper)	
							 u_ENVPCAP(cNumPC)

				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Aguardando Chegada da Mercadoria",;
 					         "200200",;
					         "PEDIDO AGUARDANDO CHEGADA",;
		                     "1",;
					         "Pedido de Compras Aguardando Chegada" )
							U_STATUSCOMP(nOper)		
								
				// Enviar Relat�rio de Pedido de Compras ao Fornecedor...
				U_EQPedCom( cNumPC )

			Case nOper == 5 // Estorno da Aprova��o
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Com Aprova��o Estornada",;
 					         "200901",;
					         "APROVACAO ESTORNADA",;
		                     "1",;
					         "Pedido de Compras com Aprova��o Estornada" )
							U_STATUSCOMP(nOper)	

			Case nOper == 6 // Bloqueio da Al�ada
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Com Bloqueio de Al�ada",;
 					         "100296",;
					         "ALCADA BLOQUEADA PELO APROVADOR",;
		                     "1",;
					         "Pedido de Compras com Bloqueio da Al�ada" )
							U_STATUSCOMP(nOper)	

			Case nOper == 7 // Rejei��o Documento
				U_EQGeraWFC( "Protheus - Pedido de Compras: " + AllTrim( cNumPC ) + " Rejeitado pelo Aprovador",;
 					         "100299",;
					         "PEDIDO REJEITADO",;
		                     "1",;
					         "Pedido de Compras Rejeitado pelo Aprovador" )
							U_STATUSCOMP(nOper)	

		EndCase
	EndIf
ElseIf AllTrim( aDocto[02] ) == "NF" // Caso Nota Fiscal de Entrada...
	If Type("aHeader") == "A"
		nPosPedido := aScan( aHeader, { |x| "D1_PEDIDO" $ x[2] })
		For nLin := 1 To Len( aCols )
			If !Empty( aCols[nLin][nPosPedido] )
				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + aCols[nLin][nPosPedido] ) )
					If !Empty( SC7->C7_EUWFID )
						If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
							aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	Else
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek( xFilial("SD1") + AllTrim( aDocto[01] ) )

		Do While !SD1->( Eof() ) .And. xFilial("SF1") + AllTrim( aDocto[01] ) == xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
			If !Empty( SD1->D1_PEDIDO )
				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + SD1->D1_PEDIDO ) )
					If !Empty( SC7->C7_EUWFID )
						If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
							aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
						EndIf
					EndIf
				EndIf
			EndIf

			SD1->( dbSkip() )
		EndDo
	EndIf

	For nPosWF := 1 To Len( aWFIDs )
		dbSelectArea("SC7")
		dbSetOrder(1)
		If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
			Do Case
				Case nOper == 1 // Inclus�o Documento
					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Bloqueado por Intoler�ncia no Recebimento. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400010",;
								 "BLOQUEIO NOTA FISCAL POR TOLERANCIA DE RECEBIMENTO",;
						         "1",;
								 "Bloqueio Nota Fiscal de Entrada por Toler�ncia de Recebimento" )

					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada Aguardando Aprova��o. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400011",;
								 "AGUARDANDO APROVACAO NOTA FISCAL",;
						         "1",;
								 "Aguardando Aprova��o Nota Fiscal de Entrada" )

				Case nOper == 4 // Aprova��o Documento
					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada Aprovada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400020",;
								 "APROVACAO NOTA FISCAL DE ENTRADA",;
						         "1",;
								 "Aprova��o Nota Fiscal de Entrada" )

					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada Aguardando Classifica��o. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400025",;
								 "AGUARDANDO CLASSIFICACAO NOTA FISCAL DE ENTRADA",;
						         "1",;
								 "Nota Fiscal de Entrada Aguardando Classifica��o" )

				Case nOper == 7 // Rejei��o Documento
					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada Rejeitadaa. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400019",;
								 "APROVACAO NOTA FISCAL DE ENTRADA REJEITADA",;
						         "1",;
								 "Rejeitada Nota Fiscal de Entrada fora da Toler�ncia" )

			EndCase
		EndIf
	Next
EndIf

//SCR->( RestArea( aAreaSCR ) )
//SC7->( RestArea( aAreaSC7 ) )
RestArea( aArea )

Return lRetorno