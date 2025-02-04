#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

#Define cEof    Chr(13)+Chr(10)

/*/{Protheus.doc} PCPM110
description
@type function
@version 1.0
@author Paulo Lenzi
@since 03/02/2025
@return variant, return_description
/*/
User Function PCPM110()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    Local aRet  	:= 	{}
    Local aPergs	:= 	{}
    local aCombo    := {"Faturamento","Media"}    
    Private nTotal   := 0
    Private nTipoFlt := 2
    aAdd( aPergs ,{2,"Qual a forma:"          , 01            ,aCombo                        ,50   ,"",.T.})
    
    If ParamBox(aPergs ,"Parametros para o Processamento",aRet)     
		nTipoFlt := iif(valtype(aRet[1])="N",aRet[1], iif(aRet[1]="Media",2,1))
	Else
		MsgAlert("Encerrado")
		Return
	EndIf	                       

    MsgRun("Limpando o arquivo.    Aguarde.....", "Processando", {|| PCP110CLEAN() })

    cQuery := "SELECT "+CRLF
    IF nTipoFlt = 1
        cQuery += "      C6_PRODUTO     CODIGO "+CRLF
        cQuery += "		,B1_DESC        DESCRICAO "+CRLF
        cQuery += "		,SUM(C6_QTDVEN) QTD "+CRLF
        cQuery += "		,ROUND((ROUND(SUM(C6_VALOR),2) / SUM(C6_QTDVEN)),2) UNITARIO "+CRLF
        cQuery += "		,(ROUND((ROUND(SUM(C6_VALOR),2) / SUM(C6_QTDVEN)),2) * SUM(C6_QTDVEN)) TOTAL "+CRLF
    else 
        cQuery += "      C6_PRODUTO  CODIGO "+CRLF
        cQuery += "		,B1_DESC DESCRICAO "+CRLF
        cQuery += "		,round((SUM(C6_QTDVEN)/6),3) QTD "+CRLF
        cQuery += "		,ROUND((ROUND((SUM(C6_VALOR)/6),2) / round((SUM(C6_QTDVEN)/6),3) ),2) UNITARIO "+CRLF
        cQuery += "		,ROUND(((ROUND((ROUND((SUM(C6_VALOR)/6),2) / round((SUM(C6_QTDVEN)/6),3) ),2)) * round((SUM(C6_QTDVEN)/6),3)),2) TOTAL "+CRLF
    Endif    

    cQuery += "FROM " + RetSqlName("SC6") + " SC6 "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC5.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO IN ( 'PA' ) AND B1_XCLASSI = 'L' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
    cQuery += "AND C5_EMISSAO BETWEEN dateadd(month, -6, getdate()) AND GetDate() "+CRLF
    cQuery += "GROUP BY C6_PRODUTO, B1_DESC "+CRLF
    cQuery += "ORDER BY C6_PRODUTO "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
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
                    SZ3->Z3_TOTAL    := (cAlias)->TOTAL
                    SZ3->Z3_PERC     := ((cAlias)->TOTAL / nTotal) * 100
                    SZ3->( MsUnlock() )
              ELSE
                    SZ3->( Reclock("SZ3",.F.) )
                    SZ3->Z3_QUANT    := (cAlias)->QTD
                    SZ3->Z3_VALOR    := (cAlias)->UNITARIO
                    SZ3->Z3_TOTAL    := (cAlias)->TOTAL
                    SZ3->Z3_PERC     := ((cAlias)->TOTAL / nTotal) * 100
                    SZ3->( MsUnlock() )
              ENDIF
            ENDIF  
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    MsgRun("Classificacao das curvas.    Aguarde.....", "Processando", {|| PCP110ACUM() })
    
    MsgRun("Impressao das curvas.    Aguarde.....", "Processando", {|| PCP110RES() })
    

    FwRestArea(cArea)
Return 

/*/{Protheus.doc} PCP150FAT
description
@type function
@version 1.0
@author Paulo Lenzi
@since 03/02/2025
@return variant, return_description
/*/
Static Function PCP150FAT()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    if nTipoFlt = 1
        cQuery := "SELECT (ROUND((ROUND(SUM(C6_VALOR),2) / SUM(C6_QTDVEN)),2)) * SUM(C6_QTDVEN)  AS TOTAL  "+CRLF
    else
        cQuery := " SELECT round(((ROUND((ROUND(SUM(C6_VALOR),2) / SUM(C6_QTDVEN)),2)) * SUM(C6_QTDVEN))/6 ,2) AS TOTAL  "+CRLF
    Endif        
    cQuery += "FROM " + RetSqlName("SC6") + " SC6 "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_CLIENTE = C6_CLI AND C5_LOJACLI = C6_LOJA AND SC5.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO IN ( 'PA' ) AND B1_XCLASSI = 'L' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "Where SC6.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"' "+CRLF
    cQuery += "AND C5_EMISSAO BETWEEN dateadd(month, -6, getdate()) AND GetDate() "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
		Return
    ENDIF

    While (cAlias)->( !Eof() )
            nTotal := (cAlias)->TOTAL
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    FwRestArea(cArea)
Return

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 03/02/2025
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PCP110ACUM()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    Local nPerc    := 0

    cQuery := "select * from  " + RetSqlName("SZ3") + "  WHERE D_E_L_E_T_ =' ' ORDER BY Z3_TOTAL DESC  "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
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
    FwRestArea(cArea)   
