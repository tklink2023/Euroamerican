#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"

/*/{Protheus.doc} PCPM070
description
@type function
@version 1.0
@author Paulo Lenzi
@since 07/11/2024
@return variant, return_description
/*/
User Function PCPM070()
    Local aArea := FwgetArea()
    Local aFields := {}
    
    Local aRet  	:=	{}
    Local aPergs   := {}
    Local dDataDe  := FirstDate(Date())
    Local dDataAt  := LastDate(Date())
    
    Local oDlgMark    as Object 
    Local aSize         := MsAdvSize()
    local bSair   as block
    Local bGrava  as block
    Local BFiltra as Block
    Local bGraf   as Block
    Local bTela   as Block
    Local bSolic  as Block
    Local bF04    as Block
    Local bF05    as Block
    Local bF06    as Block
    //Local bF10    as Block
    Local bRl01   as Block
    Local bRl02   as Block
    local oArea   as object
    local oBtn1   as object
    local oBtn2   as object
    local oBtn3   as object
    local oBtn4   as object
    local oBtn5   as object
    local oBtn6   as object
    local oBtn7   as object
    local oBtn8   as object
    local oBtn9   as object
    local oBtn10   as object
  
    local oCenterPanel as object
    local oLayout as object
    local oPanel  as object
    local oOption as object
    local oSide   as object
 
    Private ctmp    := "A"+GetNextAlias()
    Private oTable  := FWTemporaryTable():New( ctmp ) 
    Private nPosCli := 01 ,nPosPed := 02 ,nPosItem := 03 ,nPosPro := 04 ,nPosDesc := 05 ,nPosLocal := 06 ,nPosQtd := 07 ,nPosSld := 08 ,nPosTot := 09 ,nPosApu := 10 ,nPossta := 11,NPOSDEL := 12

    Private aBrowse     := {}
    Private oBrowse    := FwBrowse():New()
    Private dDataIni
    Private dDataFim

    bSair   := {|| Iif(MsgYesNo('Deseja realmente sair?','Gerenciamento'),(oDlgMark:End()),NIL)}
    bGrava := {|| PM070FIL() }
    bGraf  := {|| PM070RPT() }

    aAdd(aFields,{"TMP_FILIAL"	, GetSx3Cache("C2_FILIAL","X3_TIPO")		,tamSx3("C2_FILIAL")[1]	    ,tamSx3("C2_FILIAL")[2]})
    aAdd(aFields,{"TMP_NOME"	   , GetSx3Cache("A1_NOME","X3_TIPO")		   ,tamSx3("A1_NOME")[1]	    ,tamSx3("A1_NOME")[2]})
    aAdd(aFields,{"TMP_NUM"  		, GetSx3Cache("C6_NUM","X3_TIPO")		   ,tamSx3("C6_NUM")[1]	       ,tamSx3("C6_NUM")[2]})
    aAdd(aFields,{"TMP_ITEM"  	, GetSx3Cache("C6_ITEM","X3_TIPO")		   ,tamSx3("C6_ITEM")[1]	    ,tamSx3("C6_ITEM")[2]})
    aAdd(aFields,{"TMP_COD"  		, GetSx3Cache("C6_PRODUTO","X3_TIPO")	   ,tamSx3("C6_PRODUTO")[1]	 ,tamSx3("C6_PRODUTO")[2]})
    aAdd(aFields,{"TMP_DESC"  	, GetSx3Cache("B1_DESC","X3_TIPO")		   ,tamSx3("B1_DESC")[1]	    ,tamSx3("B1_DESC")[2]})
    aAdd(aFields,{"TMP_LOCAL"  	, GetSx3Cache("C6_LOCAL","X3_TIPO")		   ,tamSx3("C6_LOCAL")[1]	    ,tamSx3("C6_LOCAL")[2]})
    aAdd(aFields,{"TMP_QTD"  		, GetSx3Cache("C6_QTDVEN","X3_TIPO")	   ,tamSx3("C6_QTDVEN")[1]	    ,tamSx3("C6_QTDVEN")[2]})
    aAdd(aFields,{"TMP_SALDO"  	, GetSx3Cache("B2_QATU","X3_TIPO")		   ,tamSx3("B2_QATU")[1]	    ,tamSx3("B2_QATU")[2]})
    aAdd(aFields,{"TMP_TOTAL"  	, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
    aAdd(aFields,{"TMP_QTAPU"  	, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
    aAdd(aFields,{"TMP_STATUS"  	, GetSx3Cache("A1_NREDUZ","X3_TIPO")	   ,tamSx3("A1_NREDUZ")[1]	    ,tamSx3("A1_NREDUZ")[2]})

    oTable:SetFields( aFields )
	 oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_NUM","TMP_COD"} )
 	 oTable:Create()  

	 aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Data Até", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
 
    If ParamBox(aPergs, "Informe os parâmetros",aRet)  
      dDataIni := aRet[1]
		dDataFim := aRet[2]
    Else
		MsgAlert("Encerrado")
		Return
	 EndIf
   
   MsgRun("Criando tabela de dados. Aguarde.....", "Processando", {|| RunProc() })

    dbSelectArea(ctmp)
    (ctmp)->( dbgotop() )
    While (ctmp)->( !Eof() )
        aAdd( aBrowse, {        (ctmp)->TMP_NOME,;
                                (ctmp)->TMP_NUM,;
                                (ctmp)->TMP_ITEM,;
                                (ctmp)->TMP_COD,;
                                (ctmp)->TMP_DESC,;
                                (ctmp)->TMP_LOCAL,;
                                (ctmp)->TMP_QTD,;
                                (ctmp)->TMP_SALDO,;
                                (ctmp)->TMP_TOTAL,;
                                (ctmp)->TMP_QTAPU,;
                                (ctmp)->TMP_STATUS,;
                                .F.})
        (ctmp)->(dbSkip() )
    EndDo
    
    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 

   DEFINE MSDIALOG oDlgMark FROM 0,0 TO nHeight,nWidth TITLE "" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

    oPanel := TPanel():New(0,0,,oDlgMark,,,,,,15,0,.F.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oArea := FWArea():New(000,000,nHeight/2,nWidth,oPanel,0)
    oArea:CreateBorder(2)

    oArea:AddSideBar ( 12, 1, "oSide" )
    oSide := oArea:GetSideBar("oSide")

    oArea:AddWindow ( 100, 100, "cId1" ,"Ações", 3 , 2,oSide, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oOption")
    oOption := oArea:GetPanel("oOption")

    oBtn1 := TButton():New( 1,202,'Observações' ,oOption, bGrava,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn1:Align := CONTROL_ALIGN_TOP

    oBtn8 := TButton():New( 1,202,'xxx' ,oOption, BFiltra,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn8:Align := CONTROL_ALIGN_TOP    

    oBtn4 := TButton():New( 1,202,'xxx' ,oOption, bSolic,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn4:Align := CONTROL_ALIGN_TOP

    oBtn2 := TButton():New( 1,202,'xx' ,oOption, bTela,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_TOP    

    oBtn5 := TButton():New( 1,202,'xx' ,oOption, bF04,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn5:Align := CONTROL_ALIGN_TOP

    oBtn3 := TButton():New( 1,202,'Relatorio' ,oOption, bGraf,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn3:Align := CONTROL_ALIGN_TOP

    oBtn6 := TButton():New( 1,202,'xx' ,oOption, bF05,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn6:Align := CONTROL_ALIGN_TOP

    oBtn7 := TButton():New( 1,202,'xx' ,oOption, bF06,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn7:Align := CONTROL_ALIGN_TOP    

    oBtn9 := TButton():New( 1,202,'xx' ,oOption, bRl01,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn9:Align := CONTROL_ALIGN_TOP    

    oBtn10 := TButton():New( 1,202,'xx' ,oOption, bRl02,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn10:Align := CONTROL_ALIGN_TOP    

    oBtn2 := TButton():New( 1,202,'Sair'    ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_BOTTOM

    oArea:AddLayout ( "Default" )
    oLayout := oArea:GetLayout ( "Default" )

    oArea:AddWindow ( 100, 100, "cId2","Estruturas", 3 , 3,oLayout, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oCenterPanel")
    oCenterPanel := oArea:GetPanel("oCenterPanel")

     if oBrowse != nil
        oBrowse:DeActivate()
    endif
    
    // Função de telas 
    
    oBrowse:SetOwner(oCenterPanel)
    oBrowse:setDataArray()
    oBrowse:setArray( aBrowse )
    oBrowse:disableConfig()
    oBrowse:disableReport()
    //oBrowse:AddStatusColumns( { || BrwStatus() }, { || BrwLegend() } )
    oBrowse:setInsert( .T. ) 
    oBrowse:Setdelete(.T.,{ || PM070DEL() } ) 
    oBrowse:SetBlkBackColor({|| IIf(aBrowse[oBrowse:nAt,nPosDel]=.T. , CLR_LIGHTGRAY , Nil )})

    oBrowse:addColumn({"Cliente" , {||aBrowse[oBrowse:nAt,nPosCli]}, GetSx3Cache("A1_NOME","X3_TIPO"), pesqPict("SA1","A1_NOME") , 1, tamSx3("A1_NOME")[1] ,, .T. ,, .F.,, "XA1_NOME",, .F., .T.,, "XA1_NOME"})
    oBrowse:addColumn({"Pedido"  , {||aBrowse[oBrowse:nAt,nPosPed]}, GetSx3Cache("C6_NUM","X3_TIPO"), pesqPict("SC6","C6_NUM") , 1, tamSx3("C6_NUM")[1] ,, .T. ,, .F.,, "XC6_NUM",, .F., .T.,, "XC6_NUM"})
    oBrowse:addColumn({"item"    , {||aBrowse[oBrowse:nAt,nPosItem]}, GetSx3Cache("C6_ITEM","X3_TIPO"), pesqPict("SC6","C6_ITEM") , 1, tamSx3("C6_ITEM")[1] ,, .T. ,, .F.,, "XC6_ITEM",, .F., .T.,, "XC6_ITEM"})
    oBrowse:addColumn({"Produto" , {||aBrowse[oBrowse:nAt,nPosPro]}, GetSx3Cache("C6_PRODUTO","X3_TIPO"), pesqPict("SC6","C6_PRODUTO") , 1, tamSx3("C6_PRODUTO")[1] ,, .T. ,, .F.,, "XC6_PRODUTO",, .F., .T.,, "XC6_PRODUTO"})
    oBrowse:addColumn({"Descrição", {||aBrowse[oBrowse:nAt,nPosDesc]}, GetSx3Cache("B1_DESC","X3_TIPO"), pesqPict("SB1","B1_DESC") , 1, tamSx3("B1_DESC")[1] ,, .T. ,, .F.,, "XB1_DESC",, .F., .T.,, "XB1_DESC"})    
    oBrowse:addColumn({"Local"    , {||aBrowse[oBrowse:nAt,nPosLocal]}, GetSx3Cache("C6_LOCAL","X3_TIPO"), pesqPict("SC6","C6_LOCAL") , 1, tamSx3("C6_LOCAL")[1] ,, .T. ,, .F.,, "XC6_LOCAL",, .F., .T.,, "XC6_LOCAL"})
    oBrowse:addColumn({"Quantidade", {||aBrowse[oBrowse:nAt,nPosQtd]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 1, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XC6_QTDVEN",, .F., .T.,, "XC6_QTDVEN"})
    oBrowse:addColumn({"Saldo"    , {||aBrowse[oBrowse:nAt,nPosSld]}, GetSx3Cache("B2_QATU","X3_TIPO"), pesqPict("SB2","B2_QATU") , 1, tamSx3("B2_QATU")[1] ,, .T. ,, .F.,, "XB2_QATU",, .F., .T.,, "XB2_QATU"})
    oBrowse:addColumn({"Total_Qtd", {||aBrowse[oBrowse:nAt,nPosTot]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 1, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XTOTALQTD",, .F., .T.,, "XTOTALQTD"})
    oBrowse:addColumn({"Apurados" , {||aBrowse[oBrowse:nAt,nPosApu]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 1, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XAPURADO",, .F., .T.,, "XAPURADO"})
    oBrowse:addColumn({"Status"   , {||aBrowse[oBrowse:nAt,nPossta]}, GetSx3Cache("A1_NREDUZ","X3_TIPO"), pesqPict("SA1","A1_NREDUZ") , 1, tamSx3("A1_NREDUZ")[1] ,, .T. ,, .F.,, "XSTATUS",, .F., .T.,, "XSTATUS"})

    oBrowse:acolumns[nPossta]:ledit     := .T.
    oBrowse:acolumns[nPossta]:cReadVar:= 'aBrowse[oBrowse:nAt,nPossta]'

    //oBrowse:setAfterAddLine( { || posIncLine()} )
    oBrowse:setEditCell( .T.,{ || PM070VLD() } )
   oBrowse:Refresh(.T.)	
   oBrowse:Activate()

   ACTIVATE MSDIALOG oDlgMark CENTERED

   oTable:Delete()
   FwRestArea(aArea)
Return

Static Function RunProc()
   Local aArea := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "B"+getNextAlias()
   Local nTotal   := 0

   cQuery:="Select SA1.A1_NOME     NOME "+CRLF
   cQuery+="		,SC6.C6_NUM       PEDIDO "+CRLF
   cQuery+="		,SC6.C6_ITEM      ITEM "+CRLF
   cQuery+="		,SC6.C6_PRODUTO   PRODUTO "+CRLF
   cQuery+="		,SB1.B1_DESC      DESCRICAO "+CRLF
   cQuery+="		,SC6.C6_LOCAL     ARMAZEM "+CRLF
   cQuery+="		,SC6.C6_QTDVEN    QUANT "+CRLF
   cQuery+="		,SB2.B2_QATU      SALDO "+CRLF
   cQuery+="from " + RetSqlName("SC6") + " SC6 "+CRLF
   cQuery+="INNER JOIN " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="INNER JOIN " + RetSqlName("SA1") + " SA1 ON A1_FILIAL = C6_FILIAL AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="LEFT JOIN  " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = C6_FILIAL AND B2_LOCAL = C6_LOCAL AND B2_COD = SC6.C6_PRODUTO AND SB2.D_E_L_E_T_= ' ' "+CRLF
   cQuery+="Where SC6.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="AND SC6.C6_FILIAL = '"+FWxFilial("SC6")+"'  "+CRLF
   cQuery+="AND SC6.C6_NOTA = ' ' "+CRLF
   cQuery+="AND SC5.C5_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"' "+CRLF
   cQuery+="ORDER BY SC6.C6_NUM "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return
   endif

   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
         nTotal := PCPM70QTD((cAlias)->PRODUTO,(cAlias)->ARMAZEM)
         dbselectarea(ctmp)
         (ctmp)->( dbSetOrder(1))
         if (ctmp)->( !dbSeek(FWxFilial("SC6")+(cAlias)->PEDIDO+(cAlias)->PRODUTO,.T.))

          IF RecLock(ctmp,.T.)
            TMP_FILIAL := FWxFilial("SC6")
            TMP_NOME   := (cAlias)->NOME
            TMP_NUM    := (cAlias)->PEDIDO
            TMP_ITEM   := (cAlias)->ITEM
            TMP_COD    := (cAlias)->PRODUTO
            TMP_DESC   := (cAlias)->DESCRICAO
            TMP_LOCAL  := (cAlias)->ARMAZEM
            TMP_QTD    := (cAlias)->QUANT
            TMP_SALDO  := (cAlias)->SALDO
            TMP_TOTAL  := nTotal
            TMP_QTAPU  := (cAlias)->SALDO - nTotal
            TMP_STATUS := IIF(TMP_QTAPU<0,'Bloqueado','Liberado')

            (ctmp)->( MsUnlock() )
          endif
         Endif   
         (cAlias)->( dbSkip() )
   EndDo

   (calias)->(DbCloseArea()) 

Return

/*/{Protheus.doc} PCPM70QTD
description
@type function
@version 1.0
@author Paulo Lenzi
@since 07/11/2024
@param cProduto, character, param_description
@param cLocal, character, param_description
@return variant, return_description
/*/
Static Function PCPM70QTD(cProduto,cLocal)
    Local aArea := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "C"+getNextAlias()
   Local nRetorno:= 0
	cQuery:="Select SUM(C6_QTDVEN) QTDE From " + RetSqlName("SC6") + " SC6 "+CRLF
   cQuery+=" Inner Join " + RetSqlName("SC5") + " SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C5_EMISSAO BETWEEN '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"'  AND SC5.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			Where SC6.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="			AND C6_FILIAL = '"+FWxFilial("SC6")+"' "+CRLF
   cQuery+="			AND C6_NOTA = ' ' "+CRLF
   cQuery+="			AND C6_PRODUTO = '"+cProduto+"' "+CRLF
   cQuery+="			AND C6_LOCAL = '"+cLocal+"'  "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return(nRetorno)
   endif

   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
        nRetorno := (cAlias)->QTDE
       (cAlias)->( dbSkip() )
   EndDo

   (calias)->(DbCloseArea()) 
      
    FwRestArea(aArea)
Return(nRetorno)

Static Function PM070DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrowse:nAt
     Local lSit        := oBrowse:LDELETE

     if lSit 
         if MsgYesNo("Deseja excluir a linha desse produto","Atenção")
            aBrowse[nLinha][nPosDel] := .T.
            aDel(aBrowse, nLinha)
            aSize(aBrowse, Len(adespes) - 1)
         endif   
     Endif    

     oBrowse:Reset()
     oBrowse:setArray(aBrowse)	// Forço o Browse a ler os novos valores informados.
     oBrowse:GoTop()

     oBrowse:Refresh(.T.)	
     FWRestArea(cArea)
RETURN


static function PM070VLD()
   Local nPos:= oBrowse:ColPos()
   // Informações do Produto
   IF nPos = nPossta  // Posiciona na coluna Local ( Armazem ) dispara os calculos 
      adespes[oBrowse:nAt][nPossta] := ' '
   ENDIF
Return(.T.)

Static Function PM070FIL()
  Local aArea := FwgetArea()
  Local aRet  	  :=	{}
  Local aPergs    := {}
  Local cProduto  := Space(TamSX3("B1_COD")[01])
  Local nTipo    := 1
  Local cObserv   := ' '
  Local aArray    := {"1=Bloqueado","2=Liberado","3=Ag. Envase","4=Ag. Estoque"}

aAdd(aPergs, {1, "Produto De" ,  cProduto,  "", ".T.", "SB1", ".T.", 80,  .F.})
aAdd(aPergs, {2, "Tipo"       ,  nTipo, aArray,     122, ".T.", .F.})
 
 If ParamBox(aPergs, "Informe os parâmetros",aRet)  
      cProduto := aRet[1]
		cObserv  := Substring(aArray[val(aRet[2])],3,10)
 Else
		MsgAlert("Encerrado")
		Return
 EndIf
   
  MsgRun("Atualizando a  tabela de dados. Aguarde.....", "Processando", {|| RunAlter(cProduto,cObserv) })
  oBrowse:Refresh(.T.)	
  FWRestArea(aArea)

Return


Static Function RunAlter(cProduto,cObserv)
Local aArea := FwgetArea()
Local lRet  := .F.

   dbselectArea(ctmp)
   (ctmp)->( dbGoTop() )
   While (ctmp)->( !Eof())
       IF TMP_COD = cProduto
          IF RecLock(ctmp,.F.)
            TMP_STATUS := cObserv
            (ctmp)->( MsUnlock() )
            lRet  := .T.
          endif
      Endif   
      (ctmp)->( dbSkip() )
   EndDo
   IF !lRet
      MsgAlert("Não encontrou movimentacao...")
   else
    dbSelectArea(ctmp)
    (ctmp)->( dbgotop() )
    While (ctmp)->( !Eof() )
        aAdd( aBrowse, {        (ctmp)->TMP_NOME,;
                                (ctmp)->TMP_NUM,;
                                (ctmp)->TMP_ITEM,;
                                (ctmp)->TMP_COD,;
                                (ctmp)->TMP_DESC,;
                                (ctmp)->TMP_LOCAL,;
                                (ctmp)->TMP_QTD,;
                                (ctmp)->TMP_SALDO,;
                                (ctmp)->TMP_TOTAL,;
                                (ctmp)->TMP_QTAPU,;
                                (ctmp)->TMP_STATUS,;
                                .F.})
        (ctmp)->(dbSkip() )
    EndDo
   ENDIF

FWRestArea(aArea)
Return

Static Function  PM070RPT()

Return
