//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)
 
 
User Function PCPE070()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local cQry         := ""
    Local cQry3        := " "
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'PCPE070.xml'
    
    Private cPerg 		:= PADR("PCPR070",10)
    Pergunte(cPerg,.T.)	 

    //Pegando os dados


    cQry:= "SELECT STATUS AS 'STATUS',ANO AS 'ANO', "+cEof
    cQry+= "		ISNULL([1],0) AS 'JAN', "+cEof
    cQry+= "		ISNULL([2],0) AS 'FEV', "+cEof
    cQry+= "		ISNULL([3],0) AS 'MAR', "+cEof
    cQry+= "		ISNULL([4],0) AS 'ABR', "+cEof
    cQry+= "		ISNULL([5],0) AS 'MAI', "+cEof
    cQry+= "		ISNULL([6],0) AS 'JUN', "+cEof
    cQry+= "		ISNULL([7],0) AS 'JUL', "+cEof
    cQry+= "		ISNULL([8],0) AS 'AGO', "+cEof
    cQry+= "		ISNULL([9],0) AS 'SET', "+cEof
    cQry+= "		ISNULL([10],0) AS 'OUT', "+cEof
    cQry+= "		ISNULL([11],0) AS 'NOV', "+cEof
    cQry+= "		ISNULL([12],0) AS 'DEZ'  "+cEof
    cQry+= "		FROM (  "+cEof
    cQry+= "SELECT ZB_STATUS STATUS "+cEof
    cQry+= "	   ,SUBSTRING(ZB_PERIODO,1,4) ANO "+cEof
    cQry+= "	   ,SUBSTRING(ZB_PERIODO,5,2) MES "+cEof
    cQry+= "	   ,ISNULL(SUM(ZB_QTD),0) QTDE "+cEof
    cQry+= "FROM "+RetSqlName("SZB")+" SZB "+cEof
    cQry+= "WHERE SZB.D_E_L_E_T_ = ' ' "+cEof
    cQry+= "AND ZB_FILIAL = '0803' "+cEof
    cQry+= "GROUP BY ZB_STATUS,SUBSTRING(ZB_PERIODO,1,4),SUBSTRING(ZB_PERIODO,5,2) ) XARQ "+cEof
    cQry+= "PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT "+cEof
    cQry+= "WHERE PT.ANO = YEAR(GETDATE()) "+cEof
    cQry+= "				   ORDER BY 1,2 "+cEof
    If  Select("QRYSZB") > 0
                DbSelectArea("QRYSZB")
                DbCloseArea()
    Endif
 
    TCQuery cQry New Alias "QRYSZB"   



    cQuery :="Select ZB_COD,ZB_DESC,ZB_LOCAL,ZB_NOME,ZB_QTD,ZB_SALDO,ZB_TOTAL,ZB_QTAPU,ZB_STATUS  "+cEof
    cQuery +="From "+RetSqlName("SZB")+" SZB  "+cEof
    cQuery +="Where SZB.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="AND ZB_FILIAL = '0803' "+cEof
    cQuery +="AND RTRIM(ZB_PERIODO) = '"+MV_PAR01+"'  "+cEof
    cQuery +="order by ZB_COD,ZB_STATUS  "+cEof

    If  Select("QRYPRO") > 0
            DbSelectArea("QRYPRO")
            DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYPRO"
     

    cQry3:= "Select ZB_STATUS,ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQry3+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQry3+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQry3+= "AND ZB_FILIAL = '0803' "+cEof
    cQry3+= "AND RTRIM(ZB_PERIODO) = '"+MV_PAR01+"'  "+cEof
    cQry3+= "GROUP BY ZB_STATUS "+cEof
    cQry3+= "ORDER BY ZB_STATUS "+cEof

    If  Select("QRYPER") > 0
            DbSelectArea("QRYPER")
            DbCloseArea()
    Endif

   TCQuery cQry3 New Alias "QRYPER"

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
         
    //Aba 01 - Produtos
    oFWMsExcel:AddworkSheet("Relacao Produtos")
        //Criando a Tabela
    oFWMsExcel:AddTable("Relacao Produtos","Produtos")
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Produto",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Descricao",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Status",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Nome",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Quantidade",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Saldo",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Total",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Apurado",2,2)
    DbSelectArea("QRYPRO")
        //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPRO->(EoF()))
            oFWMsExcel:AddRow("Relacao Produtos","Produtos",{;
                                                                    QRYPRO->ZB_COD,;
                                                                    QRYPRO->ZB_DESC,;
                                                                    QRYPRO->ZB_STATUS,;
                                                                    QRYPRO->ZB_NOME,;
                                                                    QRYPRO->ZB_QTD,;
                                                                    QRYPRO->ZB_SALDO,;
                                                                    QRYPRO->ZB_TOTAL,;
                                                                    QRYPRO->ZB_QTAPU;
                                                                     })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
    EndDo
     
     //Aba 02 - Percentuais
    oFWMsExcel:AddworkSheet("Percentual") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
    oFWMsExcel:AddTable("Percentual","Indicadores")
        //Criando Colunas
    oFWMsExcel:AddColumn("Percentual","Indicadores","Tipo",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Percentual","Indicadores","Quantidade",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Percentual","Indicadores","Percente",2,2) //2 = Valor sem R$

    nQuant := CalcTotal()
    
    DbSelectArea("QRYPER")
    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPER->(EoF()))
            oFWMsExcel:AddRow("Percentual","Indicadores",{;
                                                                    QRYPER->ZB_STATUS,;
                                                                    QRYPER->QUANT,;
                                                                    (QRYPER->QUANT/nQuant)*100;
                                                                     })
         
            //Pulando Registro
            QRYPER->(DbSkip())
    EndDo

    //Aba 03 - Estatistica do ano
    oFWMsExcel:AddworkSheet("Estatistica") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
    oFWMsExcel:AddTable("Estatistica","Tipos Status")
        //Criando Colunas
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Tipo",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Ano",1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Janeiro",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Fevereiro",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Marco",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Abril",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Maio",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Junho",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Julho",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Agosto",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Setembro",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Outubro",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Novembro",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Estatistica","Tipos Status","Desembro",2,2) //2 = Valor sem R$

    DbSelectArea("QRYSZB")
        //Criando as Linhas
    While !(QRYSZB->(EoF()))
            oFWMsExcel:AddRow("Estatistica","Tipos Status",{;
                                                                    QRYSZB->STATUS,;
                                                                    QRYSZB->ANO,;
                                                                    QRYSZB->JAN,;
                                                                    QRYSZB->FEV,;
                                                                    QRYSZB->MAR,;
                                                                    QRYSZB->ABR,;
                                                                    QRYSZB->MAI,;
                                                                    QRYSZB->JUN,;
                                                                    QRYSZB->JUL,;
                                                                    QRYSZB->AGO,;
                                                                    QRYSZB->SET,;
                                                                    QRYSZB->OUT,;
                                                                    QRYSZB->NOV,;
                                                                    QRYSZB->DEZ;
                                                                     })
         
            //Pulando Registro
            QRYSZB->(DbSkip())
    EndDo

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return


Static Function CalcTotal()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local lRet         := 0

    cQuery:= "Select ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuery+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuery+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "AND ZB_FILIAL = '0803' "+cEof
    cQuery+= "AND RTRIM(ZB_PERIODO) = '"+MV_PAR01+"'  "+cEof

    If  Select("QRYCAL") > 0
            DbSelectArea("QRYCAL")
            DbCloseArea()
    Endif

    TCQuery cQuery New Alias "QRYCAL"

    if !(QRYCAL->(EoF()))
       lRet := QRYCAL->Quant
    endif

    RestArea(aArea)
Return(lRet)
