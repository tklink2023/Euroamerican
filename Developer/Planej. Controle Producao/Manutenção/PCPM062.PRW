#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} PCPM062
description Rotina de apontamento de paradas
@type function
@version 1.0
@author Paulo Lenzi
@since 23/09/2024
@param cOp, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PCPM062(cOp,cProduto)
    Local cArea     := FwGetArea()
    Local lRet     := "I"
    Local aItems    := PCP60BOX(cOp,cProduto)
    Local cCombo    := aItems[1]
    Local cTextHtml := ""
	
    Private oDlg      as Object
    Private oSay      as Object
    Private oBtOk     as Object
    Private oCombo    as Object
    Private oFont     as Object
    Private oTMultiget  as Object

    Private bGrava  as block
    Private cBody   := ""

    Private nJanAltu  := GETMV("ES_ALTJAN")
	Private nJanLarg  := GETMV("ES_LARGJAN")
    Private lHtml := .T.
    Private nJanMeio  := ((nJanLarg)/2)/2
	Private nTamBtn   := 048

	DEFINE MSDIALOG oDlg TITLE "Paradas" STYLE DS_MODALFRAME  FROM 000, 000  TO nJanAltu, nJanLarg  OF oMainWnd PIXEL
    oDlg:lEscClose := .T.
	cTextHtml :='<hr size="1">'+;
				'<font size="5" color="black">PARADA NA OPERAÇÃO</font><br/><br/>'+;
				'<label>Numero : '+cOp+'</label><br/>'+;
				'<label>Produto: '+cProduto+' </label><br/>'
	oFont  := TFont():New('Courier new',,-18,.T.)
    oSay   := TSay():New(01,10,{||cTextHtml},oDlg,,oFont,,,,.T.,,,200,300,,,,,,lHtml)
    oSay   := TSay():New(70, 10, {|| "Escolha a Operação "}, oDlg,,oFont,,,,.T.,,,200,300,,,,,,.F.)
    oCombo := TComboBox():New(70,150,{|u|if(PCount()>0,cCombo := u, cCombo)},aItems,50,20,oDlg,,{|| lRet:=PCP60PARA(cOp,cProduto,cCombo) },,,,.T.,,,,,,,,,'cCombo')    
	ACTIVATE MSDIALOG oDlg CENTERED
    FwRestArea(cArea)
Return

