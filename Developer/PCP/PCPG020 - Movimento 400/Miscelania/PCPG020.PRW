#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"


#Define cEof    Chr(13)+Chr(10)

/*/{Protheus.doc} PCPG020
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/02/2025
@return variant, return_description
/*/
User Function PCPG020()
    Local aArea         := FWGetArea()
    Local lRet          := .T.
    Local cCodTm        := Space(3)
    Local cCodProd      := ""
    Local cLote         := ""
    Local nQtde         := 0
    Local cLocal        := ""
    Local dtValid       := CtoD("01/01/1900")                                                                                                   
    Local nQtdEmp       := 0
    Local nQtdSC2       := 0
    Local nQtdSD3       := 0

    Static oTMsgItem1 // Objeto para exibir o total atualizado

    Private nTotal := 0
    Private cLotePrincipal  := cLote
    Private nQtdePrincial   := nQtde
    Private nSldPrincial    := nQtdEmp

    IF FWCodFil() <> "0803"
       Return(lRet)
    Endif

    if FunName() == "MATA261"
          FwRestArea(aArea)
          Return(lRet)
    endif    

    cCodTm        := CTM
    cCodProd      := AllTrim(aCols[n][nposcod])
    cLote         := IIF(Empty(AllTrim(aCols[n][nposlotctl])),M->D3_LOTECTL,AllTrim(aCols[n][nposlotctl]))
    nQtde         := aCols[n][nposquant]
    cLocal        := AllTrim(aCols[n][nposlocal])
    dtValid       := aCols[n][nposdvalid]                                                                                                   

    nQtdSC2       := PCP20SC2(cCodProd,cLote,cLocal) 
    nQtdSD3       := PCP20SD3(cCodProd,cLote,cLocal)    
 
    cLotePrincipal := cLote
    nQtdePrincial := nQtde
    
    nQtdSD3 := nQtdSD3 + nQtde
    
    IF cCodTm == "400"

        if dtValid < DATE()
            MsgStop("Data de Validade menor que a data atual : "+DTOS(dtValid))
            lRet := .F.
        endif    

        if nQtde = 0
            MsgStop("Campo Quantidade zerado")
            lRet := .F.
        endif


        if Empty(cLote)
            MsgStop("Campo Lote não preenchido")
            lRet := .F.
        endif

        IF nQtdSD3 > nQtdSC2
            nQtdLimite := nQtdSC2 - (nQtdSD3 - nQtde)
            MsgStop("Quantidade Movimentação "+cValtoChar(nQtdSD3)+"  maior que a disponível no Lote : "+cValtoChar(nQtdSC2)+" "+ Chr(13) + Chr(10) +"Limite de "+cValtoChar(nQtdLimite)+" para completar a Quantidade do Lote : "+cValtoChar(nQtdSC2))
            lRet := .F.
        Endif
    endif
    if lRet
        if ExistBlock("PCP020Saldo")
                   aDados:= {cCodProd,nQtdSC2}
                   lRet:=ExecBlock("PCP020Saldo",.F.,.F.,aDados)   
        Endif           
    endif    

    FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP20SC2
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/03/2025
@param cProduto, character, param_description
@param cLote, character, param_description
@param cLocal, character, param_description
@return variant, return_description
/*/
Static Function PCP20SC2(cProduto,cLote,cLocal)
    Local aArea   := FwgetArea()
    Local cAlias := "PCP_"+getNextAlias() 
    Local cQuery := ""
    Local lRet   := 0

    cQuery:= "Select C2_QUANT  "+cEof
    cQuery+= "from " + RetSqlName("SC2") + "  SC2  "+cEof
    cQuery+= "Where SC2.D_E_L_E_T_ = ' '  "+cEof
    cQuery+= "AND C2_FILIAL ='"+xFilial("SC2")+"' "+cEof
    cQuery+= "AND C2_PRODUTO =  '"+Alltrim(cProduto)+"' "+cEof
    cQuery+= "AND C2_LOCAL = '"+Alltrim(cLocal)+"' "+cEof
    cQuery+= "AND C2_NUM = '"+Alltrim(cLote)+"' "+cEof
    cQuery+= "AND C2_DATRF = ' '  "+cEof

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(lRet)
    endif  

    lRet := (cAlias)->(C2_QUANT)

    (cAlias)->(DbCloseArea()) 
    FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP20SD3
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/03/2025
@param cProduto, character, param_description
@param cLote, character, param_description
@param cLocal, character, param_description
@return variant, return_description
/*/
Static Function PCP20SD3(cProduto,cLote,cLocal)
    Local aArea   := FwgetArea()
    Local cAlias := "PCP_"+getNextAlias() 
    Local cQuery := ""
    Local lRet   := 0

    cQuery:= "SELECT D3_TM,D3_QUANT  "+cEof
    cQuery+= "FROM " + RetSqlName("SD3") + "  SD3  "+cEof
    cQuery+= "WHERE SD3.D_E_L_E_T_ = ' '  "+cEof
    cQuery+= "AND D3_FILIAL = '"+xFilial("SD3")+"' "+cEof
    cQuery+= "AND D3_COD =  '"+Alltrim(cProduto)+"' "+cEof
    cQuery+= "AND D3_LOCAL ='"+Alltrim(cLocal)+"' "+cEof
    cQuery+= "AND D3_LOTECTL = '"+Alltrim(cLote)+"' "+cEof

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(lRet)
    endif  

    While !(cAlias)->(Eof())
        IF (cAlias)->D3_TM <= '499'
           lRet:= lRet + (cAlias)->D3_QUANT
         else
           lRet:= lRet - (cAlias)->D3_QUANT            
        Endif    
        (cAlias)->( dbSkip() )
    Enddo

    (cAlias)->(DbCloseArea()) 
    FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP020Saldo
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
User Function PCP020Saldo()
    Local aArea   := FwgetArea()
    Local cAlias := "PCP_"+getNextAlias() 
    Local cQuery := ""
    Local cProduto :=  PARAMIXB[1]
    Local nSldLote :=  PARAMIXB[2]
    Local lRet   := .T.

    cQuery:= "Select	 G1_COMP  Codigo "+cEof
    cQuery+= "		,B1_DESC  Descricao "+cEof
    cQuery+= "		,B2_LOCAL Almox "+cEof
    cQuery+= "		,B2_QATU  Saldo "+cEof
    cQuery+= "		,B2_QEMP  Empenho "+cEof
    cQuery+= "		,(B2_QATU - B2_QEMP ) Disponivel "+cEof
    cQuery+= "from " + RetSqlName("SG1") + " SG1 "+cEof
    cQuery+= "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = G1_COMP AND B1_TIPO = 'EM' AND B1_XTPCOMP = 'P' AND SB1.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = G1_FILIAL AND B2_COD = G1_COMP AND B2_LOCAL = B1_LOCPAD AND SB2.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "Where SG1.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "AND G1_FILIAL = '"+xFilial("SG1")+"' "+cEof
    cQuery+= "AND G1_COD = '"+Alltrim(cProduto)+"' "+cEof
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            lRet := .F.
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(lRet)
    endif  

    While !(cAlias)->(Eof())
         IF (cAlias)->(Disponivel) <= 0
            cProduto := (cAlias)->(Codigo)
            cLocal   := (cAlias)->(Almox)
            nSaldo   := (cAlias)->(Saldo)
            nEmpenho := (cAlias)->(Empenho)
            nDispon  := (cAlias)->(Disponivel)
            lRet := .F.
         ENDIF    
        (cAlias)->(DbSkip())
    Enddo
    (cAlias)->(DbCloseArea()) 

    if  !lRet
        if ExistBlock("PCP020Emp")
                   aDados:= {cProduto,cLocal,nSaldo,nEmpenho,nDispon,nSldLote}    
                   lRet:=ExecBlock("PCP020Emp",.F.,.F.,aDados)   
        Endif       
    Endif

    FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP020Emp
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
User Function PCP020Emp() 
    Local aArea     := FwgetArea()
    Local cAlias    := "PCP_"+getNextAlias() 
    Local cQuery    := ""
    Local cProduto  :=  PARAMIXB[1]
    Local cLocal    :=  PARAMIXB[2]
    Local nSaldo    :=  PARAMIXB[3]
    Local nEmpenho  :=  PARAMIXB[4]
    Local nDispon   :=  PARAMIXB[5]
    Local nSldLote  :=  PARAMIXB[6]
    Local lRet      := .T.

    Local oDlgMark   as Object 

    Local oOk        := LoadBitmap( GetResources(), "LBOK" )
    Local oNo        := LoadBitmap( GetResources(), "LBNO" )
    Local aSize      := MsAdvSize()

    Local bOk 		:= {|| PCP020GRV(aBrowse),oDlgMark:End()  }
    Local bCancel	:= {|| lRet:=Saidosistema()	,oDlgMark:End() }

    Private aBrowse    := {}
    Private oBrwMark as Object 
    Private nTotalSaldo := (nSaldo - nSldLote )
    Private nTotalMark  := 0

    
    oMainWnd:ReadClientCoors()
    nHeight := (oMainWnd:nHeight-50)/2
    nWidth  := (oMainWnd:nWidth-15)/2

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 


    cQuery:= "Select Substring(D4_OP,1,6) LOTE "+cEof
    cQuery+= "		,D4_COD  CODIGO "+cEof
    cQuery+= "		,D4_QUANT QTDE "+cEof
    cQuery+= "		,D4_PRODUTO PRODUTO"+cEof
    cQuery+= "		,B1_DESC DESCRICAO "+cEof
    cQuery+= "		,D4_LOCAL ALMOX "+cEof
    cQuery+= "      ,C2_DATRF PREVISTO "+cEof
    cQuery+= "      ,D4_OP OP "+cEof
    cQuery+= "from  " + RetSqlName("SD4") + "   SD4  "+cEof
    cQuery+= "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D4_PRODUTO  AND SB1.D_E_L_E_T_ = ' '  "+cEof
    cQuery+= "INNER JOIN " + RetSqlName("SC2") + "  SC2 ON C2_FILIAL = D4_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP  AND SC2.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "WHERE SD4.D_E_L_E_T_ = ' '  "+cEof
    cQuery+= "AND D4_FILIAL = '"+xFilial("SG1")+"'  "+cEof
    cQuery+= "AND D4_QUANT > 0  "+cEof
    cQuery+= "AND D4_LOCAL = '"+Alltrim(cLocal)+"'  "+cEof
    cQuery+= "AND D4_COD = '"+Alltrim(cProduto)+"'   "+cEof
    cQuery+= "AND D4_XDOC = ' '   "+cEof
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            lRet := .F.
            (cAlias)->(DbCloseArea())   
            FWAlertError( 'Não tem movimento para gerar Empenhos', 'Empenhos em aberto' )
            FwRestArea(aArea)
            Return(lRet)
    endif  
    If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())

                 aAdd( aBrowse, { .F.,;
                            (cAlias)->LOTE,;
                            (cAlias)->CODIGO,;
                            (cAlias)->QTDE,;
                            (cAlias)->PRODUTO,;
                            (cAlias)->DESCRICAO,; 
                            (cAlias)->ALMOX,;
                            Dtoc(SToD((cAlias)->PREVISTO)),;
                            (cAlias)->OP } )

               (cAlias)->(dbSkip() )
          End
    Endif
   (cAlias)->(DbCloseArea())       

   nTotalMark  := PCP020CALCEMP(cProduto,cLocal)

   nTotalSaldo := nTotalSaldo - nTotalMark

   oDlgMark := MSDialog():New(aSize[7],0, nHeight,nWidth,"Selecione o Empenho",,,.F.,,,,,,.T.,,,.T. )

   oDlgMark:bInit := {||EnchoiceBar(oDlgMark,{|| FWMsgRun(, {|oDlgMark| U_PCP20CALC(oDlgMark) }, "Processando", "Processando a rotina...") ,oDlgMark:End()},{|| oDlgMark:End()},,)}
  

   oBrwMark := TCBrowse():New( aSize[7]+35,5, nHeight,nWidth,,{' ','Lote','Embalagem', 'Quantidade','Produto','Descricao','Local','Previsto','Numero OP'},{010,050,100,010,050,050,050,050,050},oDlgMark,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )
   
   oBrwMark:SetArray( aBrowse )
   oBrwMark:bLine := {||{ iIf( aBrowse[oBrwMark:nAt][01], oOK, oNO ) ,;  	                // 1 Marcação
                               aBrowse[oBrwMark:nAt,02],;							        // 2 Lote
                               aBrowse[oBrwMark:nAt,03],;							        // 3 Embalagem
                               Transform(aBrowse[oBrwMark:nAt,04],"@E 999999,99999"),;      // 4 Quantidade
                               aBrowse[oBrwMark:nAt,05],;							        // 5 Produto  
                               aBrowse[oBrwMark:nAt,06],;                                   // 6 Descricao
                               aBrowse[oBrwMark:nAt,07],;                                   // 7 Local
                               aBrowse[oBrwMark:nAt,08],;                                   // 8 Data Prevista
                               aBrowse[oBrwMark:nAt,09]} }                                  // 9 Numero da OP

   oBrwMark:GoTop()
   oBrwMark:bLDblClick := { || fLDblClick() }
   oBrwMark:bHeaderClick := { || fHeadClick() }
  
   oTMsgBar := TMsgBar():New(oDlgMark, 'Totais',.F.,.F.,.F.,.F., RGB(88,24,69),,,.F.)   //RGB(116,116,116)

   if nTotalMark > 0
        oTMsgItem1 := TMsgItem():New( oTMsgBar,"Saldo "+transform(nTotalSaldo,"@E 999,999,999.99"), 100,,,,.T., {|| } ) 
   else
        oTMsgItem1 := TMsgItem():New( oTMsgBar,"Saldo "+transform((nSaldo - nSldLote),"@E 999,999,999.99"), 100,,,,.T., {|| } )
   endif    

   oTMsgItem2 := TMsgItem():New( oTMsgBar,"Qtde Lote "+transform(nSldLote,"@E 999,999,999.99"), 100,,,,.T., {||} ) 

   oTMsgItem3 := TMsgItem():New( oTMsgBar,"Disponivel "+transform(nDispon,"@E 999,999,999.99"), 100,,,,.T., {||} )

   oTMsgItem4 := TMsgItem():New( oTMsgBar,"Empenho "+transform(nEmpenho,"@E 999,999,999.99"), 100,,,,.T., {||} )

   oTMsgItem5 := TMsgItem():New( oTMsgBar,"Saldo Estoque "+transform(nSaldo,"@E 999,999,999.99"), 100,,,,.T., {||} )
 
   oTMsgItem6 := TMsgItem():New( oTMsgBar,"Selecionados "+transform(nTotalMark,"@E 999,999,999.99"), 100,,,,.T., {||} )

   ACTIVATE MSDIALOG oDlgMark ON INIT EnchoiceBar(oDlgMark, bOk , bCancel) CENTERED
   //oDlgMark:Activate(,,,.T.)

    FwRestArea(aArea)
