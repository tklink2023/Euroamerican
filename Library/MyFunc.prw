//Bibliotecas
#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

User Function SeachNumber()
    Local cArea     := FwGetArea()
    Local cQuery    := ' '
    Local cNumSeq   :=" "

    Local cAlias    := ParamIXB[1]
    Local cCampo    := ParamIXB[2]
    Local cFiltro   := ParamIXB[3]
    Local cExtenso  := ParamIXB[4]

    Local cNumSxe   := GETSXENUM(cAlias,cCampo )

    cQuery := "Select " + CRLF
    cQuery += "Isnull( Max("+cCampo+"),'') as Ultimo " + CRLF
    cQuery += "From "+ CRLF
    cQuery += " "+RetSQLName(cAlias)+" TAB "+ CRLF
    cQuery += "Where TAB.D_E_L_E_T_ = ' ' "+ CRLF
    cQuery += "AND "+ cFiltro +" = '"+FWxFilial(cAlias) + "' " + CRLF
    if !Empty(cExtenso)
       cQuery += "AND "+cExtenso+" " + CRLF
    endif
    cQuery := ChangeQuery(cQuery)
    TCQuery cQuery New Alias "QRY_TAB"

    If !Empty(QRY_TAB->Ultimo)
            cNumSeq := QRY_TAB->Ultimo
    EndIf
     QRY_TAB->(DbCloseArea())
    FwRestArea(cArea)
Return(cNumSeq)

User Function TstNumber()
   Local aRetNum := " "
   Local aParam1 := {}

   if ExistBlock("SeachNumber")
              aParam1 := {"SC5","C5_NUM","C5_FILIAL","SUBSTRING(C5_NUM,1,1) < 'A'"}
              aRetNum:= ExecBlock("SeachNumber",.F.,.F.,aParam1)  
    Endif
    MsgAlert( "Sequencia : "+aRetNum,"Return")
Return
