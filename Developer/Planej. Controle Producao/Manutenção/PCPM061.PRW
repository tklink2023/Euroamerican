#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} PCPM061
description Rotina que aponta as horas das operações atraves do programa PCPM060
@type function User
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@param cOp, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PCPM061(cOp,cProduto)
    Local cArea 	 := FwGetArea()
    Local cAlias 	 := GetNextAlias()
	Local lRet       := .F.
	
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
            MsgAlert("OP Nao Encontrado","ATENÇÃO")
            FwRestArea(cArea)
	        RETURN
    Endif        

    While (cAlias)->(!EOF())
	      IF Empty((cAlias)->Z8_DATAINI) .and. Empty((cAlias)->Z8_DATAFIM) 
			 TelaApo((cAlias)->Z8_OP,(cAlias)->Z8_PRODUTO,(cAlias)->Z8_OPERAC,(cAlias)->Z8_RECUR,(cAlias)->H1_DESCRI,"I")
			 lRet := .F.
 			 exit
		  endif 

	      IF !Empty((cAlias)->Z8_DATAINI) .and. Empty((cAlias)->Z8_DATAFIM) 
			 TelaApo((cAlias)->Z8_OP,(cAlias)->Z8_PRODUTO,(cAlias)->Z8_OPERAC,(cAlias)->Z8_RECUR,(cAlias)->H1_DESCRI,"F")
			 lRet := .F.
 			 exit			 
		  endif 
          (cAlias)->(dbSkip() )
          lRet :=.T.
    EndDo
    (cAlias)->(DbCloseArea())
    
	FwRestArea(cArea)

Return

/*/{Protheus.doc} TelaApo
description Tela de Apontamento de horas de produção
@type function Static
@version 1.0
@author Paulo Lenzi
@since 23/09/2024
@param cOp, character, param_description
@param cProd, character, param_description
@param cOper, character, param_description
@param cRecurso, character, param_description
@param cDescr, character, param_description
@param cTipo, character, param_description
@return variant, return_description
/*/
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
	Local lSit  
	lOCAL cDescPro := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
	Local aDados   := {}
	Local ab
	Local cBody    := ""

    aDados   := U_PCP60STATUS(cOp,cProd)

	If Len(aDados) > 0
			For ab:= 1 to Len(aDados)
				       	cStatus := IIF( !Empty(aDados[ab][3]) .and. !Empty(aDados[ab][4]),"Ok"," ")
						if alltrim(aDados[ab][1]) = alltrim(cOper)
							cbody+= '<tr><td>'+Alltrim(aDados[ab][1])+'</td><td>'+Alltrim(aDados[ab][2])+'</td><td style="text-align: center;" bgcolor="#b5e6e1"> Aqui </td></tr>'					
						else
							if !Empty(cStatus)
							    cbody+= '<tr><td>'+Alltrim(aDados[ab][1])+'</td><td>'+Alltrim(aDados[ab][2])+'</td><td style="text-align: center;" bgcolor="#9edb1a">'+cStatus+'</td></tr>'
							else
								cbody+= '<tr><td>'+Alltrim(aDados[ab][1])+'</td><td>'+Alltrim(aDados[ab][2])+'</td><td style="text-align: center;">'+cStatus+'</td></tr>'
							endif	
						endif	
   			next	

    Endif

	lSit := PCP061VALID(cOp,cProd,cOper) 
	if !lSit
       MsgAlert("Apontamento de parada não encerrada","ATENÇAO")
	   Return
	Endif

 	bGrava  := {|| FGrava(cOp,cProd,cOper,cRecurso,cTipo),oDlg:End() } 

 	DEFINE MSDIALOG oDlg TITLE "Apontamento" STYLE DS_MODALFRAME  FROM 000, 000  TO nJanAltu, nJanLarg  OF oMainWnd PIXEL
    oDlg:lEscClose := .T.
		cTextHtml :='<hr size="1">'+;
				'<font size="5" color="black">APONTAMENTO DA ORDEM</font><br/><br/>'+;
				'<label style="font-size: 20px">Numero OP : '+cOp+'</label><br/>'+;
				'<table border="1" cellpadding="1" cellspacing="0">'+;
				'<tbody style="font-size: 12px";>'+;
				'<tr>'+;
				'<td width="100" bgcolor="#FFFF87">Produto</td>'+;
				'<td width="300" bgcolor="#FFFF87">Descricao</td>'+;
				'</tr>'+;
				'<tr>'+;
				'<td>'+cProd+'</td>'+;
				'<td>'+aLLTRIM(cDescPro)+'</td'+;
				'</tr>'+;
				'</tbody>'+;
				'</table>'+;
				'<table border="0" cellpadding="1" cellspacing="0">'+;
	 			'<tbody style="font-size: 12px";>'+;
				'<tr>'+;
				'<td width="100" bgcolor="#FFFF87">Operacao</td>'+;
				'<td width="250" bgcolor="#FFFF87">Descricao</td>'+;
				'<td width="050" bgcolor="#FFFF87">Situacao</td>'+;
				'</tr>'+cbody+;
	 			'</tbody>'+;	
				'</table>'+;	
				'<table border="1" cellpadding="1" cellspacing="0">'+;
				'<tr>'+;
				'<td width="100" bgcolor="#FFFF87">Tipo</td>'+;
				'<td width="200" bgcolor="#FFFF87">Data</td>'+;
				'<td width="100" bgcolor="#FFFF87">Hora</td>'+;
				'</tr>'+;
				'<tr>'+;
				'<td style="text-align: center;">'+IIF(cTipo='I','Incluir','Encerrar')+'</td>'+;
				'<td style="text-align: center;">'+dToc(dDatabase)+'</td>'+;
				'<td style="text-align: center;">'+Subs(Time(),1,5)+'</td>'+;
				'</tr>'+;
				'</table>'

	oFont := TFont():New('Courier new',,-18,.T.)
    oSay := TSay():New(01,10,{||cTextHtml},oDlg,,oFont,,,,.T.,,,400,300,,,,,,lHtml)
    oBtOK := TButton():New((nJanAltu/2)-24, nJanMeio - (nTamBtn/2),"Confirma",oDlg,bGrava,045,012,,oFont,,.T.)
	ACTIVATE MSDIALOG oDlg CENTERED
    FwRestArea(cArea)
