#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#DEFINE cEof  CHAR(13)+CHAR(10)

User Function COMR002()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("COMR002",10)
    Private cTitulo 	:= OemToAnsi("Projecao de compras")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo
    oReport:= TReport():New("COMR002",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

    TRCell():New(oSection1,'FILIAL'		,'cQry01','Filial'     		    	,PesqPict('SG1',"G1_FILIAL")	,TamSX3("G1_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'PRODUTO'	,'cQry01','Produto'     			,PesqPict('SG1',"G1_COD")		,TamSX3("G1_COD") [1]+1,,)  
    TRCell():New(oSection1,'DESCPROD'	,'cQry01','Descricao'     			,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,)  
    TRCell():New(oSection1,'LOCAL'		,'cQry01','Armazem'    		    	,PesqPict('SB2',"B2_LOCAL")		,TamSX3("B2_LOCAL") [1]+1,,) 
    TRCell():New(oSection1,'SALDO'   	,'cQry01','Saldo'         			,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)  
    TRCell():New(oSection1,'EMPENHO'   	,'cQry01','Empenho'        			,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)  
    TRCell():New(oSection1,'DISPONIVEL'	,'cQry01','Disponivel'     			,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)      
    TRCell():New(oSection1,'MEDIA'   	,'cQry01','Media'         			,PesqPict('SB2',"B2_QATU")		,TamSX3("B2_QATU") [1]+1,,)  

    TRCell():New(oSection1,'OUT'		,'cQry01','Outubro'    		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'NOV'		,'cQry01','Novembro'   		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'DEZ'		,'cQry01','Dezembro'   		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'JAN'		,'cQry01','Janeiro'   		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'FEV'		,'cQry01','Feveiro'    		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'MAR'		,'cQry01','Marco'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'ABR'		,'cQry01','Abril'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'MAI'		,'cQry01','Maio'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'JUN'		,'cQry01','Junho'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'JUL'		,'cQry01','julho'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'AGO'		,'cQry01','Agosto'     		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'SET'		,'cQry01','Setembro'   		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  

    
Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	Local oSection1 := oReport:Section(1)
    Local cQuery    := ' '

        cQuery :="Select	FILIAL AS 'FILIAL', "+cEof 
        cQuery +="		PRODUTO			AS 'PRODUTO',"+cEof 
        cQuery +="		DESCRICAO		AS 'DESCRICAO',"+cEof 
        cQuery +="		ARMAZEM         AS 'ARMAZEM',"+cEof 
        cQuery +="		SUM(ROUND(SALDO,2))			AS 'SALDO', "+cEof 
        cQuery +="		SUM(ROUND(EMPENHO,2))			AS 'EMPENHO', "+cEof 
        cQuery +="		SUM(ROUND(DISPONIVEL,2))		AS 'DISPONIVEL', "+cEof 
        cQuery +="		SUM(ROUND(MEDIA,2))			AS 'MEDIA', "+cEof 
        cQuery +="		SUM(ISNULL([10],0))	AS 'OUT',"+cEof 
        cQuery +="		SUM(ISNULL([11],0))	AS 'NOV',"+cEof 
        cQuery +="		SUM(ISNULL([12],0))	AS 'DEZ',"+cEof 
        cQuery +="		SUM(ISNULL([1],0))	AS 'JAN',"+cEof 
        cQuery +="		SUM(ISNULL([2],0))	AS 'FEV',"+cEof 
        cQuery +="		SUM(ISNULL([3],0))	AS 'MAR',"+cEof 
        cQuery +="		SUM(ISNULL([4],0))	AS 'ABR',"+cEof 
        cQuery +="		SUM(ISNULL([5],0))	AS 'MAI',"+cEof 
        cQuery +="		SUM(ISNULL([6],0))	AS 'JUN',"+cEof 
        cQuery +="		SUM(ISNULL([7],0))	AS 'JUL',"+cEof 
        cQuery +="		SUM(ISNULL([8],0))	AS 'AGO',"+cEof 
        cQuery +="		SUM(ISNULL([9],0))	AS 'SET' "+cEof 
        cQuery +="      	FROM ( "+cEof 
        cQuery +="				Select	B2_FILIAL FILIAL,"+cEof 
        cQuery +="						B2_COD PRODUTO,"+cEof 
        cQuery +="						B2_LOCAL ARMAZEM,"+cEof 
        cQuery +="						B1_DESC DESCRICAO,"+cEof 
        cQuery +="						SUM(B2_QATU) SALDO, "+cEof 
        cQuery +="						SUM(B2_QEMP) EMPENHO, "+cEof 
        cQuery +="						SUM((B2_QATU - B2_QEMP)) DISPONIVEL, "+cEof 
        cQuery +="						SUM(ISNULL(B3_MEDIA,0)) MEDIA, "+cEof 
        cQuery +="						YEAR(C7_DATPRF) ANO,"+cEof 
        cQuery +="    					MONTH(C7_DATPRF) MES,"+cEof 
        cQuery +="						ISNULL(SUM(C7_QUANT),0) QTDE"+cEof 
        cQuery +="						from "+RetSqlName("SB2")+"  SB2"+cEof 
        cQuery +="						INNER JOIN "+RetSqlName("SB1")+"  SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' '"+cEof 
        cQuery +="						LEFT JOIN "+RetSqlName("SB3")+"  SB3 ON B3_FILIAL = B2_FILIAL AND B3_COD = B2_COD AND SB3.D_E_L_E_T_ = ' '"+cEof 
        cQuery +="						LEFT JOIN "+RetSqlName("SC7")+"  SC7 ON C7_FILIAL = B2_FILIAL AND C7_PRODUTO = B2_COD AND  C7_DATPRF >=  GETDATE() AND SC7.D_E_L_E_T_ = ' '"+cEof 
        cQuery +="						Where SB2.D_E_L_E_T_ = ' '"+cEof 
        cQuery +="						AND B2_FILIAL =  '"+xFilial("SC2")+"' "+cEof 
        cQuery +="						AND B2_LOCAL = '"+MV_PAR01+"'"+cEof 
        cQuery +="					GROUP BY B2_FILIAL, B2_COD,B2_LOCAL,B1_DESC,YEAR(C7_DATPRF),MONTH(C7_DATPRF) ) XARQ"+cEof 
        cQuery +="		           PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT"+cEof 
        cQuery +="				   WHERE PT.ANO BETWEEN YEAR(GETDATE()) AND YEAR(GETDATE())+1"+cEof 
        cQuery +="				   GROUP BY FILIAL,PRODUTO,DESCRICAO,ARMAZEM"+cEof 
        cQuery +="				   ORDER BY 1,2"+cEof 


    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )

    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
          
        oSection1:Cell("FILIAL"):SetValue( ("cQry01")->FILIAL)
        oSection1:Cell("PRODUTO"):SetValue( ("cQry01")->PRODUTO)
        oSection1:Cell("DESCPROD"):SetValue( ("cQry01")->DESCRICAO )
        oSection1:Cell("LOCAL"):SetValue( ("cQry01")->ARMAZEM)
        oSection1:Cell("SALDO"):SetValue( ("cQry01")->SALDO )
        oSection1:Cell("EMPENHO"):SetValue(("cQry01")->EMPENHO)
		oSection1:Cell("DISPONIVEL"):SetValue(("cQry01")->DISPONIVEL)
        oSection1:Cell("MEDIA"):SetValue(("cQry01")->MEDIA)
        oSection1:Cell("OUT"):SetValue(("cQry01")->OUT)
        oSection1:Cell("NOV"):SetValue(("cQry01")->NOV)
        oSection1:Cell("DEZ"):SetValue(("cQry01")->DEZ)
        oSection1:Cell("JAN"):SetValue(("cQry01")->JAN)
        oSection1:Cell("FEV"):SetValue(("cQry01")->FEV)
        oSection1:Cell("MAR"):SetValue(("cQry01")->MAR)
        oSection1:Cell("ABR"):SetValue(("cQry01")->ABR)
        oSection1:Cell("MAI"):SetValue(("cQry01")->MAI)
        oSection1:Cell("JUN"):SetValue(("cQry01")->JUN)
        oSection1:Cell("JUL"):SetValue(("cQry01")->JUL)
        oSection1:Cell("AGO"):SetValue(("cQry01")->AGO)
        oSection1:Cell("SET"):SetValue(("cQry01")->SET)

	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 