Return(lRet)


/*/{Protheus.doc} fLDblClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
Static Function fLDblClick()
    aBrowse[oBrwMark:nAt][1] := ( ! aBrowse[oBrwMark:nAt][1] )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
    MarcaLinha()
Return( NIL )

/*/{Protheus.doc} fHeadClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
Static Function fHeadClick()
    aEval( aBrowse, { |cValue,nIndex| aBrowse[nIndex][1] := ( ! aBrowse[nIndex][1] ) } )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
    MarcaLinha()
Return( NIL )
 
/*/{Protheus.doc} MarcaLinha
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
Static Function MarcaLinha()
    Local nLinha    := oBrwMark:nRowPos // Obtém a posição da linha
    Local nStatus   := oBrwMark:GetBrowse():AARRAY[nLinha][1]
    Local cEmbalagem:= oBrwMark:GetBrowse():AARRAY[nLinha][3]
    Local nQtde     := oBrwMark:GetBrowse():AARRAY[nLinha][4]
    Local cProduto  := oBrwMark:GetBrowse():AARRAY[nLinha][5]

 
    IF nStatus
        oBrwMark:GetBrowse():AARRAY[nLinha][1] := .T.
        nTotal += nQtde
        nTotalMark += nQtde
    Else
        oBrwMark:GetBrowse():AARRAY[nLinha][1] := .F.
        nTotal -= nQtde
        nTotalMark -= nQtde
    Endif     

    oTMsgItem6:Refresh() // Atualiza a exibição do total na tela

    if nTotalSaldo > nTotal
        oBrwMark:Refresh()
    else
        If MsgYesNo("Quantidade maior que a disponível no Lote : "+cValtoChar(nTotalSaldo) + Chr(13) + Chr(10) + "Deseja continuar com o  " + cProduto, "Confirma?")
            If ExistBlock("PCP020Ord")
                aDados:= {cEmbalagem}
                ExecBlock("PCP020Ord",.F.,.F.,aDados)   
            Endif
        endif
    endif    

Return

/*/{Protheus.doc} Saidosistema
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
static function Saidosistema()

