#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

User Function PCPR070()
    Local oReport
    Private cPerg 		:= PADR("PCPR070",10)
    Private cTitulo 	:= OemToAnsi("Relação dos Produtos Barrados")
    Pergunte(cPerg,.T.)	 
    oReport 			:= ReportDef()
    oReport:PrintDialog()
Return


Static Function ReportDef() 
    Local oReport 
    Local oBreak
    Local oSection
    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo

    oReport:= TReport():New("PCPR070",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:PrintSHeader(.T.)
    oReport:ShowParamPage(.F.)

    oSection := TRSection():New(oReport,"",{"cQry01"},aOrdem)
    oSection:SetHeaderPage()

    TRCell():New(oSection,'PRODUTO'	    ,'cQry01', GetSx3Cache("ZB_COD","X3_TITULO")     	   	    ,PesqPict('SZB',"ZB_COD")	,TamSX3("ZB_COD") [1]+1,,) 
    TRCell():New(oSection,'DESCPROD'    ,'cQry01', GetSx3Cache("ZB_DESC","X3_TITULO")     		   	,PesqPict('SZB',"ZB_DESC")	,TamSX3("ZB_DESC") [1]+1,,) 
    TRCell():New(oSection,'CLASSE'		,'cQry01', GetSx3Cache("ZB_CLASSE","X3_TITULO")    		   	,PesqPict('SZB',"ZB_TIPO")  ,TamSX3("ZB_TIPO") [1]+1,,) 
    TRCell():New(oSection,'TIPO'		,'cQry01', GetSx3Cache("ZB_TIPO","X3_TITULO")    		   	,PesqPict('SZB',"ZB_CLASSE"),TamSX3("ZB_CLASSE") [1]+1,,) 
    TRCell():New(oSection,'STATUS'		,'cQry01', GetSx3Cache("ZB_STATUS","X3_TITULO")    		   	,PesqPict('SZB',"ZB_STATUS"),TamSX3("ZB_STATUS") [1]+1,,) 
    TRCell():New(oSection,'NOME'		,'cQry01', GetSx3Cache("ZB_NOME","X3_TITULO")     		   	,PesqPict('SZB',"ZB_NOME")	,TamSX3("ZB_NOME") [1]+1,,) 
    TRCell():New(oSection,'QUANT'		,'cQry01', GetSx3Cache("ZB_QTD","X3_TITULO")     		   	,PesqPict('SZB',"ZB_QTD")	,TamSX3("ZB_QTD") [1]+1,,) 
    TRCell():New(oSection,'SALDO'		,'cQry01', GetSx3Cache("ZB_SALDO","X3_TITULO")     		   	,PesqPict('SZB',"ZB_SALDO")	,TamSX3("ZB_SALDO") [1]+1,,) 
    TRCell():New(oSection,'Total'		,'cQry01', GetSx3Cache("ZB_TOTAL","X3_TITULO")     		   	,PesqPict('SZB',"ZB_TOTAL")	,TamSX3("ZB_TOTAL") [1]+1,,) 
    TRCell():New(oSection,'Disponivel'  ,'cQry01', GetSx3Cache("ZB_QTAPU","X3_TITULO")     	   	    ,PesqPict('SZB',"ZB_QTAPU")	,TamSX3("ZB_QTAPU") [1]+1,,) 

    oBreak := TRBreak():New(oSection,{|| ZB_COD },"Sub Total por Produto ", .F.)	
    TRFunction():New(oSection:Cell("QUANT")	,NIL,"SUM", oBreak, ,"@E 999,999.99" ,   ,.F., .F.)
    
Return(oReport)

Static Function ReportPrint(oReport)   

    Local cQuery    := ' '
    Local oSection := oReport:Section(1) 

    //oReport:onPageBreak( { || oReport:SkipLine(), oSection1:PrintLine(), oReport:SkipLine(), oReport:ThinLine() })

    cQuery :="Select ZB_COD,ZB_DESC,ZB_LOCAL,ZB_NOME,ZB_QTD,ZB_SALDO,ZB_TOTAL,ZB_QTAPU,ZB_STATUS,ZB_CLASSE,ZB_TIPO  "+cEof
    cQuery +="From "+RetSqlName("SZB")+" SZB  "+cEof
    cQuery +="Where SZB.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="AND RTRIM(ZB_PERIODO) = '"+MV_PAR01+"'  "+cEof
    cQuery +="order by ZB_COD,ZB_STATUS,ZB_NOME  "+cEof

    If  Select("cQry01") > 0
            DbSelectArea("cQry01")
            DbCloseArea()
    Endif

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), "cQry01" , .F., .T. )

    oSection:Init()

    oReport:SetMeter(("cQry01")->(LastRec()))


    dbSelectArea("cQry01")
    ("cQry01")->( dbGotop() )
    While !oReport:Cancel() .And. !("cQry01")->(Eof())   
        oReport:IncMeter()

        If oReport:Cancel()
            Exit
        EndIf        

        oSection:Cell("PRODUTO"):SetValue ((("cQry01")->ZB_COD))
        oSection:Cell("DESCPROD"):SetValue((("cQry01")->ZB_DESC))	
        oSection:Cell("CLASSE"):SetValue((("cQry01")->ZB_CLASSE))	
        oSection:Cell("TIPO"):SetValue((("cQry01")->ZB_TIPO))	
        oSection:Cell("STATUS"):SetValue((("cQry01")->ZB_STATUS))	
        oSection:Cell("NOME"):SetValue((("cQry01")->ZB_NOME))			  		
        oSection:Cell("QUANT"):SetValue((("cQry01")->ZB_QTD))			  		
        oSection:Cell("SALDO"):SetValue((("cQry01")->ZB_SALDO))	
        oSection:Cell("Total"):SetValue((("cQry01")->ZB_TOTAL))	               		  		
        oSection:Cell("Disponivel"):SetValue((("cQry01")->ZB_QTAPU)) 
        oSection:PrintLine()
        dbSelectArea("cQry01")
        dbSkip()

    EndDo
   
    oSection:Finish()
    oReport:ThinLine() 
    oReport:SkipLine() 
   
