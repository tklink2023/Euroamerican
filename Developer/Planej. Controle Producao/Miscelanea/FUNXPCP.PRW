#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

#define STYLE0000 "QPushButton {" +;
		  " background-image: url(rpo:totvsprinter_spool.png);background-repeat: none; margin: 2px;"  +;
		  " border-style: outset;" +;
		  " border-width: 2px;" +;
		  " border: 1px solid #C0C0C0;" +;
		  " border-radius: 5px;" +;
		  " border-color: #C0C0C0;" +;
		  " font: bold 12px Arial;" +;
		  " padding: 6px;" +;
		  "}" +;
		  "QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
 
#define STYLE0002 "QPushButton {background-image: url(rpo:totvsprinter_pdf.png);background-repeat: none; margin: 2px; " +;
		  " border-style: outset;" +;
		  " border-width: 2px;" +;
		  " border: 1px solid #C0C0C0;" +;
		  " border-radius: 0px;" +;
		  " border-color: #C0C0C0;" +;
		  " font: bold 12px Arial;" +;
		  " padding: 6px;" +;
		  "}" +;
		  "QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
 
#define STYLE0003 "QPushButton {background-image: url(rpo:totvsprinter_email.png);background-repeat: none; margin: 2px;}"

/*/{Protheus.doc} PM050GRAF
description Rotina de Geração de Grafico
@type function
@version 1.0
@author Paulo Lenzi
@since 9/1/2023
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PM050GRAF(cProduto)
	Local oChart 		as Object 
	Local oDlg   		as Object 
	Local aBindParam    as array
	Local cQuery        as character
	Local cAlias        as character

	cQuery := "SELECT ZP_COD, ZP_Q01, ZP_Q02, ZP_Q03, ZP_Q04, ZP_Q05, ZP_Q06, ZP_Q07, ZP_Q08, ZP_Q09, ZP_Q10, ZP_Q11, ZP_Q12 FROM "+ RETSQLNAME("SZP") + " WHERE D_E_L_E_T_ = ' ' AND ZP_FILIAL = ? AND  ZP_COD = ?"
    cQuery 		:= ChangeQuery(cQuery)
	aBindParam 	:= {xFilial("SZP"), cProduto}
	cAlias  	:= MPSysOpenQuery(cQuery,,,,aBindParam)
    if (cAlias)->(Eof())
        MsgAlert("Sem dados para o Grafico")
		Return
    ENDIF

DEFINE MSDIALOG oDlg PIXEL FROM 10,0 TO 600,600
		oChart := FWChartLine():New()
		oChart:init( oDlg, .t.,.t. ) 
	
        While (cAlias)->( !Eof() )
    		oChart:addSerie( cProduto, { {"Jan "+Alltrim(Transform((cAlias)->ZP_Q01, "@E 99,999.9999")),(cAlias)->ZP_Q01},;
										 {"Fev "+Alltrim(Transform((cAlias)->ZP_Q02, "@E 99,999.9999")),(cAlias)->ZP_Q02},;
										 {"Mar "+Alltrim(Transform((cAlias)->ZP_Q03, "@E 99,999.9999")),(cAlias)->ZP_Q03},;
										 {"Abr "+Alltrim(Transform((cAlias)->ZP_Q04, "@E 99,999.9999")),(cAlias)->ZP_Q04},;
										 {"Mai "+Alltrim(Transform((cAlias)->ZP_Q05, "@E 99,999.9999")),(cAlias)->ZP_Q05},;
										 {"Jun "+Alltrim(Transform((cAlias)->ZP_Q06, "@E 99,999.9999")),(cAlias)->ZP_Q06},;
										 {"Jul "+Alltrim(Transform((cAlias)->ZP_Q07, "@E 99,999.9999")),(cAlias)->ZP_Q07},;
										 {"Ago "+Alltrim(Transform((cAlias)->ZP_Q08, "@E 99,999.9999")),(cAlias)->ZP_Q08},;
										 {"Set "+Alltrim(Transform((cAlias)->ZP_Q09, "@E 99,999.9999")),(cAlias)->ZP_Q09},;
										 {"Out "+Alltrim(Transform((cAlias)->ZP_Q10, "@E 99,999.9999")),(cAlias)->ZP_Q10},;
										 {"Nov "+Alltrim(Transform((cAlias)->ZP_Q11, "@E 99,999.9999")),(cAlias)->ZP_Q11},;
										 {"Dez "+Alltrim(Transform((cAlias)->ZP_Q12, "@E 99,999.9999")),(cAlias)->ZP_Q12} })

			oChart:setLegend( CONTROL_ALIGN_LEFT ) 
	
			oChart:Build()
          (cAlias)->( dbSkip() )	
	    EndDo

ACTIVATE MSDIALOG oDlg
Return

/*/{Protheus.doc} PM050Tela
description
@type function
@version 1.0
@author Paulo Lenzi
@since 09/05/2023
@return variant, return_description
/*/
User Function PM050Tela(cProduto,dMvPar02,dMvPar03)
 Local cArea 	:= FWGetArea()
 Local oDlg 	as Object 
 Local oBrowse 	as Object 
 Local aBrowse 	as Array 
 Local cAlias  	:= GetNextAlias()
 Local aSize   	:= MsAdvSize()
 local aButtons := {}
 Local cDtIni   := dMvPar02
 Local cDtFim   := LastYDate(dMvPar03)

  
oMainWnd:ReadClientCoors()
nHeight := oMainWnd:nHeight-50
nWidth  := oMainWnd:nWidth-15
AAdd(aButtons,{"Imprimir S.C",{|| U_PCPR140("SC1",aBrowse[oBrowse:nAt,14] )},"Solicitacao Compras","Imprimir S.C"})
AAdd(aButtons,{"Pedido Compra",{|| IIF(!Empty(aBrowse[oBrowse:nAt,5]),AlteraPC(aBrowse[oBrowse:nAt,15],2),MsgAlert("Campo em Branco","Atenção")) },"Pedidos Compras","Pedido de Compras"})
//AAdd(aButtons,{"Nota Entrada",{|| IIF(!Empty(aBrowse[oBrowse:nAt,8]),NFEVisua(aBrowse[oBrowse:nAt,16]),' ') },"Nota Entrada","Nota Entrada"})
//AlteraPC(67081,2) //Visualizar
AAdd(aButtons,{"SAIR",{|| oDlg:End()},"Sair","Sair"})

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
 BeginSQL Alias cAlias
		SELECT      C1_NUM,
					C1_EMISSAO,
					C1_DATPRF,
					C1_QUANT,
					ISNULL(C7_NUM,' ') C7_NUM,
					ISNULL(C7_EMISSAO,'') C7_EMISSAO , 
					CASE WHEN C7_CONAPRO = 'L' THEN 'APROVADO'  WHEN C7_CONAPRO = 'B' THEN 'BLOQUEADO' ELSE ' ' END C7_CONAPRO,
					ISNULL(D1_DOC,' ') D1_DOC,
					ISNULL(D1_SERIE,' ') D1_SERIE,
					ISNULL(D1_DTDIGIT, ' ') D1_DTDIGIT,
					ISNULL(D1_QUANT, ' ') D1_QUANT,
					isnull(DATEDIFF ( DAY , C1_DATPRF , D1_DTDIGIT ),0) LEADTIME,
					isnull((C1_QUANT-  D1_QUANT ),0) DIVERGENCIA,
					SC1.R_E_C_N_O_ RECNO1,
					isnull(SC7.R_E_C_N_O_,0) RECNO2,
					isnull(SD1.R_E_C_N_O_,0) RECNO3

		FROM %Table:SC1% SC1

		Left Join %Table:SC7% SC7 ON C7_FILIAL = C1_FILIAL AND C7_PRODUTO = C1_PRODUTO AND C7_LOCAL = C1_LOCAL AND C7_NUM = C1_PEDIDO  AND C1_ITEMPED = C7_ITEM AND SC7.D_E_L_E_T_ = ' '
		Left join  %Table:SD1% SD1 on D1_FILIAL = C1_FILIAL AND D1_COD = C1_PRODUTO AND D1_LOCAL = C1_LOCAL AND D1_FORNECE = C7_FORNECE AND D1_LOJA = C7_LOJA AND D1_PEDIDO = C7_NUM  AND SD1.D_E_L_E_T_ = ' '

		WHERE SC1.%NotDel%
		and C1_FILIAL =  %xFilial:SC1%
		AND C1_PRODUTO =  %Exp:cProduto%
		AND C1_EMISSAO BETWEEN %Exp:cDtIni% AND %Exp:cDtFim%
	    ORDER BY C1_NUM
 EndSQL

	TCSetField(cAlias, "C1_EMISSAO", "D")
	TCSetField(cAlias, "C1_DATPRF", "D")
	TCSetField(cAlias, "C7_EMISSAO", "D")
	TCSetField(cAlias, "D1_DTDIGIT", "D")

if (cAlias)->( Eof())
   MsgAlert("Não tem movimentação de Solicitacao Compras nesse Periodo para esse produto","ATENÇÃO")
    FwRestArea(cArea)
	RETURN
Endif

 aBrowse :={}

 If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aBrowse , {(cAlias)->C1_NUM,;
							    (cAlias)->C1_EMISSAO,;
							    (cAlias)->C1_DATPRF,;
							    (cAlias)->C1_QUANT,;
							    (cAlias)->C7_NUM,;
							    (cAlias)->C7_EMISSAO,;
							    (cAlias)->C7_CONAPRO,;
							    (cAlias)->D1_DOC,;
							    (cAlias)->D1_SERIE,;
							    (cAlias)->D1_DTDIGIT,;
							    (cAlias)->D1_QUANT,;
							    (cAlias)->LEADTIME,;
							    (cAlias)->DIVERGENCIA,;
								(cAlias)->RECNO1,;
								(cAlias)->RECNO2,;
								(cAlias)->RECNO3})
                (cAlias)->(dbSkip() )
          End
 Endif
 (cAlias)->(DbCloseArea())

 oDlg := MSDialog():New(aSize[7],0, nHeight,nWidth,"Posição de Compras",,,.F.,,,,,,.T.,,,.T. )

// {|| EnchoiceBar(oDlg, {||GravarCR(oDlg)}, {||oDlg:End()},,aButtons)}

 oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,aButtons)}

 oBrowse := TCBrowse():New( aSize[7]+35,5,nWidth, nHeight,,;
    {'Solicitacao', 'Emissao', 'Data Prevista' , 'Quantidade','Pedido','Emissao','Status','Nota','Serie','Entrada','Quantidade','Lead Time','Divergencia'},;
	{   030,          050,          050,             050,        030,     050,    150,      050,   020,     50,       50,          30,          050      },;
oDlg,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

 oBrowse:SetArray(aBrowse)

 oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   							// Solicitacao
                      Dtoc(aBrowse[oBrowse:nAt,02]),;							// Emissao
                      Dtoc(aBrowse[oBrowse:nAt,03]),;							// Data Prevista
					  Transform(aBrowse[oBrowse:nAt,04],"@E 999999,99999"),;	// Quantidade
					  aBrowse[oBrowse:nAt,05],;									// Pedido de compras
					  Dtoc(aBrowse[oBrowse:nAt,06]),;							// Emissao
					  aBrowse[oBrowse:nAt,07],;                                 // Status
					  aBrowse[oBrowse:nAt,08],; 								// Nota
					  aBrowse[oBrowse:nAt,09],; 								// Serie
					  Dtoc(aBrowse[oBrowse:nAt,10]),; 							// Entrada
					  Transform(aBrowse[oBrowse:nAt,11],"@E 999999,99999"),; 	// Quantidade
					  Transform(aBrowse[oBrowse:nAt,12],"@E 99999"),; 			// Diverg Qtde
					  Transform(aBrowse[oBrowse:nAt,13],"@E 9999999")} } 			// Dias

   
   oDlg:Activate(,,,.T.)


 FwRestArea(cArea)

RETURN


User Function PM050SOLC()
Local cArea := FwGetArea()
Local cItem := StrZero(0,TamSx3("C1_ITEM")[1])

Local aCabec 	as Array 
Local aItens 	as Array 
Local cNum   	as Caracter
Local AB 		as Numeric
Local cCCusto   := GetMv("ES_CCPCP")

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

dbSelectArea("SC1")
cNum := GetSXENum("SC1","C1_NUM")
SC1->(dbSetOrder(1))		

While SC1->(dbSeek(xFilial("SC1")+cNum))			
		ConfirmSX8()			
		cNum := GetSXENum("SC1","C1_NUM")		
EndDo

aCabec :={	{ "C1_NUM"		, cNum						, NIL},;
			{ "C1_SOLICIT"	, UsrRetName(RetCodUsr())	, NIL},;
			{ "C1_EMISSAO"	, date()					, NIL}}

	        aItens	:={}


FOR AB:=1 TO Len(aBrowse)

	   if aBrowse[AB][1] 

            cItem	:= Soma1(cItem)
			aAdd(aItens,{	{ "C1_ITEM"			, cItem 		, NIL},;
							{ "C1_PRODUTO"	, aBrowse[AB][2]	, NIL},;
							{ "C1_LOCAL"	, aBrowse[AB][4]	, NIL},;
							{ "C1_EMISSAO"	, aBrowse[AB][5]	, NIL},;
							{ "C1_QUANT"	, aBrowse[AB][6]	, NIL},;
							{ "C1_DATPRF"	, aBrowse[AB][7]	, NIL},;
							{ "C1_CC"		, cCCusto			, NIL},;
							{ "C1_ORIGEM"	, "PCPM050"			, NIL}})	

	    Endif		
NEXT
MSExecAuto({|X,Y,Z| Mata110(X,Y,Z)}, aCabec, aItens, 3)

If lMsErroAuto
	Alert("Erro na Inclusao da Solicitacao de Compras !!!")
	MostraErro()
Else
	Alert("Foi Gerada a Solicitacao de Compras ==> "+cNum)
	FOR AB:=1 TO LEN(aBrowse)
	    dbSelectArea("SZL")
		SZL->( dbSetOrder(1) )
		IF SZL->( dbSeek(xFilial("SZL")+aBrowse[AB][2] + aBrowse[AB][4] +Dtos(aBrowse[AB][5]) , .T.  ))
		   IF RecLock("SZL",.F.)
              SZL->ZL_STATUS := 'B'
			  MsUnlock()
		   Endif 
        ENDIF
	Next
Endif


FwRestArea(cArea)
RETURN


/*/{Protheus.doc} PM050USO
description
@type function
@version 1.0
@author Paulo Lenzi
@since 9/6/2023
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PM050USO(cProduto)
 Local cArea := FWGetArea()
 Local oDlg as Object 
 Local oBrowse as Object 
 Local aBrowse as Array 
 Local cAlias  := GetNextAlias()
 Local aSize   := MsAdvSize()
 
