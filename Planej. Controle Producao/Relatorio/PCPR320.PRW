//Bibliotecas
#Include "TOTVS.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

/*/{Protheus.doc} PCPR320
description Programa que lista a estrutura conforme a função do Protheus
@type function
@version 1.0
@author Paulo Lenzi
@since 03/07/2024
@return variant, return_description
/*/
User Function PCPR320()
    Local cArea := FwGetArea()
    Local aRet  	:= 	{}
	Local aPergs	:= 	{}
    Local cOpIni    := Space(11)
    Local cOpFim    := Space(11)
    Local cDtIni    := Ctod('  /  /  ')
    Local cDtFim    := Ctod('  /  /  ')
    Local cTitulo   := "Calculo Estrutura"   
	Local aSays		:= {}
	Local aButtons	:= {}    
    lOCAL lOk
    Private cMvPar01
	Private cMvPar02
	Private cMvPar03
	Private cMvPar04

    aAdd( aPergs ,{1,"Da Ordem Produção"		, cOpIni   		, PesqPict("SD4", "D4_OP"),'.T.',"SC2"   	,'.T.'	,50, .T.})
    aAdd( aPergs ,{1,"Atea Ordem Produção"		, cOpFim   		, PesqPict("SD4", "D4_OP"),'.T.',"SC2"   	,'.T.'	,50, .T.})
	aAdd( aPergs ,{1,"Da Data"					, cDtIni     	, PesqPict("SC2", "C2_Emissao"),'.T.',""   	,'.T.'	,50, .T.})
    aAdd( aPergs ,{1,"Ate a Data"				, cDtFim     	, PesqPict("SC2", "C2_Emissao"),'.T.',""   	,'.T.'	,50, .T.})

    If ParamBox(aPergs ,"Parametros para o relatorio",aRet)     
		cMvPar01 := aRet[1]
		cMvPar02 := aRet[2]
		cMvPar03 := aRet[3]
        cMVPar04 := aRet[4]
	Else
		MsgAlert("Encerrado")
		Return
	EndIf	

    AAdd(aSays,"Geração do Relatorio conforme os parametros selecionados")
	AAdd(aSays,"Ordem de Produção de :"+cMvPar01+ " ate: "+cMvPar02  )
	AAdd(aSays,"Filtrando as datas de:"+Dtoc(cMvPar03)+" ate: "+Dtoc(cMvPar04))
	AAdd(aSays,"Filial : "+cFilant)

    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    FormBatch(cTitulo, aSays, aButtons)

    If lOk
            FWMsgRun(, {|oSay| ProcRun(oSay) }, "Processando", "Processando dados para o relatório")
    EndIf

    FwRestArea(cArea)
Return

