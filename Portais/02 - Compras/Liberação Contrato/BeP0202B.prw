#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Efetiva Aprova�ao / Bloqueio do Pedido de Compra
User Function BeP0202B()

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
//If !SCR->(DbSeek(xFilial("SC3")+"CP"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
If !SCR->(DbSeek(AllTrim(HttpPost->filped)+"CP"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
	cMsgHdr		:= "BEP0202B - Al�ada N�o Encontrada"
	cMsgBody	:= "A al�ada de aprova��o n�o foi encontrada!"
	cRetFun		:= "u_BeP0202.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun})

ElseIf SCR->CR_STATUS <> "02"
	//�����������������������������������������������������������Ŀ
	//�       	  �
	//�������������������������������������������������������������
	cMsgHdr		:= "BEP0202B - "+Iif(nOpc == 4,"Aprova��o","Reprova��o")+" Cancelada
	cMsgBody	:= "Aprova��o ou reprova��o realizada por outro usu�rio!"
	cRetFun		:= "u_BeP0202.apw"

ElseIf lSession .Or. HttpPost->numpc == Nil .Or. nOpc > 0
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+HttpPost->filped,.T.)
	cFilAnt := SM0->M0_CODFIL
 
	dbSelectArea("SC3")
	dbSetOrder(1)
	//dbSeek(xFilial("SC3")+Alltrim(HttpPost->numpc))
	dbSeek(cFilAnt+Alltrim(HttpPost->numpc))
	cGrupo := SC3->C3_APROV

	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))
	
	dbSelectArea("SAL")       
	dbSetOrder(3)
	MsSeek(xFilial("SAL")+SC3->C3_APROV+SAK->AK_COD)    

	cHtml += Execblock("BePMenus",.F.,.F.)

	Begin	Transaction
    
  		While SCR->(!Eof())	.And. SCR->CR_FILIAL ==	xFilial("SCR") .And. SCR->CR_TIPO == "CP" .And. Alltrim(SCR->CR_NUM) == HttpPost->numpc
      
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
					lRet := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,SCR->CR_TOTAL,SCR->CR_APROV	,,SC3->C3_APROV,,,,,SCR->CR_OBS},dDatabase,nOpc )
					
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
						cMsgHdr		:= "BEP0202B - Contrato Parceria "+cOpc
						cMsgBody	:= "O contrato de parceria "+SCR->CR_NUM+" foi "+cOpc+" com sucesso!"
						cRetFun		:= "u_BeP0202.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
            				
						If lRet 

							MEnviaMail("034",{SC7->C7_NUM,SCR->CR_TIPO},/*SC7->C7_USER*/"000000") 				
							
							dbSelectArea("SC3")
							While !SC3->(Eof()) .And. SC3->C3_FILIAL+Substr(SC3->C3_NUM,1,len(SC3->C3_NUM)) == xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM))
								Reclock("SC3",.F.)
									SC3->C3_CONAPRO := "L"
								MsUnlock()
							
								SC3->(dbSkip())
							EndDo
                        EndIf
         	 		Else
						//�����������������������������������������������������������Ŀ
  						//�      	  �
  						//�������������������������������������������������������������
						cMsgHdr		:= "BEP0202B - Erro Inesperado "
						cMsgBody	:= "O contrato de parceria "+SCR->CR_NUM+" n�o p�de ser "+cOpc+". Entre em contato com o Administrador do Sistema!"
						cRetFun		:= "u_BeP0202.apw"
	
						cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
         	 		Endif  
        		Endif
      		
      			Exit

      		EndIf
      		
      		SCR->(DbSkip())
		EndDo  

	End Transaction
	
Else
	cMsgHdr		:= "BEP0202B - Sess�o n�o Iniciada"
	cMsgBody	:= "A sess�o n�o foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL

Return (EncodeUTF8(cHtml))