oMainWnd:ReadClientCoors()
nHeight := oMainWnd:nHeight-50
nWidth  := oMainWnd:nWidth-15

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
 BeginSQL Alias cAlias
		SELECT  G1_COD,B1_DESC
		FROM %Table:SG1% SG1

		Left Join %Table:SB1% SB1 ON B1_COD = G1_COD  AND SB1.D_E_L_E_T_ = ' '

		WHERE SG1.%NotDel%
		and G1_FILIAL =  %xFilial:SG1%
		AND G1_COMP =  %Exp:cProduto%
	    ORDER BY G1_COD
 EndSQL

 aBrowse :={}

 If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aBrowse , {(cAlias)->G1_COD,(cAlias)->B1_DESC})
                (cAlias)->(dbSkip() )
          End
 Endif
 (cAlias)->(DbCloseArea())

 oDlg := MSDialog():New(000,000, 455,700,"Onde é usado",,,.F.,,,,,,.T.,,,.T. )

 oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,)}
 oBrowse := TCBrowse():New( 000,000,455,700,,{'Produto', 'Descricao'},{050,150},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

 
 oBrowse:SetArray(aBrowse)

 oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02]} } 	

 oDlg:Activate(,,,.T.)

 FwRestArea(cArea)

RETURN

/*/{Protheus.doc} PM050SC2
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PM050SC2(cProduto)
 Local cArea := FWGetArea()
 Local oDlg as Object 
 Local oBrowse as Object 
 Local aBrw		 as Array 
 Local cAlias  := GetNextAlias()
 Local aSize   := MsAdvSize()

 Local nQuant  := 0
 Local nQuse   := 0
 Local nPerda  := 0

 If Pergunte("PM050SC2",.T.,"Datas",.T.)
 else
		FwRestArea(cArea)   
		Return
endif

oMainWnd:ReadClientCoors()
nHeight := oMainWnd:nHeight-50
nWidth  := oMainWnd:nWidth-15

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
 BeginSQL Alias cAlias
		SELECT  C2_NUM,
				C2_ITEM,
				C2_SEQUEN,
				C2_PRODUTO,
				C2_LOCAL,
				C2_CC,
				C2_QUANT,
				C2_UM,
				C2_DATPRI,
				C2_DATPRF,
				C2_QUJE,
				C2_DATRF,
				C2_PERDA,
				C2_REVISAO
		FROM %Table:SG1% SG1
        INNER JOIN  %Table:SC2% SC2 ON C2_FILIAL = G1_FILIAL AND C2_PRODUTO = G1_COD AND SC2.D_E_L_E_T_ = ' '
	
		WHERE SG1.%NotDel%
		and G1_FILIAL =  %xFilial:SG1%
		AND G1_COMP =  %Exp:cProduto%
		AND C2_EMISSAO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% 

	    ORDER BY C2_NUM
 EndSQL
TCSetField(cAlias, "C2_DATPRI", "D")
TCSetField(cAlias, "C2_DATPRF", "D")
TCSetField(cAlias, "C2_DATRF", "D")

if (cAlias)->( Eof())
   MsgAlert("Não tem movimentação de OPs nesse Periodo para esse produto","ATENÇÃO")
    FwRestArea(cArea)
	RETURN
Endif

 aBrw :={}

 If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aBrw ,    {(cAlias)->C2_NUM,;
								(cAlias)->C2_ITEM,;
								(cAlias)->C2_SEQUEN,;
								(cAlias)->C2_PRODUTO,;
								(cAlias)->C2_LOCAL,;
								(cAlias)->C2_CC,;
								(cAlias)->C2_QUANT,;
								(cAlias)->C2_UM,;
								(cAlias)->C2_DATPRI,;
								(cAlias)->C2_DATPRF,;
								(cAlias)->C2_QUJE,;
								(cAlias)->C2_DATRF,;
								(cAlias)->C2_PERDA,;
								(cAlias)->C2_REVISAO})

								nQuant := nQuant + (cAlias)->C2_QUANT
								nQuse  := nQuse  + (cAlias)->C2_QUJE
								nPerda := nPerda + (cAlias)->C2_PERDA
                (cAlias)->(dbSkip() )
          End
 Endif
 (cAlias)->(DbCloseArea())

 oDlg := MSDialog():New(000,000, 455,1000,"Consumo Real em Ops",,,.F.,,,,,,.T.,,,.T. )

 oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,)}
 oBrowse := TCBrowse():New( 035,000,450,950,,{'Ordem','Item','Seq','Produto','Local','C.Custo','Quantidade','UM','Dt Inicio','Dt Prevista','Qtde Usada','Fabricacao','Perda','Revisao' },;
 											   {050,    020,    020,   050,     010,     020,      050,       010,  020,         020,          050,           020,      020,    020},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

 
 oBrowse:SetArray(aBrw)

 oBrowse:bLine := {||{ 	aBrw[oBrowse:nAt,01],;
 						aBrw[oBrowse:nAt,02],;
						aBrw[oBrowse:nAt,03],;
						aBrw[oBrowse:nAt,04],;
						aBrw[oBrowse:nAt,05],;
						aBrw[oBrowse:nAt,06],;
						Transform(aBrw[oBrowse:nAt,07],"@E 99999.99999"),;
						aBrw[oBrowse:nAt,08],;
						Dtoc(aBrw[oBrowse:nAt,09]),;
						Dtoc(aBrw[oBrowse:nAt,10]),;
						Transform(aBrw[oBrowse:nAt,11],"@E 99999.99999"),;
						Dtoc(aBrw[oBrowse:nAt,12]),;
						Transform(aBrw[oBrowse:nAt,13],"@E 99999.99999"),;
						aBrw[oBrowse:nAt,14]	} } 	

						oTMsgBar := TMsgBar():New(oDlg, 'TOTAL DA MOVIMENTACAO DAS OPS',.F.,.F.,.F.,.F., RGB(116,116,116),,oFont,.F.)
						oTMsgItem3 := TMsgItem():New( oTMsgBar,'Quantidade: '+Transform(nQuant,"@R 9999999.9999"), 100,,,,.T., {||} )
						oTMsgItem2 := TMsgItem():New( oTMsgBar,'Usados : '+Transform(nQuse,"@R 9999999.9999"), 100,,,,.T., {|| } )
						oTMsgItem1 := TMsgItem():New( oTMsgBar,'Perda : '+Transform(nPerda,"@R 9999999.9999"), 100,,,,.T., {|| } )

 oDlg:Activate(,,,.T.)

 FwRestArea(cArea)

RETURN


/*/{Protheus.doc} PM050QBR
description
@type function
@version 1.0
@author Paulo Lenzi
@since 05/10/2023
@return variant, return_description
/*/ 
User Function PM050QBR(cProduto,cLocal,nConsumo,nDisponivel,nSeguranca,dDataEntrega)

	local oModal   		:= Nil
	local aCoors      	:= FwGetDialogSize()
	Private nPCodPro	:= 1 
	Private nPLocal 	:= 2
	Private nPosDtIn    := 3
	Private nPosSimu    := 4
	Private nPosDia		:= 5
	Private	nPosData	:= 6
	Private nPDelete	:= 7
	Private oBrwQb     	:= Nil
    Private aBrwData    := {}
	Private cCodProd   	:= cProduto
	Private cLocProd    := cLocal
	Private nConsMed    := nConsumo
	Private nSaldoDisp  := IIF(nDisponivel<0,(nDisponivel * -1 ), nDisponivel )
	Private cSeguranca  := nSeguranca
	Private dDtEnt		:= dDataEntrega

	aBrwData:={	{	IIF(!Empty(cCodProd),cCodProd,space( tamSx3( "ZL_PRODUTO" ))[1]),;  // 1-Produto
					  IIF(!Empty(cLocProd),cLocProd,space( tamSx3( "ZL_LOCAL" ))[1]),;  // 2-Armazem
					  													     dDtEnt ,;  // 3-Data Inical
																			 0.0000 ,;  // 4-Simulação
																			 0.0000 ,;  // 5-Estoque Segurança
									                               cToD("  /  /   "),;	// 6-Data Prevista
					   				                                             .F.}}  // 7-Status Linha .T. Deletada

	
    oModal := FwDialogModal():New()

    oModal:SetTitle('Quebra Solicitacao de Compras')
    oModal:SetEscClose(.F.)
    oModal:SetSize(aCoors[3] / 2.7, aCoors[4] / 2.9)
    oModal:CreateDialog()

    oModal:EnableFormBar(.T.)
    oModal:CreateFormBar()

    oBrwQb := FwBrowse():New()
	oBrwQb:SetOwner(oModal:GetPanelMain())
    oBrwQb:SetDataArray()
    oBrwQb:SetArray(aBrwData)
    oBrwQb:disableConfig()
    oBrwQb:disableReport()
	oBrwQb:SetFilterDefault("aBrwData[oBrwQb:nAt,nPDelete]!=.T.")
	oBrwQb:setInsert( .T. ) 
    oBrwQb:Setdelete(.T.,{ || PX050DEL() } ) 
    oBrwQb:SetBlkBackColor({|| IIf(aBrwData[oBrwQb:nAt,nPDelete]=.T. , CLR_LIGHTGRAY , Nil )})
    
	oBrwQb:addColumn({"Produto", {||aBrwData[oBrwQb:nAt,nPCodPro]}, GetSx3Cache("ZL_PRODUTO","X3_TIPO"), pesqPict("SZL","ZL_PRODUTO") , 1, tamSx3("ZL_PRODUTO")[1] ,, .T. ,, .F.,, "XZL_PRODUTO",, .F., .T.,, "XZL_PRODUTO"})

   	oBrwQb:addColumn({"Local", {||aBrwData[oBrwQb:nAt,nPLocal]}, GetSx3Cache("ZL_LOCAL","X3_TIPO"), pesqPict("SZL","ZL_LOCAL") , 1, tamSx3("ZL_LOCAL")[1] ,, .T. ,, .F.,, "XZL_LOCAL",, .F., .T.,, "XZL_LOCAL"})

	oBrwQb:addColumn({FWX3Titulo("ZL_DTINIC"), {||aBrwData[oBrwQb:nAt,nPosDtIn]}, GetSx3Cache("ZL_DTINIC","X3_TIPO"), pesqPict("SZL","ZL_DTINIC")   , 1, tamSx3("ZL_DTINIC")[1] ,tamSx3("ZL_DTINIC")[2], .T. , , .F.,, "XZL_DTINIC",, .F., .T.,, "XZL_DTINIC"})

	oBrwQb:addColumn({FWX3Titulo("ZL_SIMULA"), {||aBrwData[oBrwQb:nAt,nPosSimu]}, GetSx3Cache("ZL_SIMULA","X3_TIPO"), pesqPict("SZL","ZL_SIMULA")   , 1, tamSx3("ZL_SIMULA")[1] ,tamSx3("ZL_SIMULA")[2], .T. , , .F.,, "XZL_SIMULA",, .F., .T.,, "XZL_SIMULA"})

	oBrwQb:addColumn({FWX3Titulo("ZL_SEGURA"), {||aBrwData[oBrwQb:nAt,nPosDia]}, GetSx3Cache("ZL_SEGURA","X3_TIPO"), pesqPict("SZL","ZL_SEGURA")   , 1, tamSx3("ZL_SEGURA")[1] ,tamSx3("ZL_SEGURA")[2], .T. , , .F.,, "XZL_SEGURA",, .F., .T.,, "XZL_SEGURA"})


	oBrwQb:addColumn({FWX3Titulo("ZL_DATPRF"), {||aBrwData[oBrwQb:nAt,nPosData]}, GetSx3Cache("ZL_DATPRF","X3_TIPO"), pesqPict("SZL","ZL_DATPRF")   , 1, tamSx3("ZL_DATPRF")[1] ,tamSx3("ZL_DATPRF")[2], .T. , , .F.,, "XZL_DATPRF",, .F., .T.,, "XZL_DATPRF"})

	oBrwQb:aColumns[nPCodPro]:XF3 := 'SB1'
    oBrwQb:acolumns[nPCodPro]:ledit     := .F.
    oBrwQb:acolumns[nPCodPro]:cReadVar:= 'aBrwData[oBrwQb:nAt,nPCodPro]'

    oBrwQb:acolumns[nPLocal]:ledit     := .F.
    oBrwQb:acolumns[nPLocal]:cReadVar:= 'aBrwData[oBrwQb:nAt,nPLocal]'

	oBrwQb:acolumns[nPosDtIn]:ledit     := .T.
    oBrwQb:acolumns[nPosDtIn]:cReadVar:= 'aBrwData[oBrwQb:nAt,nPosDtIn]'

    oBrwQb:acolumns[nPosSimu]:ledit     := .T.
    oBrwQb:acolumns[nPosSimu]:cReadVar:= 'aBrwData[oBrwQb:nAt,nPosSimu]'

    oBrwQb:acolumns[nPosDia]:ledit     := .F.

    oBrwQb:acolumns[nPosData]:ledit     := .T.
    oBrwQb:acolumns[nPosData]:cReadVar:= 'aBrwData[oBrwQb:nAt,nPosData]'	

    oBrwQb:setAfterAddLine( { || posIncLine()} )
    oBrwQb:setEditCell( .T.,{ || PX050VLD() } )

    oBrwQb:Activate()

    oModal:AddButton('Gravar'  , { || FX050GRV(),oModal:DeActivate() }, 'Gravar',,.T.,.F.,.T.,)
    oModal:AddButton('Sair'    , { || oModal:DeActivate() }, 'Sair',,.T.,.F.,.T.,)

oModal:Activate()
return

/*/{Protheus.doc} posIncLine
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@return variant, return_description
/*/
Static function posIncLine()
    aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_PRODUTO"):nOrder ] := IIF(!Empty(cCodProd),cCodProd,space( tamSx3( "ZL_PRODUTO" ))[1]        )
	aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_LOCAL"):nOrder ]   := IIF(!Empty(cLocProd),cLocProd,space( tamSx3( "ZL_LOCAL" ))[1]        )
	aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_DTINIC"):nOrder ]  := dDtEnt
	aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_SIMULA"):nOrder ]  := 0.0000
	aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_SEGURA"):nOrder ]  := 0.0000
    aBrwData[ oBrwQb:nAt , oBrwQb:GetColByID("XZL_DATPRF"):nOrder ]    := cTod(" /  /  ")
    aBrwData[ oBrwQb:nAt , nPDelete]                                 := .F.
return
/*/{Protheus.doc} PX050VLD
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@return variant, return_description
/*/
static function PX050VLD()
   Local nPos	:= oBrwQb:ColPos()
   Local cDtIni := IIF(Valtype(aBrwData[oBrwQb:nAt][nPosDtIn]) == "C",ctod(aBrwData[oBrwQb:nAt][nPosDtIn]),aBrwData[oBrwQb:nAt][nPosDtIn])
   Local nDias  := 0 
   Local cCalcData := cDtIni

   IF !Empty(aBrwData[oBrwQb:nAt][nPCodPro])
      if nPos = nPosSimu
	     nDias := aBrwData[oBrwQb:nAt][nPosSimu] / nConsMed
		 cCalcData := cDtIni + nDias 
         dDtEnt    := cCalcData
	     aBrwData[oBrwQb:nAt][nPosDia] 	:=  nDias 	
 		 aBrwData[oBrwQb:nAt][nPosData] := cCalcData
      endif
   Endif
Return(.T.)

/*/{Protheus.doc} PX050DEL
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@return variant, return_description
/*/
Static Function PX050DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrwQb:nAt
	 Local nPosDelet   := 7
     Local lSit        := oBrwQb:LDELETE
	 if lSit 
        if MsgYesNo("Deseja excluir a linha desse produto","Atenção")
		   aBrwData[nLinha][nPosDelet] := .T.
		   aDel(aBrwData, nLinha)
           aSize(aBrwData, Len(adespes) - 1)
		Endif
	 Endif	
	 oBrwQb:Reset()
     oBrwQb:setArray(aBrwData)	// Forço o Browse a ler os novos valores informados.
     oBrwQb:GoTop()
     oBrwQb:Refresh(.T.)	
     FWRestArea(cArea)
RETURN


/*/{Protheus.doc} FX050GRV
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@return variant, return_description
/*/
Static Function FX050GRV()
    Local cArea := FWGetArea()
	Local I,xY
	Local arDt  := {}
	Local cDentrega := " "

    FOR I:=1 TO LEN(aBrwData)
         
         cSeq := StrZero(I,3)
         dbSelectArea("SZL")
         SZL->( dbSetOrder(1) )
         IF SZL->( !dbSeek(xFilial("SZL")+Alltrim(aBrwData[I][nPCodPro])+Alltrim(aBrwData[I][nPLocal])+IIF(ValType(aBrwData[I][nPosDtIn])=="D",Dtos(aBrwData[I][nPosDtIn]),Dtos(ctod(aBrwData[I][nPosDtIn]) )),.T. ) )
                  IF RecLock("SZL",.T.)
                           SZL->ZL_FILIAL       :=    xFilial("SZL")
                           SZL->ZL_PRODUTO      :=    aBrwData[I][nPCodPro]
                           SZL->ZL_LOCAL        :=    aBrwData[I][nPLocal]
						   SZL->ZL_DTINIC       :=    IIF(Valtype(aBrwData[I][nPosDtIn])=="C",CTOD(aBrwData[I][nPosDtIn]),aBrwData[I][nPosDtIn])
                           SZL->ZL_SIMULA       :=    aBrwData[I][nPosSimu]
						   SZL->ZL_SEGURA       :=    aBrwData[I][nPosDia]
                           SZL->ZL_DATPRF       :=    IIF(Valtype(aBrwData[I][nPosData])=="C",CTOD(aBrwData[I][nPosData]),aBrwData[I][nPosData])
                           SZL->ZL_STATUS       :=    "A"
                        MsUnlock()
                  Endif  
         ENDIF
		 aAdd(arDt,{IIF(Valtype(aBrwData[I][nPosData])=="C",CTOD(aBrwData[I][nPosData]),aBrwData[I][nPosData]),cValtoChar( aBrwData[I][nPosSimu])})
    Next

    if len(arDt) > 0
	   For xY:=1 to  len(arDt)
            cDentrega += Dtoc( arDt[xY][1] ) + " "+cValtoChar( arDt[xY][2] )+" / "
	   Next		
    Endif

	adespes[oBrowse:nAt][nPosEnt] := cDentrega
	oBrowse:Refresh()
    FwRestArea(cArea)

Return

/*/{Protheus.doc} FM050LINE
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function FM050LINE(cProduto)
	Local oScroll
	Local nGrafico := LINECHART
	Static oMonitor
 
	DEFINE MSDIALOG oMonitor TITLE "Grafico" FROM 0,0  TO 600,900 COLORS 0, 16777215 PIXEL 
	oScroll := TScrollArea():New(oMonitor,01,01,500,800)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT    
	Grafico(oScroll,nGrafico,cProduto)
	
	oMenu := TBar():New( oMonitor, 48, 48, .T., , ,"CONTEUDO_BODY-FUNDO", .T. )
	DEFINE BUTTON RESOURCE "FW_LINECHART_1"		OF oMenu	ACTION Grafico(oScroll,LINECHART,cProduto) 	 PROMPT " "	TOOLTIP "Linha"			
	DEFINE BUTTON RESOURCE "FW_BARCOMPCHART_2"	OF oMenu	ACTION Grafico(oScroll,BARCOMPCHART,cProduto) PROMPT " "	TOOLTIP "Barra"			
	ACTIVATE MSDIALOG oMonitor CENTERED