/*/{Protheus.doc} ProcRun
description Função que Roda o processamento do programa
@type function
@version 1.0
@author Paulo Lenzi
@since 03/07/2024
@return variant, return_description
/*/
Static Function ProcRun(oSay)

    Local aFields       :={}
    Local cTrab         := "X-"+GetNextAlias()
    Local cArquivo      := "" 
    Local oReport

    Private ctmp        := "TMP"+GetNextAlias()
    Private oTable      := FWTemporaryTable():New( ctmp ) 

    Private cTitulo 	:= OemToAnsi("Lista de Estrutura dos produtos da Ordem de Produção")
    Private oTempTable  := Nil
    Private cAliasTmp   := "ESTRUT"
    Private nEstru      := 0

    oSay:SetText("Iniciando processamento...")

    aAdd(aFields,{"TMP_FILIAL"		, GetSx3Cache("C2_FILIAL","X3_TIPO")		,tamSx3("C2_FILIAL")[1]	    ,tamSx3("C2_FILIAL")[2]})
    aAdd(aFields,{"TMP_OP"		    , GetSx3Cache("C2_NUM","X3_TIPO")		    ,tamSx3("C2_NUM")[1]	    ,tamSx3("C2_NUM")[2]})
    aAdd(aFields,{"TMP_QTOP" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
    aAdd(aFields,{"TMP_ITEM"	    , GetSx3Cache("C2_ITEM","X3_TIPO")		    ,tamSx3("C2_ITEM")[1]	    ,tamSx3("C2_ITEM")[2]})
    aAdd(aFields,{"TMP_SEQ" 	    , GetSx3Cache("C2_SEQUEN","X3_TIPO")	    ,tamSx3("C2_SEQUEN")[1]	    ,tamSx3("C2_SEQUEN")[2]})
    aAdd(aFields,{"TMP_COD" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})
    aAdd(aFields,{"TMP_REV" 	    , GetSx3Cache("C2_REVISAO","X3_TIPO")	    ,tamSx3("C2_REVISAO")[1]	,tamSx3("C2_REVISAO")[2]})
    aAdd(aFields,{"TMP_COMP" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})
    aAdd(aFields,{"TMP_NIVEL" 	    , GetSx3Cache("D3_NIVEL","X3_TIPO")	        ,tamSx3("D3_NIVEL")[1]	    ,tamSx3("D3_NIVEL")[2]})
    aAdd(aFields,{"TMP_TRT" 	    , GetSx3Cache("D4_TRT","X3_TIPO")	        ,tamSx3("D4_TRT")[1]	    ,tamSx3("D4_TRT")[2]})
    aAdd(aFields,{"TMP_MAT" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})
    aAdd(aFields,{"TMP_QTDE" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
    aAdd(aFields,{"TMP_QUSE" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})

    aAdd(aFields,{"TMP_DESC" 	    , GetSx3Cache("B1_DESC","X3_TIPO")	        ,tamSx3("B1_DESC")[1]	    ,tamSx3("B1_DESC")[2]})
    aAdd(aFields,{"TMP_TIPO" 	    , GetSx3Cache("B1_TIPO","X3_TIPO")	        ,tamSx3("B1_TIPO")[1]	    ,tamSx3("B1_TIPO")[2]})
    aAdd(aFields,{"TMP_UM" 	        , GetSx3Cache("B1_UM","X3_TIPO")	        ,tamSx3("B1_UM")[1]	        ,tamSx3("B1_UM")[2]})
    aAdd(aFields,{"TMP_CUSTD" 	    , GetSx3Cache("B1_CUSTD","X3_TIPO")	        ,tamSx3("B1_CUSTD")[1]	    ,tamSx3("B1_CUSTD")[2]})
    aAdd(aFields,{"TMP_CNET" 	    , GetSx3Cache("B1_CUSTNET","X3_TIPO")       ,tamSx3("B1_CUSTNET")[1]	,tamSx3("B1_CUSTNET")[2]})

    aAdd(aFields,{"TMP_QMOV" 	    , GetSx3Cache("D3_QUANT","X3_TIPO")         ,tamSx3("D3_QUANT")[1]	,tamSx3("D3_QUANT")[2]})
    aAdd(aFields,{"TMP_MCUS" 	    , GetSx3Cache("D2_CUSTO1","X3_TIPO")        ,tamSx3("D2_CUSTO1")[1]	,tamSx3("D3_QUANT")[2]})

    oTable:SetFields( aFields )
	oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_OP","TMP_COD","TMP_NIVEL","TMP_COMP"} )
 	oTable:Create()

    // Filtra os dados conforme os parametros selecionados pelo usuario
    BeginSQL Alias cTrab
		SELECT  C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_QUANT,C2_QUJE,C2_REVISAO,C2_LOCAL,
                B1_DESC,B1_TIPO,B1_UM,B1_CUSTD,B1_CUSTNET

		FROM %Table:SC2% SC2
        INNER JOIN %Table:SB1% SB1 ON SB1.%NotDel% AND B1_COD = C2_PRODUTO 
		WHERE SC2.%NotDel%
		and C2_FILIAL =  %xFilial:SC2%
        and C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN  %exp:cMvPar01% AND %exp:cMvPar02%
        and C2_EMISSAO BETWEEN  %exp:DTOS(cMvPar03)% AND %exp:DTOS(cMvPar04)%
    EndSQL  
    if (cTrab)->(Eof())
        FWAlertError("Sem dados para processar!", "Falha")
		Return
    ENDIF

    While !(cTrab)->(EoF())

            cCodProd := AvKey((cTrab)->C2_PRODUTO, "B1_COD")
            // Função que gera a estrutura do produto    
            // cArquivo := Estrut2(cProduto, nQuant, NIL, @oTempTable, .T.)    
            // FimEstrut2(NIL, @oTempTable)    
            cArquivo := Estrut2(cCodProd, (cTrab)->C2_QUANT, cAliasTmp, @oTempTable,.T.)
             

            // Inclui dos dados referente a estrutura do produto        
            (cAliasTmp)->(DbGoTop())
            If ! (cAliasTmp)->(EoF())
                While ! (cAliasTmp)->(EoF())

                   aDados := SeacherR320((cTrab)->C2_NUM+(cTrab)->C2_ITEM+(cTrab)->C2_SEQUEN,(cAliasTmp)->COMP,(cAliasTmp)->TRT)

                     IF RecLock(ctmp,.T.)
                         (ctmp)->TMP_FILIAL  := (cTrab)->C2_FILIAL
                         (ctmp)->TMP_OP      := (cTrab)->C2_NUM
                         (ctmp)->TMP_QTOP    := (cTrab)->C2_QUANT
                         (ctmp)->TMP_ITEM    := (cTrab)->C2_ITEM
                         (ctmp)->TMP_SEQ     := (cTrab)->C2_SEQUEN
                         (ctmp)->TMP_COD     := (cTrab)->C2_PRODUTO
                         (ctmp)->TMP_QUSE    := (cTrab)->C2_QUJE
                         (ctmp)->TMP_REV     := (cTrab)->C2_REVISAO

                         (ctmp)->TMP_COMP    := (cAliasTmp)->CODIGO
                         (ctmp)->TMP_NIVEL   := STRZERO(VAL((cAliasTmp)->NIVEL),3)
                         (ctmp)->TMP_TRT     := (cAliasTmp)->TRT
                         (ctmp)->TMP_MAT     := (cAliasTmp)->COMP
                         (ctmp)->TMP_QTDE    := (cAliasTmp)->QUANT

                         (ctmp)->TMP_DESC    := (cTrab)->B1_DESC
                         (ctmp)->TMP_TIPO    := (cTrab)->B1_TIPO
                         (ctmp)->TMP_UM 	 := (cTrab)->B1_UM
                         (ctmp)->TMP_CUSTD   := (cTrab)->B1_CUSTD
                         (ctmp)->TMP_CNET    := (cTrab)->B1_CUSTNET

                         (ctmp)->TMP_QMOV    := aDados[1]
                         (ctmp)->TMP_MCUS    := aDados[2]

                        (ctmp)->( MsUnlock() )
                     Endif
                    (cAliasTmp)->(DbSkip())
                EndDo
            Endif
            //Finaliza a função de estrutura
            FimEstrut2(cAliasTmp, @oTempTable) 
            nEstru:=0
            
        (cTrab)->(DbSkip())
    EndDo
    (cTrab)->(dbCloseArea())   
     // processo de atualização da tabela temporaria


     // Impressão da tabela temporaria
    oReport := ReportDef()
    oReport:PrintDialog()

    // Destroi a tabela temporaria
    oTable:Delete()

Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    Local cPerg     := " "

    oReport:= TReport():New("PCPR300",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'OP'				,'cQry01','Lote'     		,	 							, 							,,) 
    TRCell():New(oSection1,'PRODUTO'		,'cQry01','Produto'     		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
	TRCell():New(oSection1,'DESCRICAO'		,'cQry01','Descricao'     		   	,PesqPict('SB1',"B1_DESC")	    ,TamSX3("B1_DESC") [1]+1,,)
	TRCell():New(oSection1,'TIPO'		    ,'cQry01','Tipo'     		     	,PesqPict('SB1',"B1_TIPO")	    ,TamSX3("B1_TIPO") [1]+1,,)
    TRCell():New(oSection1,'UM'		        ,'cQry01','U.M.'     		     	,PesqPict('SB1',"B1_UM")	    ,TamSX3("B1_UM") [1]+1,,)
    TRCell():New(oSection1,'CUSTO'	        ,'cQry01','Custo Standart'	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    TRCell():New(oSection1,'NET'	        ,'cQry01','Custo Net'	     		,PesqPict('SB1',"B1_CUSTNET")	,TamSX3("B1_CUSTNET") [1]+1,,)    
    TRCell():New(oSection1,'REVISAO'		,'cQry01','Revisao'     		   	,PesqPict('SC2',"C2_REVISAO")	,TamSX3("C2_REVISAO") [1]+1,,) 
    TRCell():New(oSection1,'PRODUZIR'		,'cQry01','Produzir'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'UTILIZA'		,'cQry01','Produzido'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'NIVEL'  		,'cQry01','Nivel'       		   	,PesqPict('SD3',"D3_NIVEL")	    ,TamSX3("D3_NIVEL") [1]+1,,) 
    TRCell():New(oSection1,'COMPONENTE'		,'cQry01','Componente'     		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
    TRCell():New(oSection1,'TRT'			,'cQry01','TRT'     		    	,PesqPict('SD4',"D4_TRT")		,TamSX3("D4_TRT") [1]+1,,) 
    TRCell():New(oSection1,'MATERIAL'		,'cQry01','Material'     		    ,PesqPict('SD3',"D3_COD")		,TamSX3("D3_COD") [1]+1,,) 
    TRCell():New(oSection1,'QUANT'			,'cQry01','Quant'    		    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'QTMOV'			,'cQry01','Qtde Mov'    	    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'CSTMED'	        ,'cQry01','Custo Mov'   	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    
Return(oReport)

Static Function ReportPrint(oReport)      
    Private oSection1 := oReport:Section(1)
    
    dbSelectArea(ctmp)
    (ctmp)->( dbGotop() )

    oReport:SetMeter((ctmp)->(LastRec()))
    oSection1:Init()
    
    While !oReport:Cancel() .And. !(ctmp)->(Eof())   
    
        oSection1:Cell("FILIAL"):SetValue((ctmp)->TMP_FILIAL)
        oSection1:Cell("OP"):SetValue((ctmp)->TMP_OP+"."+(ctmp)->TMP_ITEM+"."+(ctmp)->TMP_SEQ  )		
        oSection1:Cell("PRODUTO"):SetValue((ctmp)->TMP_COD)
        oSection1:Cell("DESCRICAO"):SetValue((ctmp)->TMP_DESC)
        oSection1:Cell("TIPO"):SetValue((ctmp)->TMP_TIPO)
        oSection1:Cell("UM"):SetValue((ctmp)->TMP_UM)
        oSection1:Cell("CUSTO"):SetValue((ctmp)->TMP_CUSTD)
        oSection1:Cell("NET"):SetValue((ctmp)->TMP_CNET)        
        oSection1:Cell("REVISAO"):SetValue((ctmp)->TMP_REV )
        oSection1:Cell("PRODUZIR"):SetValue((ctmp)->TMP_QTOP)
        oSection1:Cell("UTILIZA"):SetValue((ctmp)->TMP_QUSE)
        oSection1:Cell("NIVEL"):SetValue((ctmp)->TMP_NIVEL)
        oSection1:Cell("COMPONENTE"):SetValue((ctmp)->TMP_COMP)
        oSection1:Cell("TRT"):SetValue((ctmp)->TMP_TRT)	
        oSection1:Cell("MATERIAL"):SetValue((ctmp)->TMP_MAT)
        oSection1:Cell("QUANT"):SetValue((ctmp)->TMP_QTDE)

        oSection1:Cell("QTMOV"):SetValue((ctmp)->TMP_QMOV)
        oSection1:Cell("CSTMED"):SetValue((ctmp)->TMP_MCUS)        	
        
	    oSection1:PrintLine()
	    oReport:IncMeter()

        dbSelectArea(ctmp)
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


Static Function SeacherR320(cOrdem,cProduto,cTRT)
    Local cArea := FwGetArea()
    Local xAlias:= GetNextAlias()
    Local nQuant:= 0
    Local nCusto:= 0
    
    BeginSQL Alias xAlias
		SELECT D3_QUANT, D3_CUSTO1
		FROM %Table:SD3% SD3
		WHERE SD3.%NotDel%
		and D3_FILIAL =  %xFilial:SD3%
        AND D3_OP = %exp:cOrdem% 
        AND D3_COD = %exp:cProduto% 
        AND D3_TRT = %exp:cTRT% 
    EndSQL  
    if (xAlias)->(Eof())
		Return({0,0})
    ENDIF
    dbSelectArea(xAlias)
    (xAlias)->(dbgotop() )
    While !(xAlias)->( Eof() )
            nQuant := (xAlias)->D3_QUANT
            nCusto :=  (xAlias)->D3_CUSTO1
        (xAlias)->( dbSkip())
    Enddo
    (xAlias)->( dbcloseArea() )
    FwRestArea(cArea)
Return({nQuant,nCusto})
