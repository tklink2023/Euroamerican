#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Efetiva Aprova�ao / Bloqueio do Pedido de Compra
User Function BeP0201B()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= ""
Local cOpc		:= ""
Local nRegSM0	:= SM0->(Recno())

Local lRet		:= .F.
Local lLiberou	:= .F.
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sess�o

Local nOpc		:= 0

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

//�����������������������������������������������������������Ŀ
//� Valida Op��o										      �
//�������������������������������������������������������������
If HttpPost->optlib <> Nil
	If HttpPost->optlib == "1"
		cOpc 	:= "Aprovado"
		nOpc	:= 4
	ElseIf HttpPost->optlib == "2"
		cOpc 	:= "Reprovado"
		nOpc	:= 6
	EndIf	
EndIf

//�����������������������������������������������������������Ŀ
//� 													      �
//�������������������������������������������������������������
DbSelectArea("SCR")
SCR->(DbSetOrder(1))	
//If !SCR->(DbSeek(HttpPost->filped+"PC"+HttpPost->numpc)) // Tratar para linha de baixo, com n�vel e campo CR_NUM tamanho de 50 no padr�o
//If !SCR->(DbSeek(xFilial("SC7")+"PC"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
If !SCR->(DbSeek(HttpPost->filped+"PC"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
	cMsgHdr		:= "BEP0201B - Al�ada N�o Encontrada"
	cMsgBody	:= "A al�ada de aprova��o n�o foi encontrada!"
	cRetFun		:= "u_BeP0201.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 

ElseIf SCR->CR_STATUS <> "02"
	//�����������������������������������������������������������Ŀ
	//�       	  �
	//�������������������������������������������������������������
	cMsgHdr		:= "BEP0201B - "+Iif(nOpc == 4,"Aprova��o","Reprova��o")+" Cancelada
	cMsgBody	:= "Aprova��o ou reprova��o realizada por outro usu�rio!"
	cRetFun		:= "u_BeP0201.apw"

ElseIf lSession .Or. HttpPost->numpc == Nil .Or. nOpc > 0
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+HttpPost->filped,.T.)
	cFilAnt := SM0->M0_CODFIL
 
	dbSelectArea("SC7")
	dbSetOrder(1)
	//dbSeek(xFilial("SC7")+Alltrim(HttpPost->numpc))
	dbSeek(cFilAnt+Alltrim(HttpPost->numpc))
	cGrupo := SC7->C7_APROV

	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))
	
	dbSelectArea("SAL")       
	dbSetOrder(3)
	MsSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD)    

	cHtml += Execblock("BePMenus",.F.,.F.)

	Begin	Transaction
    
  		While SCR->(!Eof())	.And. SCR->CR_FILIAL ==	xFilial("SCR") .And. SCR->CR_TIPO == "PC" .And. Alltrim(SCR->CR_NUM) == HttpPost->numpc
      
      		If AllTrim(SCR->CR_USER) == HttpSession->ccodusr .and. Empty(SCR->CR_USERLIB)

        		lRet := .t.

        		If lRet  

					/*
					�������������������������������������������������������������������������Ĵ��
					���Sintaxe   � MaAlcDoc(ExpA1,ExpD1,ExpN1,ExpC1,ExpL1)               	  ���
					�������������������������������������������������������������������������Ĵ��
					���Parametros� ExpA1 = Array com informacoes do documento                 ���
					���          �       [1] Numero do documento                              ���
					���          �       [2] Tipo de Documento                                ���
					���          �       [3] Valor do Documento                               ���
					���          �       [4] Codigo do Aprovador                              ���
					���          �       [5] Codigo do Usuario                                ���
					���          �       [6] Grupo do Aprovador                               ���
					���          �       [7] Aprovador Superior                               ���
					���          �       [8] Moeda do Documento                               ���
					���          �       [9] Taxa da Moeda                                    ���
					���          �      [10] Data de Emissao do Documento                     ���
					���          �      [11] Grupo de Compras                                 ���
					���          �      [12] Aprovador Original                               ���
					���          � ExpD1 = Data de referencia para o saldo                    ���
					���          � ExpN1 = Operacao a ser executada                           ���
					���          �       1 = Inclusao do documento                            ���
					���          �       2 = Transferencia para Superior                      ���
					���          �       3 = Exclusao do documento                            ���
					���          �       4 = Aprovacao do documento                           ���
					���          �       5 = Estorno da Aprovacao                             ���
					���          �       6 = Bloqueio Manual da Aprovacao                     ���
					���          � ExpC1 = Chave(Alternativa) do SF1 para exclusao SCR        ���
					���          � ExpL1 = Eliminacao de Residuos                             ���
					*/
					lRet := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV	,,SC7->C7_APROV,,,,,SCR->CR_OBS},dDatabase,nOpc )
					
      				// CR_STATUS== "01" Bloqueado p/ sistema (aguardando outros niveis)
      				// CR_STATUS== "02" Aguardando Liberacao do usuario
      				// CR_STATUS== "03" Pedido Liberado pelo usuario
      				// CR_STATUS== "04" Pedido Bloqueado pelo usuario
     	 			// CR_STATUS== "05" Pedido Liberado por outro usuario
          			If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03|04" 
          				If HttpPost->obslib <> Nil
            				RecLock("SCR",.F.)
            				SCR->CR_OBS := Transform(DecodeUTF8(HttpPost->obslib),"@x")
            				SCR->(MsUnLock())
            			EndIf

						//�����������������������������������������������������������Ŀ
  						//�       	  �
  						//�������������������������������������������������������������
						cMsgHdr		:= "BEP0201B - Pedido "+cOpc
						cMsgBody	:= "O pedido de compra "+SCR->CR_NUM+" foi "+cOpc+" com sucesso!"
						cRetFun		:= "u_BeP0201.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
            				
						If lRet 

							MEnviaMail("034",{SC7->C7_NUM,SCR->CR_TIPO},/*SC7->C7_USER*/"000000") 				
							
							If SuperGetMv("MV_EASY")=="S" .AND. SC7->(FieldPos("C7_PO_EIC"))<>0 .And. !Empty(SC7->C7_PO_EIC)
								If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .AND. SW2->(FieldPos("W2_CONAPRO"))<>0 .AND. !Empty(SW2->W2_CONAPRO)
									Reclock("SW2",.F.)
									SW2->W2_CONAPRO := "L"
									MsUnlock()
								EndIf
							EndIf
						
							dbSelectArea("SC7")
							While !SC7->(Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
								Reclock("SC7",.F.)
								SC7->C7_CONAPRO := "L"
								MsUnlock()
							
								SC7->(dbSkip())
							EndDo
                        EndIf

						cQuery := "SELECT C7_FILIAL, C7_NUM " + CRLF
						cQuery += "FROM " + RetSqlName("SC7") + " AS SC7 WITH (NOLOCK) " + CRLF
						cQuery += "WHERE C7_FILIAL = '" + xFilial("SC7") + "' " + CRLF
						cQuery += "AND C7_NUM = '" + AllTrim( SCR->CR_NUM ) + "' " + CRLF
						cQuery += "AND C7_PRODUTO LIKE 'RE%' " + CRLF
						cQuery += "AND C7_QUJE = 0 " + CRLF
						cQuery += "AND C7_CONAPRO = 'L' " + CRLF
						cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SC7") + " WITH (NOLOCK) WHERE C7_FILIAL = SC7.C7_FILIAL AND C7_NUM = SC7.C7_NUM AND C7_CONAPRO = 'B' AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SCR") + " WITH (NOLOCK) WHERE CR_FILIAL = C7_FILIAL AND CR_NUM = C7_NUM AND CR_TIPO = 'PC' AND CR_STATUS NOT IN ('03','05') AND D_E_L_E_T_ = ' ') " + CRLF
						cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF
						cQuery += "GROUP BY C7_FILIAL, C7_NUM " + CRLF

						TCQuery cQuery New Alias "TMPSC7"
						dbSelectArea("TMPSC7")
						dbGoTop()

						If !TMPSC7->( Eof() )
							_aCabSF1   := {}
							_aItensSD1 := {}
							_aLinha    := {}
							cFornece   := ""
						
							cQry := " SELECT	ROW_NUMBER() OVER (ORDER BY C7_ITEM) AS ITEM, * "
							cQry += " FROM " + RetSqlName("SC7")
							cQry += " WHERE	D_E_L_E_T_ = '' AND C7_PRODUTO LIKE 'RE%' "
							cQry += " 		AND C7_NUM = '" + TMPSC7->C7_NUM + "' "
							cQry += " 		AND C7_FILIAL = '" + TMPSC7->C7_FILIAL + "' "
							cQry += " ORDER BY C7_ITEM "
						
							If Select("TSC7") > 0
								TSC7->(dbCloseArea())
							EndIf
						
							TCQUERY cQry NEW ALIAS TSC7
						
							dbSelectArea("TSC7")
							dbGoTop()
						
							If	!EOF("TSC7")
								lMsErroAuto     :=	.F.
								cFornece		:=	TSC7->C7_FORNECE
						
								Aadd(_aCabSF1,{"F1_FILIAL"		,TSC7->C7_FILIAL	,Nil})
								Aadd(_aCabSF1,{"F1_TIPO"		,"N"				,Nil})
								Aadd(_aCabSF1,{"F1_FORMUL"		,"N"				,Nil})
								Aadd(_aCabSF1,{"F1_DOC"			,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
								Aadd(_aCabSF1,{"F1_SERIE"		,"REC"				,Nil})
								Aadd(_aCabSF1,{"F1_EMISSAO"		,dDataBase			,Nil})
								Aadd(_aCabSF1,{"F1_FORNECE"     ,TSC7->C7_FORNECE	,Nil})
								Aadd(_aCabSF1,{"F1_LOJA"		,TSC7->C7_LOJA		,Nil})
								Aadd(_aCabSF1,{"F1_ESPECIE"		,"RECIB"			,Nil})
								Aadd(_aCabSF1,{"F1_COND"		,TSC7->C7_COND		,Nil})
								Aadd(_aCabSF1,{"F1_DTDIGIT"		,dDataBase			,Nil})
								Aadd(_aCabSF1,{"F1_EST"			," "				,Nil})
								If	AllTrim(TSC7->C7_PRODUTO) $ "RE.0017"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403004"		,Nil})	// 1403.1
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0018"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402046"		,Nil})  // 1606
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0019"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0404004"		,Nil})  // 1304
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0021"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202004"		,Nil})  // 1519
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0022"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402003"		,Nil})  // 1402
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0030"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0403005"		,Nil})  // 1403.2
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0031"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402060"		,Nil})  // 1901
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0033"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402071"		,Nil})  // 1931
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0034"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402072"		,Nil})  // 1932
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0035"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0202003"		,Nil})  // 1514 	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0036"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301008"		,Nil})  // 1802
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0037"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301009"		,Nil})  // 1803
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0038"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301010"		,Nil})  // 1804	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0039"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301007"		,Nil})  // 1801	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0040"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301011"		,Nil})  // 1806	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0041"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301016"		,Nil})  // 1899	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0042"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301001"		,Nil})  // 1447
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0044"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402050"		,Nil})  // 1719	
								ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.SGA.0049"
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0301021"		,Nil})  												
								Else
									Aadd(_aCabSF1,{"E2_NATUREZ"		,"0402068"		,Nil})  // 1917
								EndIf

								While !EOF("TSC7")
									_aLinha		:=	{}
									Aadd(_aLinha,{"D1_FILIAL"	,TSC7->C7_FILIAL	,Nil})
									Aadd(_aLinha,{"D1_ITEM"		,StrZero(TSC7->ITEM,4),Nil})  //Alterado 28/09/2016 TSC7->C7_ITEM
									Aadd(_aLinha,{"D1_FORNECE"	,TSC7->C7_FORNECE	,Nil})
									Aadd(_aLinha,{"D1_LOJA"		,TSC7->C7_LOJA		,Nil})
									Aadd(_aLinha,{"D1_DOC"		,StrZero(Val(TMPSC7->C7_NUM),9)	,Nil})
									Aadd(_aLinha,{"D1_PEDIDO"	,TSC7->C7_NUM		,Nil})
									Aadd(_aLinha,{"D1_COD"		,TSC7->C7_PRODUTO	,Nil})
									Aadd(_aLinha,{"D1_UM"		,TSC7->C7_UM		,Nil})
									Aadd(_aLinha,{"D1_QUANT"	,TSC7->C7_QUANT		,Nil})
									Aadd(_aLinha,{"D1_VUNIT"	,TSC7->C7_PRECO		,Nil})
									Aadd(_aLinha,{"D1_TOTAL"	,TSC7->C7_TOTAL		,Nil})
									Aadd(_aLinha,{"D1_TES"		,IIf(Empty(AllTrim(TSC7->C7_TES)),"000",TSC7->C7_TES),Nil})
									Aadd(_aLinha,{"D1_CF"		,"1949"				,Nil})
									Aadd(_aLinha,{"D1_CC"		,TSC7->C7_CC		,Nil})
									Aadd(_aLinha,{"D1_ITEMPC"	,TSC7->C7_ITEM		,Nil})
									Aadd(_aLinha,{"D1_EMISSAO"	,dDataBase				})
									Aadd(_aLinha,{"D1_DTDIGIT"	,dDataBase			,Nil})
									Aadd(_aLinha,{"D1_LOCAL"	,TSC7->C7_LOCAL		,Nil})
									Aadd(_aLinha,{"D1_SERIE"	,"REC"				,Nil})
									Aadd(_aLinha,{"D1_TIPO"		,"N"				,Nil})
									Aadd(_aLinha,{"D1_FORMUL"	,"N"					})
									Aadd(_aLinha,{"D1_RATEIO"	,"2"				,Nil})
									Aadd(_aLinha,{"D1_TP"		,"RE"				,Nil})
									Aadd(_aLinha,{"AUTDELETA"	,"N"				,Nil})
									Aadd(_aItensSD1,_aLinha)
						
									TSC7->(dbSkip())
								EndDo
						
								MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)
						
								If lMsErroAuto
									//MostraErro()
								EndIf
							EndIf
						EndIf

						TMPSC7->( dbCloseArea() )
         	 		Else
						//�����������������������������������������������������������Ŀ
  						//�      	  �
  						//�������������������������������������������������������������
						cMsgHdr		:= "BEP0201B - Erro Inesperado "
						cMsgBody	:= "O pedido de compra "+SCR->CR_NUM+" n�o p�de ser "+cOpc+". Entre em contato com o Administrador do Sistema!"
						cRetFun		:= "u_BeP0201.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
         	 		Endif  
        		Endif
      		
      			Exit

      		EndIf
      		
      		SCR->(DbSkip())
		EndDo  

	End Transaction
	
Else
	cMsgHdr		:= "BEP0201B - Sess�o n�o Iniciada"
	cMsgBody	:= "A sess�o n�o foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL

Return (EncodeUTF8(cHtml))
