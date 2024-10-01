#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function GTCom001()
    Local cArea := FwGetArea()
    Local lRetorno := .T.
    dbSelectArea("SA2")
    dbSetOrder(1)
	If SA2->( dbSeek( xFilial("SA2") + cA120Forn + cA120Loj ) )
		If AllTrim( SA2->A2_EQ_ISO9 ) == "S"
		 	If SA2->A2_EQ_ISOV < dDataBase
				ApMsgAlert( "Fornecedor possui validade do certificado ISO 9000 vencida, pedido não pode ser gravado!", "Atenção")
				lRetorno := .F.
			ElseIf SA2->A2_EQ_ISOV >= dDataBase .and. SA2->A2_EQ_ISOV <= dDatabase + 30 
				ApMsgInfo( "Certificado do fornecedor está para expirar!", "Aviso")
			EndIf
		EndIf
	EndIf
    FwRestArea(cArea)
Return(lRetorno)
