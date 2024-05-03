#Include 'Protheus.ch'

/*/{Protheus.doc} A116TECT
description Ponto de Entrada utilizado para permitir alterar TES e a Condição de pagamento utilizadas na importação das notas de conhecimento de transporte.
Attencion Ponto de entrada serve para alterar TES configurada no parâmetro MV_XMLTECT e condição de pagamento configurada no parâmetro MV_XMLCPCT, que utilizados para importação de um CTE.
@type function 
@version 1.0
@author Paulo Lenzi
@since 30/04/2024
@return variant, return_description
Parâmetros: oXML := Objeto contendo a estrutura do arquivo XML referente ao conhecimento do transporte
1) Evento (Gerando documento para ser visualizado no Monitor - MATA116I) ? Retorno do objeto a partir do _InfCte
2) Evento (Gerando documento a partir do Monitor - COMXCOL) ? Retorno do objeto a partir do _CTEPROC:_CTE:_InfCte

Retorno: aRet
aRet[1] = Código da TES
aRet[2] = Código da condição de pagamento
Obs: aRet[2] não é obrigatório caso deseje alterar somente a TES.

/*/
User function A116TECT()
Local oXML := Paramixb[1]
Local aRet   := {}

aAdd(aRet, "001") //Código da TES
aAdd(aRet, "000") //Código da condição de pagamento


// Customizações do usuário

Return aRet

