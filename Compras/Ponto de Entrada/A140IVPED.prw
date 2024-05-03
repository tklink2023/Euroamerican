#Include 'Protheus.ch'

/*/{Protheus.doc} A140IVPED
description O Ponto de Entrada A140IVPED permite vincular Pedidos de Compras ao importar um documento no Totvs Colaboração
@type function MATA140I - IMPXML_NFE
@version 1.0
@author Paulo Lenzi
@since 30/04/2024
@return variant, return_description

PARAMIXB    Personagem  Código do Fornecedor    X
PARAMIXB	Personagem	Loja do Fornecedor	    X
PARAMIXB	Personagem	Código do Produto	    X
PARAMIXB	Numérico	Quantidade do Produto	X

Retorno:	
cPedido	Personagem	Número do Pedido	        X
cItPed	Personagem	Artigo do Pedido	        X
nQuant	Numérico	Quantidade	                X
lVálida	Lógico	    Valida Quantidade do Pedido	

/*/
User Function A140IVPED()

Local cQry := ""
Local aRet := {}
Local lValida := .T. 
//.T. para validar a quantidade do pedido de compra superior ao XML ou .F. para não validar a quantidade do pedido de compra superior ao XML.

If Select("PED") > 0
         PED->(DbCloseArea())
Endif

cQry += " SELECT C7_NUM,"
cQry += " C7_ITEM,"
cQry += " C7_QUANT"
cQry += " FROM " + RetSqlName("SC7 ")
cQry += " WHERE D_E_L_E_T_ = ''
cQry += " AND C7_FORNECE = '" + PARAMIXB[1] + "'"
cQry += " AND C7_LOJA = '" + PARAMIXB[2] + "'"
cQry += " AND C7_PRODUTO = '" + PARAMIXB[3] + "'"

cQry := ChangeQuery(cQry)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQry),"PED", .T., .T. )

DbSelectArea("PED")
While PED->(!EOF())
            aAdd(aRet,{PED->C7_NUM,PED->C7_ITEM,PED->C7_QUANT,lValida})
            PED->(DbSkip())
EndDo

PED ->(DbCloseArea())

Return aRet
