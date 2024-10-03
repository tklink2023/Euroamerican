#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR250()
    Local oReport
    Private cArqTrab
    Private cPerg 		:= PADR("PCPR251",10)
    Private cTitulo 	:= OemToAnsi("Listagem da Estrutura")

    Pergunte(cPerg,.T.)	 


    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return


Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo


    oReport:= TReport():New("PCPR250",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)

    oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)

    TRCell():New(oSection1,'FILIAL'		,'cQry01','Filial'     		    	,PesqPict('SG1',"G1_FILIAL")	,TamSX3("G1_FILIAL") [1]+1,,) 
     TRCell():New(oSection1,'TIPO'   	,'cQry01','Tipo'         			,PesqPict('SB1',"B1_TIPO")		,TamSX3("B1_TIPO") [1]+1,,)  
    TRCell():New(oSection1,'PRODUTO'	,'cQry01','Produto'     			,PesqPict('SG1',"G1_COD")		,TamSX3("G1_COD") [1]+1,,)  
    TRCell():New(oSection1,'DESCPROD'	,'cQry01','Descricao'     			,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,)  
    TRCell():New(oSection1,'SEQ'		,'cQry01','Seq'     		    	,PesqPict('SG1',"G1_TRT")		,TamSX3("G1_TRT") [1]+1,,) 
    TRCell():New(oSection1,'TIPOC'   	,'cQry01','Tipo'         			,PesqPict('SB1',"B1_TIPO")		,TamSX3("B1_TIPO") [1]+1,,)  
	TRCell():New(oSection1,'COMPONENTE'	,'cQry01','Componente'     			,PesqPict('SG1',"G1_COD")		,TamSX3("G1_COD") [1]+1,,)  
    TRCell():New(oSection1,'DESCCOMP'	,'cQry01','Descricao'     			,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,)  
   
    TRCell():New(oSection1,'QTDE'		,'cQry01','Quantidade' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
	TRCell():New(oSection1,'PERDA'		,'cQry01','Perda'   		    	,PesqPict('SG1',"G1_PERDA")		,TamSX3("G1_PERDA") [1]+1,,)  
    TRCell():New(oSection1,'CUSTD'		,'cQry01','Custo Stand'  	    	,PesqPict('SB1',"B1_CUSTD")		,TamSX3("B1_CUSTD") [1]+1,,) 
    TRCell():New(oSection1,'CUSTN'		,'cQry01','Custo Net'  	        	,PesqPict('SB1',"B1_CUSTNET")	,TamSX3("B1_CUSTNET") [1]+1,,)  
    TRCell():New(oSection1,'CUSTM'		,'cQry01','Custo Medio'  	       	,PesqPict('SB9',"B9_CM1")		,TamSX3("B9_CM1") [1]+1,,)
    TRCell():New(oSection1,'PESOL'		,'cQry01','Peso Liq'  	        	,PesqPict('SB1',"B1_PESO")		,TamSX3("B1_PESO") [1]+1,,)
    TRCell():New(oSection1,'PESOB'		,'cQry01','Peso Bruto'  	       	,PesqPict('SB1',"B1_PESBRU")	,TamSX3("B1_PESBRU") [1]+1,,)
    TRCell():New(oSection1,'DIP'		,'cQry01','Peso DIP'  	        	,PesqPict('SB5',"B5_CONVDIP")	,TamSX3("B5_CONVDIP") [1]+1,,)
    TRCell():New(oSection1,'REVINI'		,'cQry01','Rev.Inicial'     		,PesqPict('SG1',"G1_REVINI")	,TamSX3("G1_REVINI") [1]+1,,)  
    TRCell():New(oSection1,'REVSG5'		,'cQry01','Rev.SG5'         		,PesqPict('SG5',"G5_REVISAO")	,TamSX3("G5_REVISAO") [1]+1,,)  
    TRCell():New(oSection1,'REVFIM'		,'cQry01','Rev.Final'     			,PesqPict('SG1',"G1_REVFIM")	,TamSX3("G1_REVFIM") [1]+1,,)  
    TRCell():New(oSection1,'REVISA'		,'cQry01','Rev. em uso'  	       	,PesqPict('SB1',"B1_REVATU")	,TamSX3("B1_REVATU") [1]+1,,)
    TRCell():New(oSection1,'UDREV'		,'cQry01','Data'        	       	,PesqPict('SB1',"B1_UREV")		,TamSX3("B1_UREV") [1]+1,,)
    //TRCell():New(oSection1,'MARGEM'		,'cQry01','Margem Prod'        		,PesqPict('SB9',"B9_CM1")		,TamSX3("B9_CM1") [1]+1,,)
    //TRCell():New(oSection1,'MARGCP'		,'cQry01','Margem Comp'       		,PesqPict('SB9',"B9_CM1")		,TamSX3("B9_CM1") [1]+1,,)
   
    TRCell():New(oSection1,'ESTOQUE'	,'cQry01','Saldo' 		        	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'EMPENHO'	,'cQry01','Empenho' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  
    TRCell():New(oSection1,'DISPON'		,'cQry01','Disponivel' 		    	,PesqPict('SG1',"G1_QUANT")		,TamSX3("G1_QUANT") [1]+1,,)  

     TRCell():New(oSection1,'STATUS'  	,'cQry01','Status'	         		,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,) 
    
Return(oReport)
                                   

Static Function ReportPrint(oReport)      
  	Local oSection1 := oReport:Section(1)
    Local cQuery    := ' '
    Local nMargem   := 0
    Local nMargComp := 0
    Local cStatus   := ' '

   cQuery :="SELECT	DISTINCT G1_FILIAL,  "+cEof 
   cQuery +="		 G1_COD,            "+cEof 
   cQuery +="		 G1_COMP,           "+cEof 
   cQuery +="		 G1_TRT,            "+cEof 
   cQuery +="		 G1_QUANT,          "+cEof 
   cQuery +="		 G1_PERDA,          "+cEof 
   cQuery +="		 G1_INI,            "+cEof 
   cQuery +="		 G5_REVISAO,         "+cEof 
   cQuery +="		 G1_FIM,            "+cEof 
   cQuery +="		 G1_REVINI,         "+cEof 
   cQuery +="		 G1_REVFIM,         "+cEof 
   cQuery +="	     SB1_A.B1_TIPO,     "+cEof 
   cQuery +=" 		 SB1_A.B1_CUSTD,    "+cEof 
   cQuery +="		 SB1_A.B1_CUSTNET,  "+cEof 
   cQuery +="		 B9_CM1,            "+cEof 
   cQuery +="	     SB1_B.B1_TIPO TIPOC,"+cEof 
   cQuery +="		 SB1_B.B1_REVATU,   "+cEof 
   cQuery +="		 SB1_B.B1_UREV,     "+cEof 
   cQuery +="		 SB1_B.B1_PESO,     "+cEof 
   cQuery +="		 SB1_B.B1_PESBRU,   "+cEof 
   cQuery +="		 ISNULL(B5_CONVDIP,0) B5_CONVDIP, "+cEof 
   cQuery +="		 CASE WHEN SB1_A.B1_MSBLQL='1' THEN 'S' ELSE '' END  BLQPRO,"+cEof 
   cQuery +="		 CASE WHEN SG5.G5_MSBLQL = '1' THEN 'S' ELSE '' END  BLQSG5,"+cEof 
   cQuery +="        SB2.B2_QATU,       "+cEof 
   cQuery +="        SB2.B2_QEMP,       "+cEof 
   cQuery +="        (SB2.B2_QATU - SB2.B2_QEMP) AS DISPONIVEL  "+cEof 
   cQuery +="FROM "+RetSqlName("SG1")+" SG1 (NOLOCK)"+cEof 
   cQuery +="LEFT JOIN "+RetSqlName("SG5")+" SG5 ON G5_FILIAL = G1_FILIAL  AND G5_PRODUTO = G1_COD AND G5_REVISAO  >= G1_REVINI AND G5_REVISAO  <= G1_REVFIM AND SG5.D_E_L_E_T_ = ' ' "+cEof 
   cQuery +="LEFT JOIN "+RetSqlName("SB5")+" SB5 (NOLOCK) ON SB5.D_E_L_E_T_ = ' ' AND B5_FILIAL = G1_FILIAL AND B5_COD = G1_COD "+cEof 
   cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1_A (NOLOCK) ON SB1_A.D_E_L_E_T_ = '' AND SB1_A.B1_FILIAL = '' AND SB1_A.B1_COD = G1_COMP "+cEof 
   cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1_B (NOLOCK) ON SB1_B.D_E_L_E_T_ = '' AND SB1_B.B1_FILIAL = '' AND SB1_B.B1_COD = G1_COD "+cEof 
   cQuery +="LEFT JOIN "+RetSqlName("SB9")+" SB9 ON B9_FILIAL = G1_FILIAL AND B9_COD = SB1_A.B1_COD AND B9_LOCAL = SB1_A.B1_LOCPAD  AND B9_DATA = (SELECT MAX(B9_DATA) FROM  "+RetSqlName("SB9")+" WHERE D_E_L_E_T_ = ' 'AND B9_COD = SB1_A.B1_COD AND B9_LOCAL = SB1_A.B1_LOCPAD AND B9_FILIAL = G1_FILIAL) "+cEof    
   cQuery +="INNER JOIN "+RetSqlName("SB2")+" SB2 (NOLOCK) ON SB2.D_E_L_E_T_ = '' AND SB2.B2_FILIAL = G1_FILIAL AND SB2.B2_COD = G1_COMP  AND SB2.B2_LOCAL = SB9.B9_LOCAL"+cEof 
   cQuery +="     WHERE SG1.D_E_L_E_T_ = ''  "+cEof 
   cQuery +="     AND G1_FILIAL      = '"+xFilial("SC2")+"' "+cEof 
   cQuery +="	  AND G1_COD BETWEEN '"+MV_PAR01+"' and '"+MV_PAR02+"' "+cEof
   cQuery +="	  and G1_REVINI >=   '"+MV_PAR04+"' "+cEof 
   cQuery +="	  and G1_REVFIM <=   '"+MV_PAR05+"' "+cEof 
   //cQuery +="     AND G5_STATUS <> '2' "+cEof 
   cQuery +="	  ORDER BY G1_COD,G1_COMP,G1_REVINI,G1_REVFIM "+cEof 


    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "G1_INI", "D")
    TCSetField("cQry01", "G1_FIM", "D")
    TCSetField("cQry01", "B1_UREV", "D")

    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        // Calculo das Margens o PA e PI e Calculo dos Componentes
           nMargem := CalcMarg(("cQry01")->G1_COD)
           nMargComp := CALCMARG(("cQry01")->G1_COMP)
        // Verifica se existe Bloqueios de PA e PI
            cStatus := IIF(("cQry01")->BLQSG5 = 'S',"Revisão da Estrutura Bloqueada ","")
            cStatus += IIF(("cQry01")->BLQPRO = 'S',"Produto da Estrutura Bloqueada ","")
          
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->G1_FILIAL)
        oSection1:Cell("SEQ"):SetValue(("cQry01")->G1_TRT)

        oSection1:Cell("TIPO"):SetValue(("cQry01")->B1_TIPO ) 
        oSection1:Cell("PRODUTO"):SetValue(("cQry01")->G1_COD)

        oSection1:Cell("TIPOC"):SetValue(("cQry01")->TIPOC ) 
        oSection1:Cell("DESCPROD"):SetValue( Posicione("SB1",1,xFilial("SB1")+("cQry01")->G1_COD,"B1_DESC") )
        oSection1:Cell("COMPONENTE"):SetValue(("cQry01")->G1_COMP)
        oSection1:Cell("DESCCOMP"):SetValue( Posicione("SB1",1,xFilial("SB1")+("cQry01")->G1_COMP,"B1_DESC") )
       
        oSection1:Cell("QTDE"):SetValue(("cQry01")->G1_QUANT)
		oSection1:Cell("PERDA"):SetValue(("cQry01")->G1_PERDA)
        oSection1:Cell("CUSTD"):SetValue(("cQry01")->B1_CUSTD)
        oSection1:Cell("CUSTN"):SetValue(("cQry01")->B1_CUSTNET)
        oSection1:Cell("CUSTM"):SetValue(("cQry01")->B9_CM1)

        oSection1:Cell("REVISA"):SetValue(("cQry01")->B1_REVATU)
        oSection1:Cell("UDREV"):SetValue(("cQry01")->B1_UREV)
        oSection1:Cell("PESOL"):SetValue(("cQry01")->B1_PESO)
        oSection1:Cell("PESOB"):SetValue(("cQry01")->B1_PESBRU)
        oSection1:Cell("DIP"):SetValue(("cQry01")->B5_CONVDIP)

        oSection1:Cell("REVINI"):SetValue(("cQry01")->G1_REVINI)
        oSection1:Cell("REVSG5"):SetValue(("cQry01")->G5_REVISAO)
        oSection1:Cell("REVFIM"):SetValue(("cQry01")->G1_REVFIM) 
        //oSection1:Cell("MARGEM"):SetValue(nMargem) 
        //oSection1:Cell("MARGCP"):SetValue(nMargComp) 
        oSection1:Cell("STATUS"):SetValue( cStatus )
        oSection1:Cell("ESTOQUE"):SetValue(("cQry01")->B2_QATU) 
        oSection1:Cell("EMPENHO"):SetValue(("cQry01")->B2_QEMP) 
        oSection1:Cell("DISPON"):SetValue(("cQry01")->DISPONIVEL) 

        
        cStatus := " "
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


