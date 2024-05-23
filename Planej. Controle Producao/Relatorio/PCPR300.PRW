#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR300()
    Local oReport
     Private cArqTrab
    Private cPerg 		:= PADR("PCPR290",10)
    Private cTitulo 	:= OemToAnsi("Relacao de Ordem Producao por Insumos")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    oReport:= TReport():New("PCPR300",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'OP'				,'cQry01','Ordem Producao'     		,	 							, 							,,) 
    TRCell():New(oSection1,'EMISSAO'		,'cQry01','Emissao'     		   	,PesqPict('SC2',"C2_EMISSAO")	,TamSX3("C2_EMISSAO") [1]+1,,) 
    TRCell():New(oSection1,'FABRIC'			,'cQry01','Fabricacao'     		   	,PesqPict('SC2',"C2_DATRF")		,TamSX3("C2_DATRF") [1]+1,,) 
    TRCell():New(oSection1,'PRODUTO'		,'cQry01','Produto'     		   	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 
    TRCell():New(oSection1,'QUANT'			,'cQry01','Previsto'     		   	,PesqPict('SC2',"C2_QUANT")		,TamSX3("C2_QUANT") [1]+1,,) 
    TRCell():New(oSection1,'QTDUSA'			,'cQry01','Realizado'     		   	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'DIF'			,'cQry01','Divergencia'     		,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'STATUS'			,'cQry01','Status'     		    	,								,						,,) 
    TRCell():New(oSection1,'TRT'			,'cQry01','TRT'     		    	,PesqPict('SD4',"D4_TRT")		,TamSX3("D4_TRT") [1]+1,,) 
    TRCell():New(oSection1,'MATERIAL'		,'cQry01','Material'     		    ,PesqPict('SD3',"D3_COD")		,TamSX3("D3_COD") [1]+1,,) 
    TRCell():New(oSection1,'TIPO'			,'cQry01','Tipo'     		    	,PesqPict('SD3',"D3_TIPO")		,TamSX3("D3_TIPO") [1]+1,,)
    TRCell():New(oSection1,'QTDSTR'			,'cQry01','Qtd Stru'  		    	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 
    TRCell():New(oSection1,'TOTSTR'			,'cQry01','Qt. Total Stru'       	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,)     
    TRCell():New(oSection1,'QTDEORI'		,'cQry01','Empenho'     		    ,PesqPict('SD4',"D4_QTDEORI")	,TamSX3("D4_QTDEORI") [1]+1,,) 
    TRCell():New(oSection1,'QTDMOV'			,'cQry01','Movimento'     		    ,PesqPict('SD3',"D3_QUANT")		,TamSX3("D3_QUANT") [1]+1,,) 
    TRCell():New(oSection1,'PERDA'			,'cQry01','Divergencia'   	    	,PesqPict('SD3',"D3_PERDA")		,TamSX3("D3_PERDA") [1]+1,,) 
    TRCell():New(oSection1,'CUSTO'			,'cQry01','Custo Medio'     		,PesqPict('SD3',"D3_CUSTO1")	,TamSX3("D3_CUSTO1") [1]+1,,) 
    TRCell():New(oSection1,'CSTSB1'			,'cQry01','Custo Apur'     		    ,PesqPict('SD3',"D3_CUSTO1")	,TamSX3("D3_CUSTO1") [1]+1,,) 
    TRCell():New(oSection1,'CUSTNET'		,'cQry01','Custo Net'     		    ,PesqPict('SD3',"D3_CUSTO1")	,TamSX3("D3_CUSTO1") [1]+1,,) 	

Return(oReport)

Static Function ReportPrint(oReport)      
  	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)

    cQuery :="Select 	                                                                       "+cEof
    cQuery +="      C2_FILIAL  AS  FILIAL,                                                     "+cEof
    cQuery +="		C2_NUM+C2_ITEM+C2_SEQUEN OP,                                                "+cEof
    cQuery +="  	C2_EMISSAO AS EMISSAO,                                                      "+cEof        
    cQuery +="		C2_DATRF   AS FABRIC,                                                       "+cEof
    cQuery +="		C2_PRODUTO AS PRODUTO,                                                      "+cEof
    cQuery +="	    C2_QUANT AS QUANT,                                                          "+cEof             
    cQuery +="		C2_QUJE AS QTDUSA,                                                          "+cEof
    cQuery +="	   	CASE WHEN ( C2_QUJE-C2_QUANT) > 0 THEN ROUND(( C2_QUJE-C2_QUANT),2)         "+cEof
    cQuery +="			 WHEN ( C2_QUJE-C2_QUANT) < 0 THEN ROUND((( C2_QUJE-C2_QUANT)*-1),2)    "+cEof
    cQuery +="		ELSE 0 END AS DIF,                                                          "+cEof
    cQuery +="	    CASE WHEN ( C2_QUJE-C2_QUANT) > 0 THEN 'GANHO'                              "+cEof
    cQuery +="			WHEN ( C2_QUJE-C2_QUANT) < 0 THEN 'PERDA'                               "+cEof
    cQuery +="		ELSE ' ' END AS STATUS,                                                     "+cEof
    cQuery +="		ISNULL(D4_TRT,' ') AS TRT,                                                  "+cEof
    cQuery +="		D3_COD  as MATERIAL,                                                        "+cEof
    cQuery +="		D3_TIPO as TIPO,                                                            "+cEof 
    cQuery +="      G1_QUANT as QTDSTR,                                                         "+cEof   
	cQuery +="  CASE WHEN ( C2_QUJE-C2_QUANT) > 0 THEN  (G1_QUANT * C2_QUANT)                   "+cEof 
	cQuery +="	     WHEN ( C2_QUJE-C2_QUANT) < 0 THEN  (G1_QUANT * C2_QUANT)/100               "+cEof 
    cQuery +="  ELSE 0 END as TOTSTR,                                                           "+cEof   
    cQuery +="      ISNULL(D4_QTDEORI,0) AS QTDEORI,                                            "+cEof
    cQuery +="		D3_QUANT AS QTDMOV,                                                         "+cEof
    cQuery +="  CASE WHEN ( C2_QUJE-C2_QUANT) > 0 THEN  (D3_QUANT - (G1_QUANT * C2_QUANT))      "+cEof
	cQuery +="	     WHEN ( C2_QUJE-C2_QUANT) < 0 THEN  (D3_QUANT - ((G1_QUANT * C2_QUANT)/100)) "+cEof 
    cQuery +="       ELSE 0 END 	AS PERDA,                                                   "+cEof
    cQuery +="		ROUND((D3_CUSTO1/D3_QUANT),2) AS CUSTO,                                     "+cEof
    cQuery +="		SB1.B1_CUSTD as CSTSB1,                                                     "+cEof
    cQuery +="		SB1.B1_CUSTNET AS CUSTNET                                                   "+cEof
    cQuery +="From "+RetSqlName("SC2")+" SC2                                                    "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SD3")+" SD3 ON D3_FILIAL = C2_FILIAL AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND SD3.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="LEFT JOIN "+RetSqlName("SD4")+" SD4 ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND D4_COD = D3_COD AND D4_TRT = D3_TRT AND D4_LOCAL = D3_LOCAL AND SD4.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = D3_COD AND SB1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SG1")+" SG1 ON G1_FILIAL = C2_FILIAL AND G1_COD = C2_PRODUTO AND G1_COMP = D3_COD AND G1_TRT = D3_TRT and G1_REVFIM = C2_REVISAO AND SG1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="WHERE SC2.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="AND C2_FILIAL = '"+xFilial("SC2")+"' "+cEof
    cQuery +="AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN  '"+MV_PAR01+"'  AND '"+MV_PAR02+"' "+cEof
    cQuery +="AND C2_EMISSAO BETWEEN   '"+Dtos(MV_PAR03)+"'  AND '"+Dtos(MV_PAR04)+"' "+cEof
    cQuery +="AND D3_TIPO IN ( 'PA','PI','MP','EM' ) "+cEof
    cQuery +="AND C2_PRODUTO <> D3_COD "+cEof
    cQuery +="Order by C2_NUM+C2_ITEM+C2_SEQUEN,D4_TRT  "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "EMISSAO", "D")
    TCSetField("cQry01", "FABRIC", "D")
  
    
    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        oReport:IncMeter()
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->FILIAL)
        oSection1:Cell("OP"):SetValue(("cQry01")->OP)		
        oSection1:Cell("EMISSAO"):SetValue(("cQry01")->EMISSAO)
        oSection1:Cell("FABRIC"):SetValue(("cQry01")->FABRIC)		
        oSection1:Cell("PRODUTO"):SetValue(("cQry01")->PRODUTO)
        oSection1:Cell("QUANT"):SetValue(("cQry01")->QUANT)	
        oSection1:Cell("QTDUSA"):SetValue(("cQry01")->QTDUSA)	
        oSection1:Cell("DIF"):SetValue(("cQry01")->DIF)	
        oSection1:Cell("STATUS"):SetValue(("cQry01")->STATUS)	
        oSection1:Cell("TRT"):SetValue(("cQry01")->TRT)	
        oSection1:Cell("MATERIAL"):SetValue(("cQry01")->MATERIAL)
        oSection1:Cell("TIPO"):SetValue(("cQry01")->TIPO)	
        
        oSection1:Cell("QTDSTR"):SetValue(("cQry01")->QTDSTR)
        oSection1:Cell("TOTSTR"):SetValue(("cQry01")->TOTSTR)

        oSection1:Cell("QTDEORI"):SetValue(("cQry01")->QTDEORI)
        oSection1:Cell("QTDMOV"):SetValue(("cQry01")->QTDMOV)		
        oSection1:Cell("PERDA"):SetValue(("cQry01")->PERDA)	
        oSection1:Cell("CUSTO"):SetValue(("cQry01")->CUSTO)		
        oSection1:Cell("CSTSB1"):SetValue(("cQry01")->CSTSB1)		
        oSection1:Cell("CUSTNET"):SetValue(("cQry01")->CUSTNET)

	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


