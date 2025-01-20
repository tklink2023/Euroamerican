//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR100()
     Local aArea        := GetArea()
     Private cPerg 		:= PADR("PCPR100",10)
     Pergunte(cPerg,.T.)	 
     MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| RunProc() })
     RestArea(aArea)
Return

Static Function RunProc()
    Local aArea         := GetArea()
    Local cQuery        as character 
    Local cAlias        := "PCP_"+getNextAlias()     
    Local lRet          := {}
  
    Local oFWMsExcel
    Local oExcel
    Local cArquivo      := GetTempPath()+'PCPR100.xml'

    cQuery:="Select B2_COD,B1_DESC,B1_TIPO,B2_LOCAL,B2_QATU,B2_QEMP,B2_QPEDVEN,B2_CM1,B1_LE,B1_LOTVEN,B5_XTPCOMP     "+CRLF
    cQuery+="From " + RetSqlName("SB2") + " SB2   "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = B2_COD AND B1_TIPO IN ( 'MP','EM' )  AND SB1.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SB5") + " SB5 ON B5_FILIAL = B2_FILIAL AND B5_COD = B2_COD  AND SB1.D_E_L_E_T_ = ' '   "+CRLF    
    cQuery+="Where SB2.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="AND B2_FILIAL =  '"+xFilial("SB2")+"'    "+CRLF
    cQuery+="AND B2_LOCAL = B1_LOCPAD   "+CRLF
    cQuery+="AND B2_COD BETWEEN '"+Alltrim(MV_PAR03)+"' AND  '"+Alltrim(MV_PAR04)+"'   "+CRLF
    cQuery+="ORDER BY B2_COD   "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return
   endif

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Relacao Produtos")
    oFWMsExcel:AddTable("Relacao Produtos","Produtos")
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Codigo",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Descrição",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Tipo",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Local",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Saldo",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Empenho",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Lote Econ",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Custo Medio",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Demanda",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Consumido até Hoje",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Falta",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Saldo Final",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Estoque Segur",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Necessidade",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Compra Mes",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Valor Mes",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Compra Prevista",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Valor Previsto",2,2)
    oFWMsExcel:SetTitleHAlign(2)
    oFWMsExcel:SetLineVAlign(2)

    DbSelectArea(cAlias)
        //Criando as Linhas... Enquanto não for fim da query
    While (cAlias)->( !EoF() )
            IF (cAlias)->B5_XTPCOMP <> 'P'
                    DbSelectArea(cAlias)
                    (cAlias)->(DbSkip())
                    Loop       
            ENDIF
            // Variaveis de Calculo dentro do Mes
            
            nConsMes := 0
            nMediaDemanda := 0
            nDiferença := 0
            nSldFinal  := 0
            nNecessidade := 0
            nCalcFalta:= 0
            nProducao := 0
            nReposicao:= 0
            nSldMesCompra := 0
            nPontoSegur := 0

            // Variaveis para projecao de compras
            nProjecaoEstoque := 0
            
            // Variaveis de Valorizacao
              nVlrEst := 0
              nVlrPro := 0
    
            
            lRet :=  PCP100SQL((cAlias)->B2_COD)
            if len(lRet) > 0
                   
                   // Calculo dentro do Mes 
                   nConsMes          := lRet[1]
                   nMediaDemanda     := lRet[2]
                   nDiferenca        := nMediaDemanda - nConsMes
                   nSldFinal         :=  nDiferenca - (cAlias)->B2_QATU
                   nPontoSegur       := ((nMediaDemanda/30) * MV_PAR02)
                   nNecessidade      := nSldFinal + nPontoSegur
                   nProducao         := nConsMes + (cAlias)->B2_QEMP
                   nSldMesCompra     := nSldFinal + nPontoSegur

                   IF nSldMesCompra < 0
                      nSldMesCompra := 0
                   else
                       if nSldMesCompra < (cAlias)->B1_LE
                            nSldMesCompra := (cAlias)->B1_LE
                       endif
                   endif  

                   nVlrEst := nSldMesCompra * (cAlias)->B2_CM1
                   
                    // Calculo para Projecao de Compras

                   nProjecaoEstoque     := nMediaDemanda - ((nMediaDemanda*MV_PAR01)/100)                   
                   nVlrPro := nProjecaoEstoque * (cAlias)->B2_CM1
            else
                  DbSelectArea(cAlias)
                  (cAlias)->(DbSkip())
                  Loop       
            Endif
            
            oFWMsExcel:AddRow("Relacao Produtos","Produtos",{   (cAlias)->B2_COD,;
                                                                (cAlias)->B1_DESC,;
                                                                (cAlias)->B1_TIPO,;
                                                                (cAlias)->B2_LOCAL,;
                                                                (cAlias)->B2_QATU,;
                                                                (cAlias)->B2_QEMP,;
                                                                (cAlias)->B1_LE,;
                                                                (cAlias)->B2_CM1,;
                                                                nMediaDemanda,;
                                                                nConsMes,;
                                                                nDiferenca,;
                                                                nSldFinal,;
                                                                nPontoSegur,;
                                                                nNecessidade,;
                                                                nSldMesCompra,;
                                                                nVlrEst,;
                                                                nProjecaoEstoque,;
                                                                nVlrPro})
            (cAlias)->(DbSkip())
    EndDo

    oFWMsExcel:AddworkSheet("Configuracao") //Não utilizar número junto com sinal de menos. Ex.: 1-
    oFWMsExcel:AddTable("Configuracao","Parametros")
    oFWMsExcel:AddColumn("Configuracao","Parametros","Percentual",2,2) //1 = Modo Texto
    oFWMsExcel:AddColumn("Configuracao","Parametros","Lead Time",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Configuracao","Parametros","Produto inicial",1) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Configuracao","Parametros","Produto Final",1) //2 = Valor sem R$    
    oFWMsExcel:AddColumn("Configuracao","Parametros","Data Emissao",1) //2 = Valor sem R$   

    oFWMsExcel:AddRow("Configuracao","Parametros",{ MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,Dtoc(ddatabase) } )


    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    (cAlias)->(DbCloseArea())
    FwRestArea(aArea)   
