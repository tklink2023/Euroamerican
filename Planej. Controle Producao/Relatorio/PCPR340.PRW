#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR340()
    Local oReport
    Local aRet  	:= 	{}
	Local aPergs	:= 	{}
    Local cProd01   := Space(15)
    Local cProd02   := Space(15)
	Local aSays		:= {}
	Local aButtons	:= {}    
    lOCAL lOk

    Private cMvPar01
	Private cMvPar02
    Private cTitulo := OemToAnsi("Relacao das Revisões")
    Private cPerg   := ""

    aAdd( aPergs ,{1,"Do Produto"		    , cProd01   		, PesqPict("SD4", "D4_OP"),'.T.',"SB1"   	,'.T.'	,50, .T.})
    aAdd( aPergs ,{1,"Ate o Produto"		, cProd02   		, PesqPict("SD4", "D4_OP"),'.T.',"SB1"   	,'.T.'	,50, .T.})
     
    If ParamBox(aPergs ,cTitulo,aRet)     
		cMvPar01 := aRet[1]
		cMvPar02 := aRet[2]
	Else
		MsgAlert("Encerrado")
		Return
	EndIf	

    AAdd(aSays,"Geração do Relatorio conforme os parametros selecionados")
	AAdd(aSays,"Produto de :"+cMvPar01+ " ate: "+cMvPar02  )
	AAdd(aSays,"Filial : "+cFilant)

    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

    FormBatch(cTitulo, aSays, aButtons)

    If !lOk
        Return
    EndIf
   oReport:= ReportDef()
   oReport:PrintDialog()
Return

Static Function ReportDef() 
    Local oReport   := Nil
    Local oSection1 := Nil 
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo

    oReport:= TReport():New("PCPR340",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.

    oSection1 := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    TRCell():New(oSection1,'FILIAL'			,'cQry01','Filial'     		    	,PesqPict('SC2',"C2_FILIAL")	,TamSX3("C2_FILIAL") [1]+1,,) 
    TRCell():New(oSection1,'CODIGO'			,'cQry01','Codigo'     				,PesqPict('SB1',"B1_COD")		,TamSX3("B1_COD") [1]+1,,) 
    TRCell():New(oSection1,'Descpro'		,'cQry01','Descricao'  				,PesqPict('SB1',"B1_DESC")		,TamSX3("B1_DESC") [1]+1,,) 
    TRCell():New(oSection1,'UM'	           	,'cQry01','UM'      				,PesqPict('SB1',"B1_UM")		,TamSX3("B1_UM") [1]+1,,) 
    TRCell():New(oSection1,'LOCAL'	       	,'cQry01','Local'      				,PesqPict('SB1',"B1_LOCPAD")	,TamSX3("B1_LOCPAD") [1]+1,,) 
    TRCell():New(oSection1,'TIPO'		   	,'cQry01','Tipo'     				,PesqPict('SB1',"B1_TIPO")		,TamSX3("B1_TIPO") [1]+1,,) 
    TRCell():New(oSection1,'REVISA'		   	,'cQry01','Revisao'    				,PesqPict('SG5',"G5_REVISAO")	,TamSX3("G5_REVISAO") [1]+1,,) 
    TRCell():New(oSection1,'CODUSR'		   	,'cQry01','ID' 	                    ,	 							, 							,,) 
    TRCell():New(oSection1,'KEYUSR'		   	,'cQry01','Usuario'	                ,	 							, 							,,) 
    TRCell():New(oSection1,'DATA'	    	,'cQry01','Data'     				,PesqPict('SG5',"G5_DATAREV")	,TamSX3("G5_DATAREV") [1]+1,,) 

Return(oReport)

Static Function ReportPrint(oReport)      
 	
    Local cQuery    := ' '
    Private oSection1 := oReport:Section(1)

   cQuery :="Select G5_FILIAL, G5_PRODUTO, B1_DESC, B1_UM, B1_TIPO,B1_LOCPAD, G5_REVISAO, G5_USER, USR_NOME, G5_DATAREV "+cEof
   cQuery +="from  "+RetSqlName("SG5")+" SG5 "+cEof
   cQuery +="INNER JOIN  "+RetSqlName("SB1")+" SB1 ON B1_COD = G5_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+cEof
   cQuery +="INNER JOIN SYS_USR ON USR_ID = G5_USER "+cEof
   cQuery +="WHERE SG5.D_E_L_E_T_ = ' ' "+cEof
   cQuery +="AND G5_FILIAL  =  '"+xFilial("SG5")+"'"+cEof
   cQuery +="AND G5_PRODUTO BETWEEN '"+cMvPar01+"' AND '"+cMvPar02+"'  "+cEof
   cQuery +="ORDER BY 1,2 "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )
    TCSetField("cQry01", "G5_REVISAO", "D")
   
    
    oReport:SetMeter(("cQry01")->(LastRec()))
    oSection1:Init()

    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        oReport:IncMeter()
        oSection1:Cell("FILIAL"):SetValue(("cQry01")->G5_FILIAL)
        oSection1:Cell("CODIGO"):SetValue(("cQry01")->G5_PRODUTO)	
        oSection1:Cell("Descpro"):SetValue(("cQry01")->B1_DESC)	
        oSection1:Cell("TIPO"):SetValue(("cQry01")->B1_TIPO)		
        oSection1:Cell("LOCAL"):SetValue(("cQry01")->B1_LOCPAD)		
        oSection1:Cell("UM"):SetValue(("cQry01")->B1_UM)	
        oSection1:Cell("REVISA"):SetValue(("cQry01")->G5_REVISAO)	
        oSection1:Cell("CODUSR"):SetValue(("cQry01")->G5_USER)	
        oSection1:Cell("KEYUSR"):SetValue(("cQry01")->USR_NOME)	
        oSection1:Cell("DATA"):SetValue(("cQry01")->G5_DATAREV)	    
	    oSection1:PrintLine()
	    oReport:IncMeter()
        dbSelectArea("cQry01")
        dbSkip()
    EndDo
    oSection1:Finish()
    oReport:ThinLine() 

Return NIL 


