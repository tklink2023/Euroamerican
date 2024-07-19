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
    aAdd(aFields,{"TMP_DTEMIS"	    , GetSx3Cache("C2_EMISSAO","X3_TIPO")		,tamSx3("C2_EMISSAO")[1]	,tamSx3("C2_EMISSAO")[2]})  
    aAdd(aFields,{"TMP_DTFABR"	    , GetSx3Cache("C2_EMISSAO","X3_TIPO")		,tamSx3("C2_EMISSAO")[1]	,tamSx3("C2_EMISSAO")[2]})  
    aAdd(aFields,{"TMP_COD" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})
    aAdd(aFields,{"TMP_DESC" 	    , GetSx3Cache("B1_DESC","X3_TIPO")	        ,tamSx3("B1_DESC")[1]	    ,tamSx3("B1_DESC")[2]})
    aAdd(aFields,{"TMP_TIPO" 	    , GetSx3Cache("B1_TIPO","X3_TIPO")	        ,tamSx3("B1_TIPO")[1]	    ,tamSx3("B1_TIPO")[2]})
    aAdd(aFields,{"TMP_QTDPR" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDRA" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDPD" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_COMP" 	    , GetSx3Cache("C2_PRODUTO","X3_TIPO")	    ,tamSx3("C2_PRODUTO")[1]	,tamSx3("C2_PRODUTO")[2]})  
    aAdd(aFields,{"TMP_CDES" 	    , GetSx3Cache("B1_DESC","X3_TIPO")	        ,tamSx3("B1_DESC")[1]	    ,tamSx3("B1_DESC")[2]})
    aAdd(aFields,{"TMP_CTIPO" 	    , GetSx3Cache("B1_TIPO","X3_TIPO")	        ,tamSx3("B1_TIPO")[1]	    ,tamSx3("B1_TIPO")[2]})
    aAdd(aFields,{"TMP_STRUT" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  

    aAdd(aFields,{"TMP_QTDST" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDD4" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})  
    aAdd(aFields,{"TMP_QTDD3" 	    , GetSx3Cache("C2_QUANT","X3_TIPO")	        ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})

    aAdd(aFields,{"TMP_CUSTM" 	    , GetSx3Cache("B1_CUSTD","X3_TIPO")	        ,tamSx3("B1_CUSTD")[1]	    ,tamSx3("B1_CUSTD")[2]})      
    aAdd(aFields,{"TMP_CUSTD" 	    , GetSx3Cache("B1_CUSTD","X3_TIPO")	        ,tamSx3("B1_CUSTD")[1]	    ,tamSx3("B1_CUSTD")[2]})      
    aAdd(aFields,{"TMP_CUSTN" 	    , GetSx3Cache("B1_CUSTD","X3_TIPO")	        ,tamSx3("B1_CUSTD")[1]	    ,tamSx3("B1_CUSTD")[2]})  

    aAdd(aFields,{"TMP_REVISA" 	    , GetSx3Cache("B1_REVATU","X3_TIPO")	    ,tamSx3("B1_REVATU")[1]	    ,tamSx3("B1_REVATU")[2]})    

    oTable:SetFields( aFields )
	oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_LOTE","TMP_COD","TMP_COMP"} )
 	oTable:Create()


    cQuery :="Select  SD3.D3_FILIAL	FILIAL,"+cEof
    cQuery +="		SD3.D3_DOC		LOTE,"+cEof
    cQuery +="      SD3.D3_OP		OP,"+cEof
    cQuery +="	    SC2.C2_PRODUTO  PRODUTO,"+cEof
    cQuery +="		SC2.C2_LOCAL	LOCAL,"+cEof
    cQuery +="		SB1.B1_DESC		DESCRICAO,"+cEof
    cQuery +="		SB1.B1_TIPO		TIPO,"+cEof
    cQuery +="		SB1.B1_REVATU   REVISAO,"+cEof
    cQuery +="		SC2.C2_QUANT	PREVISTO,"+cEof
    cQuery +="		SC2.C2_QUJE		REALIZADO,"+cEof
    cQuery +="		SC2.C2_PERDA    PERDA,"+cEof
    cQuery +="		SC2.C2_EMISSAO	EMISSAO,"+cEof
    cQuery +="		SC2.C2_DATRF	FABRICACAO,"+cEof
    cQuery +="		SD3.D3_COD		COMPONENTE,"+cEof
    cQuery +="	    XB1.B1_DESC		DESCCOMP,"+cEof
    cQuery +="		XB1.B1_TIPO		TIPOCOMP,"+cEof
    cQuery +="		SD3.D3_CUSTO1	CUSTM,"+cEof
    cQuery +="		XB1.B1_CUSTD	CUSTD,"+cEof
    cQuery +="		XB1.B1_CUSTNET	CUSTN,"+cEof
    cQuery +="		XB1.B1_QB		QUEBRA,"+cEof
    cQuery +="		SD3.D3_LOCAL	LOCCOMP,"+cEof
    cQuery +="		SD3.D3_UM		UM,"+cEof
    cQuery +="		ISNULL(D4_QTDEORI,0)  EMPENHO ,"+cEof
    cQuery +="		SD3.D3_QUANT	QTDMOV,"+cEof
    cQuery +="		ISNULL((G1_QUANT*C2_QUANT)/SB1.B1_QB,0) QTDESTR"+cEof

    cQuery +="From "+RetSqlName("SD3")+"  SD3"+cEof

    cQuery +="INNER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.D_E_L_E_T_ = ' ' AND C2_FILIAL = D3_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D3_OP "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = C2_PRODUTO"+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" XB1 ON XB1.D_E_L_E_T_ = ' ' AND XB1.B1_COD = SD3.D3_COD AND XB1.B1_TIPO <> 'MO'"+cEof
    cQuery +="LEFT JOIN  "+RetSqlName("SD4")+"  SD4 ON SD4.D_E_L_E_T_ = ' ' AND D4_OP = D3_OP AND D4_COD = D3_COD AND  D4_TRT = D3_TRT"+cEof
    cQuery +="LEFT JOIN  "+RetSqlName("SG1")+" SG1 ON SG1.D_E_L_E_T_ = ' ' AND G1_FILIAL = D3_FILIAL AND G1_COD = C2_PRODUTO AND G1_COMP = D3_COD AND G1_TRT = D3_TRT"+cEof
    cQuery +="		AND G1_REVFIM = (SELECT MAX(G1_REVFIM) FROM "+RetSqlName("SG1")+" WHERE D_E_L_E_T_ = ' ' AND G1_FILIAL = D3_FILIAL AND G1_COD = C2_PRODUTO AND G1_COMP = D3_COD AND G1_TRT = D3_TRT)"+cEof

    cQuery +="Where SD3.D_E_L_E_T_ = ' '"+cEof
    cQuery +="AND D3_FILIAL =  '"+xFilial("SC2")+"'"+cEof
    cQuery +="AND D3_OP BETWEEN '"+cMvPar01+"' AND '"+cMvPar02+"' "+cEof
    cQuery +="AND D3_EMISSAO BETWEEN '"+dtos(cMvPar03)+"'  AND '"+dtos(cMvPar04)+"' "+cEof
    cQuery +="AND D3_COD <> C2_PRODUTO"+cEof
    cQuery +="ORDER BY D3_OP,C2_PRODUTO,D3_COD"+cEof
    
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
                (ctmp)->TMP_FILIAL := (cAlias)->FILIAL
                (ctmp)->TMP_LOTE   := (cAlias)->LOTE
                (ctmp)->TMP_COD    := (cAlias)->PRODUTO
                (ctmp)->TMP_DESC   := (cAlias)->DESCRICAO
                (ctmp)->TMP_TIPO   := (cAlias)->TIPO
                (ctmp)->TMP_DTEMIS := stod((cAlias)->EMISSAO)
                (ctmp)->TMP_DTFABR := stod((cAlias)->FABRICACAO)
                (ctmp)->TMP_QTDPR  := (cAlias)->PREVISTO
                (ctmp)->TMP_QTDRA  := (cAlias)->REALIZADO
                (ctmp)->TMP_QTDPD  := (cAlias)->PREVISTO - (cAlias)->REALIZADO //(cAlias)->PERDA
                (ctmp)->TMP_COMP   := (cAlias)->COMPONENTE
                (ctmp)->TMP_CDES   := (cAlias)->DESCCOMP
                (ctmp)->TMP_CTIPO  := (cAlias)->TIPOCOMP
                (ctmp)->TMP_QTDST  := (cAlias)->QTDESTR
                (ctmp)->TMP_QTDD4  := (cAlias)->EMPENHO
                (ctmp)->TMP_QTDD3  := (cAlias)->QTDMOV
                (ctmp)->TMP_CUSTM  := ((cAlias)->CUSTM / (cAlias)->QTDMOV )
                (ctmp)->TMP_CUSTD  := (cAlias)->CUSTD
                (ctmp)->TMP_CUSTN  := (cAlias)->CUSTN
                (ctmp)->TMP_REVISA := (cAlias)->REVISAO
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

    oReport:= TReport():New("PCPR330",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

      // Dados da Ordem de Producao
	TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'LOTE'			,'cQry01','Lote'     		        ,PesqPict('SC2',"C2_NUM")		,TamSX3("C2_NUM") [1]+1,,) 
    TRCell():New(oSection1,'EMISSAO'		,'cQry01','Emissao'     		   	,PesqPict('SC2',"C2_EMISSAO")	,TamSX3("C2_EMISSAO") [1]+1,,) 
    TRCell():New(oSection1,'FABRIC'			,'cQry01','Fabricacao'     		   	,PesqPict('SC2',"C2_DATRF")		,TamSX3("C2_DATRF") [1]+1,,) 
    TRCell():New(oSection1,'PRODUTO'		,'cQry01','Produto'     		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
	TRCell():New(oSection1,'DESCRICAO'		,'cQry01','Descricao'     		   	,PesqPict('SB1',"B1_DESC")	    ,TamSX3("B1_DESC") [1]+1,,)
	TRCell():New(oSection1,'TIPO'		    ,'cQry01','Tipo'     		     	,PesqPict('SB1',"B1_TIPO")	    ,TamSX3("B1_TIPO") [1]+1,,)    
	TRCell():New(oSection1,'PRODUZIR'		,'cQry01','Produzir'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'UTILIZA'		,'cQry01','Produzido'     		   	,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 
	TRCell():New(oSection1,'PERDA'			,'cQry01','Perda/Ganho' 	   	    ,PesqPict('SC2',"C2_QUJE")	    ,TamSX3("C2_QUJE") [1]+1,,) 	
    TRCell():New(oSection1,'REVISAO'		,'cQry01','Revisao'    		   	    ,PesqPict('SB1',"B1_REVATU")    ,TamSX3("B1_REVATU") [1]+1,,) 	    	
    TRCell():New(oSection1,'COMPONENTE'		,'cQry01','Prod.Estrutura' 		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
    TRCell():New(oSection1,'DESC1'  		,'cQry01','Descricao'     		   	,PesqPict('SB1',"B1_DESC")	    ,TamSX3("B1_DESC") [1]+1,,)
	TRCell():New(oSection1,'TIP1'		    ,'cQry01','Tipo'     		     	,PesqPict('SB1',"B1_TIPO")	    ,TamSX3("B1_TIPO") [1]+1,,)
    TRCell():New(oSection1,'QTDST'			,'cQry01','Qtde.Prevista'	    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'QTDD4'			,'cQry01','Qtde Empenhado' 	    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,)
	TRCell():New(oSection1,'QTDD3'			,'cQry01','Qtde Movimentos' 	   	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'QTDDV'			,'cQry01','Qtde Divergente' 	   	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'CSTMED'	        ,'cQry01','Custo Medio'   	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    TRCell():New(oSection1,'CSTSTD'	        ,'cQry01','Custo Standart'	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    TRCell():New(oSection1,'CSTNET'	        ,'cQry01','Custo Net'   	     	,PesqPict('SB1',"B1_CUSTD")	    ,TamSX3("B1_CUSTD") [1]+1,,)
    
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
        oSection1:Cell("DESCRICAO"):SetValue((ctmp)->TMP_DESC) 
        oSection1:Cell("TIPO"):SetValue((ctmp)->TMP_TIPO) 
        oSection1:Cell("EMISSAO"):SetValue((ctmp)->TMP_DTEMIS) 
        oSection1:Cell("FABRIC"):SetValue((ctmp)->TMP_DTFABR) 
        oSection1:Cell("PRODUZIR"):SetValue((ctmp)->TMP_QTDPR)
        oSection1:Cell("UTILIZA"):SetValue((ctmp)->TMP_QTDRA)
        oSection1:Cell("PERDA"):SetValue((ctmp)->TMP_QTDPD)
        oSection1:Cell("REVISAO"):SetValue((ctmp)->TMP_REVISA)

        oSection1:Cell("COMPONENTE"):SetValue((ctmp)->TMP_COMP)
        oSection1:Cell("QTDST"):SetValue((ctmp)->TMP_QTDST)
        oSection1:Cell("QTDD4"):SetValue((ctmp)->TMP_QTDD4)
        oSection1:Cell("QTDD3"):SetValue((ctmp)->TMP_QTDD3)
        oSection1:Cell("QTDDV"):SetValue((ctmp)->TMP_QTDST - (ctmp)->TMP_QTDD3)
        oSection1:Cell("CSTMED"):SetValue((ctmp)->TMP_CUSTM) 
        oSection1:Cell("DESC1"):SetValue((ctmp)->TMP_CDES) 
        oSection1:Cell("TIP1"):SetValue((ctmp)->TMP_CTIPO) 
        oSection1:Cell("CSTSTD"):SetValue((ctmp)->TMP_CUSTD) 
        oSection1:Cell("CSTNET"):SetValue((ctmp)->TMP_CUSTN) 

	    oSection1:PrintLine()
	    oReport:IncMeter()

        dbSelectArea(ctmp)
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 

