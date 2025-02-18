#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#DEFINE cEof  CHAR(13)+CHAR(10)

/*/{Protheus.doc} MPCPWF002
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
User Function PCPJ020()
  If !IsBlind()
        Ambiente()
  Endif      
  RunProc()
Return

/*/{Protheus.doc} Ambiente
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
Static Function Ambiente()
    Local cAutoEmp := "10"
    Local cAutoFil := "0803"
    RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
    If Select("SX2") <= 0
	    RpcSetEnv( cAutoEmp, cAutoFil )
    Endif    
Return

/*/{Protheus.doc} RunProc
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
Static Function RunProc()
    Local cArea       := FwGetArea()
    Local cAlias      := GetNextAlias()
    Local cQuery      := ''
    Private nTotal    := 0  

    PCP110CLEAN()

    cQuery := "SELECT                                                                                                                     "+CRLF
    cQuery += "    C6_PRODUTO  CODIGO                                                                                                     "+CRLF
    cQuery += "		,B1_DESC DESCRICAO                                                                                                      "+CRLF
    cQuery += "		,round((SUM(C6_QTDVEN)/6),3) QTD                                                                                        "+CRLF
    cQuery += "		,ROUND((ROUND((SUM(C6_VALOR)/6),2) / round((SUM(C6_QTDVEN)/6),3) ),2) UNITARIO                                          "+CRLF
    cQuery += "		,ROUND(((ROUND((ROUND((SUM(C6_VALOR)/6),2) / round((SUM(C6_QTDVEN)/6),3) ),2)) * round((SUM(C6_QTDVEN)/6),3)),2) TOTALFAT  "+CRLF
    cQuery += "FROM " + RetSqlName("SC6") + " SC6                                                                                         "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC5.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO IN ( 'PA' ) AND B1_XCLASSI = 'L' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"'                                                                                       "+CRLF
    cQuery += "AND C5_EMISSAO BETWEEN dateadd(month, -6, getdate()) AND GetDate()                                                         "+CRLF
    cQuery += "GROUP BY C6_PRODUTO, B1_DESC                                                                                               "+CRLF
    cQuery += "ORDER BY C6_PRODUTO                                                                                                        "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
        RegLog("Sem dados para processar")
		Return
    ENDIF

    PCP150FAT()

    While (cAlias)->( !Eof() )
            dbSelectArea("SZ3")
            SZ3->( dbSetOrder(1) )
            IF SZ3->( !dbseek(xFilial("SZ3")+(cAlias)->CODIGO,.T. ) )
              if    SZ3->( Reclock("SZ3",.T.) )
                    SZ3->Z3_FILIAL   := xFilial("SZ3")
                    SZ3->Z3_COD      := (cAlias)->CODIGO
                    SZ3->Z3_DESC     := (cAlias)->DESCRICAO
                    SZ3->Z3_QUANT    := (cAlias)->QTD
                    SZ3->Z3_VALOR    := (cAlias)->UNITARIO
                    SZ3->Z3_TOTAL    := (cAlias)->TOTALFAT
                    SZ3->Z3_PERC     := ((cAlias)->TOTALFAT / nTotal) * 100
                    SZ3->( MsUnlock() )
              ELSE
                    SZ3->( Reclock("SZ3",.F.) )
                    SZ3->Z3_QUANT    := (cAlias)->QTD
                    SZ3->Z3_VALOR    := (cAlias)->UNITARIO
                    SZ3->Z3_TOTAL    := (cAlias)->TOTALFAT
                    SZ3->Z3_PERC     := ((cAlias)->TOTALFAT / nTotal) * 100
                    SZ3->( MsUnlock() )
              ENDIF
            ENDIF  
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    PCP110ACUM()
  
    FwRestArea(cArea)
Return 

/*/{Protheus.doc} PCP150FAT
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
Static Function PCP150FAT()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    cQuery := " SELECT round(((ROUND((ROUND(SUM(C6_VALOR),2) / SUM(C6_QTDVEN)),2)) * SUM(C6_QTDVEN))/6 ,2) AS TOTALFAT  "+CRLF
    cQuery += "FROM " + RetSqlName("SC6") + " SC6 "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC5.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO IN ( 'PA' ) AND B1_XCLASSI = 'L' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "Where SC6.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
    cQuery += "AND C5_EMISSAO BETWEEN dateadd(month, -6, getdate()) AND GetDate() "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
         RegLog("Sem dados para processar")
		Return
    ENDIF

    While (cAlias)->( !Eof() )
            nTotal := (cAlias)->TOTALFAT
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    FwRestArea(cArea)
Return

/*/{Protheus.doc} PCP110ACUM
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
Static Function PCP110ACUM()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    Local nPerc    := 0

    cQuery := " SELECT SZ3.* "+CRLF
    cQuery += "FROM " + RetSqlName("SZ3") + " SZ3 "+CRLF
    cQuery += "WHERE D_E_L_E_T_ =' '   "+CRLF
    cQuery += "ORDER BY Z3_TOTAL DESC  "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
         RegLog("Sem dados para processar")
		Return
    ENDIF
    
    While (cAlias)->( !Eof() )
            nPerc := nPerc + (cAlias)->Z3_PERC
            dbSelectArea("SZ3")
            SZ3->( dbSetOrder(1) )
            if SZ3->( dbseek(xFilial("SZ3")+(cAlias)->Z3_COD,.T. ) )
                    SZ3->( Reclock("SZ3",.F.) )
                    SZ3->Z3_ACUM:= nPerc
                    
                    if SZ3->Z3_ACUM >= 0 .and. SZ3->Z3_ACUM <= 80
                        SZ3->Z3_CURVA := "A"
                    elseif SZ3->Z3_ACUM > 80 .and. SZ3->Z3_ACUM <= 95
                        SZ3->Z3_CURVA := "B"
                    else
                        SZ3->Z3_CURVA := "C"
                    ENDIF    

                    SZ3->( MsUnlock() )
            ENDIF
            
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())
    IF nPerc > 0
        RegLog("Gerado com sucesso")
    ENDIF
    FwRestArea(cArea)   
Return

/*/{Protheus.doc} PCP110CLEAN
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@return variant, return_description
/*/
Static FuNction PCP110CLEAN()
    Local cArea    := FwGetArea()
    Local cQuery   := ''
    cQuery := "DELETE FROM " + RetSqlName("SZ3") + " "+CRLF
    If TCSqlExec(cQuery) < 0
         CONOUT("Erro ao limpar a tabela SZ3")
         RegLog("Erro ao limpar a tabela SZ3")
     EndIf    
    FwRestArea(cArea)
Return

/*/{Protheus.doc} RegLog
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/02/2025
@param cMensagem, character, param_description
@return variant, return_description
/*/
Static Function RegLog(cMensagem)
    Local cArea := FwGetArea()

        dbSelectArea("CV8")
        If RecLock("CV8",.T.)
                CV8->CV8_FILIAL:= xFilial("CV8")
                CV8->CV8_DATA 	:= MsDate()
                CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
                CV8->CV8_PROC	:= 'PCPJ020'
                CV8->CV8_USER	:= 'ADMINISTRADOR            '
                CV8->CV8_INFO   := '2'
                CV8->CV8_MSG 	:= cMensagem
                CV8->(MsUnlock())
          EndIf

     FwRestArea(cArea)
Return
