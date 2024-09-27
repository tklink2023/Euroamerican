#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "RptDef.ch"
#Include "FWPrintSetup.ch"
#Include "TopConn.ch"
#Include 'TbiConn.Ch'
#Include 'Totvs.Ch'
#Include 'Ap5Mail.Ch'

User Function PCPM064()
    Local cArea     := FwGetArea()
    Local cOrdem    := PARAMIXB[1]
    Local cProduto  := PARAMIXB[2]
    Local cOperacao := PARAMIXB[3]
    Local cTipo     := PARAMIXB[4]
    Local cMotivo   := PARAMIXB[5]
 
    local cEmail    := GETMV("ES_EMAPON")
    Local cSubject  := IIF(cTipo='I',"PARADA DA OPERACAO","RETORNO DA OPERACAO")+" DA ORDEM :"+cOrdem+" DO PRODUTO :"+cProduto
    Local cBody		:= ""
    Local cRelName  := "PCPM064"

    
cBody		:='<hr size="1">'+;
            '<font style="font-size: 30px" >'+IIF(cTipo='I',"PARADA DA OPERACAO","RETORNO DA OPERACAO")+'</font><br/><br/>'+;
            '<label style="font-size: 20px">Numero OP : '+cOrdem+'</label><br/><br/>'+;
            '<table border="0" cellpadding="1" cellspacing="0">'+;
            '<tbody style="font-size: 18px";>'+;
		    '<tr>'+;
			'<td width="100" bgcolor="#FFFF87">Produto</td>'+;
			'<td width="300" bgcolor="#FFFF87">Descricao</td>'+;
		    '</tr>'+;
		    '<tr>'+;
			'<td style="text-align: center;">'+cProduto+'</td>'+;
			'<td style="text-align: center;">'+AllTrim( Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") )+'</td>'+;
		    '</tr>'+;
            '</tbody>'+;
'</table>'+;	
'<table border="1" cellpadding="1" cellspacing="0">'+;
	'<tr>'+;
		'<td width="100" bgcolor="#FFFF87" style="text-align: center;" >Tipo</td>'+;
		'<td width="200" bgcolor="#FFFF87" style="text-align: center;">Data</td>'+;
		'<td width="100" bgcolor="#FFFF87" style="text-align: center;">Hora</td>'+;
	'</tr>'+;
	'<tr>'+;
		'<td style="text-align: center;">'+IIF(cTipo='I','Incluir','Encerrar')+'</td>'+;
		'<td style="text-align: center;">'+dToc(dDatabase)+'</td>'+;
		'<td style="text-align: center;">'+Subs(Time(),1,5)+'</td>'+;
	'</tr>'+;
'</table>'+;
'<table border="0" cellpadding="1" cellspacing="0">'+;
	 '<tbody style="font-size: 18px";>'+;
		'<tr>'+;
			'<td width="100" bgcolor="#FFFF87">Operacao</td>'+;
			'<td width="300" bgcolor="#FFFF87">Descricao</td>'+;
		'</tr>'+;
		'<tr>'+;
			'<td style="text-align: center;">'+cOperacao+'</td>'+;
			'<td style="text-align: center;">'+Alltrim( Posicione("SZ8",1,XFILIAL("SZ8")+cOrdem+cProduto+cOperacao,"Z8_DESCR" ) )+'</td>'+;
		'</tr>'+;
	 '</tbody>'+;	
'</table>'+;	
'<table border="0" cellpadding="1" cellspacing="0">'+;
	 '<tbody style="font-size: 18px";>'+;
		'<tr>'+;
		    '<td width="5" bgcolor="#FFFF87" style="text-align: center;" ></td>'+;
			'<td width="395" bgcolor="#FFFF87"style="text-align: center;" >Motivo</td>'+;
		'</tr>'+;
		'<tr>'+;
			'<td style="text-align: center;"> </td>'+;
			'<td style="text-align: center;">'+Alltrim(cMotivo)+'</td>'+;
		'</tr>'+;
	 '</tbody>'+;	
'</table>'+;	
'<br/>'+;
'<br/>'


    U_TManagerEmail(cEmail, cSubject, cBody, cRelName)


    FwRestArea(cArea)
Return
