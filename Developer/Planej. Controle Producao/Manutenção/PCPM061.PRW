#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function PCPM061(cOp,cProduto)
    Local cArea 	 := FwGetArea()
    Local cAlias 	 := GetNextAlias()
	
 	BeginSQL Alias cAlias
        Select Z8_OP,Z8_PRODUTO,Z8_OPERAC,Z8_RECUR,Z8_DATAINI,Z8_DATAFIM,H1_DESCRI
        FROM %Table:SZ8% SZ8
		INNER JOIN %Table:SH1% SH1 ON H1_CODIGO = Z8_RECUR AND SH1.%NotDel%
        WHERE SZ8.%NotDel%
        and Z8_FILIAL =  %xFilial:SZ8%
        AND Z8_OP = %Exp:cOp%
		AND Z8_PRODUTO = %Exp:cProduto%
		ORDER BY Z8_OP,Z8_PRODUTO,Z8_OPERAC
    EndSQL

    if (cAlias)->( Eof())
            MsgAlert("OP Encerrada","ATENÇÃO")
            FwRestArea(cArea)
	        RETURN
    Endif        

    While (cAlias)->(!EOF())
	      IF Empty((cAlias)->Z8_DATAINI) .and. Empty((cAlias)->Z8_DATAFIM) 
			 TelaApo((cAlias)->Z8_OP,(cAlias)->Z8_PRODUTO,(cAlias)->Z8_OPERAC,(cAlias)->Z8_RECUR,(cAlias)->H1_DESCRI,"I")
 			 exit
		  endif 

	      IF !Empty((cAlias)->Z8_DATAINI) .and. Empty((cAlias)->Z8_DATAFIM) 
			 TelaApo((cAlias)->Z8_OP,(cAlias)->Z8_PRODUTO,(cAlias)->Z8_OPERAC,(cAlias)->Z8_RECUR,(cAlias)->H1_DESCRI,"F")
 			 exit			 
		  endif 
          (cAlias)->(dbSkip() )

    EndDo
    (cAlias)->(DbCloseArea())

    FwRestArea(cArea)
	SysRefresh()
Return

Static Function TelaApo(cOp,cProd,cOper,cRecurso,cDescr,cTipo)
    Local cArea := FwGetArea()
	Local nJanAltu  := GETMV("ES_ALTJAN")
	Local nJanLarg  := GETMV("ES_LARGJAN")
	Local nJanMeio := ((nJanLarg)/2)/2
	Local nTamBtn  := 048
	Local oDlg   as Object 
	Local oSay   as Object 
	Local oBtOK   as Object 
	Local cTextHtml := ""
	Local lHtml := .T.
	Local bGrava  as block

 	bGrava  := {|| FGrava(cOp,cProd,cOper,cRecurso,cTipo),oDlg:End() } 

 	DEFINE MSDIALOG oDlg TITLE "Apontamento" STYLE DS_MODALFRAME  FROM 000, 000  TO nJanAltu, nJanLarg  OF oMainWnd PIXEL
    oDlg:lEscClose := .T.
	cTextHtml :='<hr size="1">'+;
				'<font size="5" color="black">APONTAMENTO DA ORDEM</font><br/><br/>'+;
				'<label>Numero : '+cOp+'</label><br/>'+;
				'<label>Produto: '+cProd+' </label><br/>'+;
				'<label>Operacao:'+cOper+' </label><br/>'+;
				'<label>Desc: '+Alltrim(cDescr)+' </label><br/><br/>'+;
				'<table border="1" cellpadding="1" cellspacing="0">'+;
				'<tr>'+;
				'<td width="100" bgcolor="#FFFF87">Tipo</td>'+;
				'<td width="200" bgcolor="#FFFF87">Data</td>'+;
				'<td width="100" bgcolor="#FFFF87">Hora</td>'+;
				'</tr>'+;
				'<tr>'+;
				'<td>'+IIF(cTipo='I','Incluir','Encerrar')+'</td>'+;
				'<td>'+dToc(dDatabase)+'</td>'+;
				'<td>'+Subs(Time(),1,5)+'</td>'+;
				'</tr>'+;
				'</table>'

	oFont := TFont():New('Courier new',,-18,.T.)
    oSay := TSay():New(01,10,{||cTextHtml},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)

    oBtOK := TButton():New((nJanAltu/2)-24, nJanMeio - (nTamBtn/2),"Confirma",oDlg,bGrava,045,012,,oFont,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED
    FwRestArea(cArea)
Return

Static Function Fgrava(cOp,cProd,cOper,cRecurso,cTipo)
	Local cArea := FwGetArea()
	dbSelectArea("SZ8")
	SZ8->( dbSetOrder(1) )
	IF SZ8->( dbSeek( xFilial("SZ8")+cOp+cProd+cOper+cRecurso,.T. ))
	   IF Reclock("SZ8",.F.)
		  if cTipo = "I"
		     SZ8->Z8_DATAINI := dDataBase
			 SZ8->Z8_HORAINI := Subs(Time(),1,5)
		  else
		     SZ8->Z8_DATAFIM := dDataBase
			 SZ8->Z8_HORAFIM := Subs(Time(),1,5)
			 SZ8->Z8_TOTAL   := AtTotHora(SZ8->Z8_DATAINI, SZ8->Z8_HORAINI, SZ8->Z8_DATAFIM, SZ8->Z8_HORAFIM)
	      endif								
	   Endif
      SZ8->( MsUnlock() )
	ENDIF

    FwRestArea(cArea)
Return
