#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR310()
    Local oReport
     Private cArqTrab
    Private cPerg 		:= PADR("PCPR310",10)
    Private cTitulo 	:= OemToAnsi("Relacao dos Produtos com Lotes")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    oReport:= TReport():New("PCPR310",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'CODIGO'			,'cQry01','Codigo'     				,PesqPict('SB1',"B1_COD")		,TamSX3("B1_COD") [1]+1,,) 
    TRCell():New(oSection1,'Descpro'		,'cQry01','Descricao'  				,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,) 
    TRCell():New(oSection1,'TIPO'		   	,'cQry01','Tipo'     				,PesqPict('SB1',"B1_TIPO")		,TamSX3("B1_TIPO") [1]+1,,) 
    TRCell():New(oSection1,'LOCAL'		   	,'cQry01','Local'     				,PesqPict('SB1',"B1_LOCPAD")	,TamSX3("B1_LOCPAD") [1]+1,,) 
    TRCell():New(oSection1,'UM'		    	,'cQry01','U.M'     				,PesqPict('SB1',"B1_UM")		,TamSX3("B1_UM") [1]+1,,) 
    TRCell():New(oSection1,'SLDATU'	    	,'cQry01','Saldo Est'  				,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,) 
    TRCell():New(oSection1,'LOCALIZ'	   	,'cQry01','Endereco'  				,PesqPict('SBF',"BF_LOCALIZ")	,TamSX3("BF_LOCALIZ") [1]+1,,) 
    TRCell():New(oSection1,'SLDEND'	    	,'cQry01','Saldo Local' 			,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)
    TRCell():New(oSection1,'LOTE'	       	,'cQry01','Lote'    				,PesqPict('SB8',"B8_LOTECTL")	,TamSX3("B8_LOTECTL") [1]+1,,) 
    TRCell():New(oSection1,'EMISSAO'       	,'cQry01','Emissao'    				,PesqPict('SB8',"B8_DATA")		,TamSX3("B8_DATA") [1]+1,,) 
    TRCell():New(oSection1,'VALIDADE'      	,'cQry01','Validade'    			,PesqPict('SB8',"B8_DTVALID")	,TamSX3("B8_DTVALID") [1]+1,,)
    TRCell():New(oSection1,'SLDLOTE'	  	,'cQry01','Saldo Lote' 		    	,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)
    TRCell():New(oSection1,'BLOQUEIO'  	    ,'cQry01','Docto Bloq' 		    	,PesqPict('SDD',"DD_DOC")		,TamSX3("DD_DOC") [1]+1,,)
    TRCell():New(oSection1,'MOTIVO'  	    ,'cQry01','Motivo' 		        	,PesqPict('SX5',"X5_DESCRI")	,TamSX3("X5_DESCRI") [1]+1,,)

Return(oReport)

Static Function ReportPrint(oReport)      
 	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)

   cQuery :="SELECT B1_COD, B1_DESC, B1_TIPO,B1_LOCPAD,B1_UM,B2_FILIAL,B2_QATU,BF_LOCALIZ,BF_LOTECTL, BF_QUANT,B8_DATA, B8_DTVALID,B8_SALDO,ISNULL(DD_DOC,'') DD_DOC,ISNULL(X5_DESCRI,'') X5_DESCRI  "+cEof
   cQuery +="FROM SB1100 SB1 "+cEof
   cQuery +="INNER JOIN  "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' '  "+cEof
   cQuery +="INNER JOIN  "+RetSqlName("SBF")+" SBF ON BF_FILIAL = B2_FILIAL AND BF_PRODUTO = B1_COD AND BF_LOCAL = B2_LOCAL AND SBF.D_E_L_E_T_ = ' '  "+cEof
   cQuery +="INNER JOIN  "+RetSqlName("SB8")+" SB8 ON B8_FILIAL = B2_FILIAL AND B8_PRODUTO = B1_COD AND B8_LOCAL = B2_LOCAL AND B8_LOTECTL = BF_LOTECTL AND SB8.D_E_L_E_T_ = ' '  "+cEof
   cQuery +="LEFT JOIN "+RetSqlName("SDD")+" SDD ON DD_FILIAL = B2_FILIAL AND DD_PRODUTO = B1_COD AND DD_LOCAL = B2_LOCAL AND DD_LOTECTL = BF_LOTECTL AND SDD.D_E_L_E_T_ = ' ' "+cEof
   cQuery +="LEFT JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = SUBSTRING(B2_FILIAL,1,2) AND X5_TABELA = 'E1' AND X5_CHAVE = DD_MOTIVO AND SX5.D_E_L_E_T_ = ' ' "+cEof
   cQuery +="WHERE SB1.D_E_L_E_T_ = ' '  "+cEof
   cQuery +="AND B1_TIPO = '"+MV_PAR01+"'  "+cEof
   cQuery +="AND B1_MSBLQL <> '1'  "+cEof
   cQuery +="AND B1_LOCALIZ = 'S'  "+cEof
   cQuery +="AND B1_RASTRO = 'L'  "+cEof
   cQuery +="AND B1_COD BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'  "+cEof
   cQuery +="ORDER BY  B1_COD "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "B8_DATA", "D")
    TCSetField("cQry01", "B8_DTVALID", "D")
  
    
    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        oReport:IncMeter()
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->B2_FILIAL)
        oSection1:Cell("CODIGO"):SetValue(("cQry01")->B1_COD)	
        oSection1:Cell("Descpro"):SetValue(("cQry01")->B1_DESC)	
        oSection1:Cell("TIPO"):SetValue(("cQry01")->B1_TIPO)		
        oSection1:Cell("LOCAL"):SetValue(("cQry01")->B1_LOCPAD)		
        oSection1:Cell("UM"):SetValue(("cQry01")->B1_UM)		
        oSection1:Cell("SLDATU"):SetValue(("cQry01")->B2_QATU)	
        oSection1:Cell("LOCALIZ"):SetValue(("cQry01")->BF_LOCALIZ)	
        oSection1:Cell("SLDEND"):SetValue(("cQry01")->BF_QUANT)	
        oSection1:Cell("LOTE"):SetValue(("cQry01")->BF_LOTECTL)	    
        oSection1:Cell("EMISSAO"):SetValue(("cQry01")->B8_DATA)   
        oSection1:Cell("VALIDADE"):SetValue(("cQry01")->B8_DTVALID)  
        oSection1:Cell("SLDLOTE"):SetValue(("cQry01")->B8_SALDO)	
        oSection1:Cell("BLOQUEIO"):SetValue(("cQry01")->DD_DOC)	
        oSection1:Cell("MOTIVO"):SetValue(("cQry01")->X5_DESCRI)	
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