Return NIL 

user Function PRINTGRAPH()

Local oReport as Object
Local oSection as Object

//Classe TREPORT
oReport := TReport():New('EXEMPLO',"Status",/*cPerg*/,{|oReport|ReportPrtG(oReport,oSection)})

//Seção 1 
oSection := TRSection():New(oReport,'Status')

//Definição das colunas de impressão da seção 1
TRCell():New(oSection, "STATUS" , "TRB", "Status", /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection, "QUANT"  , "TRB", "Quantidade" , /*Picture*/, /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)

//Definção da collection
oColl:=TRCollection():New("Status", "SUM", /*oBreak*/,"Total Por Status",/*cPicture*/, /*uFormula*/ oSection:Cell("STATUS"), /*.lEndSection.*/ .F.,/*.lEndReport.*/ .T., /*oParent*/ oSection, /*bCondition*/,/*uContent*/ oSection:Cell("STATUS") ) 

oReport:PrintGraphic()
oReport:PrintDialog()

Return

Static Function ReportPrtG(oReport,oSection)

#IFDEF TOP

    Local cAlias := "TRB"

    BEGIN REPORT QUERY oSection

        BeginSql alias cAlias
            Select ZB_STATUS AS STATUS
                ,sum(ZB_QTD) AS QUANT
            From %table:SZB%  SZB
            Where SZB.D_E_L_E_T_ = ' '
            AND RTRIM(ZB_PERIODO) = '202410'
            GROUP BY ZB_STATUS
            order by ZB_STATUS
        EndSql

    END REPORT QUERY oSection 

    oSection:aCollection[1]:SetGraphic(4,"STATUS")
    oSection:PrintGraphic()
    oSection:Print()

#ENDIF

return