Return

/*/{Protheus.doc} Fgrava
description Rotina que grava os apontamentos de horas trabalhadas
@type function
@version 1.0
@author Paulo Lenzi
@since 20/09/2024
@param cOp, character, param_description
@param cProd, character, param_description
@param cOper, character, param_description
@param cRecurso, character, param_description
@param cTipo, character, param_description
@return variant, return_description
/*/
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
	      endif								
	   Endif

	   SZ8->( MsUnlock() )

       if ExistBlock("CalcHoras")
          aDados:= {SZ8->Z8_DATAINI,SZ8->Z8_HORAINI,SZ8->Z8_DATAFIM,SZ8->Z8_HORAFIM,cOp,cProd,cOper,cTipo,"SZ8"}
          ExecBlock("CalcHoras",.F.,.F.,aDados)   
       Endif

	ENDIF
    FwRestArea(cArea)
Return

/*/{Protheus.doc} PCP061VALID
description Valida se há apontamento de horas paradas
@type function
@version 1.0
@author Paulo Lenzi
@since 20/09/2024
@param cOp, character, param_description
@param cProd, character, param_description
@param cOper, character, param_description
@return variant, return_description
/*/
Static Function PCP061VALID(cOp,cProd,cOper) 
	Local cArea := FwGetArea()
	Local lRet := .T.
    dbSelectArea("SZ9")
	SZ9->( DbSetOrder(1))
	if SZ9->( DbSeek( xFilial("SZ9")+cOp+cProd+cOper,.T. ))
       if Empty(SZ9->Z9_DATAFIM)
          lRet := .F.
	   Endif
	endif
	FwRestArea(cArea)
Return(lRet)


//========================================================================================================================================================================//
// FIM DA PROGRAMAÇÃO DO FONTE PCPM060
//========================================================================================================================================================================//

