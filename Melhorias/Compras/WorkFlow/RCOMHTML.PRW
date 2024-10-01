#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/{Protheus.doc} RCOMHTML
description Relação de Fornecedores com validade do iso 9000 para vencer
@type function User
@version 1.0
@author Paulo Lenzi
@since 19/09/2024
@return variant, return_description
/*/
User Function RCOMHTML()
    Local cArea     := FwGetArea()
    Local cAlias    := GetNextAlias()
    Local cPatch    := "\workflow\HTML\wfiso9000.html"
    LOCAL cSubject  := "RELACAO DE FORNECEDORES COM VALIDADE A VENCER DO ISO 9000  [ Emissao: "+dToc(dDataBase)+"]" 
    Local cPara     := GetMv("ES_EMAISO")
    Local cMensagem := ""
    Local aDados    := {}

    BeginSQL Alias cAlias
            Select  A2_COD,A2_LOJA,A2_NOME,A2_EQ_ISOV
            FROM %Table:SA2% SA2
            WHERE SA2.%NotDel%
            and A2_FILIAL =  %xFilial:SA2%
            AND A2_EQ_ISO9 = 'S'
            AND A2_EQ_ISOV > GetDate()
            AND A2_EQ_ISOV <= (GetDate() + 30)
            AND A2_MSBLQL <> '1'
            ORDER BY A2_COD,A2_LOJA,A2_NOME
    EndSQL
	TCSetField(cAlias, "A2_EQ_ISOV", "D")	
    if (cAlias)->( Eof())
                FwRestArea(cArea)
                RETURN
    Endif

    While (cAlias)->(!EOF())
        aAdd(aDados, {(cAlias)->A2_COD ,(cAlias)->A2_LOJA , (cAlias)->A2_NOME,Dtoc((cAlias)->A2_EQ_ISOV)})
        (cAlias)->(dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())		

    cMensagem := MontaTabelaHTML(aDados, .T., "800")
    MemoWrite(cPatch, cMensagem)
    cBody := WFLoadFile(cPatch) 
    cBody := MtHTML2Str(cPatch) 
    cHtmlFirt := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' 
    cHtmlFirt +=' '
    cBody := StrTran(cBody , '' , cHtmlFirt )
    U_TManagerEmail(cPara, cSubject, cBody, "WF ISO")

    FwRestArea(cArea)
Return  
