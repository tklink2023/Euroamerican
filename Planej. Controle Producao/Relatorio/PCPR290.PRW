#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR290()
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


    oReport:= TReport():New("PCPR290",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 	
	TRCell():New(oSection1,'OP'				,'cQry01','Numero OP'            	,								, 						  ,,) 	
    TRCell():New(oSection1,'EMISSAO'		,'cQry01','Emissao'     	     	,PesqPict('SC2',"C2_EMISSAO")	,TamSX3("C2_EMISSAO") [1]+1,,) 	
    TRCell():New(oSection1,'FABRIC'  		,'cQry01','Fabricacao'     	     	,PesqPict('SC2',"C2_EMISSAO")	,TamSX3("C2_EMISSAO") [1]+1,,) 	
    TRCell():New(oSection1,'PRODUTO'		,'cQry01','Produto'     	     	,PesqPict('SC2',"C2_DATRF")	    ,TamSX3("C2_DATRF") [1]+1,,) 	
    TRCell():New(oSection1,'DESCRIC'		,'cQry01','Descricao'  		    	,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC")    [1]+1,,) 	
    TRCell():New(oSection1,'UM'		    	,'cQry01','UM'     		    	    ,PesqPict('SB1',"B1_UM")		,TamSX3("B1_UM")     [1]+1,,) 	
    TRCell():New(oSection1,'REVISAO'		,'cQry01','Revisao'     		    ,PesqPict('SB1',"B1_REVATU")	,TamSX3("B1_REVATU")    [1]+1,,) 	
    TRCell():New(oSection1,'CUSTOM'  		,'cQry01','Custo Med'           	,PesqPict('SB2',"B2_CM1")		,TamSX3("B2_CM1")   [1]+1,,) 	
    TRCell():New(oSection1,'CUSTON'	    	,'cQry01','Custo Net'        	    ,PesqPict('SB1',"B1_CUSTNET")	,TamSX3("B1_CUSTNET")  [1]+1,,) 	
    TRCell():New(oSection1,'QUANT'   		,'cQry01','Quantidade'       	    ,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE")    [1]+1,,) 	
    TRCell():New(oSection1,'QTDUSA'	    	,'cQry01','Qtde Usada' 		      	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE")    [1]+1,,) 	
    TRCell():New(oSection1,'TRT'		    ,'cQry01','TRT' 	      	        ,PesqPict('SD4',"D4_TRT")		,TamSX3("D4_TRT")   [1]+1,,) 
	TRCell():New(oSection1,'MATERIAL'	    ,'cQry01','Material' 	      	    ,PesqPict('SD4',"D4_COD")		,TamSX3("D4_COD")   [1]+1,,) 
	TRCell():New(oSection1,'DESCMAT'        ,'cQry01','Descr.Mat'  		    	,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC")    [1]+1,,) 
    TRCell():New(oSection1,'QTDEORI'   		,'cQry01','Qtde.Orig'       	    ,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE")    [1]+1,,) 		
	TRCell():New(oSection1,'QTDEMAT'   		,'cQry01','Quantidade'       	    ,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE")    [1]+1,,) 	
    TRCell():New(oSection1,'REVMAT'	    	,'cQry01','Rev.Material'   		    ,PesqPict('SB1',"B1_REVATU")	,TamSX3("B1_REVATU")    [1]+1,,) 	
    TRCell():New(oSection1,'CSTMMAT'  		,'cQry01','Custo Med'           	,PesqPict('SB2',"B2_CM1")		,TamSX3("B2_CM1")   [1]+1,,) 	
    TRCell():New(oSection1,'CSTNMAT'	   	,'cQry01','Custo Net'        	    ,PesqPict('SB1',"B1_CUSTNET")	,TamSX3("B1_CUSTNET")  [1]+1,,) 	

Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)


    cQuery :="Select C2_FILIAL AS FILIAL,                         "+cEof
    cQuery +="		 C2_NUM+C2_ITEM+C2_SEQUEN AS OP,              "+cEof
    cQuery +="		 C2_EMISSAO AS EMISSAO,                       "+cEof
    cQuery +="		 C2_DATRF   AS FABRIC,                        "+cEof
    cQuery +="		 C2_PRODUTO AS PRODUTO,                       "+cEof
    cQuery +="		 SB1.B1_DESC AS DESCRIC,                      "+cEof
    cQuery +="		 SB1.B1_UM AS UM,                             "+cEof
    cQuery +="		 SB1.B1_REVATU AS REVISAO,                    "+cEof
    cQuery +="		 SB2.B2_CM1 AS CUSTOM,                        "+cEof
    cQuery +="		 SB1.B1_CUSTNET AS CUSTON,                    "+cEof
    cQuery +="		 C2_QUANT AS QUANT,                           "+cEof
    cQuery +="		 C2_QUJE AS QTDUSA ,                          "+cEof
    cQuery +="		 D4_TRT AS TRT,                               "+cEof
    cQuery +="		 D4_COD AS MATERIAL,                          "+cEof
    cQuery +="		 SB11.B1_DESC AS DESCMAT,                     "+cEof
    cQuery +="		 D4_QTDEORI AS QTDEORI,                       "+cEof
    cQuery +="		 D4_QUANT AS QTDEMAT,                         "+cEof
    cQuery +="		 SB11.B1_REVATU AS REVMAT,                    "+cEof
    cQuery +="		 SB21.B2_CM1 as CSTMMAT,                      "+cEof
    cQuery +="		 SB11.B1_CUSTNET as CSTNMAT                   "+cEof
    cQuery +="From "+RetSqlName("SC2")+" SC2    "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = C2_FILIAL AND SB2.B2_COD = C2_PRODUTO AND SB2.B2_LOCAL = C2_LOCAL AND SB2.D_E_L_E_T_ = ' '    "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SD4")+" SD4 ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND D4_PRODUTO = C2_PRODUTO AND SD4.D_E_L_E_T_ = ' '   "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB11 ON SB11.B1_COD = D4_COD AND SB11.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB2")+" SB21 ON SB21.B2_FILIAL = D4_FILIAL AND SB21.B2_COD = D4_COD AND SB21.B2_LOCAL = D4_LOCAL AND SB21.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="Where SC2.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="AND C2_FILIAL = '"+xFilial("SC2")+"' "+cEof
    cQuery +="AND C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN  '"+MV_PAR01+"'  AND '"+MV_PAR02+"' "+cEof
    cQuery +="AND C2_EMISSAO BETWEEN  '"+Dtos(MV_PAR03)+"'  AND '"+Dtos(MV_PAR04)+"' "+cEof
    cQuery +="ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN,D4_TRT,D4_COD "+cEof


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
             
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->FILIAL)
        oSection1:Cell("OP"):SetValue(("cQry01")->OP)
        oSection1:Cell("EMISSAO"):SetValue(("cQry01")->EMISSAO)
        oSection1:Cell("FABRIC"):SetValue(("cQry01")->FABRIC)
        oSection1:Cell("PRODUTO"):SetValue(("cQry01")->PRODUTO)
        oSection1:Cell("DESCRIC"):SetValue(("cQry01")->DESCRIC)
        oSection1:Cell("UM"):SetValue(("cQry01")->UM)
        oSection1:Cell("REVISAO"):SetValue(("cQry01")->REVISAO)
        oSection1:Cell("CUSTOM"):SetValue(("cQry01")->CUSTOM)
        oSection1:Cell("CUSTON"):SetValue(("cQry01")->CUSTON)
        oSection1:Cell("QUANT"):SetValue(("cQry01")->QUANT)
        oSection1:Cell("QTDUSA"):SetValue(("cQry01")->QTDUSA)
        oSection1:Cell("TRT"):SetValue(("cQry01")->TRT)
        oSection1:Cell("MATERIAL"):SetValue(("cQry01")->MATERIAL)
        oSection1:Cell("DESCMAT"):SetValue(("cQry01")->DESCMAT)
        oSection1:Cell("QTDEORI"):SetValue(("cQry01")->QTDEORI)
        oSection1:Cell("QTDEMAT"):SetValue(("cQry01")->QTDEMAT)
        oSection1:Cell("REVMAT"):SetValue(("cQry01")->REVMAT)
        oSection1:Cell("CSTMMAT"):SetValue(("cQry01")->CSTMMAT)
        oSection1:Cell("CSTNMAT"):SetValue(("cQry01")->CSTNMAT)

	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


