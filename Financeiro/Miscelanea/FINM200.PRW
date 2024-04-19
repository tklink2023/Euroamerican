#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

/*/{Protheus.doc} FINM200
description
@type function
@version 1.0
@author Paulo Lenzi
@since 18/04/2024
@param nTitulo, numeric, param_description
@param cPref, character, param_description
@param cCliente, character, param_description
@param cLoja, character, param_description
@param cOpc, character, param_description
@return variant, return_description
/*/
User Function FINM200(nTitulo,cPref,cCliente,cLoja,cOpc)
     Local cArea := FwGetArea()
     Local cAlias   := GetNextAlias()

    BeginSQL Alias cAlias
		SELECT  F2_DOC, F2_SERIE,F2_VALBRUT,F2_EMISSAO,F2_CHVNFE
		FROM %Table:SF2% SF2
		WHERE SF2.%NotDel%
		and F2_FILIAL =  %xFilial:SF2%
        and F2_DOC =  %exp:nTitulo%
        and F2_SERIE = %exp:cPref%
        and F2_CLIENTE = %exp:cCliente%
        and F2_LOJA = %exp:cLoja%
    EndSQL  
    TCSetField(cAlias, "F2_EMISSAO", "D")

    if (cAlias)->(Eof())
		Return
    ENDIF
    While ! (cAlias)->(EoF())
        if cOpc = 1
            FwRestArea(cArea)
            Return((cAlias)->F2_DOC)
        Endif

        // Opcao para enviar o valor da Nota Fiscal
        if cOpc = 2
            FwRestArea(cArea)
           Return((cAlias)->F2_VALBRUT)
        Endif

        // Opcao para enviar a data da nota fiscal
        if cOpc = 3
            FwRestArea(cArea)
           Return((cAlias)->F2_EMISSAO)
        Endif

        // Opcao para enviar a chave de acesso da nota fiscal
        if cOpc = 4
            FwRestArea(cArea)
            Return((cAlias)->F2_CHVNFE)
        Endif

        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())    

     // Opcao para enviar o numero da nota fiscal
     FwRestArea(cArea)
Return(0)