Return
/*/{Protheus.doc} Grafico
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@param oScroll, object, param_description
@param nGrafico, numeric, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function Grafico(oScroll,nGrafico,cProduto)
    Local cArea := FWGetArea()
	Local oChart
	Local cQuery:= ""
	Local cAnoAtu := alltrim(Str(Year(dDataBase)))
	Local cAnoAnt := alltrim(str(Year(dDataBase)-1))
	Local cMesAtu := month(dDataBase)
	Local cMeses  := month(dDataBase)
	Local AB
	Local aDados := {}

	If Valtype(oChart)=="O"
		FreeObj(@oChart) //Usando a função FreeObj liberamos o objeto para ser recriado novamente, gerando um novo gráfico
	Endif
	
	oChart := FWChartFactory():New()
	oChart := oChart:getInstance( nGrafico ) 
	oChart:init( oScroll )
	oChart:SetTitle("Demandas por Ops", CONTROL_ALIGN_LEFT)
	oChart:SetMask( "QTD *@*")
	oChart:SetPicture("@E 999,999,999.9999")
	oChart:setColor("Random") //Deixamos o protheus definir as cores do gráfico
	oChart:nTAlign := CONTROL_ALIGN_ALLCLIENT
 
	//Uma consulta bem Simples

	cQuery := "SELECT ZP_COD, ZP_Q01, ZP_Q02, ZP_Q03, ZP_Q04, ZP_Q05, ZP_Q06, ZP_Q07, ZP_Q08, ZP_Q09, ZP_Q10, ZP_Q11, ZP_Q12 FROM "+ RETSQLNAME("SZP") + " WHERE D_E_L_E_T_ = ' ' AND ZP_FILIAL = ? AND  ZP_COD = ?"
    cQuery 		:= ChangeQuery(cQuery)
	aBindParam 	:= {xFilial("SZP"), cProduto}
	cAlias  	:= MPSysOpenQuery(cQuery,,,,aBindParam)
    if (cAlias)->(Eof())
        MsgAlert("Sem dados para o Grafico")
		Return
    ENDIF

    While (cAlias)->( !Eof() )

	   	FOR AB:=1 TO 12
	
			XCAMPO := "(cAlias)->ZP_Q"+strzero(cMeses,2)							
			aAdd(aDados,{ strzero(cMeses,2)+"/"+IIF(cMeses <= cMesAtu ,Substr(cAnoAtu,3,2),Substr(cAnoAnt,3,2)), &(XCAMPO)})
	
			cMeses:= cMeses - 1
	
			if cMeses <= 0
				cMeses := 12
    		endif

		NEXT 

        
  			oChart:addSerie( cProduto, { {ADADOS[1][1],ADADOS[1][2]},;
										 {ADADOS[2][1],ADADOS[2][2]},;
										 {ADADOS[3][1],ADADOS[3][2]},;
										 {ADADOS[4][1],ADADOS[4][2]},;
										 {ADADOS[5][1],ADADOS[5][2]},;
										 {ADADOS[6][1],ADADOS[6][2]},;
										 {ADADOS[7][1],ADADOS[7][2]},;
										 {ADADOS[8][1],ADADOS[8][2]},;
										 {ADADOS[9][1],ADADOS[9][2]},;
										 {ADADOS[10][1],ADADOS[10][2]},;
										 {ADADOS[11][1],ADADOS[11][2]},;
										 {ADADOS[12][1],ADADOS[12][2]} })

 			oChart:setLegend( CONTROL_ALIGN_LEFT ) 
			oChart:Build()
		(cAlias)->( dbSkip() )	
	EndDo 
	(cAlias)->( dbcloseArea() )
    FwRestArea(cArea)	
Return


/*/{Protheus.doc} AlteraPC
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@param nRecno, numeric, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Static Function AlteraPC(nRecno,nOpc)
    Local aArea		:= GetArea()
    Local aAreaSC7	:= SC7->(GetArea())
    dbSelectArea("SC7")
    SC7->(dbGoto(nRecno))

    //Mata120(ExpN1,ExpA1,ExpA2,ExpN2,ExpA1)
    /*
    ExpN1 = 1-Pedido de compras ou 2-Autorizacao de entrega
    ExpA1 = Array Cabecalho para Rotina Automatica 
    ExpA2 = Array Itens para Rotina Automatica 
    ExpN2 = Opcao do aRotina para Rotina Automatica 
    ExpA1 = Apresenta a Dialog da Rotina em Rotina Automatica (.T. ou .F.)
    */
    Mata120(1,/*aCabec*/,/*aItens*/,nOpc,.T.) 
	RestArea(aAreaSC7) 
	RestArea(aArea) 
Return .T.
/*/{Protheus.doc} NFEVisua
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/01/2024
@param nRecno, numeric, param_description
@return variant, return_description
/*/
Static Function NFEVisua(nRecno)
	Local cArea := FwGetArea()
	Local cAreaSD1 := SD1->(GetArea())
	Local cAreaSF1 := SF1->(GetArea())
	Private aRotina:={}
	
	dbSelectArea("SD1")
	SD1->(dbGoto(nRecno))
	dbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	IF SF1->( dbSeek(SD1->D1_FILIAL  +  SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ,.T.))
       A103NFiscal("SF1",SF1->(Recno()),2)
	Endif
	FwRestArea(cAreaSF1)
    FwRestArea(cAreaSD1)
    FwRestArea(cArea)
Return .T.