msgAlert("Abortando o Processo....")

return(.F.)


/*/{Protheus.doc} PCP020Ord
description
@type function
@version 1.0
@author Paulo Lenzi
@since 25/02/2025
@return variant, return_description
/*/
User Function PCP020Ord()
    Local aArea         := FWGetArea()
    Local cEmbalagem    := PARAMIXB[1]
    Local cPara         := UsrRetMail( RetCodUsr() )  //"alex.blasques@qualyvinil.com.br" +";"+ UsrRetMail( RetCodUsr() )
    Local lExibeHelp    := .F.
    Local ny            := 0
    Local nCtaLin       := 0

    Private oDlg
    Private cMotivo     := ""
    Private cJust       := Space(3)
    Private cCodMot     := Space(3)
    Private lMotivo     := .T.    
    Private cMensagem  := ""

    Private aCabec      as Array
    Private aCabec2     as Array
    Private aColunas    as Array
    Private cMark       := ' '

   

    Do While lMotivo

    		DEFINE MSDIALOG oDlg TITLE "Informe o Motivo e Justificativa " FROM C(178),C(181) TO C(551),C(872) PIXEL

			@ C(002),C(002) TO C(164),C(341) LABEL "Digite um motivo válido para confirmação" PIXEL OF oDlg

			@ C(013),C(006) Say "Justificativa:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg
			@ C(013),C(038) MsGet oJust Var cJust F3 "Z3" Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
			@ C(023),C(006) Say "Motivo:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg
			@ C(023),C(038) GET oMemo1 Var cMotivo MEMO Size C(299),C(129) PIXEL OF oDlg
			@ C(167),C(303) Button "Confirmar" Size C(037),C(012) Action (oDlg:End()) PIXEL OF oDlg

			oJust:bValid := {|| !Empty( cJust ) .And. fGat(1) }
		
	  	   ACTIVATE MSDIALOG oDlg CENTERED

            If Len( AllTrim( cMotivo ) ) > 4
                lMotivo := .F.
            Else
			ApMsgAlert('Informe um motivo válido!', 'Atenção')
		EndIf

		If !lMotivo
			If Empty( Tabela("Z3", cJust) )
				ApMsgAlert('Selecione uma Justificativa válido!', 'Atenção')
				lMotivo := .T.
			EndIf
		EndIf

    EndDo
  
    aCabec := {}
    aCabec2:= {}

	aAdd( aCabec, {{'<B><Font Size=4 color=white>Movimento 400</Font></B>', '6', 100, 6, 'C'}})

	aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' +"Registro Movimentacao 400"+'</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Tipo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + "Empenho" + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Justificativa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cJust ) + " - " + Tabela("Z3", cJust) + '</Font>', '1', 90, 5, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})

    aAdd( aCabec, {{'<B><Font Size=4 color=white>MOVIMENTO 400</Font></B>', '6', 100, 6, 'C'}})

    aAdd( aCabec2, {{'<B><Font Size=4 color=white>DETALHAMENTO MOVIMENTO 400</Font></B>', '6', 100, 6, 'C'}})

    aColsPrinc := {}
    aAdd( aColsPrinc, {'Lote'			    , 06	, 'C'})
    aAdd( aColsPrinc, {'Embalagem'			, 15	, 'C'})
    aAdd( aColsPrinc, {'Quantidade'			, 13	, 'N'})
    aAdd( aColsPrinc, {'Saldo'			    , 13	, 'N'})      
    cMensagem += U_BeHtmHead( '',.T.,aCabec, aColsPrinc )

    aColsPrinc := {}
    aAdd( aColsPrinc, {AllTrim(cLotePrincipal) , 06	, 'C'})
    aAdd( aColsPrinc, {AllTrim(cEmbalagem)	, 15	, 'C'})
    aAdd( aColsPrinc, {cvaltochar(nQtdePrincial), 13	, 'N'})
    aAdd( aColsPrinc, {cvaltochar(nSldPrincial) , 13	, 'N'})
    cMensagem += U_BeHtmDet( aColsPrinc, .F. , .F. )


	aColunas := {}
	aAdd( aColunas, {'Lote'				    , 06	, 'C'})
	aAdd( aColunas, {'Embalagem'			, 15	, 'C'})
	aAdd( aColunas, {'Quantidade'			, 13	, 'N'})
	aAdd( aColunas, {'Produto'			    , 15	, 'C'})
    aAdd( aColunas, {'Descricao'			, 100	, 'C'})
    aAdd( aColunas, {'Local'				, 02	, 'C'})
    aAdd( aColunas, {'Data Prevista'		, 08	, 'C'})
    aAdd( aColunas, {'Ordem Producao'		, 11	, 'C'})
    aAdd( aColunas, {'ID'	            	, 01	, 'C'})

	cMensagem += U_BeHtmHead( '',.T.,aCabec2, aColunas ) //U_BeHtmDet( aColunas, .F. , .F. )


	aColunas := {}

    cMark    := ' '
    
    if len(aBrowse) > 0
       for ny:=1 to len(aBrowse)
           if aBrowse[ny][1]
               nCtaLin := nCtaLin + 1
           Endif
       next 
    Endif


    if len(aBrowse)>0
       for ny:=1 to len(aBrowse)
           if aBrowse[ny][1]

                cMark := iif(ny == nCtaLin,"X"," " )

                aAdd( aColunas, {AllTrim(aBrowse[ny][2])	        , 06	, 'C'})
                aAdd( aColunas, {AllTrim(aBrowse[ny][3])	        , 15	, 'C'})
                aAdd( aColunas, {cvaltochar(aBrowse[ny][4])         , 13	, 'C'})
                aAdd( aColunas, {AllTrim(aBrowse[ny][5])	  	 	, 15	, 'C'}) 
                aAdd( aColunas, {AllTrim(aBrowse[ny][6])	    	, 50	, 'C'})
                aAdd( aColunas, {AllTrim(aBrowse[ny][7])	    	, 02	, 'C'})
                aAdd( aColunas, {Dtoc(SToD(aBrowse[ny][8]))         , 08	, 'C'})
                aAdd( aColunas, {Alltrim(aBrowse[ny][9])            , 11	, 'C'})
                aAdd( aColunas, {cMark                              , 01	, 'C'})

                cMensagem += U_BeHtmDet( aColunas, .F. , .F. )
                
                aColunas := {}
           endif 
       Next
    Endif
    
    cMensagem += U_BeHtmRod(.T.)
   
    cAssunto := "Movimentacao 400, Lote : " + cLotePrincipal + " Embalagem : " + cEmbalagem

    cCorpo   := cMensagem
    aAnexos  :={}

    lEnvio   := u_TManagerEmail(cPara, cAssunto, cCorpo, aAnexos, lExibeHelp, .T.)
   
    If lEnvio
        FWAlertSuccess("Sucesso no disparo do e-Mail", "Sucesso")
    Else
        FWAlertError("Falha no disparo do e-Mail", "Atenção (Erro)")
    EndIf

    FwRestArea(aArea)
