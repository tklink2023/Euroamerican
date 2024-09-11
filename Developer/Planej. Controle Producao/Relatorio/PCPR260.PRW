#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR260()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("PCPR260",10)
    Private cTitulo 	:= OemToAnsi("Lista de Solic.Compras com Pedido de Compras")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo


    oReport:= TReport():New("PCPR260",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

    TRCell():New(oSection1,'FILIAL'		,'cQry01','Filial'     		    	,PesqPict('SG1',"G1_FILIAL")	,TamSX3("G1_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'PRODUTO'	,'cQry01','Produto'     			,PesqPict('SG1',"G1_COD")		,TamSX3("G1_COD") [1]+1,,)  
    TRCell():New(oSection1,'DESCPROD'	,'cQry01','Descricao'     			,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,)  
    TRCell():New(oSection1,'SOLIC'     ,'cQry01','N.Solicitacao' 	    	,PesqPict('SC1',"C1_NUM")		,TamSX3("C1_NUM") [1]+1,,) 
    TRCell():New(oSection1,'QTDSOL'    ,'cQry01','Qtde Solicitada' 	    	,PesqPict('SC1',"C1_QUANT")		,TamSX3("C1_QUANT") [1]+1,,) 
    TRCell():New(oSection1,'DTPRFSC'   ,'cQry01','Data Prevista' 	    	,PesqPict('SC1',"C1_DATPRF")	,TamSX3("C1_DATPRF") [1]+1,,) 
    TRCell():New(oSection1,'PEDIDO'     ,'cQry01','N.Ped.Compra' 	    	,PesqPict('SC7',"C7_NUM")		,TamSX3("C7_NUM") [1]+1,,) 
    TRCell():New(oSection1,'QTDPED'    ,'cQry01','Qtde Pedido' 	        	,PesqPict('SC7',"C7_QUANT")		,TamSX3("C7_QUANT") [1]+1,,) 
    TRCell():New(oSection1,'DTPRFPD'   ,'cQry01','Data Prevista' 	    	,PesqPict('SC7',"C7_DATPRF")	,TamSX3("C7_DATPRF") [1]+1,,) 
    TRCell():New(oSection1,'JAN'		,'cQry01','Janeiro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'FEV'		,'cQry01','Fevereiro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'MAR'		,'cQry01','Marco'  		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'ABR'		,'cQry01','Abril' 		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'MAI'		,'cQry01','Maio' 		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'JUN'		,'cQry01','Junho' 		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'JUL'		,'cQry01','Julho' 		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'AGO'		,'cQry01','Agosto' 		    	    ,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'SET'		,'cQry01','Setembro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'OUT'		,'cQry01','Outubro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'NOV'		,'cQry01','Novembro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'DEZ'		,'cQry01','Dezembro' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    
Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)

    cQuery :="Select C1_FILIAL,B1_COD,B1_DESC,C1_NUM,C1_QUANT,C1_DATPRF,ISNULL(C7_NUM,' ') C7_NUM, ISNULL(C7_QUANT,0) C7_QUANT, ISNULL(C7_DATPRF,' ') C7_DATPRF "+cEof
    cQuery +="from "+RetSqlName("SB1")+" SB1 "+cEof
    cQuery +="INNER JOIN "+RetSqlName("SC1")+" SC1 ON C1_FILIAL = '"+xFilial("SC2")+"'  AND C1_PRODUTO = B1_COD  AND SC1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="LEFT JOIN "+RetSqlName("SC7")+" SC7 ON C7_FILIAL = C1_FILIAL AND C7_PRODUTO = C1_PRODUTO AND C7_NUMSC = C1_NUM AND SC7.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="Where SB1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="and B1_TIPO BETWEEN '"+MV_PAR01+"' and '"+MV_PAR02+"' "+cEof
    cQuery +="AND C1_DATPRF BETWEEN '"+DTOS(MV_PAR03)+"' and '"+DTOS(MV_PAR04)+"' "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "C1_DATPRF", "D")
    TCSetField("cQry01", "C7_DATPRF", "D")
    
    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
             
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->C1_FILIAL)
        oSection1:Cell("PRODUTO"):SetValue(("cQry01")->B1_COD)
        oSection1:Cell("DESCPROD"):SetValue(("cQry01")->B1_DESC)
        oSection1:Cell("SOLIC"):SetValue(("cQry01")->C1_NUM)
        oSection1:Cell("QTDSOL"):SetValue(("cQry01")->C1_QUANT)
        oSection1:Cell("DTPRFSC"):SetValue(("cQry01")->C1_DATPRF ) 
        oSection1:Cell("PEDIDO"):SetValue(("cQry01")->C7_NUM)
		oSection1:Cell("QTDPED"):SetValue(("cQry01")->C7_QUANT)
        oSection1:Cell("DTPRFPD"):SetValue(("cQry01")->C7_DATPRF)      
        FMeses(("cQry01")->B1_COD)
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


Static Function FMeses(cProduto)
    Local aArea := FwGetArea()
    Local cAlias:= GetNextAlias()
    Local cQuery:= " "

   cQuery:="	SELECT FILIAL	FILIAL, "+CRLF
   cQuery+="		PRODUTO     PRODUTO, "+CRLF
   cQuery+="		ANO         ANO, "+CRLF
   cQuery+="	   JANEIRO		'JANEIRO', "+CRLF
   cQuery+="	   FEVEREIRO	'FEVEREIRO', "+CRLF
   cQuery+="	   MARCO		   'MARCO', "+CRLF
   cQuery+="	   ABRIL		   'ABRIL', "+CRLF
   cQuery+="	   MAIO			'MAIO', "+CRLF
   cQuery+="	   JUNHO		   'JUNHO', "+CRLF
   cQuery+="	   JULHO		   'JULHO', "+CRLF
   cQuery+="	   AGOSTO		'AGOSTO', "+CRLF
   cQuery+="	   SETEMBRO		'SETEMBRO', "+CRLF
   cQuery+="	   OUTUBRO		'OUTUBRO', "+CRLF
   cQuery+="	   NOVEMBRO		'NOVEMBRO', "+CRLF
   cQuery+="	   DEZEMBRO		'DEZEMBRO' "+CRLF
   cQuery+="	   FROM ( SELECT 	FILIAL as 'FILIAL',  "+CRLF
   cQuery+="	                  PRODUTO AS 'PRODUTO', "+CRLF
   cQuery+="	                  ANO AS 'ANO', "+CRLF
   cQuery+="	                  ISNULL([1],0)  AS 'JANEIRO', "+CRLF
   cQuery+="	                  ISNULL([2],0)  AS 'FEVEREIRO', "+CRLF
   cQuery+="	                  ISNULL([3],0)  AS 'MARCO', "+CRLF
   cQuery+="	                  ISNULL([4],0)  AS 'ABRIL', "+CRLF
   cQuery+="	                  ISNULL([5],0)  AS 'MAIO', "+CRLF
   cQuery+="	                  ISNULL([6],0)  AS 'JUNHO', "+CRLF
   cQuery+="	                  ISNULL([7],0)  AS 'JULHO', "+CRLF
   cQuery+="	                  ISNULL([8],0)  AS 'AGOSTO', "+CRLF
   cQuery+="	                  ISNULL([9],0)  AS 'SETEMBRO', "+CRLF
   cQuery+="	                  ISNULL([10],0) AS 'OUTUBRO', "+CRLF
   cQuery+="	                  ISNULL([11],0) AS 'NOVEMBRO', "+CRLF
   cQuery+="	                  ISNULL([12],0) AS 'DEZEMBRO'  "+CRLF
   cQuery+="	FROM ( 	SELECT G1_FILIAL FILIAL, "+CRLF
   cQuery+="			          G1_COMP PRODUTO, "+CRLF
   cQuery+="				       YEAR(C2_DATRF) ANO, "+CRLF
   cQuery+="    			       MONTH(C2_DATRF) MES, "+CRLF
   cQuery+="				       ISNULL(SUM(C2_QUJE),0) QTDE "+CRLF
   cQuery+="		 	FROM  " + RetSqlName("SG1") + " SG1 "+CRLF
   cQuery+="			INNER JOIN  " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = G1_FILIAL AND C2_PRODUTO = G1_COD AND SC2.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			WHERE SG1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			AND YEAR(C2_EMISSAO) = YEAR(GETDATE())-1  "+CRLF
   cQuery+="			AND C2_QUJE > 0 "+CRLF
   cQuery+="			GROUP BY G1_FILIAL, G1_COMP, YEAR(C2_DATRF),MONTH(C2_DATRF) ) XARQ "+CRLF
   cQuery+="	      PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT "+CRLF
   cQuery+="		   WHERE PT.ANO =  YEAR(GETDATE())-1 "+CRLF
   cQuery+="			AND PT.FILIAL = '"+xFilial("SC2")+"' "+CRLF
   cQuery+="    UNION ALL
   cQuery+="	          SELECT 	FILIAL as 'FILIAL',  "+CRLF
   cQuery+="	                  PRODUTO AS 'PRODUTO', "+CRLF
   cQuery+="	                  ANO AS 'ANO', "+CRLF
   cQuery+="	                  ISNULL([1],0)  AS 'JANEIRO', "+CRLF
   cQuery+="	                  ISNULL([2],0)  AS 'FEVEREIRO', "+CRLF
   cQuery+="	                  ISNULL([3],0)  AS 'MARCO', "+CRLF
   cQuery+="	                  ISNULL([4],0)  AS 'ABRIL', "+CRLF
   cQuery+="	                  ISNULL([5],0)  AS 'MAIO', "+CRLF
   cQuery+="	                  ISNULL([6],0)  AS 'JUNHO', "+CRLF
   cQuery+="	                  ISNULL([7],0)  AS 'JULHO', "+CRLF
   cQuery+="	                  ISNULL([8],0)  AS 'AGOSTO', "+CRLF
   cQuery+="	                  ISNULL([9],0)  AS 'SETEMBRO', "+CRLF
   cQuery+="	                  ISNULL([10],0) AS 'OUTUBRO', "+CRLF
   cQuery+="	                  ISNULL([11],0) AS 'NOVEMBRO', "+CRLF
   cQuery+="	                  ISNULL([12],0) AS 'DEZEMBRO' "+CRLF
   cQuery+="	FROM ( 	SELECT G1_FILIAL FILIAL, "+CRLF
   cQuery+="			          G1_COMP PRODUTO, "+CRLF
   cQuery+="				       YEAR(C2_DATRF) ANO, "+CRLF
   cQuery+="    			       MONTH(C2_DATRF) MES, "+CRLF
   cQuery+="				       ISNULL(SUM(C2_QUJE),0) QTDE "+CRLF
   cQuery+="		 	FROM  " + RetSqlName("SG1") + " SG1 "+CRLF
   cQuery+="			INNER JOIN  " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = G1_FILIAL AND C2_PRODUTO = G1_COD AND SC2.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			WHERE SG1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			AND YEAR(C2_EMISSAO) = YEAR(GETDATE())  "+CRLF
   cQuery+="			AND C2_QUJE > 0 "+CRLF
   cQuery+="			GROUP BY G1_FILIAL, G1_COMP, YEAR(C2_DATRF),MONTH(C2_DATRF) ) XARQ "+CRLF
   cQuery+="	      PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT "+CRLF
   cQuery+="		   WHERE PT.ANO =  YEAR(GETDATE()) "+CRLF
   cQuery+="			AND PT.FILIAL = '"+xFilial("SC2")+"' "+CRLF
   cQuery+=") ARQTMP  "+CRLF
   cQuery+=" WHERE ARQTMP.PRODUTO = '"+cProduto+"' "+CRLF      
   cQuery+=" AND ARQTMP.ANO =  YEAR(GETDATE()) "+CRLF
   cQuery+=" ORDER BY 1,2,3 "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
      RestArea(aArea)                                
      Return        
   endif


    If  Select(cAlias) > 0
                DbSelectArea(cAlias)
                DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery),cAlias, .F., .T. )

    dbSelectArea(cAlias)
    (cAlias)->( dbGotop() )
    While !(cAlias)->(Eof())   

            oSection1:Cell("JAN"):SetValue((cAlias)->JANEIRO)  
            oSection1:Cell("FEV"):SetValue((cAlias)->FEVEREIRO)  
            oSection1:Cell("MAR"):SetValue((cAlias)->MARCO)  
            oSection1:Cell("ABR"):SetValue((cAlias)->ABRIL)  
            oSection1:Cell("MAI"):SetValue((cAlias)->MAIO)  
            oSection1:Cell("JUN"):SetValue((cAlias)->JUNHO)  
            oSection1:Cell("JUL"):SetValue((cAlias)->JULHO)  
            oSection1:Cell("AGO"):SetValue((cAlias)->AGOSTO)  
            oSection1:Cell("SET"):SetValue((cAlias)->SETEMBRO)  
            oSection1:Cell("OUT"):SetValue((cAlias)->OUTUBRO)  
            oSection1:Cell("NOV"):SetValue((cAlias)->NOVEMBRO)  
            oSection1:Cell("DEZ"):SetValue((cAlias)->DEZEMBRO)   
      
       (cAlias)->( dbSkip() )
    ENDDO
    (cAlias)->( dbCloseArea() )
    FwRestArea(aArea)
Return
