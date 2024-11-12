//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

User Function LABEX001()
    Local aArea        := GetArea()
    Local cQryCol        := ""
    Local cQryPro        := ""
    Local cQryVen        := ""
    Local nAux            := 0
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'zTstExc4.xml'
    Local cWorkSheet    := "Aba - Produtos"
    Local cTable        := "Produtos x Datas"
    Local aColunas    := {}
    Local dDataDe        := sToD("20240101")
    Local dDataAt        := sToD("20241231")
    Local aLinhaAux    := {}
     
    //Buscando as datas que tiveram pedidos
    cQryCol := " SELECT DISTINCT "
    cQryCol += "     C5_EMISSAO "
    cQryCol += " FROM "
    cQryCol += "     "+RetSQLName('SC5')+" SC5 "
    cQryCol += " WHERE "
    cQryCol += "     C5_FILIAL = '"+FWxFilial('SC5')+"' "
    cQryCol += "     AND C5_TIPO = 'N' "
    cQryCol += "     AND C5_EMISSAO >= '"+dToS(dDataDe)+"' "
    cQryCol += "     AND C5_EMISSAO <= '"+dToS(dDataAt)+"' "
    cQryCol += "     AND SC5.D_E_L_E_T_ = ' ' "
    cQryCol += " ORDER BY "
    cQryCol += "     C5_EMISSAO "
    TCQuery cQryCol New Alias "QRY_COL"
    TCSetField("QRY_COL", "C5_EMISSAO", "D")
 
    //Compondo as colunas do relatório
    aAdd(aColunas, "Produto")
    aAdd(aColunas, "Descrição")
    While !QRY_COL->(EoF())
        aAdd(aColunas, dToC(QRY_COL->C5_EMISSAO))
        QRY_COL->(DbSkip())
    EndDo
    QRY_COL->(DbCloseArea())
     
    //Montando a consulta de produtos
    cQryPro := " SELECT "
    cQryPro += "     B1_COD, "
    cQryPro += "     B1_DESC "
    cQryPro += " FROM "
    cQryPro += "     "+RetSQLName('SB1')+" SB1 "
    cQryPro += " WHERE "
    cQryPro += "     B1_FILIAL = '"+FWxFilial('SB1')+"' "
    cQryPro += "     AND B1_TIPO = 'PA' "
    cQryPro += "     AND SB1.D_E_L_E_T_ = ' ' "
    cQryPro += " ORDER BY "
    cQryPro += "     B1_COD "
    TCQuery cQryPro New Alias "QRY_PRO"
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
    //Aba 01 - Teste
    oFWMsExcel:AddworkSheet(cWorkSheet) //Não utilizar número junto com sinal de menos. Ex.: 1-
         
        //Criando a Tabela
        oFWMsExcel:AddTable(cWorkSheet, cTable)
         
        //Criando Colunas
        For nAux := 1 To Len(aColunas)
            oFWMsExcel:AddColumn(cWorkSheet, cTable, aColunas[nAux], 1, 1)
        Next
         
        //Percorrendo os produtos
        While !QRY_PRO->(EoF())
            //Criando a linha
            aLinhaAux := Array(Len(aColunas))
            aLinhaAux[1] := QRY_PRO->B1_COD
            aLinhaAux[2] := QRY_PRO->B1_DESC
            For nAux := 3 To Len(aColunas)
                cQryVen := " SELECT "
                cQryVen += "     ISNULL(SUM(C6_QTDVEN),0) AS TOT "
                cQryVen += " FROM "
                cQryVen += "     "+RetSQLName('SC6')+" SC6 "
                cQryVen += "     INNER JOIN "+RetSQLName('SC5')+" SC5 ON ( "
                cQryVen += "         C5_FILIAL = '"+FWxFilial('SC5')+"' "
                cQryVen += "         AND C5_NUM = C6_NUM "
                cQryVen += "         AND C5_TIPO = 'N' "
                cQryVen += "         AND C5_EMISSAO = '"+dToS(cToD(aColunas[nAux]))+"' "
                cQryVen += "         AND SC5.D_E_L_E_T_ = ' ' "
                cQryVen += "     ) "
                cQryVen += "     INNER JOIN "+RetSQLName('SB1')+" SB1 ON ( "
                cQryVen += "         B1_FILIAL = '"+FWxFilial('SB1')+"' "
                cQryVen += "         AND B1_COD = C6_PRODUTO "
                cQryVen += "         AND B1_TIPO = 'PA' "
                cQryVen += "         AND SB1.D_E_L_E_T_ = ' ' "
                cQryVen += "     ) "
                cQryVen += " WHERE "
                cQryVen += "     C6_FILIAL = '"+FWxFilial('SC6')+"' "
                cQryVen += "     AND C6_PRODUTO = '"+QRY_PRO->B1_COD+"' "
                cQryVen += "     AND SC6.D_E_L_E_T_ = ' ' "
                TCQuery cQryVen New Alias "QRY_VEN"
                 
                //Atribuindo o valor
                aLinhaAux[nAux] := QRY_VEN->TOT
                QRY_VEN->(DbCloseArea())
            Next
             
            //Adiciona a linha no Excel
            oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
             
            QRY_PRO->(DbSkip())
        EndDo
         
        //Tratativa para o Total
        aLinhaAux := Array(Len(aColunas))
        aLinhaAux[1] := "Total: "
        aLinhaAux[2] := ""
        For nAux := 3 To Len(aColunas)
            cQryVen := " SELECT "
            cQryVen += "     ISNULL(SUM(C6_QTDVEN),0) AS TOT "
            cQryVen += " FROM "
            cQryVen += "     "+RetSQLName('SC6')+" SC6 "
            cQryVen += "     INNER JOIN "+RetSQLName('SC5')+" SC5 ON ( "
            cQryVen += "         C5_FILIAL = '"+FWxFilial('SC5')+"' "
            cQryVen += "         AND C5_NUM = C6_NUM "
            cQryVen += "         AND C5_TIPO = 'N' "
            cQryVen += "         AND C5_EMISSAO = '"+dToS(cToD(aColunas[nAux]))+"' "
            cQryVen += "         AND SC5.D_E_L_E_T_ = ' ' "
            cQryVen += "     ) "
            cQryVen += "     INNER JOIN "+RetSQLName('SB1')+" SB1 ON ( "
            cQryVen += "         B1_FILIAL = '"+FWxFilial('SB1')+"' "
            cQryVen += "         AND B1_COD = C6_PRODUTO "
            cQryVen += "         AND B1_TIPO = 'PA' "
            cQryVen += "         AND SB1.D_E_L_E_T_ = ' ' "
            cQryVen += "     ) "
            cQryVen += " WHERE "
            cQryVen += "     C6_FILIAL = '"+FWxFilial('SC6')+"' "
            cQryVen += "     AND SC6.D_E_L_E_T_ = ' ' "
            TCQuery cQryVen New Alias "QRY_VEN"
             
            //Atribuindo o valor
            aLinhaAux[nAux] := QRY_VEN->TOT
            QRY_VEN->(DbCloseArea())
        Next
         
        //Adiciona a linha no Excel
        oFWMsExcel:AddRow(cWorkSheet, cTable, aLinhaAux)
         
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    QRY_PRO->(DbCloseArea())
    RestArea(aArea)
Return
