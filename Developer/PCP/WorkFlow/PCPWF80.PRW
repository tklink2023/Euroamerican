#include "totvs.ch"

/*/{Protheus.doc} PCPWF80
description Scheduller para atualizar a tabela PZ2 que corresponde os movimentos producao
@type function
@version 1.0
@author Paulo Lenzi
@since 17/12/2024
@return variant, return_description
/*/
User Function PCPWF80()
     Local  _lAuto	:= .F.

     If Select("SM0") <= 0
		RPCSetType(3)
		RpcSetEnv( "10","0803",,,"PCP",,,,,,)
		CONOUT(">>>Inicio do processo de gravacao das tabelas PZ2/PZ3<<<")
		CONOUT("Data:"+Dtos(dDataBase)+" Hora: "+Time())
		_lAuto := .T.
	endif

    if _lAuto
        RunProc()
        RunProj()
        RegLog()
    else
         Processa({||  RunProc() }, "Processando...")
         Processa({||  RunProj() }, "Processando...")
         Processa({||  RegLog() }, "Processando...")
    endif

Return


/*/{Protheus.doc} RunProc
description Rotina que utliza a Query para atualizar a tabela PZ2
@type function
@version 1.0
@author Paulo Lenzi
@since 17/12/2024
@return variant, return_description
/*/
Static Function RunProc()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "PCP_"+getNextAlias()     

   cQuery:="Select B2_FILIAL	FILIAL                                                         "+CRLF
   cQuery+="		,B2_COD		CODIGO                                                         "+CRLF
   cQuery+="		,B1_DESC    DESCRICAO                                                      "+CRLF
   cQuery+="		,B2_LOCAL	ALMOX                                                          "+CRLF
   cQuery+="		,B2_QATU	   SALDO                                                          "+CRLF
   cQuery+="		,B2_QEMP	   EMPENHO                                                        "+CRLF
   cQuery+="		,ROUND((B2_QATU - B2_QEMP),3) DISPO                                        "+CRLF
   cQuery+="		,ISNULL(ROUND((SELECT DIstinct AVG(Produzido) OVER(PARTITION BY Ano) AS Media "+CRLF
   cQuery+="		  FROM ( Select	D4_COD as Produto,                                       "+CRLF
   cQuery+="						Year(D4_DATA) as Ano,                                          "+CRLF
   cQuery+="						Month(D4_DATA) as Mes,                                         "+CRLF
   cQuery+="						Sum(D4_QTDEORI) as Produzido                                   "+CRLF
   cQuery+="				 From " + RetSqlName("SD4") + " SD4                                  "+CRLF
   cQuery+="				 Where SD4.D_E_L_E_T_ = ' '                                          "+CRLF
   cQuery+="				 AND D4_FILIAL = B2_FILIAL                                           "+CRLF
   cQuery+="				 AND Year(D4_DATA) = YEAR(Getdate())                                 "+CRLF
   cQuery+="				 AND Month(D4_DATA) BETWEEN Month(GetDate())-6 AND Month(GetDate())  "+CRLF
   cQuery+="				 AND D4_COD = B2_COD                                                 "+CRLF
   cQuery+="				 Group By D4_COD, Year(D4_DATA),Month(D4_DATA) ) xxx),3),0) MEDIA    "+CRLF
   cQuery+="From " + RetSqlName("SB2") + " SB2                                               "+CRLF
   cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = B2_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="Where SB2.D_E_L_E_T_ = ' '                                                       "+CRLF
   cQuery+="AND B2_FILIAL = '"+xFilial("SB2")+"'                                             "+CRLF
   cQuery+="AND B2_LOCAL = B1_LOCPAD                                                         "+CRLF
   cQuery+="AND B2_QATU > 0                                                                  "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return
   endif

    dbselectArea(cAlias)
    (cAlias)->( dbGoTop() )
    While (cAlias)->( !Eof())
            dbSelectArea("PZ2")
            PZ2->( dbSetOrder(1))
            IF PZ2->( !dbSeek(xFilial("PZ2")+(cAlias)->CODIGO,.T.))
               IF RecLock("PZ2", .T.)
                  PZ2->PZ2_FILIAL   :=  xFilial("PZ2")
                  PZ2->PZ2_COD      := (cAlias)->CODIGO
                  PZ2->PZ2_DESCR    := (cAlias)->DESCRICAO
                  PZ2->PZ2_LOCAL    := (cAlias)->ALMOX
                  PZ2->PZ2_SALDO    := (cAlias)->SALDO
                  PZ2->PZ2_EMP      := (cAlias)->EMPENHO
                  PZ2->PZ2_DISPO    := (cAlias)->DISPO
                  PZ2->PZ2_MEDIA    := (cAlias)->MEDIA
                  PZ2->PZ2_DEMAN    := IIF((cAlias)->MEDIA>0, ROUND(((cAlias)->MEDIA / 30 ),0) ,0 )
                  PZ2->PZ2_STOK     := IIF((cAlias)->DISPO>0, ROUND(((cAlias)->DISPO / 30),0),0)
                  PZ2->( MsUnlock())
               Endif
            else
               IF RecLock("PZ2", .F.)
                  PZ2->PZ2_SALDO    := (cAlias)->SALDO
                  PZ2->PZ2_EMP      := (cAlias)->EMPENHO
                  PZ2->PZ2_DISPO    := (cAlias)->DISPO
                  PZ2->PZ2_MEDIA    := (cAlias)->MEDIA
                  PZ2->PZ2_DEMAN    := IIF((cAlias)->MEDIA>0, ROUND(((cAlias)->MEDIA / 30 ),0) ,0 )
                  PZ2->PZ2_STOK     := IIF((cAlias)->DISPO>0, ROUND(((cAlias)->DISPO / 30),0),0)
                  PZ2->( MsUnlock())
               Endif
                   
            Endif
        (cAlias)->( dbSkip() )
    EndDo
            
    (calias)->(DbCloseArea()) 
    FwRestArea(aArea)
