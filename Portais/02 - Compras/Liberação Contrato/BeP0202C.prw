#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

//Transfer�ncia Superior
User Function BeP0202C()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= ""
Local nRegSM0	:= SM0->(Recno())
Local lRet		:= .F.
Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sess�o
Local cCodUser  := ""
Local cCodAprov := ""

Private cHtml 	:= ""    

WEB EXTENDED INIT cHtml                               

cHtml += Execblock("BePHeader",.F.,.F.)

DbSelectArea("SCR")
SCR->(DbSetOrder(1))	
If !SCR->(DbSeek(xFilial("SC3")+"CP"+Padr(HttpPost->numpc,TamSX3("CR_NUM")[1])+HttpPost->nivapr))
	cMsgHdr		:= "BeP0202C - Al�ada N�o Encontrada"
	cMsgBody	:= "A al�ada de aprova��o n�o foi encontrada!"
	cRetFun		:= "u_BeP0202.apw"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
ElseIf SCR->CR_STATUS <> "02"
	//�����������������������������������������������������������Ŀ
	//�       	  �
	//�������������������������������������������������������������
	cMsgHdr		:= "BeP0202C - Transfer�ncia Superior Cancelada"
	cMsgBody	:= "Aprova��o ou reprova��o realizada por outro usu�rio!"
	cRetFun		:= "u_BeP0202.apw"
ElseIf lSession .Or. HttpPost->numpc == Nil
	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))

	cCodUser  := SAK->AK_USER
	cCodAprov := SAK->AK_COD

	dbSelectArea("SAK")
	dbSetOrder(1)
	dbSeek(xFilial("SAK")+Alltrim(SAK->AK_APROSUP))

	cQuery := "UPDATE " + RetSqlName("SCR") + " SET CR_USER = '" + SAK->AK_USER + "', CR_APROV = '" + SAK->AK_COD + "', CR_USERORI = '" + cCodUser + "', CR_APRORI = '" + cCodAprov + "' "
	cQuery += "WHERE CR_FILIAL = '" + SCR->CR_FILIAL + "' "
	cQuery += "AND CR_NUM = '" + AllTrim( HttpPost->numpc ) + "' "
	cQuery += "AND CR_TIPO = 'CP' "
	cQuery += "AND CR_STATUS = '02' "
	cQuery += "AND CR_APROV = '" + cCodAprov + "' "
	cQuery += "AND CR_USER = '" + cCodUser + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "

	TCSqlExec( cQuery )

	cMsgHdr		:= "BeP0202C - Contrato de Parceria"
	cMsgBody	:= "O contrato de parceria "+SCR->CR_NUM+" foi transferido para o superior com sucesso!"
	cRetFun		:= "u_BeP0202.apw"

	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
Else
	cMsgHdr		:= "BEP0202C - Sess�o n�o Iniciada"
	cMsgBody	:= "A sess�o n�o foi iniciada, realize o Login!"
	cRetFun		:= "u_BePLogin"
	
	cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
EndIf

cHtml += Execblock("BePFooter",.F.,.F.)

WEB EXTENDED END

SM0->(dbGoTo(nRegSM0))
cFilAnt := SM0->M0_CODFIL

Return (EncodeUTF8(cHtml))