Return

/*/{Protheus.doc} fGat
description
@type function
@version 1.0
@author Paulo Lenzi
@since 31/03/2025
@param nOp, numeric, param_description
@return variant, return_description
/*/
Static Function fGat( nOp )
If nOp == 1
	@ C(014),C(088) Say Tabela("Z3", cJust) Size C(162),C(008) COLOR CLR_HBLUE PIXEL OF oDlg
EndIf
Return .T.

/*/{Protheus.doc} PCP020GRV
description
@type function
@version 1.0
@author Paulo Lenzi
@since 31/03/2025
@param aBrowse, array, param_description
@return variant, return_description
/*/
Static Function PCP020GRV(aBrowse)
    Local aArea         := FWGetArea()
    Local nLinhas       := Len(aBrowse)
    Local Ny            := 0
    if nLinhas > 0
       For Ny :=1 to nLinhas
          if aBrowse[nY][1]
             DbSelectArea("SD4")
             SD4->( dbSetOrder(1))
             if SD4->( dbSeek(xFilial("SD4")+aBrowse[Ny][3]+aBrowse[Ny][9],.T. ))
                if Reclock("SD4",.F.)
                   SD4->D4_XDOC = CDOCUMENTO
                   SD4->( MsUnlock() )
                Endif
             Endif
          Endif   
       Next 
    Endif

    FwRestArea(aArea)
