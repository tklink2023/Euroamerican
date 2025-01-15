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
    Local nConsumo      := nDemanda := VlrReduz := 0
    Local nProducao     := nFalta :=  nEstSeg := 0
    Local nSobra        := nCompraMes := nCustoMes := 0
    Local nCompraPox    := nCustoProx := 0

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
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Pedidos",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Custo Medio",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Consumo",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Consumido até Hoje",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","% Previsto",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Projecao Consumo",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Producao",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Falta",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Saldo Final",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Dias Estoque",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Estoque Seg",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Lote Econom",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Quebra Compra",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Compra Mes",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Custo Mes",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Compra Prevista",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Custo Previsto",2,2)
    oFWMsExcel:SetTitleHAlign(2)
    oFWMsExcel:SetLineVAlign(2)

    DbSelectArea(cAlias)
        //Criando as Linhas... Enquanto não for fim da query
    While (cAlias)->( !EoF() )
            IF (cAlias)->B5_XTCOMP <> 'P'
                    DbSelectArea(cAlias)
                    (cAlias)->(DbSkip())
                    Loop       
            ENDIF
            lRet :=  PCP100SQL((cAlias)->B2_COD)
            nConsumo := 0
            nDemanda := 0
            VlrReduz := 0
            nProducao := 0
            nFalta := 0
            nEstSeg := 0
            nSobra  := 0
            nCompraMes := 0
            nCustoMes := 0
            nPontoFor := (cAlias)->B1_LE
            if len(lRet) > 0
                   nConsumo     := lRet[1]
                   nDemanda     := lRet[2]
                   VlrReduz     := nDemanda - ((nDemanda*MV_PAR01)/100)
                   nProducao    := nConsumo + (cAlias)->B2_QEMP

                   nFalta       := nDemanda - nConsumo //IIF((nDemanda - nConsumo)<0,0,nDemanda - nConsumo)

                   nSobra       := nFalta - (cAlias)->B2_QATU //IIF((nFalta - (cAlias)->B2_QATU)<0,0,nFalta - (cAlias)->B2_QATU)
                   nEstSeg      := (nDemanda/30) * MV_PAR02
                   nCompraMes   := nSobra + nEstSeg  //IIF((nSobra+nEstSeg)<0,0,nSobra + nEstSeg)
                   if nCompraMes < nPontoFor
                      nCompraMes :=  nPontoFor
                   endif

                   nCustoMes    := IIF(nCompraMes<=0,0,nCompraMes * (cAlias)->B2_CM1)  //nCompraMes * (cAlias)->B2_CM1
                   nCompraPox   := VlrReduz
                   nCustoProx   := nCompraPox * (cAlias)->B2_CM1
            else
                  DbSelectArea(cAlias)
                  (cAlias)->(DbSkip())
                  Loop       
            Endif
            
            oFWMsExcel:AddRow("Relacao Produtos","Produtos",{(cAlias)->B2_COD,(cAlias)->B1_DESC,(cAlias)->B1_TIPO,(cAlias)->B2_LOCAL,;
            (cAlias)->B2_QATU,(cAlias)->B2_QEMP,(cAlias)->B2_QPEDVEN,(cAlias)->B2_CM1,nDemanda,nConsumo,MV_PAR01,VlrReduz,nProducao,;
            nFalta,nSobra,MV_PAR02,nEstSeg,(cAlias)->B1_LE,(cAlias)->B1_LOTVEN,nCompraMes,nCustoMes,nCompraPox,nCustoProx})
            (cAlias)->(DbSkip())
    EndDo
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