Static Function CALCMARG(cProduto)
    Local aArea := FwGetArea()
    Local cAlias:= GetNextAlias()
    Local cQuery:= " "
    Local nMargem:= 0

    cQuery :="SELECT  SD2.D2_COD, "+cEof
    cQuery +="		Sum(SD2.D2_QUANT) QUANTIDADE_VENDIDA, "+cEof
    cQuery +="		ISNULL(Sum(SD1.D1_QUANT),0) QUANTIDADE_DEVOLUCAO, "+cEof
    cQuery +="		Sum((SD2.D2_VALBRUT-SD2.D2_VALIPI-SD2.D2_VALICM-SD2.D2_VALIMP5-SD2.D2_VALIMP6-SD2.D2_DESPESA-SD2.D2_VALFRE-SD2.D2_DESCON-SD2.D2_SEGURO-SD2.D2_ICMSRET)) VALOR_SAIDA, "+cEof
    cQuery +="		ISNULL(Sum((SD1.D1_TOTAL-SD1.D1_VALDESC-SD1.D1_VALIPI-SD1.D1_DESPESA-SD1.D1_VALFRE-SD1.D1_SEGURO-SD1.D1_ICMSRET)),0) VALOR_DEVOLUCAO, "+cEof
    cQuery +="		sum(SD2.D2_CUSTO1) CUSTO_SAIDA, "+cEof
    cQuery +="		ISNULL(SUM(SD1.D1_CUSTO),0)  CUSTO_DEVOLUCAO, "+cEof
    cQuery +="		ISNULL(SUM(B1_CUSTD*D2_QUANT),0) CUSTO_STAND "+cEof

    cQuery +="FROM "+RetSqlName("SD2")+" SD2 "+cEof
    cQuery +="left  join "+RetSqlName("SD1")+" SD1 on D1_FILIAL = D2_FILIAL AND D1_NFORI = SD2.D2_DOC AND D1_SERIORI = SD2.D2_SERIE AND D1_COD = SD2.D2_COD AND D1_TIPO = 'D' and SD1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="Inner join "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,2) AND F4_CODIGO = SD2.D2_TES AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="inner join "+RetSqlName("SA1")+" SA1 on A1_FILIAL = SD2.D2_FILIAL AND A1_COD = SD2.D2_CLIENTE AND A1_LOJA = SD2.D2_LOJA  AND SA1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="inner join "+RetSqlName("SB1")+" SB1 on SB1.B1_COD = SD2.D2_COD and SB1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="Where SD2.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="AND D2_FILIAL = '"+xFilial("SD2")+"'  "+cEof
    cQuery +="AND D2_COD = '"+cProduto+"' "+cEof
    cQuery +="AND D2_EMISSAO BETWEEN '"+DTOS(MV_PAR06)+"'  AND '"+DTOS(MV_PAR07)+"'  "+cEof
    cQuery +="GROUP BY D2_COD" +cEof
    cQuery +="ORDER BY D2_COD" +cEof

    If  Select(cAlias) > 0
                DbSelectArea(cAlias)
                DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery),cAlias, .F., .T. )

    dbSelectArea(cAlias)
    (cAlias)->( dbGotop() )
    While !(cAlias)->(Eof())   
       nMargem := ROUND(((cAlias)->CUSTO_SAIDA / (cAlias)->VALOR_SAIDA)*100,2)
       (cAlias)->( dbSkip() )
    ENDDO
    (cAlias)->( dbCloseArea() )
    FwRestArea(aArea)
Return(nMargem)