Return

/*/{Protheus.doc} PCP020CALCEMP
description
@type function
@version 1.0
@author Paulo Lenzi
@since 02/04/2025
@param cProduto, character, param_description
@param cLocal, character, param_description
@return variant, return_description
/*/
Static Function PCP020CALCEMP(cProduto,cLocal)
    Local aArea     := FWGetArea()
    Local cAlias    := "PCP_"+getNextAlias() 
    Local cQuery    := ""
    Local lRet      := 0

    cQuery:= "Select sum(D4_QUANT) D4_QUANT "+cEof
    cQuery+= "from   " + RetSqlName("SD4") + "    SD4   "+cEof
    cQuery+= "WHERE SD4.D_E_L_E_T_ = ' '  "+cEof 
    cQuery+= "AND D4_FILIAL =  '"+xFilial("SG1")+"'  "+cEof
    cQuery+= "AND D4_QUANT > 0   "+cEof
    cQuery+= "AND D4_LOCAL = '"+Alltrim(cLocal)+"'   "+cEof
    cQuery+= "AND D4_COD = '"+Alltrim(cProduto)+"'   "+cEof
    cQuery+= "AND D4_XDOC != ' ' "+cEof
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(lRet)
    endif  
    If (cAlias)->(!EOF())
        lRet := (cAlias)->D4_QUANT
    ENDIF

    FwRestArea(aArea)
Return(lRet)
//---------------------------------------------------------------------------//
// Final do Programa
//---------------------------------------------------------------------------//