/*/{Protheus.doc} PCP60BOX
description Rotina que buscas as Operações da OP
@type function
@version 1.0
@author Paulo Lenzi
@since 23/09/2024
@param cOp, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function PCP60BOX(cOp,cProduto)
    Local cArea := FwGetArea()
    Local cAlias 	 := GetNextAlias()
    Local aItens    := {}

    BeginSQL Alias cAlias
        Select Z8_OPERAC
        FROM %Table:SZ8% SZ8
        WHERE SZ8.%NotDel%
        and Z8_FILIAL =  %xFilial:SZ8%
        AND Z8_OP = %Exp:cOp%
		AND Z8_PRODUTO = %Exp:cProduto%
		ORDER BY Z8_OPERAC
    EndSQL

    if (cAlias)->( Eof())
            FwRestArea(cArea)
	        RETURN
    Endif        
 
    aAdd(aItens,"  ")

    While (cAlias)->(!EOF())
          aAdd(aItens,(calias)->Z8_OPERAC)
          (cAlias)->(dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

    FwRestArea(cArea)
Return(aItens)

/*/{Protheus.doc} PCP60PARA
description Rotina de parada de recurso
@type function
@version 1.0
@author Paulo Lenzi
@since 23/09/2024
@param cOp, character, param_description
@param cProduto, character, param_description
@param cOperac, character, param_description
@return variant, return_description
/*/
Static Function PCP60PARA(cOp,cProduto,cOperac)
    Local cArea     := FwGetArea()
    Local cAlias 	:= GetNextAlias()
    Local lTipo     := "I"
    Local cTextRet  := ""
    Local cMotivo   := ""
    
    lSit := PCP062VALID(cOp,cProduto,cOperac) 
	if !lSit
	   Return
	Endif

	BeginSQL Alias cAlias
        Select Z9_OP,Z9_PRODUTO,Z9_OPERAC,Z9_DATAINI,Z9_DATAFIM
        FROM %Table:SZ9% SZ9
        WHERE SZ9.%NotDel%
        and Z9_FILIAL =  %xFilial:SZ9%
        AND Z9_OP = %Exp:cOp%
		AND Z9_PRODUTO = %Exp:cProduto%
        And Z9_OPERAC = %Exp:cOperac%
		ORDER BY Z9_OP,Z9_PRODUTO,Z9_OPERAC
    EndSQL

  if (cAlias)->( Eof())
        lTipo := "I"
            cTextRet := '<table border="1" cellpadding="1" cellspacing="0">'+;
                    '<tr>'+;
                    '<td width="100" bgcolor="#FFFF87">Tipo</td>'+;
                    '<td width="200" bgcolor="#FFFF87">Data</td>'+;
                    '<td width="100" bgcolor="#FFFF87">Hora</td>'+;
                    '</tr>'+;
                    '<tr>'+;
                    '<td>'+IIF(lTipo='I','Incluir','Encerrar')+'</td>'+;
                    '<td>'+dToc(dDatabase)+'</td>'+;
                    '<td>'+Subs(Time(),1,5)+'</td>'+;
                    '</tr>'+;
                    '</table>'

                    oSay   := TSay():New(090,10,{||cTextRet},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

                    oTMultiget :=TMultiget():Create(oDlg ,{|u|if(Pcount()>0,cMotivo:=u,cMotivo)},120 ,01,nJanLarg-50,100,oFont,,,,,.T.,,,,,,,,,,,.T.,'MOTIVO',1,oFont,)
                    oBtOK := TButton():New((nJanAltu/2)-24, nJanMeio - (nTamBtn/2),"Confirma",oDlg,{|| U_FGrvSZ9(cOp,cProduto,cOperac,lTipo,cMotivo),oDlg:End() },045,012,,oFont,,.T.)

            FwRestArea(cArea)
	        RETURN
    Endif        

    While (cAlias)->(!EOF())
	      IF Empty((cAlias)->Z9_DATAINI) .and. Empty((cAlias)->Z9_DATAFIM) 
			  lTipo     := "I"
 			 exit
		  endif 

	      IF !Empty((cAlias)->Z9_DATAINI) .and. Empty((cAlias)->Z9_DATAFIM) 
              lTipo     := "F"
 			 exit			 
		  endif 
          (cAlias)->(dbSkip() )

    EndDo
    (cAlias)->(DbCloseArea())

    cTextRet := '<table border="1" cellpadding="1" cellspacing="0">'+;
                    '<tr>'+;
                    '<td width="100" bgcolor="#FFFF87">Tipo</td>'+;
                    '<td width="200" bgcolor="#FFFF87">Data</td>'+;
                    '<td width="100" bgcolor="#FFFF87">Hora</td>'+;
                    '</tr>'+;
                    '<tr>'+;
                    '<td>'+IIF(lTipo='I','Incluir','Encerrar')+'</td>'+;
                    '<td>'+dToc(dDatabase)+'</td>'+;
                    '<td>'+Subs(Time(),1,5)+'</td>'+;
                    '</tr>'+;
                    '</table>'

        oSay   := TSay():New(090,10,{||cTextRet},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)
        IF lTipo = "I"
            oTMultiget :=TMultiget():Create(oDlg ,{|u|if(Pcount()>0,cMotivo:=u,cMotivo)},120 ,01,nJanLarg-50,100,oFont,,,,,.T.,,,,,,,,,,,.T.,'MOTIVO',1,oFont,)
        ENDIF    
        oBtOK := TButton():New((nJanAltu/2)-24, nJanMeio - (nTamBtn/2),"Confirma",oDlg,{|| U_FGrvSZ9(cOp,cProduto,cOperac,lTipo,cMotivo),oDlg:End() },045,012,,oFont,,.T.)
    FwRestArea(cArea)    
Return

/*/{Protheus.doc} FGrvSZ9
description Rotina que grava os apontamentos de paradas
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param cOp, character, param_description
@param cProd, character, param_description
@param cOperac, character, param_description
@param lTipo, logical, param_description
@param cMotivo, character, param_description
@return variant, return_description
/*/
User Function FGrvSZ9(cOp,cProd,cOperac,lTipo,cMotivo)
	Local cArea := FwGetArea()
	dbSelectArea("SZ9")
	SZ9->( dbSetOrder(1) )
	IF SZ9->( !dbSeek( xFilial("SZ9")+cOp+cProd+cOperac,.T. ))
        IF Reclock("SZ9",.T.)
           SZ9->Z9_FILIAL := xFilial("SZ9")
           SZ9->Z9_OP     := cOp
           SZ9->Z9_PRODUTO:= cProd
           SZ9->Z9_OPERAC := cOperac
           SZ9->Z9_MOTIVO := cMotivo
           SZ9->Z9_DATAINI := dDataBase
		   SZ9->Z9_HORAINI := Subs(Time(),1,5)
           SZ9->( MsUnlock() )   
        Endif   
    else
       IF Reclock("SZ9",.F.) 
                SZ9->Z9_DATAFIM := dDataBase
			    SZ9->Z9_HORAFIM := Subs(Time(),1,5)                       
                SZ9->( MsUnlock() )   
      Endif   

    Endif
    
    if ExistBlock("PCPM064")
          aDados:= {cOp,cProd,cOperac,lTipo,cMotivo}
          ExecBlock("PCPM064",.F.,.F.,aDados)   
    Endif

    if ExistBlock("CalcHoras")
          aDados:= {SZ9->Z9_DATAINI,SZ9->Z9_HORAINI,SZ9->Z9_DATAFIM,SZ9->Z9_HORAFIM,cOp,cProd,cOperac,lTipo,"SZ9"}
          ExecBlock("CalcHoras",.F.,.F.,aDados)   
    Endif
 
    FwRestArea(cArea)
Return

/*/{Protheus.doc} PCP062VALID
description Validacao das Operações
@type function
@version 1.0
@author Paulo Lenzi
@since 23/09/2024
@param cOp, character, param_description
@param cProd, character, param_description
@param cOper, character, param_description
@return variant, return_description
/*/
Static Function PCP062VALID(cOp,cProd,cOper) 
	Local cArea := FwGetArea()
	Local lRet := .T.

    dbSelectArea("SZ8")
	SZ8->( DbSetOrder(1))
	if SZ8->( DbSeek( xFilial("SZ8")+cOp+cProd+cOper,.T. ))
        if Empty(SZ8->Z8_DATAINI)
           MsgAlert("Apontamento de Hora não Inicializado","ATENÇÃO")
           lRet := .F.
        Endif

       if !Empty(SZ8->Z8_DATAFIM)
          MsgAlert("Apontamento de Hora Finalizado","ATENÇÃO")
          lRet := .F.
	   Endif
	endif
	FwRestArea(cArea)

Return(lRet)

//========================================================================================================================================================================//
// FIM DA PROGRAMAÇÃO DO FONTE PCPM060
//========================================================================================================================================================================//