Return NIL 


Static Function PCP100SQL(cProduto)
    Local aArea         := FwgetArea()
    Local cQuery        as character 
    Local cAlias        := "B_"+getNextAlias()    
    Local cAno          := alltrim(Str(Year(dDataBase)))
    Local cMes          :=  alltrim(Str(Month(dDataBase)))
    Local nRetorno      := {}
    Local aArray        := {}
    cQuery:="SELECT Produto,Ano,Mes, Produzido, AVG(Produzido) OVER(PARTITION BY Ano) AS Media  "+CRLF
    cQuery+="FROM (  "+CRLF
    cQuery+="Select	D3_COD as Produto,  "+CRLF
    cQuery+="		Year(D3_EMISSAO) as Ano,  "+CRLF
    cQuery+="		Month(D3_EMISSAO) as Mes,  "+CRLF
    cQuery+="		Sum(D3_QUANT) as Produzido  "+CRLF
    cQuery+="From " + RetSqlName("SD3") + " SD3  "+CRLF
    cQuery+="WHERE SD3.D_E_L_E_T_ =  ' '  "+CRLF
    cQuery+="AND D3_FILIAL =  '"+xFilial("SD3")+"'  "+CRLF
    cQuery+="AND Year(D3_EMISSAO) = "+cAno+" "+CRLF
    cQuery+="AND D3_COD = '"+Alltrim(cProduto)+"' "+CRLF
    cQuery+="AND MONTH(D3_EMISSAO) <= "+cMes+"  "+CRLF
    cQuery+="AND D3_OP <> ' ' "+CRLF
    cQuery+="Group By D3_COD, Year(D3_EMISSAO),Month(D3_EMISSAO)  "+CRLF
    cQuery+=") xxx  "+CRLF
    cQuery+="ORDER BY Produto,Ano,Mes  "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return(nRetorno)
   endif

    DbSelectArea(cAlias)
    While (cAlias)->( !EoF() )
            aAdd(aArray,{(cAlias)->Mes,(cAlias)->Produzido,(cAlias)->Media})
            (cAlias)->(DbSkip())
    EndDo

    nPos :=  aScan(aArray,{|x| x[1] == Month(dDataBase) } )
    IF nPos > 0
       nRetorno := {aArray[nPos][2],aArray[nPos][3] }
    endif
    (cAlias)->(DbCloseArea())   
    FwRestArea(aArea)

Return(nRetorno)
