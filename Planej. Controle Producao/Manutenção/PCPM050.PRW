#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

#DEFINE cTitulo   "Lançamentos de Programação PCP"

/*/{Protheus.doc} PCPM050
description Programa de manutenção dos Lançamentos de Programação
@type function User
@version 1
@author Paulo Lenzi
@since 01/02/2024
@return variant, return_description
/*/
user function PCPM050()

    local bSair   as block
    Local bGrava  as block
    Local BvldPro as Block
    Local bGraf   as Block
    Local bTela   as Block
    Local bSolic  as Block

    Local bF04    as Block
    Local bF05    as Block
    Local bF06    as Block
    Local bF10    as Block

    Local bRl01   as Block
    //Local bRl02   as Block

    Local bMsg    as Block
    local nHeight as numeric
    local nWidth  as numeric

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
    //local oBtn10   as object
    local oBtn11   as object

    local oCenterPanel as object
    local oDlg    as object
    local oLayout as object
    local oPanel  as object
    local oOption as object
    local oSide   as object

    Local cAlias  := GetNextAlias()
     
    Private oBrowse := FwBrowse():New()
    Private nPosPro:= 01, nPosLoc:= 02, nPosSLD:= 03, nPosQEP:= 04, nPosDPN:= 05, nPosCmm:= 06, nPosProj := 07, nPosCmD:= 08
    Private nPosEAD:= 09, nPosEDD:= 10, nPosESD:= 11, nPosESQ:= 12,nPosSMQ := 13, nPosSMD := 14 ,nPosDUR:= 15,nPosEnt:= 16,nPosDel := 17
    Private nMvPar01 := 0, dMvPar02 := Ctod("/ / "), dMvPar03 := cTod(" / / ")
    Private aDespes:= {}
    Private nConsumoDia := 0.0000
    Private nEstDispDia := nEstSegDia := nEstSimDia := 0

     // Botões do painel lateral da tela
    bSair   := {|| Iif(MsgYesNo('Deseja realmente sair do gerenciamento?','Gerenciamento'),(oDlg:End()),NIL)}
    bGrava  := {|| Iif(MsgYesNo('Grava Lançamentos?','Programação'),(PM050GRAVA(),oDlg:End()),NIL)} 
 
    BvldPro := {|| PM050CPO(adespes[oBrowse:nAt][nPosPro]) }
    bGraf   := {|| U_FM050LINE(adespes[oBrowse:nAt][nPosPro]) }
    bTela   := {|| U_PM050Tela(adespes[oBrowse:nAt][nPosPro],dMvPar02,dMvPar03) }
    bSolic  := {|| U_PM050MARK(adespes[oBrowse:nAt][nPosPro]) }
     
 
    bF04    := {|| PM050CONS() }
    bF05    := {|| U_PM050USO(adespes[oBrowse:nAt][nPosPro] )}
    bF06    := {|| U_PM050SC2(adespes[oBrowse:nAt][nPosPro] )} 

    bF10    := {|| U_PM050QBR(adespes[oBrowse:nAt][nPosPro],adespes[oBrowse:nAt][nPosLoc],adespes[oBrowse:nAt][nPosCmD],adespes[oBrowse:nAt][nPosEDD],adespes[oBrowse:nAt][nPosESD],adespes[oBrowse:nAt][nPosDUR])}
    
    bRl01   := {|| U_PCPR200() }
    //bRl02   := {|| U_PCPR230() }

    bMsg    := {|| MsgAlert("Aguardando Desenvolvimento","ATENCAO") }

    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    // Call do parametro de pergunta
    If Pergunte("PCPM050",.T.)
		Set Key VK_F12 To
		SetKey( VK_F12, { || pergunte("PCPM050",.T.) } )
      nMvPar01 := MV_PAR01
      dMvPar02 := MV_PAR02
      dMvPar03 := MV_PAR03
	EndIf
    // Carga nos Arrays

    BeginSQL Alias cAlias
		SELECT *  	
		FROM %Table:SZJ% SZJ
		WHERE SZJ.%NotDel%
		and ZJ_FILIAL =  %xFilial:SZJ%
      and ZJ_KEYUSER =  %Exp:__cUserID% 
	    ORDER BY ZJ_PRODUTO
    EndSQL
     If (cAlias)->(!EOF())
        While (cAlias)->(!EOF())
                aAdd(aDespes,{  (cAlias)->ZJ_PRODUTO,;                  // Produto
                                (cAlias)->ZJ_LOCAL,;                    // Local
                                (cAlias)->ZJ_SALDO,;
                                (cAlias)->ZJ_QEMP,;
                                (cAlias)->ZJ_DISPON,;
                                (cAlias)->ZJ_CONSUM,;
                                (cAlias)->ZJ_PROJEC,;
                                (cAlias)->ZJ_CONSUD,;
                                (cAlias)->ZJ_STOKATU,;
                                (cAlias)->ZJ_STOKDAY,;
                                (cAlias)->ZJ_SEGDIA,;
                                (cAlias)->ZJ_SEGQTD,;
                                (cAlias)->ZJ_SIMQTD,;
                                (cAlias)->ZJ_SIMDIA,;
                                Dtoc(Stod((cAlias)->ZJ_DURA)),;
                                (cAlias)->ZJ_ENTREGA,;
                                .F. })    
                               
              (cAlias)->(dbSkip() )
        ENDDO
     else
        aDespes:=  {{space( tamSx3( "ZJ_PRODUTO" )[1]),;  // Codigo do produto
                      space( tamSx3( "ZJ_LOCAL" )[1]),;       // Local
                      0.0000,;                                // Saldo Atual
                      0.0000,;                                // Empenhos
                      0.0000,;                                // Disponivel
                      0.0000,;                                // Consumo Mes
                      0.0000,;                                // Consumo Dia
                      0.0000,;                                // Projecao
                      0.0000,;                                // Estoque Atual em dias
                      0.0000,;                                // Estoque Disponivel em dias
                      0.0000,;                                // Estoque de Segurança em Dias (Digitado)
                      0.0000,;                                // Estoque de Segurança em Quantidade
                      0.0000,;                                // Simulacao em Quantidade
                      0.0000,;                                // Simulacao em Dias
                      0.0000,;                                // Duracao em Dias
                      space( tamSx3( "ZJ_ENTREGA" )[1]),;    // Entregas
                      .F. }}    

     Endif
     (cAlias)->(DbCloseArea())

    // Tela Principal 
    DEFINE MSDIALOG oDlg FROM 0,0 TO nHeight,nWidth TITLE "" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

    oPanel := TPanel():New(0,0,,oDlg,,,,,,15,0,.F.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oArea := FWArea():New(000,000,nHeight/2,nWidth,oPanel,0)
    oArea:CreateBorder(2)

    oArea:AddSideBar ( 12, 1, "oSide" )
    oSide := oArea:GetSideBar("oSide")

    oArea:AddWindow ( 100, 100, "cId1" ,"Ações", 3 , 2,oSide, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oOption")
    oOption := oArea:GetPanel("oOption")

    oBtn1 := TButton():New( 1,202,'Gravar Lançamentos' ,oOption, bGrava,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn1:Align := CONTROL_ALIGN_TOP

    oBtn8 := TButton():New( 1,202,'Simulação' ,oOption, bF10,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn8:Align := CONTROL_ALIGN_TOP    

    oBtn4 := TButton():New( 1,202,'Gera Solicitação Compra' ,oOption, bSolic,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn4:Align := CONTROL_ALIGN_TOP

    oBtn2 := TButton():New( 1,202,'Posicao de Compras' ,oOption, bTela,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_TOP    

    oBtn5 := TButton():New( 1,202,'Consumo Medio' ,oOption, bF04,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn5:Align := CONTROL_ALIGN_TOP

    oBtn3 := TButton():New( 1,202,'Grafico Consumo' ,oOption, bGraf,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn3:Align := CONTROL_ALIGN_TOP

    oBtn6 := TButton():New( 1,202,'Onde é Usado' ,oOption, bF05,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn6:Align := CONTROL_ALIGN_TOP

    oBtn7 := TButton():New( 1,202,'Consumo Real Ops' ,oOption, bF06,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn7:Align := CONTROL_ALIGN_TOP    

    oBtn9 := TButton():New( 1,202,'Relação de Produtos parados' ,oOption, bRl01,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn9:Align := CONTROL_ALIGN_TOP    

    //oBtn10 := TButton():New( 1,202,'Relação de Ops por Custo' ,oOption, bRl02,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    //oBtn10:Align := CONTROL_ALIGN_TOP    

    oBtn11 := TButton():New( 1,202,'Sair'    ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn11:Align := CONTROL_ALIGN_BOTTOM

    oArea:AddLayout ( "Default" )
    oLayout := oArea:GetLayout ( "Default" )

    oArea:AddWindow ( 100, 100, "cId2","Lançamento", 3 , 3,oLayout, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oCenterPanel")
    oCenterPanel := oArea:GetPanel("oCenterPanel")

     if oBrowse != nil
        oBrowse:DeActivate()
    endif
    
    // Função de telas 
    
    oBrowse:SetOwner(oCenterPanel)
    oBrowse:setDataArray()
    oBrowse:setArray( aDespes )
    oBrowse:disableConfig()
    oBrowse:disableReport()
    oBrowse:setInsert( .T. ) 
    oBrowse:Setdelete(.T.,{ || PM050DEL() } ) 
    oBrowse:SetChange({ || IIF(PM050VLCP(),PM050GRAVA(),Alert("Linha acima com campos obrigatorios")) })
    oBrowse:SetBlkBackColor({|| IIf(aDespes[oBrowse:nAt,nPosdel] , CLR_HMAGENTA , Nil )})
   
   // Colunas da tela
   oBrowse:addColumn({"Produto", {||aDespes[oBrowse:nAt,nPosPro]}, GetSx3Cache("ZJ_PRODUTO","X3_TIPO"), pesqPict("SZJ","ZJ_PRODUTO") , 1, tamSx3("ZJ_PRODUTO")[1] ,, .T. ,BvldPro, .F.,, "XZJ_PRODUTO",, .F., .T.,, "XZJ_PRODUTO"})

   oBrowse:addColumn({"Local", {||aDespes[oBrowse:nAt,nPosLoc]}, GetSx3Cache("ZJ_LOCAL","X3_TIPO"), pesqPict("SZJ","ZJ_LOCAL")   , 1, tamSx3("ZJ_LOCAL")[1],, .T. , , .F.,, "XZJ_LOCAL",, .F., .T.,, "XZJ_LOCAL"})

   oBrowse:addColumn({"Saldo", {||aDespes[oBrowse:nAt,nPosSLD]}, GetSx3Cache("ZJ_SALDO","X3_TIPO"), pesqPict("SZJ","ZJ_SALDO")   , 1, tamSx3("ZJ_SALDO")[1] ,tamSx3("ZJ_SALDO")[2], .T. , , .F.,, "XZJ_SALDO",, .F., .T.,, "XZJ_SALDO"})

   oBrowse:addColumn({"Empenho", {||aDespes[oBrowse:nAt,nPosQEP]}, GetSx3Cache("ZJ_QEMP","X3_TIPO"), pesqPict("SZJ","ZJ_QEMP")   , 1, tamSx3("ZJ_QEMP")[1] ,tamSx3("ZJ_QEMP")[2], .T. , , .F.,, "XZJ_QEMP",, .F., .T.,, "XZJ_QEMP"})

   oBrowse:addColumn({"Disponivel", {||aDespes[oBrowse:nAt,nPosDPN]}, GetSx3Cache("ZJ_DISPON","X3_TIPO"), pesqPict("SZJ","ZJ_DISPON")   , 1, tamSx3("ZJ_DISPON")[1] ,tamSx3("ZJ_DISPON")[2], .T. , , .F.,, "XZJ_DISPON",, .F., .T.,, "XZJ_DISPON"})

   oBrowse:addColumn({FWX3Titulo("ZJ_CONSUM"), {||aDespes[oBrowse:nAt,nPosCmm]}, GetSx3Cache("ZJ_CONSUM","X3_TIPO"), pesqPict("SZJ","ZJ_CONSUM")   , 1, tamSx3("ZJ_CONSUM")[1] ,tamSx3("ZJ_CONSUM")[2], .T. , , .F.,, "XZJ_CONSUM",, .F., .T.,, "XZJ_CONSUM"})

   oBrowse:addColumn({FWX3Titulo("ZJ_PROJEC"), {||aDespes[oBrowse:nAt,nPosProj]}, GetSx3Cache("ZJ_PROJEC","X3_TIPO"), pesqPict("SZJ","ZJ_PROJEC")   , 1, tamSx3("ZJ_PROJEC")[1] ,tamSx3("ZJ_PROJEC")[2], .T. , , .F.,, "XZJ_PROJEC",, .F., .T.,, "XZJ_PROJEC"})

   oBrowse:addColumn({FWX3Titulo("ZJ_CONSUD"), {||aDespes[oBrowse:nAt,nPosCmD]}, GetSx3Cache("ZJ_CONSUD","X3_TIPO"), pesqPict("SZJ","ZJ_CONSUD")   , 1, tamSx3("ZJ_CONSUD")[1] ,tamSx3("ZJ_CONSUD")[2], .T. , , .F.,, "XZJ_CONSUD",, .F., .T.,, "XZJ_CONSUD"})
  
   oBrowse:addColumn({FWX3Titulo("ZJ_STOKATU"), {||aDespes[oBrowse:nAt,nPosEAD]}, GetSx3Cache("ZJ_STOKATU","X3_TIPO"), pesqPict("SZJ","ZJ_STOKATU")   , 1, tamSx3("ZJ_STOKATU")[1] ,tamSx3("ZJ_STOKATU")[2], .T. , , .F.,, "XZJ_STOKATU",, .F., .T.,, "XZJ_STOKATU"})

   oBrowse:addColumn({FWX3Titulo("ZJ_STOKDAY"), {||aDespes[oBrowse:nAt,nPosEDD]}, GetSx3Cache("ZJ_STOKDAY","X3_TIPO"), pesqPict("SZJ","ZJ_STOKDAY")   , 1, tamSx3("ZJ_STOKDAY")[1] ,tamSx3("ZJ_STOKDAY")[2], .T. , , .F.,, "XZJ_STOKDAY",, .F., .T.,, "XZJ_STOKDAY"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SEGDIA"), {||aDespes[oBrowse:nAt,nPosESD]}, GetSx3Cache("ZJ_SEGDIA","X3_TIPO"), pesqPict("SZJ","ZJ_SEGDIA")   , 1, tamSx3("ZJ_SEGDIA")[1] ,tamSx3("ZJ_SEGDIA")[2], .T. , , .F.,, "XZJ_SEGDIA",, .F., .T.,, "XZJ_SEGDIA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SEGQTD"), {||aDespes[oBrowse:nAt,nPosESQ]}, GetSx3Cache("ZJ_SEGQTD","X3_TIPO"), pesqPict("SZJ","ZJ_SEGQTD")   , 1, tamSx3("ZJ_SEGQTD")[1] ,tamSx3("ZJ_SEGQTD")[2], .T. , , .F.,, "XZJ_SEGQTD",, .F., .T.,, "XZJ_SEGQTD"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SIMQTD"), {||aDespes[oBrowse:nAt,nPosSMQ]}, GetSx3Cache("ZJ_SIMQTD","X3_TIPO"), pesqPict("SZJ","ZJ_SIMQTD")   , 1, tamSx3("ZJ_SIMQTD")[1] ,tamSx3("ZJ_SIMQTD")[2], .T. , , .F.,, "XZJ_SIMQTD",, .F., .T.,, "XZJ_SIMQTD"})

   oBrowse:addColumn({FWX3Titulo("ZJ_SIMDIA"), {||aDespes[oBrowse:nAt,nPosSMD]}, GetSx3Cache("ZJ_SIMDIA","X3_TIPO"), pesqPict("SZJ","ZJ_SIMDIA")   , 1, tamSx3("ZJ_SIMDIA")[1] ,tamSx3("ZJ_SIMDIA")[2], .T. , , .F.,, "XZJ_SIMDIA",, .F., .T.,, "XZJ_SIMDIA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_DURA"), {||aDespes[oBrowse:nAt,nPosDUR]}, GetSx3Cache("ZJ_DURA","X3_TIPO"), pesqPict("SZJ","ZJ_DURA")   , 1, tamSx3("ZJ_DURA")[1] ,tamSx3("ZJ_DURA")[2], .T. , , .F.,, "XZJ_DURA",, .F., .T.,, "XZJ_DURA"})

   oBrowse:addColumn({FWX3Titulo("ZJ_ENTREGA"), {||aDespes[oBrowse:nAt,nPosEnt]}, GetSx3Cache("ZJ_ENTREGA","X3_TIPO"), pesqPict("SZJ","ZJ_ENTREGA")   , 1, tamSx3("ZJ_ENTREGA")[1] ,tamSx3("ZJ_ENTREGA")[2], .T. , , .F.,, "XZJ_ENTREGA",, .F., .T.,, "XZJ_ENTREGA"})

   oBrowse:aColumns[nPosPro]:XF3 := 'SB1'  // 01
   oBrowse:acolumns[nPosPro]:ledit     := .T.
   oBrowse:acolumns[nPosPro]:cReadVar:= 'aDespes[oBrowse:nAt,nPosPro]'

   oBrowse:aColumns[nPosLoc]:XF3 := 'SB2' // 02
   oBrowse:acolumns[nPosLoc]:ledit     := .T.
   oBrowse:acolumns[nPosLoc]:cReadVar:= 'aDespes[oBrowse:nAt,nPosLoc]'

   oBrowse:acolumns[nPosSLD]:ledit     := .F. //03
   oBrowse:acolumns[nPosQEP]:ledit     := .F. //04
   oBrowse:acolumns[nPosDPN]:ledit     := .F. //05
   oBrowse:acolumns[nPosCmm]:ledit     := .F. //06
 

   oBrowse:acolumns[nPosProj]:ledit     := .T. // 07
   oBrowse:acolumns[nPosProj]:cReadVar:= 'aDespes[oBrowse:nAt,nPosProj]'

   oBrowse:acolumns[nPosCmD]:ledit     := .F. //08
   oBrowse:acolumns[nPosEAD]:ledit     := .F. //09
   oBrowse:acolumns[nPosEDD]:ledit     := .F. //10

   oBrowse:acolumns[nPosESD]:ledit     := .T. //11
   oBrowse:acolumns[nPosESD]:cReadVar:= 'aDespes[oBrowse:nAt,nPosESD]'

   oBrowse:acolumns[nPosESQ]:ledit     := .F. //12

   oBrowse:acolumns[nPosSMQ]:ledit     := .T. //13
   oBrowse:acolumns[nPosSMQ]:cReadVar:= 'aDespes[oBrowse:nAt,nPosSMQ]'

   oBrowse:acolumns[nPosSMD]:ledit     := .F. //14
   oBrowse:acolumns[nPosDUR]:ledit     := .F. //15
   oBrowse:acolumns[nPosEnt]:ledit     := .F. //16
 
   oBrowse:setAfterAddLine( { || posIncLine()} )
   oBrowse:setEditCell( .T.,{ || PM050VLD() } )

   SetKey(VK_F4,  {|| PM050CONS() } )
   SetKey(VK_F5,  {|| U_PM050USO(adespes[oBrowse:nAt][nPosPro] )} )
   SetKey(VK_F6,  {|| U_PM050SC2(adespes[oBrowse:nAt][nPosPro] )} )
   SetKey(VK_F10, {||  U_PM050QBR(adespes[oBrowse:nAt][nPosPro],adespes[oBrowse:nAt][nPosLoc],adespes[oBrowse:nAt][nPosCmD],adespes[oBrowse:nAt][nPosEDD],adespes[oBrowse:nAt][nPosESD],adespes[oBrowse:nAt][nPosDUR])} )

  oBrowse:Activate()

  ACTIVATE MSDIALOG oDlg CENTERED
return

/*/{Protheus.doc} posIncLine
description Controle de inclusão dos arrays
@type function Static
@version 1.0
@author Paulo Lenzi
@since 8/29/2023
@return variant, return_description
/*/
Static function posIncLine()
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_PRODUTO"):nOrder ] := space( tamSx3( "ZJ_PRODUTO" )[1]        )
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_LOCAL"):nOrder ]   := space( tamSx3( "ZJ_LOCAL" )[1]        )
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SALDO"):nOrder ]   := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_QEMP"):nOrder ]    := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_DISPON"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_CONSUM"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_CONSUD"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_PROJEC"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_STOKATU"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_STOKDAY"):nOrder ] := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SEGDIA"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SEGQTD"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SIMQTD"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_SIMDIA"):nOrder ]  := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_DURA"):nOrder ]    := 0
    aDespes[ oBrowse:nAt , oBrowse:GetColByID("XZJ_ENTREGA"):nOrder ] := space( tamSx3( "ZJ_ENTREGA" )[1])
    aDespes[ oBrowse:nAt , nPosDel]                                   := .F.
return

/*/{Protheus.doc} PM050VLD
description Calculo das Celulas
@type function Static
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
static function PM050VLD()
   Local nPos:= oBrowse:ColPos()
   // Informações do Produto
   IF nPos = nPosLoc  // Posiciona na coluna Local ( Armazem ) dispara os calculos 
      adespes[oBrowse:nAt][nPosSLD] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QATU' ) // saldo atual
      adespes[oBrowse:nAt][nPosQEP] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QEMP' ) // Quantidade Emprenhas
      adespes[oBrowse:nAt][nPosDPN] := Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QATU' ) - Posicione("SB2",1,xFilial("SB2")+adespes[oBrowse:nAt][nPosPro]+adespes[oBrowse:nAt][nPosLoc],'B2_QEMP' ) // Saldo Disponivel
      adespes[oBrowse:nAt][nPosCmm] := PCPCALCOM() // Comsumo Medio conforme parametros 
      adespes[oBrowse:nAt][nPosESD] := 0 // Dias Estoque Digitado
      adespes[oBrowse:nAt][nPosESQ] := 0
      adespes[oBrowse:nAt][nPosSMD] := 0
      adespes[oBrowse:nAt][nPosEnt] := " " // Observação

   ENDIF

   // Calculos para quantidade diario
   if nPos = nPosProj
      nConsumoDia := adespes[oBrowse:nAt][nPosProj] /30  // Consumo Medio do Dia
      adespes[oBrowse:nAt][nPosCmD] := nConsumoDia
      adespes[oBrowse:nAt][nPosEAD] := adespes[oBrowse:nAt][nPosSLD] / nConsumoDia // Estoque Atual Dia
      adespes[oBrowse:nAt][nPosEDD] := adespes[oBrowse:nAt][nPosDPN] / nConsumoDia // Disponivel Dia
   endif   

   IF nPos = nPosESD // Apos digitar o estoque de seguranção Dia, faz o calculo para estoque de segurança Quantidade
      adespes[oBrowse:nAt][nPosESQ] := nConsumoDia * adespes[oBrowse:nAt][nPosESD]  // Estoque Segurança Quantidade
   Endif

   if nPos = nPosSMQ
      adespes[oBrowse:nAt][nPosSMD] := adespes[oBrowse:nAt][nPosSMQ] / nConsumoDia

      // Variaveis para Calculo de Data
      nEstDispDia  := adespes[oBrowse:nAt][nPosEDD]  // Estoque Disponivel Diario
      nEstSegDia   := adespes[oBrowse:nAt][nPosESD]  // Estoque Sugestao Diario
      nEstSimDia   := adespes[oBrowse:nAt][nPosSMD]  // Estoque Simulacao Dia
      
      /*
           Data sistema + Estoque Disponivel Dias - Estoque Sugestao Dia + Estoque Simulacao Dia
      */

      nDataGrv     := ((Date() + nEstDispDia) - nEstSegDia ) + nEstSimDia // Calculo de Datas
     
      adespes[oBrowse:nAt][nPosDUR] := nDataGrv // ( ((Date() + adespes[oBrowse:nAt][nPosEDD] ) - adespes[oBrowse:nAt][nPosESD]) )
   endif 

Return(.T.)

/*/{Protheus.doc} PM050CONS
description Tela de Consumo Medio 
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
Static Function PM050CONS()
   Local cArea := FWGetArea()
   Local Cod_Produto := adespes[oBrowse:nAt][nPosPro]
   MACOMVIEWSM(Cod_Produto)
   FWRestArea(cArea)
RETURN

/*/{Protheus.doc} PM050VLCP
description
@type function
@version 1.0
@author Paulo Lenzi
@since 29/02/2024
@return variant, return_description
/*/
Static Function PM050VLCP()
   Local cArea := FwGetArea()
   Local yX    := 0
   Local lRet  := .T.
   if len(aDespes) > 0 
      FOR yX :=1 to len(aDespes)   
          IF !adespes[yX][nPosDel] .AND. !Empty(adespes[yX][nPosPro])
              IIF(Empty(adespes[yX][nPosDUR]),lRet := .F., lRet:= .T.)
          ENDIF    
      Next
   Endif
   FwRestArea(cArea)
Return(lRet)

/*/{Protheus.doc} PM050GRAVA
description Rotina de gravação dos lançamentos de programação
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/
Static Function PM050GRAVA()
   Local cArea       := FWGetArea()
   Local AB as numeric
   Local cSeq as caracter
   cSeq := "001"
   IF len(aDespes) > 0

       FOR AB:=1 to len(aDespes)

            IF !adespes[AB][nPosDel] .AND. !Empty(adespes[AB][nPosPro])  // Valida se o array não foi deletado
               dbSelectArea("SZJ")
               SZJ->( dbSetOrder(1) )
               IF SZJ->( !dbSeek(xFilial("SZJ")+adespes[AB][nPosPro]+adespes[AB][nPosLoc] ,.T. ) )
                        IF RecLock("SZJ",.T.)
                              SZJ->ZJ_FILIAL       :=    xFilial("SZJ")
                              SZJ->ZJ_PRODUTO      :=    adespes[AB][nPosPro]
                              SZJ->ZJ_LOCAL        :=    adespes[AB][nPosloc]
                              SZJ->ZJ_SALDO        :=    adespes[AB][nPosSLD]
                              SZJ->ZJ_QEMP         :=    adespes[AB][nPosQEP]
                              SZJ->ZJ_DISPON       :=    adespes[AB][nPosDPN]
                              SZJ->ZJ_CONSUM       :=    adespes[AB][nPosCmm]
                              SZJ->ZJ_CONSUD       :=    adespes[AB][nPosCmD]
                              SZJ->ZJ_PROJEC       :=    adespes[AB][nPosProj]
                              SZJ->ZJ_STOKATU      :=    adespes[AB][nPosEAD]
                              SZJ->ZJ_STOKDAY      :=    adespes[AB][nPosEDD]
                              SZJ->ZJ_SEGDIA       :=    adespes[AB][nPosESD]
                              SZJ->ZJ_SEGQTD       :=    adespes[AB][nPosESQ]
                              SZJ->ZJ_SIMQTD       :=    adespes[AB][nPosSMQ]
                              SZJ->ZJ_SIMDIA       :=    adespes[AB][nPosSMD]
                              SZJ->ZJ_DURA         :=    IIF(ValType(adespes[AB][nPosDUR])="C",cToD(adespes[AB][nPosDUR]),adespes[AB][nPosDUR])
                              SZJ->ZJ_ENTREGA      :=    adespes[AB][nPosEnt]
                              SZJ->ZJ_KEYUSER      :=     __cUserID 
                              SZJ->ZJ_DATA         :=    dDataBase
                           MsUnlock()
                        ENDIF 
               else
                        IF RecLock("SZJ",.F.)
                              SZJ->ZJ_SALDO        :=    adespes[AB][nPosSLD]
                              SZJ->ZJ_QEMP         :=    adespes[AB][nPosQEP]
                              SZJ->ZJ_DISPON       :=    adespes[AB][nPosDPN]
                              SZJ->ZJ_CONSUM       :=    adespes[AB][nPosCmm]
                              SZJ->ZJ_CONSUD       :=    adespes[AB][nPosCmD]
                              SZJ->ZJ_PROJEC       :=    adespes[AB][nPosProj]
                              SZJ->ZJ_STOKATU      :=    adespes[AB][nPosEAD]
                              SZJ->ZJ_STOKDAY      :=    adespes[AB][nPosEDD]
                              SZJ->ZJ_SEGDIA       :=    adespes[AB][nPosESD]
                              SZJ->ZJ_SEGQTD       :=    adespes[AB][nPosESQ]
                              SZJ->ZJ_SIMQTD       :=    adespes[AB][nPosSMQ]
                              SZJ->ZJ_SIMDIA       :=    adespes[AB][nPosSMD]
                              SZJ->ZJ_DURA         :=    IIF(ValType(adespes[AB][nPosDUR])="C",cToD(adespes[AB][nPosDUR]),adespes[AB][nPosDUR])
                              SZJ->ZJ_ENTREGA      :=    adespes[AB][nPosEnt]
                              
                           MsUnlock()
                        ENDIF 
                  
            Endif
         Endif 
     
       NEXT
    ENDIF

    FWRestArea(cArea)
Return

/*/{Protheus.doc} PM050DEL
description Função para registros (aCols) deletados
@type function Static
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@return variant, return_description
/*/

Static Function PM050DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrowse:nAt
     Local lSit        := oBrowse:LDELETE

     if lSit 
      if MsgYesNo("Deseja excluir a linha desse produto","Atenção")
         aDespes[nLinha][nPosDel] := .T.
         dbSelectArea("SZJ")
         SZJ->( dbSetOrder(1) )
         IF SZJ->( dbSeek(xFilial("SZJ")+adespes[nLinha][nPosPro]+adespes[nLinha][nPosLoc] ,.T. ) )
              if reclock("SZJ")
                 SZJ->( dbDelete() )
                 SZJ->( MsUnlock() )
              endif   
         endif 
         aDel(adespes, nLinha)
         aSize(adespes, Len(adespes) - 1)
      endif   
     Endif    

     oBrowse:Reset()
     oBrowse:setArray(aDespes)	// Forço o Browse a ler os novos valores informados.
     oBrowse:GoTop()

     oBrowse:Refresh(.T.)	
     FWRestArea(cArea)
RETURN


/*/{Protheus.doc} PM050CPO
description Valida a existencia do Fornecedor, Produto e a Amarração
@type function
@version 1.0
@author Paulo Lenzi
@since 8/30/2023
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function PM050CPO(cProduto)
  Local cArea       := FWGetArea()
  Local lRet        := .T.
  dbSelectArea("SB1")
  SB1->( dbSetOrder(1) )
  IF SB1->( !dbSeek( xFilial("SB1")+cProduto,.T. ))   
                  lRet        := .F.
                  MsgAlert( " Esse Produto nao existe no cadastro")
  Endif
  FWRestArea(cArea)    
RETURN(lRet)

/*/{Protheus.doc} PM050MARK
description
@type function
@version 1.0
@author Paulo Lenzi
@since 9/6/2023
@return variant, return_description
/*/
User Function PM050MARK(cProduto)
 Local cArea      := FWGetArea()
 Local oDlgMark   as Object 

 Local oOk        := LoadBitmap( GetResources(), "LBOK" )
 Local oNo        := LoadBitmap( GetResources(), "LBNO" )
 Local cAlias     := GetNextAlias()
 Local aSize      := MsAdvSize()

 Private aBrowse    := {}
 Private oBrwMark as Object 

 if Empty(cProduto)
      FWAlertError( 'Campo do Produto em Branco', 'Atenção' )
      FWRestArea(cArea)   
      Return
 Endif

 oMainWnd:ReadClientCoors()
 nHeight := oMainWnd:nHeight-50
 nWidth  := oMainWnd:nWidth-15

 aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 

  BeginSQL Alias cAlias
      SELECT ZL_PRODUTO,ZL_LOCAL,ZL_DTINIC,ZL_SIMULA,ZL_SEGURA,ZL_DATPRF
      FROM %Table:SZL% SZL
      WHERE SZL.%NotDel%
		and ZL_FILIAL =  %xFilial:SZL%
      and ZL_PRODUTO = %exp:cProduto%
      and ZL_STATUS = 'A'
	   ORDER BY ZL_PRODUTO
  ENDSQL
  TCSetField(cAlias, "ZL_DTINIC", "D")
  TCSetField(cAlias, "ZL_DATPRF", "D")

  IF (cAlias)->(EOF())
      FWAlertError( 'Não tem movimento para gerar solicitação de Compras', 'Solicitação de Compras' )
      FWRestArea(cArea)   
      Return
  Endif

  If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())

               aAdd( aBrowse, { .F.,;
                            (cAlias)->ZL_PRODUTO,;
                            Posicione("SB1",1,xFilial("SB1")+(cAlias)->ZL_PRODUTO,"B1_DESC"),;
                            (cAlias)->ZL_LOCAL,;
                            (cAlias)->ZL_DTINIC,;
                            (cAlias)->ZL_SIMULA,; 
                            (cAlias)->ZL_DATPRF})

               (cAlias)->(dbSkip() )
          End
  Endif
  (cAlias)->(DbCloseArea())
 
  oDlgMark := MSDialog():New(aSize[7],0, nHeight,nWidth,"Gera Solicitação de Compras",,,.F.,,,,,,.T.,,,.T. )
  oDlgMark:bInit := {||EnchoiceBar(oDlgMark,{|| FWMsgRun(, {|oDlgMark| U_PM050SOLC(oDlgMark) }, "Processando", "Processando a rotina...") ,oDlgMark:End()},{|| oDlgMark:End()},,)}
  
  oBrwMark := TCBrowse():New( aSize[7]+35,5, nHeight,nWidth,,{' ','Produto', 'Descrição','Local','Emissao', 'Quantidade','Data Prevista'},{010,050,100,010,050,050,050},oDlgMark,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )
   oBrwMark:SetArray( aBrowse )

   oBrwMark:bLine := {||{ iIf( aBrowse[oBrwMark:nAt][01], oOK, oNO ) ,;  	            // Marcação
                               aBrowse[oBrwMark:nAt,02],;							         // Produto
                               aBrowse[oBrwMark:nAt,03],;							         // Descrição
                               aBrowse[oBrwMark:nAt,04],;                              // Local
                               DtoC(aBrowse[oBrwMark:nAt,05]),;                        // Data Inicial
					           Transform(aBrowse[oBrwMark:nAt,06],"@E 999999,99999"),;      // Quantidade
                               DtoC(aBrowse[oBrwMark:nAt,07])} }                            // Data Prevista


   oBrwMark:bLDblClick := { || fLDblClick() }

   oBrwMark:bHeaderClick := { || fHeadClick() }

   oBrwMark:GoTop()

 oDlgMark:Activate(,,,.T.)

 FWRestArea(cArea)   

Return

/*/{Protheus.doc} fLDblClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 9/6/2023
@return variant, return_description
/*/
Static Function fLDblClick()
    aBrowse[oBrwMark:nAt][1] := ( ! aBrowse[oBrwMark:nAt][1] )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
Return( NIL )

/*/{Protheus.doc} fHeadClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 9/6/2023
@return variant, return_description
/*/
Static Function fHeadClick()
    aEval( aBrowse, { |cValue,nIndex| aBrowse[nIndex][1] := ( ! aBrowse[nIndex][1] ) } )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
Return( NIL )
 
 //----------------------------------------------------------
//Static Function ValidMark()
//Local lRet := .F.

//----------------------------------------------------------
//Static Function BrwStatus()
//Return Iif(ValidMark(),"BR_VERDE","BR_VERMELHO")

//----------------------------------------------------------
//Static Function BrwLegend()
//Local oLegend := FWLegend():New()

//oLegend:Add("","BR_VERDE" , "VERDE" ) 
// oLegend:Add("","BR_VERMELHO", "VERMELHO" ) 
// oLegend:Activate()
// oLegend:View()
// oLegend:DeActivate()

//Return


Static Function PCPCALCOM()
    Local aArea := FwgetArea()
    Local cProduto := adespes[oBrowse:nAt][nPosPro]
    Local cMeses  := month(date())
    Local nMeses  := MV_PAR01

    Local aFields :={}
    Local ctmp    := 'TMP' + GetNextAlias()
    Local cQuery  as character 
    Local cAlias  := 'Qry' + getNextAlias()
    Local oTable  := FWTemporaryTable():New( ctmp ) 

    Local nConsumo:= 0
    Local AB

   aAdd(aFields,{"TMP_FILIAL"		, GetSx3Cache("C2_FILIAL","X3_TIPO")		,tamSx3("C2_FILIAL")[1]	    ,tamSx3("C2_FILIAL")[2]})
   aAdd(aFields,{"TMP_PROD"		, GetSx3Cache("G5_PRODUTO","X3_TIPO")		,tamSx3("G5_PRODUTO")[1]	,tamSx3(" G5_PRODUTO")[2]})
   aAdd(aFields,{"TMP_JAN"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_FEV"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_MAR"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_ABR"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_MAI"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_JUN"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_JUL"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_AGO"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_SET"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_OUT"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_NOV"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})
   aAdd(aFields,{"TMP_DEZ"  		, GetSx3Cache("C2_QUANT","X3_TIPO")		   ,tamSx3("C2_QUANT")[1]	    ,tamSx3("C2_QUANT")[2]})

   oTable:SetFields( aFields )
	oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_PROD"} )
 	oTable:Create()  

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
   cQuery+=" ORDER BY 1,2,3 "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
      RestArea(aArea)                                
      Return(nConsumo)        
   endif

   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
             dbselectarea(ctmp)
             (ctmp)->( dbSetOrder(1 ))
             if (ctmp)->( !dbSeek(xFilial("SC2")+(cAlias)->PRODUTO,.T.))
                  IF RecLock(ctmp,.T.)
                     TMP_FILIAL 	:= xFilial("SC2")
                     TMP_PROD    := (cAlias)->PRODUTO
                     TMP_JAN     := (cAlias)->JANEIRO
                     TMP_FEV     := (cAlias)->FEVEREIRO
                     TMP_MAR     := (cAlias)->MARCO
                     TMP_ABR     := (cAlias)->ABRIL
                     TMP_MAI     := (cAlias)->MAIO
                     TMP_JUN     := (cAlias)->JUNHO
                     TMP_JUL     := (cAlias)->JULHO
                     TMP_AGO     := (cAlias)->AGOSTO
                     TMP_SET     := (cAlias)->SETEMBRO
                     TMP_OUT     := (cAlias)->OUTUBRO
                     TMP_NOV     := (cAlias)->NOVEMBRO
                     TMP_DEZ     := (cAlias)->DEZEMBRO
                     (ctmp)->( MsUnlock() )
                  ENDIF
             else
                  IF RecLock(ctmp,.F.)
                     TMP_JAN     := iif((cAlias)->JANEIRO > 0     ,(cAlias)->JANEIRO   , TMP_JAN )
                     TMP_FEV     := iif((cAlias)->FEVEREIRO > 0   ,(cAlias)->FEVEREIRO , TMP_FEV )
                     TMP_MAR     := iif((cAlias)->MARCO > 0       ,(cAlias)->MARCO     , TMP_MAR )
                     TMP_ABR     := iif((cAlias)->ABRIL > 0       ,(cAlias)->ABRIL     , TMP_ABR )
                     TMP_MAI     := iif((cAlias)->MAIO > 0        ,(cAlias)->MAIO      , TMP_MAI )
                     TMP_JUN     := iif((cAlias)->JUNHO > 0       ,(cAlias)->JUNHO     , TMP_JUN )
                     TMP_JUL     := iif((cAlias)->JULHO > 0       ,(cAlias)->JULHO     , TMP_JUL )
                     TMP_AGO     := iif((cAlias)->AGOSTO > 0      ,(cAlias)->AGOSTO    , TMP_AGO )
                     TMP_SET     := iif((cAlias)->SETEMBRO > 0    ,(cAlias)->SETEMBRO  , TMP_SET )
                     TMP_OUT     := iif((cAlias)->OUTUBRO > 0     ,(cAlias)->OUTUBRO   , TMP_OUT )
                     TMP_NOV     := iif((cAlias)->NOVEMBRO > 0    ,(cAlias)->NOVEMBRO  , TMP_NOV )
                     TMP_DEZ     := iif((cAlias)->DEZEMBRO > 0    ,(cAlias)->DEZEMBRO  , TMP_DEZ )
                     (ctmp)->( MsUnlock() )
                  ENDIF
              endif    
            (cAlias)->( dbSkip() )
   EndDo
   (calias)->(DbCloseArea()) 

// Atualizar a tabela SZP 
   dbselectarea(ctmp)
   (ctmp)->( dbgotop() )
   While (ctmp)->( !Eof())
            dbSelectArea("SZP")
               SZP->( dbSetOrder(1))
               IF SZP->( !dbSeek( (ctmp)->TMP_FILIAL+(ctmp)->TMP_PROD))
                  IF SZP->( RecLock("SZP",.T.))
                    SZP->ZP_FILIAL := (ctmp)->TMP_FILIAL
                    SZP->ZP_COD  := (ctmp)->TMP_PROD
                    SZP->ZP_Q01  := (ctmp)->TMP_JAN
                    SZP->ZP_Q02  := (ctmp)->TMP_FEV
                    SZP->ZP_Q03  := (ctmp)->TMP_MAR
                    SZP->ZP_Q04  := (ctmp)->TMP_ABR
                    SZP->ZP_Q05  := (ctmp)->TMP_MAI
                    SZP->ZP_Q06  := (ctmp)->TMP_JUN
                    SZP->ZP_Q07  := (ctmp)->TMP_JUL
                    SZP->ZP_Q08  := (ctmp)->TMP_AGO
                    SZP->ZP_Q09  := (ctmp)->TMP_SET
                    SZP->ZP_Q10  := (ctmp)->TMP_OUT
                    SZP->ZP_Q11  := (ctmp)->TMP_NOV
                    SZP->ZP_Q12  := (ctmp)->TMP_DEZ    
                    SZP->( MsUnlock() )
                  Endif
               ELSE
                  IF SZP->( RecLock("SZP",.F.))
                        SZP->ZP_Q01  := (ctmp)->TMP_JAN
                        SZP->ZP_Q02  := (ctmp)->TMP_FEV
                        SZP->ZP_Q03  := (ctmp)->TMP_MAR
                        SZP->ZP_Q04  := (ctmp)->TMP_ABR
                        SZP->ZP_Q05  := (ctmp)->TMP_MAI
                        SZP->ZP_Q06  := (ctmp)->TMP_JUN
                        SZP->ZP_Q07  := (ctmp)->TMP_JUL
                        SZP->ZP_Q08  := (ctmp)->TMP_AGO
                        SZP->ZP_Q09  := (ctmp)->TMP_SET
                        SZP->ZP_Q10  := (ctmp)->TMP_OUT
                        SZP->ZP_Q11  := (ctmp)->TMP_NOV
                        SZP->ZP_Q12  := (ctmp)->TMP_DEZ    
                     SZP->( MsUnlock() )
                  Endif

               Endif
            (ctmp)->( dbSkip() )
   ENDDO

// CALCULO CONSUMO MEDIO 
   dbselectarea(ctmp)
   (ctmp)->( dbgotop() )
   While (ctmp)->( !Eof())
            
       FOR AB:=1 TO nMeses
               XCAMPO := "(ctmp)->TMP_"+ UPPER(Substr( MesExtenso(cMeses,2),1,3))
               nConsumo +=  &(XCAMPO) 
               cMeses := cMeses - 1
               if cMeses = 0
                  cMeses := 12
               endif
       NEXT        
      (ctmp)->( dbSkip() )
   Enddo

   nConsumo := nConsumo / nMeses

   
  oTable:Delete()
  FwRestArea(aArea)
Return(nConsumo)
 
 
