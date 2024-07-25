//Bibliotecas
#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/{Protheus.doc} Ms520Vld
description Ponto de Entrada que vai enviar uma notificação para o Departamento Fiscal sobre exclusão
@type function
@version 1.0
@author Paulo Lenzi
@since 24/07/2024
@return variant, return_description
/*/              
user Function M521DNFS()
    Local cArea     := FwGetArea()
    Local aDados    as Array
    Local aPedidos  := ParamIxb[1]
    Local nHoras    := SubtHoras(SF2->F2_DAUTNFE, SF2->F2_HAUTNFE,dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
    Local nSpedExc  := GetNewPar("MV_SPEDEXC",24)
   
    If nHoras > nSpedExc
       FWAlertError("Não foi possível excluir a(s) nota(s), pois o prazo em horas para o cancelamento da(s) NF-e ?de: "+nSpedExc+ " horas", "Aviso ")
       FwRestArea(cArea)
       Return(.F.)
    endif
   
    if ExistBlock("CompoemNF")
       aDados:= {SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA, SF2->F2_EMISSAO,SF2->F2_TIPO,aPedidos}
       ExecBlock("CompoemNF",.F.,.F.,aDados)   
    Endif

    FwRestArea(cArea)
Return(.T.)

/*/{Protheus.doc} CompoemNF
@type function Tela para digitar o motivo do cancelamento
@version 1.0
@author Paulo Lenzi
@since 24/07/2024
@return variant, return_description
/*/
User Function CompoemNF()
    Local cNumNota      := PARAMIXB[1]
    Local cSerNota      := PARAMIXB[2]
    Local cCliNota      := PARAMIXB[3]
    Local cLojaNota     := PARAMIXB[4]
    Local cEmisNota     := PARAMIXB[5]
    Local cTipoNota     := PARAMIXB[6]
    LOCAL aPedidos      := PARAMIXB[7]

    Local cPara      := GetMV("MV_BE_NFSX",,"paulo.lenzi@euroamerican.com.br")
    Local cAssunto   := ""
    Local cCorpo     := ""
    Local aAnexos    := {}
    Local lExibeHelp := .T.
    Local cMensagem  := ""
    local ab         := 0

    Private aCabec      as Array
    Private aColunas    as Array

    Private oDlg2
    Private cMotivo     := ""
    Private cJust       := Space(3)
    Private cCodMot     := Space(3)
    Private lMotivo     := .T.
    Private cUserMail   := UsrRetMail(__cUserID)

    cPara := Alltrim(cPara)+";"+Alltrim(cUserMail)
    
    Do While lMotivo

    		DEFINE MSDIALOG oDlg2 TITLE "Informe o Motivo e Justificativa para Exclusao" FROM C(178),C(181) TO C(551),C(872) PIXEL

			@ C(002),C(002) TO C(164),C(341) LABEL "Digite um motivo válido para confirmação" PIXEL OF oDlg2

			@ C(013),C(006) Say "Justificativa:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg2
			@ C(013),C(038) MsGet oJust Var cJust F3 "Z2" Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg2
			@ C(023),C(006) Say "Motivo:" Size C(032),C(008) COLOR CLR_RED PIXEL OF oDlg2
			@ C(023),C(038) GET oMemo1 Var cMotivo MEMO Size C(299),C(129) PIXEL OF oDlg2
			@ C(167),C(303) Button "Confirmar" Size C(037),C(012) Action (oDlg2:End()) PIXEL OF oDlg2

			oJust:bValid := {|| !Empty( cJust ) .And. fGat(1) }
		
		ACTIVATE MSDIALOG oDlg2 CENTERED

		If Len( AllTrim( cMotivo ) ) > 4
			lMotivo := .F.
		Else
			ApMsgAlert('Informe um motivo válido!', 'Atenção')
		EndIf

		If !lMotivo
			If Empty( Tabela("Z2", cJust) )
				ApMsgAlert('Selecione uma Justificativa válido!', 'Atenção')
				lMotivo := .T.
			EndIf
		EndIf

    EndDo

    IF Len(aPedidos) > 0
      for ab:=1 to len(aPedidos)
            RecLock( "Z20", .T.)
                Z20->Z20_FILIAL := xFilial("Z20")
                Z20->Z20_EVENTO := "N"
                Z20->Z20_TIPONF := "S"
                Z20->Z20_USUARI := cUserName
                Z20->Z20_OBJETO := "N"
                Z20->Z20_PEDIDO := aPedidos[ab]
                Z20->Z20_DATA   := MsDate()
                Z20->Z20_HORA   := Time()
                Z20->Z20_DOC    := cNumNota
                Z20->Z20_SERIE  := cSerNota
                Z20->Z20_TIPO   := cTipoNota
                Z20->Z20_CLIFOR := cCliNota
                Z20->Z20_LOJA   := cLojaNota
                Z20->Z20_EMISSA := cEmisNota
                Z20->Z20_DTDIGI := dDataBase
                Z20->Z20_MOTIVO := cMotivo
                Z20->Z20_JUSTIF := cJust
            MsUnLock()
            Sleep( 1000 )
       next     
    endif 

    aCabec := {}
	aAdd( aCabec, {{'<B><Font Size=4 color=white>Log do Evento</Font></B>', '6', 100, 6, 'C'}})

	aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' +"Exclusão Nota Fiscal Saída"+'</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Tipo NF</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + "Saída" + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Justificativa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cJust ) + " - " + Tabela("Z2", cJust) + '</Font>', '1', 90, 5, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})

    aAdd( aCabec, {{'<B><Font Size=4 color=white>Nota Fiscal de Saída</Font></B>', '6', 100, 6, 'C'}})


	aColunas := {}
	aAdd( aColunas, {'Documento'				, 12	, 'C'})
	aAdd( aColunas, {'Série'					, 05	, 'C'})
	aAdd( aColunas, {'Tipo'						, 05	, 'C'})
	aAdd( aColunas, {'Cliente'					, 07	, 'C'})
	aAdd( aColunas, {'Loja'						, 05	, 'C'})
	aAdd( aColunas, {'Emissão'					, 08	, 'C'})
	cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

	aColunas := {}
	aAdd( aColunas, {AllTrim(cNumNota)			, 12	, 'C'})
	aAdd( aColunas, {AllTrim(cSerNota)	  		, 05	, 'C'})
	aAdd( aColunas, {AllTrim(cTipoNota)	    	, 05	, 'C'})
	aAdd( aColunas, {AllTrim(cCliNota)		  	, 07	, 'C'})
	aAdd( aColunas, {AllTrim(cLojaNota)		  	, 05	, 'C'})
	aAdd( aColunas, {DTOC(cEmisNota)		  	, 08	, 'C'})
	cMensagem += U_BeHtmDet( aColunas, .F. , .F. )

    cMensagem += U_BeHtmRod(.T.)
   
    cAssunto := "Exclusão de Nota Fiscal Saída, Documento: " + cNumNota + " Série: " + cSerNota
    cCorpo   := cMensagem
    aAnexos  :={}

    lEnvio   := u_TManagerEmail(cPara, cAssunto, cCorpo, aAnexos, lExibeHelp, .T.)
   
    If lEnvio
        FWAlertSuccess("Sucesso no disparo do e-Mail", "Sucesso")
    Else
        FWAlertError("Falha no disparo do e-Mail", "Atenção (Erro)")
    EndIf
Return

/*/{Protheus.doc} fGat
description Mostrar na tela a opção usada na justificativa
@type function
@version 1.0
@author Paulo Lenzi
@since 24/07/2024
@param nOp, numeric, param_description
@return variant, return_description
/*/
Static Function fGat( nOp )

If nOp == 1
	@ C(014),C(088) Say Tabela("Z2", cJust) Size C(162),C(008) COLOR CLR_HBLUE PIXEL OF oDlg2
EndIf

Return .T.
