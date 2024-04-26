#Include 'Protheus.ch'
/*/{Protheus.doc} A140IGRV
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/04/2024
@return variant, return_description
/*/
User Function A140IGRV()
    Local cArea  := FwGetArea()

    Local cNota  := Paramixb[1]
    Local cSerie := Paramixb[2]
    Local cfornec:=Paramixb[3]
    Local cLoja  := Paramixb[4]
    Local nRet   := 0
    Local cQuery := ""
    Local cFilOp := cFilant

    if cFilOp = '1001'
   
        cQuery:= "UPDATE "+RetSQLName("SDT")+" SET DT_LOTE = SD2.D2_LOTECTL , DT_DTVALID = SD2.D2_DTVALID "
        cQuery+= "FROM "+RetSQLName("SDT")+" SDT "
        cQuery+= "INNER JOIN "+RetSQLName("SD2")+" SD2 ON SD2.D2_FILIAL = '0803' AND SD2.D2_DOC = DT_DOC AND SD2.D2_COD = DT_PRODFOR AND SUBSTRING(DT_ITEM,3,2) = SD2.D2_ITEM AND SD2.D_E_L_E_T_ = ' ' "
        cQuery+= "Where SDT.D_E_L_E_T_ = ' ' "
        cQuery+= "AND DT_FILIAL = '"+xFilial("SDT")+"' "
        cQuery+= "AND DT_DOC = '"+cNota+"' "
        cQuery+= "AND DT_SERIE = '"+cSerie+"' "
        cQuery+= "AND DT_FORNEC = '"+cfornec+"' "
        cQuery+= "AND DT_LOJA = '"+cLoja+"' "
        nRet := TCSQLExec(cQuery)
    
        If(nRet < 0 )
            Conout("Erro na execução da query:"+TcSqlError(), "Atenção")
        EndIf    
    endif   

   if cFilOp = '0902'
   
        cQuery:= "UPDATE "+RetSQLName("SDT")+" SET DT_LOTE = SD2.D2_LOTECTL , DT_DTVALID = SD2.D2_DTVALID "
        cQuery+= "FROM "+RetSQLName("SDT")+" SDT "
        cQuery+= "INNER JOIN "+RetSQLName("SD2")+" SD2 ON SD2.D2_FILIAL = '0200' AND SD2.D2_DOC = DT_DOC AND SD2.D2_COD = DT_PRODFOR AND SUBSTRING(DT_ITEM,3,2) = SD2.D2_ITEM AND SD2.D_E_L_E_T_ = ' ' "
        cQuery+= "Where SDT.D_E_L_E_T_ = ' ' "
        cQuery+= "AND DT_FILIAL = '"+xFilial("SDT")+"' "
        cQuery+= "AND DT_DOC = '"+cNota+"' "
        cQuery+= "AND DT_SERIE = '"+cSerie+"' "
        cQuery+= "AND DT_FORNEC = '"+cfornec+"' "
        cQuery+= "AND DT_LOJA = '"+cLoja+"' "
        nRet := TCSQLExec(cQuery)
    
        If(nRet < 0 )
            Conout("Erro na execução da query:"+TcSqlError(), "Atenção")
        EndIf    
    endif    

    FwRestArea(cArea)
Return

/*/{Protheus.doc} COLSTTS
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/04/2024
@return variant, return_description
/*/
User Function COLSTTS()
    Local cArea  := FwGetArea()
    Local cNota  := SDS->DS_DOC
    Local cSerie := SDS->DS_SERIE
    Local cfornec:= SDS->DS_FORNEC
    Local cLoja  := SDS->DS_LOJA
    Local nRet   := 0
    Local cQuery := ""
    Local cFilOp := cFilant
    if cFilOp <> '1001'
        FwRestArea(cArea)
        Return
    Endif

    cQuery:= "UPDATE "+RetSQLName("SD1")+" SET D1_LOTEFOR = DT_LOTE  "
    cQuery+= "FROM "+RetSQLName("SD1")+" SD1 "
    cQuery+= "INNER JOIN "+RetSQLName("SDT")+" SDT ON DT_FILIAL = D1_FILIAL AND D1_DOC = DT_DOC AND D1_FORNECE = DT_FORNEC AND D1_COD = DT_COD AND SDT.D_E_L_E_T_ = ' '
    cQuery+= "Where SD1.D_E_L_E_T_ = ' ' "
    cQuery+= "AND D1_FILIAL = '"+xFilial("SD1")+"' "
    cQuery+= "AND D1_DOC = '"+cNota+"' "
    cQuery+= "AND D1_SERIE = '"+cSerie+"' "
    cQuery+= "AND D1_FORNECE = '"+cfornec+"' "
    cQuery+= "AND D1_LOJA = '"+cLoja+"' "
    nRet := TCSQLExec(cQuery)
 
    If(nRet < 0 )
        Conout("Erro na execução da query:"+TcSqlError(), "Atenção")
    EndIf    

   FwRestArea(cArea)
Return


