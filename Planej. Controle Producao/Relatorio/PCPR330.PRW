//Bibliotecas
#Include "TOTVS.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR330()
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
    Private cMvPar05
    Private cMvPar06
    Private cMvPar07

    Private cLogErro := {}

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

Static Function ProcRun(oSay)

    Local aFields       :={}
    Local oReport
    Local cAlias        := "Y-"+GetNextAlias()
    Local cQuery        := ' '

    Private ctmp        := "Z-"+GetNextAlias()
    Private oTable      := FWTemporaryTable():New( ctmp ) 
    Private cTitulo 	:= OemToAnsi("Lista de Estrutura dos produtos da Ordem de Produção")

    aAdd(aFields,{"TMP_FILIAL"		, GetSx3Cache("C2_FILIAL","X3_TIPO")		,tamSx3("C2_FILIAL")[1]	    ,tamSx3("C2_FILIAL")[2]})
    aAdd(aFields,{"TMP_LOTE"	    , GetSx3Cache("C2_NUM","X3_TIPO")		    ,tamSx3("C2_NUM")[1]	    ,tamSx3("C2_NUM")[2]})  
    aAdd(aFields,{"TMP_COD" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})
    aAdd(aFields,{"TMP_QTDPR" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDRA" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDPD" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_TRT" 	    , GetSx3Cache("D4_TRT","X3_TIPO")	        ,tamSx3("D4_TRT")[1]	    ,tamSx3("D4_TRT")[2]})
    aAdd(aFields,{"TMP_COMP" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})    
    aAdd(aFields,{"TMP_QTDST" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDD4" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDD3" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
    aAdd(aFields,{"TMP_CUSTD" 	    , GetSx3Cache("B1_CUSTD","X3_TIPO")	        ,tamSx3("B1_CUSTD")[1]	    ,tamSx3("B1_CUSTD")[2]})      
    oTable:SetFields( aFields )
	oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_LOTE","TMP_COD","TMP_COMP","TMP_TRT"} )
 	oTable:Create()

    cQuery :="Select  C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_LOCAL,C2_QUANT,C2_QUJE,C2_EMISSAO,C2_DATRF,C2_PERDA,"+cEof
    cQuery +="		   D4_TRT,D4_COD,(G1_QUANT*C2_QUANT)/100 QTD_STRU,D4_QTDEORI,D3_QUANT,D3_CUSTO1 "+cEof
    cQuery +="FROM "+RetSqlName("SC2")+" SC2 "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_COD = C2_PRODUTO "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SD4")+" SD4 ON SD4.D_E_L_E_T_ = ' ' AND D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN  "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SD3")+" SD3 ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND SD3.D_E_L_E_T_ = ' ' AND D3_TRT = D4_TRT "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SG1")+" SG1 ON SG1.D_E_L_E_T_ = ' ' AND G1_FILIAL = C2_FILIAL AND G1_COD = C2_PRODUTO AND G1_COMP = D4_COD AND G1_TRT = D4_TRT  "+cEof
    cQuery +="Where SC2.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="AND C2_FILIAL =  '"+xFilial("SC2")+"'"+cEof
    cQuery +="AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '"+cMvPar01+"' AND '"+cMvPar02+"' "+cEof
    cQuery +="AND C2_EMISSAO BETWEEN   '"+dtos(cMvPar03)+"'  AND '"+dtos(cMvPar04)+"' "+cEof
    cQuery +="ORDER BY C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,D4_TRT "+cEof    

     If  Select(cAlias) > 0
                DbSelectArea(cAlias)
                DbCloseArea()
     Endif

     DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), cAlias , .F., .T. )

     if (cAlias)->(Eof())
        (cAlias)->( dbcloseArea() )
        FWAlertError("Sem dados para processar!", "Falha")
		Return
     ENDIF

      While !(cAlias)->(EoF())
             IF RecLock(ctmp,.T.)
                (ctmp)->TMP_FILIAL  := (cAlias)->C2_FILIAL
                (ctmp)->TMP_LOTE   := (cAlias)->C2_NUM
                (ctmp)->TMP_COD    := (cAlias)->C2_PRODUTO
                (ctmp)->TMP_QTDPR  := (cAlias)->C2_QUANT
                (ctmp)->TMP_QTDRA  := (cAlias)->C2_QUJE
                (ctmp)->TMP_QTDPD  := (cAlias)->C2_PERDA
                (ctmp)->TMP_TRT    := (cAlias)->D4_TRT
                (ctmp)->TMP_COMP   := (cAlias)->D4_COD
                (ctmp)->TMP_QTDST  := (cAlias)->QTD_STRU
                (ctmp)->TMP_QTDD4  := (cAlias)->D4_QTDEORI
                (ctmp)->TMP_QTDD3  := (cAlias)->D3_QUANT
                (ctmp)->TMP_CUSTD  := (cAlias)->D3_CUSTO1
               (ctmp)->( MsUnlock() )
             Endif
             (cAlias)->( dbSkip() )
      EndDo
      (cAlias)->( dbCloseArea() )
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

    oReport:= TReport():New("PCPR320",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

      // Dados da Ordem de Producao
	TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'LOTE'			,'cQry01','Lote'     		        ,PesqPict('SC2',"C2_NUM")		,TamSX3("C2_NUM") [1]+1,,) 
    TRCell():New(oSection1,'PRODUTO'		,'cQry01','Produto'     		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
	TRCell():New(oSection1,'PRODUZIR'		,'cQry01','Produzir'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'UTILIZA'		,'cQry01','Produzido'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
	TRCell():New(oSection1,'PERDA'			,'cQry01','Perda'     		   	    ,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 		
    TRCell():New(oSection1,'TRT'			,'cQry01','TRT'     		    	,PesqPict('SD4',"D4_TRT")		,TamSX3("D4_TRT") [1]+1,,) 
    TRCell():New(oSection1,'COMPONENTE'		,'cQry01','Prod.Estrutura' 		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
    TRCell():New(oSection1,'QTDST'			,'cQry01','Qtde.Estrutura'	    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'QTDD4'			,'cQry01','Qtde Empenhado' 	    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
	TRCell():New(oSection1,'QTDD3'			,'cQry01','Qtde Movimentos' 	   	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'CSTMED'	        ,'cQry01','Custo Mov'   	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    
Return(oReport)

Static Function ReportPrint(oReport)      
    Private oSection1 := oReport:Section(1)
    
    dbSelectArea(ctmp)
    (ctmp)->( dbGotop() )

    oReport:SetMeter((ctmp)->(LastRec()))
    oSection1:Init()
    
    While !oReport:Cancel() .And. !(ctmp)->(Eof())   

        // Dados da Ordem de Producao
        oSection1:Cell("FILIAL"):SetValue((ctmp)->TMP_FILIAL)
        oSection1:Cell("LOTE"):SetValue((ctmp)->TMP_LOTE  )	
        oSection1:Cell("PRODUTO"):SetValue((ctmp)->TMP_COD)
        oSection1:Cell("PRODUZIR"):SetValue((ctmp)->TMP_QTDPR)
        oSection1:Cell("UTILIZA"):SetValue((ctmp)->TMP_QTDRA)
        oSection1:Cell("PERDA"):SetValue((ctmp)->TMP_QTDPD)
        oSection1:Cell("TRT"):SetValue((ctmp)->TMP_TRT)	
        oSection1:Cell("COMPONENTE"):SetValue((ctmp)->TMP_COMP)
        oSection1:Cell("QTDST"):SetValue((ctmp)->TMP_QTDST)
        oSection1:Cell("QTDD4"):SetValue((ctmp)->TMP_QTDD4)
        oSection1:Cell("QTDD3"):SetValue((ctmp)->TMP_QTDD3)
        oSection1:Cell("CSTMED"):SetValue((ctmp)->TMP_CUSTD) 
        
	    oSection1:PrintLine()
	    oReport:IncMeter()

        dbSelectArea(ctmp)
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 