Return

/*/{Protheus.doc} PCP110CLEAN
description
@type function
@version 1.0
@author Paulo Lenzi
@since 04/02/2025
@return variant, return_description
/*/
Static FuNction PCP110CLEAN()
    Local cArea    := FwGetArea()
    Local cQuery   := ''
    cQuery := "DELETE FROM " + RetSqlName("SZ3") + " "+CRLF
    If TCSqlExec(cQuery) < 0
         FWAlertInfo("Falha: " + TCSQLError(), "Teste 1 TCSQLExec e TCSQLError")
     EndIf    
    FwRestArea(cArea)
Return


Static Function PCP110RES()
    Local cArea    := FwGetArea()
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    Local nTotal   := 0
    Local aCols    := {}
    Local xy       := NCont := 0
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'PCPE110_'+IIF(nTipoFlt=1,'Faturados','Media')+'.xml'    

    cQuery := "Select  Z3_CURVA, COUNT(*) QTDE From SZ3100 SZ3 WHERE SZ3.D_E_L_E_T_ = ' ' GROUP BY Z3_CURVA ORDER BY Z3_CURVA "+CRLF 

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
		Return
    ENDIF
    
    While (cAlias)->( !Eof() )
            nTotal := nTotal + (cAlias)->QTDE
            aAdd(aCols,{ (cAlias)->Z3_CURVA, (cAlias)->QTDE,0} )            
            (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    if len(aCols) > 0
       for xy:=1 to Len(aCols)
           aCols[xy][3] := round((aCols[xy][2] / nTotal) * 100,2)   
       next    
    endif

    oFWMsExcel := FWMSExcel():New()  
         
    //Aba 01 - Produtos
    oFWMsExcel:AddworkSheet("Curva")
        //Criando a Tabela
    oFWMsExcel:AddTable("Curva","Produtos")
    oFWMsExcel:AddColumn("Curva","Produtos","Produto",1)
    oFWMsExcel:AddColumn("Curva","Produtos","Descricao",1)
    oFWMsExcel:AddColumn("Curva","Produtos","Quantidade",2,2)
    oFWMsExcel:AddColumn("Curva","Produtos","Preco",2,2)
    oFWMsExcel:AddColumn("Curva","Produtos","Total",2,2)
    oFWMsExcel:AddColumn("Curva","Produtos","Percentual",2,2)
    oFWMsExcel:AddColumn("Curva","Produtos","Acumulado",2,2)
    oFWMsExcel:AddColumn("Curva","Produtos","Curva",1)

    dbSelectArea("SZ3")
    dbgotop()
    While !Eof() 
        oFWMsExcel:AddRow("Curva","Produtos",{ SZ3->Z3_COD,;
                                               SZ3->Z3_DESC,;
                                               SZ3->Z3_QUANT,;
                                               SZ3->Z3_VALOR,;
                                               SZ3->Z3_TOTAL,;
                                               SZ3->Z3_PERC,;
                                               SZ3->Z3_ACUM,;
                                               SZ3->Z3_CURVA })
         
            //Pulando Registro
        SZ3->(DbSkip())
    Enddo

    //Aba 02 - Percentuais
    oFWMsExcel:AddworkSheet("Percentual") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
    oFWMsExcel:AddTable("Percentual","Indicadores")
        //Criando Colunas
    oFWMsExcel:AddColumn("Percentual","Indicadores","CURVA",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Percentual","Indicadores","Percente",2,2) //2 = Valor sem R$
    FOR NCont = 1 TO Len(aCols)
        oFWMsExcel:AddRow("Percentual","Indicadores",{aCols[NCont][1],aCols[NCont][3]})
    NEXT NCont

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    FwRestArea(cArea)   
Return
//---------------------------------------------------------------------------------------------------------------------------------------//
// FINAL DO PROGRAMA
//---------------------------------------------------------------------------------------------------------------------------------------//