Return

/*/{Protheus.doc} RunProj
description Rotina que atualiza a tabela PZ3 sobre empenho das materias primas e embalagem
@type function
@version 1.0
@author Paulo Lenzi
@since 17/12/2024
@return variant, return_description
/*/
Static Function RunProj()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "PCP_"+getNextAlias()     

cQuery:="SELECT CODIGO,ANO,MES,DIA,QTD,D4_DATA              "+CRLF
cQuery+="FROM (                                             "+CRLF
cQuery+="    SELECT                                         "+CRLF
cQuery+="		  D4_COD			   AS CODIGO,                 "+CRLF
cQuery+="        DAY(D4_DATA)	   AS DIA,                    "+CRLF
cQuery+="        MONTH(D4_DATA)	AS MES,                    "+CRLF
cQuery+="        YEAR(D4_DATA)	AS ANO,                    "+CRLF
cQuery+="        D4_DATA,                                   "+CRLF
cQuery+="        Sum(D4_QTDEORI) as QTD                     "+CRLF
cQuery+="    FROM " + RetSqlName("SD4") + " SD4             "+CRLF
cQuery+="	INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D4_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' '  "+CRLF
cQuery+="	INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND  B2_LOCAL = D4_LOCAL AND B2_QATU > 0 AND  SB2.D_E_L_E_T_ = ' '                               "+CRLF
cQuery+="	Where SD4.D_E_L_E_T_ = ' '                      "+CRLF
cQuery+="	AND D4_FILIAL = '"+xFilial("SD4")+"'            "+CRLF
cQuery+="	AND YEAR(D4_DATA) = YEAR(Getdate())             "+CRLF
cQuery+="	AND MONTH(D4_DATA) >= Month(GetDate())          "+CRLF
cQuery+="    GROUP BY D4_COD, YEAR(D4_DATA), MONTH(D4_DATA), DAY(D4_DATA),D4_DATA "+CRLF
cQuery+=") a                                                 "+CRLF
cQuery+="ORDER BY CODIGO, ANO, MES, DIA                      "+CRLF

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
TCSetField(cAlias, "D4_DATA", "D")

   IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return
   endif

    dbselectArea(cAlias)
    (cAlias)->( dbGoTop() )
    While (cAlias)->( !Eof())
            dbSelectArea("PZ3")
            PZ3->( dbSetOrder(1))
            IF PZ3->( !dbSeek(xFilial("PZ3")+(cAlias)->CODIGO + cValtoChar((cAlias)->ANO) + cValtoChar((cAlias)->MES) + cValtoChar((cAlias)->DIA) ,.T.))
               IF RecLock("PZ3", .T.)
                  PZ3->PZ3_FILIAL       :=  xFilial("PZ3")
                  PZ3->PZ3_PROD         := (cAlias)->CODIGO
                  PZ3->PZ3_ANO          := cValtoChar((cAlias)->ANO)
                  PZ3->PZ3_MES          := cValtoChar((cAlias)->MES)
                  PZ3->PZ3_DIA          := cValtoChar((cAlias)->DIA)
                  PZ3->PZ3_QTD          := (cAlias)->QTD
                  PZ3->PZ3_DATA         := (cAlias)->D4_DATA
                  PZ3->( MsUnlock())
               Endif
            else
               IF RecLock("PZ3", .F.)
                  PZ3->PZ3_QTD          := (cAlias)->QTD
                  PZ3->( MsUnlock())
               Endif
                   
            Endif
        (cAlias)->( dbSkip() )
    EndDo
            
    (calias)->(DbCloseArea()) 
    FwRestArea(aArea)
Return

Static Function RegLog()
    Local cArea := FwGetArea()

        dbSelectArea("CV8")
        If RecLock("CV8",.T.)
                CV8->CV8_FILIAL:= xFilial("CV8")
                CV8->CV8_DATA 	:= MsDate()
                CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
                CV8->CV8_PROC	:= 'PCPWF80'
                CV8->CV8_USER	:= 'ADMINISTRADOR            '
                CV8->CV8_INFO   := '2'
                CV8->CV8_MSG 	:= 'Gravando Tabelas PZ2/PZ3 '
                CV8->(MsUnlock())
          EndIf

     FwRestArea(cArea)
Return
