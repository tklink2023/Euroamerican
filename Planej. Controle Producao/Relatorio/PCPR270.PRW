#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR270()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("PCPR270",10)
    Private cTitulo 	:= OemToAnsi("Relacao de Ordem Producao por produto")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo


    oReport:= TReport():New("PCPR270",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

    TRCell():New(oSection1,'C2_FILIAL'		,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 	
    TRCell():New(oSection1,'C2_PRODUTO'		,'cQry01','Codigo'     		    	,PesqPict('SC2',"C2_PRODUTO")	,TamSX3("C2_PRODUTO") [1]+1,,) 	
    TRCell():New(oSection1,'B1_DESC'		,'cQry01','Descricao'  		    	,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,) 	
    TRCell():New(oSection1,'C2_NUM'	    	,'cQry01','Lote'     		    	,PesqPict('SC2',"C2_NUM")		,TamSX3("C2_NUM") [1]+1,,) 	
    TRCell():New(oSection1,'C2_ITEM'		,'cQry01','Item'     		    	,PesqPict('SC2',"C2_ITEM")		,TamSX3("C2_ITEM") [1]+1,,) 	
    TRCell():New(oSection1,'C2_SEQUEN'		,'cQry01','Sequencia'           	,PesqPict('SC2',"C2_SEQUEN")	,TamSX3("C2_QUANT") [1]+1,,) 	
    TRCell():New(oSection1,'C2_QUANT'		,'cQry01','Qtd.Prevista'        	,PesqPict('SC2',"C2_QUANT")	    ,TamSX3("C2_FILIAL") [1]+1,,) 	
    TRCell():New(oSection1,'C2_QUJE'		,'cQry01','Qtd.Utilizada'       	,PesqPict('SC2',"C2_QUJE")		,TamSX3("C2_QUJE") [1]+1,,) 	
    TRCell():New(oSection1,'C2_REVISAO'		,'cQry01','Revisao' 		      	,PesqPict('SC2',"C2_REVISAO")	,TamSX3("C2_REVISAO") [1]+1,,) 
    TRCell():New(oSection1,'C2_DATRF'		,'cQry01','Data Encerra' 	      	,PesqPict('SC2',"C2_DATRF")		,TamSX3("C2_DATRF") [1]+1,,) 

Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)



    cQuery :="Select	C2_FILIAL,  "+cEof
	cQuery +="	        C2_PRODUTO, "+cEof
    cQuery +="		    B1_DESC ,   "+cEof
    cQuery +="		    C2_NUM ,    "+cEof
    cQuery +="		    C2_ITEM ,   "+cEof
    cQuery +="		    C2_SEQUEN,  "+cEof
    cQuery +="		    C2_QUANT,   "+cEof
    cQuery +="		    C2_QUJE,    "+cEof
    cQuery +="		    C2_REVISAO, "+cEof
    cQuery +="		    C2_DATRF    "+cEof
    cQuery +="From "+RetSqlName("SC2")+" SC2  "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="Where SC2.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="AND C2_FILIAL = '"+xFilial("SC2")+"'  "+cEof
    cQuery +="AND C2_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' and '"+Dtos(MV_PAR02)+"' "+cEof
    cQuery +="ORDER BY C2_PRODUTO  "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "C2_DATRF", "D")
    
    
    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
             
        oSection1:Cell("C2_FILIAL"):SetValue(("cQry01")->C2_FILIAL)
        oSection1:Cell("C2_PRODUTO"):SetValue(("cQry01")->C2_PRODUTO)
        oSection1:Cell("B1_DESC"):SetValue(("cQry01")->B1_DESC)
        oSection1:Cell("C2_NUM"):SetValue(("cQry01")->C2_NUM)	
        oSection1:Cell("C2_ITEM"):SetValue(("cQry01")->C2_ITEM)
        oSection1:Cell("C2_SEQUEN"):SetValue(("cQry01")->C2_SEQUEN)
        oSection1:Cell("C2_QUANT"):SetValue(("cQry01")->C2_QUANT)
        oSection1:Cell("C2_QUJE"):SetValue(("cQry01")->C2_QUJE)	
        oSection1:Cell("C2_REVISAO"):SetValue(("cQry01")->C2_REVISAO)
        oSection1:Cell("C2_DATRF"):SetValue(("cQry01")->C2_DATRF)

	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


