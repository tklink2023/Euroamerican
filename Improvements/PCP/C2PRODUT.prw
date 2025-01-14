#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/{Protheus.doc} C2PRODUT
Esta função é chamada pelo X3_VLDUSER do campo C2_PRODUTO. Se o produto informado, tiver em sua estrutura (Tabela SG1) algum componente que esta bloqueado (B1_MSBLQL='1'), retorna .F. não validadndo o codigo de produto, impedindo a inclusão da O.P.
type function
@version  
@author geronimo.alves
@since 05/11/2024
@return variant, return_description
/*/
User Function C2PRODUT()
Local aArea     	:= GetArea()
Local lRet			:= .T.
Local cMsgErro		:= ""
Local cMsgSolução	:= ""
Local cB1REVATU		:= ""
Local cQuery	    := ""
Local cBloqueado	:= ""
Local nBloqueado	:= 0
Local _CRLF 		:= chr(13) + chr(10)
Local cAmbiente     := GetEnvServer()


if cAmbiente != "PROD"
	RestArea( aArea )
	Return lRet
Endif 

/*/ If Type("M->C2_PRODUTO") == "U"
	oModel   := FWModelActive()
	oModelMAS := oMdlSGF:GetModel('MASTER')
	cProduto  := oModelMAS:GetValue('C2_PRODUTO')
	cOP       := oModelMAS:GetValue('C2_NUM')
	cItem     := oModelMAS:GetValue('C2_ITEM')
Else
	cProduto  := M->C2_PRODUTO
	cOP       := M->C2_NUM
	cItem     := M->C2_ITEM
EndIf               /*/  //

If Empty(M->C2_PRODUTO)
	lRet		:= .F.
	cMsgErro	:= "O Codigo de Produto não foi informado"
	cMsgSolução	:= "Digite um código de produto válido"
EndIf
 

If lRet	
	cB1REVATU	:= posicione("SB1",1,xFilial("SB1")+M->C2_PRODUTO,"B1_REVATU")
	If ReadVar() == 'M->C2_REVISAO' .and. !Empty(M->C2_REVISAO)
		cB1REVATU	:= M->C2_REVISAO
	Endif

	If Empty(cB1REVATU)
		Return .T. // Se o produto não tem revisão de estrutura devo retornar com valido, pois tem produto acabado como o da Phoenix por exemplo que abre op de "PA" sem estrutura somente para emitir etiquetas

		//lRet		:= .F.
		//cMsgErro	:= oemtoansi( 'O produto ' +AllTrim(M->C2_PRODUTO)+ ', está com o campo "Rev.Estrutur"  em branco no cadastro de produtos.' )
		//cMsgSoluca	:= oemtoansi( "informe o número atual da revisão da estrutura no campo 'Rev.Estrutur' do cadastro de produtos e no cadastro de estrutura." )
		//Help(NIL, NIL, "Informe_a_revisao_da_Estrutura", NIL, cMsgErro , 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsgSoluca})
	EndIf
EndIf

If lRet	
	cQuery := " SELECT G1_COMP FROM " +RetSqlName("SG1")+ " SG1 "		// Query para selecionar componente do produto digitado na OP que está bloqueado no cadastro de produto
	cQuery += " INNER JOIN " +RetSqlName("SB1")+ " SB1 ON B1_COD = G1_COMP AND B1_MSBLQL = '1' AND SB1.D_E_L_E_T_ = ' '
	cQuery += " WHERE G1_FILIAL = '" + xFilial("SG1") + "' AND G1_COD = '" +M->C2_PRODUTO+ "' "
	cQuery += " AND G1_REVINI >= '" +cB1REVATU+ "' AND  G1_REVFIM <= '" +cB1REVATU+ "' "
	cQuery += " AND SG1.D_E_L_E_T_ =  ' '
	cQuery += " ORDER BY G1_TRT, G1_COMP 
	TCQuery cQuery New Alias "TMPSB1"
	dbSelectArea("TMPSB1")
	dbGoTop()

	While !TMPSB1->(EOF())		// Se encontrado um ou mais componentes do produto bloqueado (B1_MSBLQL='1')
		lRet	:= .F.			// retorno .F. para não validar o produto / O.P. 
		cBloqueado	+= Alltrim(TMPSB1->G1_COMP) + ", "
		nBloqueado++
		dbSkip()
	Enddo
	TMPSB1->( dbCloseArea() )
	If !lRet		// Se encontrou componente bloqueado no cadastro de produto
		cBloqueado	:= Subs(cBloqueado,1,Len(cBloqueado)-2)
		If nBloqueado = 1 
			//Help(NIL, NIL, "Texto do Help", NIL, "Texto do Problema", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Texto da Solução"})
			Help(NIL, NIL, "OP_com_Componente_Bloqueado", NIL, "Não é possível incluir a O.P. " +M->C2_NUM+ " para o produto " +AllTrim(M->C2_PRODUTO)+ " na revisão " +cB1REVATU+ " pois ele possui componente em sua estrutura que está bloqueado no cadastro de produto. O componente bloqueados é :" +_CRLF+ cBloqueado , 1, 0, NIL, NIL, NIL, NIL, NIL, {"Se o produto/revisão informado estiver correto, Informe aos superiores sobre o componente bloqueado."})
		Else
			Help(NIL, NIL, "OP_com_Componente_Bloqueado", NIL, "Não é possível incluir a O.P. " +M->C2_NUM+ " para o produto " +AllTrim(M->C2_PRODUTO)+ " na revisão " +cB1REVATU+ " pois ele possui componentes em sua estrutura que estão bloqueados no cadastro de produto. Os componentes bloqueados sâo:" +_CRLF+ cBloqueado , 1, 0, NIL, NIL, NIL, NIL, NIL, {"Se o produto/revisão informado estiver correto, Informe aos superiores sobre os componentes bloqueados."})
		Endif
	Endif
Endif

RestArea( aArea )
Return lRet

