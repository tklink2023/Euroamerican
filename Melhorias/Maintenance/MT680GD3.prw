#Include 'Totvs.Ch'
#Include 'TopConn.Ch'

/*/{Protheus.doc} MT680GD3 
É executada no final da função A680GeraD3(), e permite a validação do seu retorno.
Utilizado aqui para na tabela SDA-Saldos a distribuir gravar o campo DA_HORA com time()
@type function
@version  1.00
@author geronimo.alves
@since 1/10/2024
@return Logical, Retorno o mesmo valor lRet recebido no parametro[4]
/*/
User Function MT680GD3
//Local cProduto    := PARAMIXB[1] // H6_PRODUTO
//Local cOp         := PARAMIXB[2] // H6_OP
//Local cIdentOpPai := PARAMIXB[3] // H6_IDENT
Local lRet        := PARAMIXB[4] // Retorno

 // Geronimo 09/01/2024 P.E. A250ETRAN, MA680INC, MT681INC e MT680VAL
 Conout(" ***** MT680GD3 CHAMANDO U_DA_HORAG() " + cQry )
 U_DA_HORAG()   //Para produtos que controlam localização, (alimentam a tabela SDA), preencho o campo DA_HORA com time() nos registros incluidos hoje que ainda estão com o campo DA_HORA vazio.

Return lRet
