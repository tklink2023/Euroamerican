//Bibliotecas
#Include "Totvs.ch"
#Include "TopConn.ch"
 
/*/{Protheus.doc} CriaSXE
Ponto de Entrada para controlar a numeração
@author Atilio
@since 17/10/2019
@version 1.0
@return cCodRet, Código de retorno que entrará no lugar do chamado pelo License
@type function
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6815179
@obs Esse p.e. é chamado na primeira vez de pegar a numeração na tabela
/*/
 
User Function CriaSXE()
    Local aArea      := GetArea()
    Local cAliasX    := ParamIXB[1] //cAlias - Nome da tabela;
    Local cCpoSX8X   := ParamIXB[2] //cCpoSX8 - Nome do campo que será utilizado para verificar o próximo sequencial;
    Local cAliasSX8X := ParamIXB[3] //cAliasSX8 - Filial e nome da tabela na base de dados que será utilizada para verificar o sequencial;
    Local nOrdSX8X   := ParamIXB[4] //nOrdSX8 - Índice de pesquisa a ser usada na tabela.
    Local cCodRet    := Nil
    Local cQryMax    := ""
     
    //Se for a tabela SZJ
    If cAliasX == "SZJ"
         
        //Montando a query, pegando o último
        cQryMax := " SELECT " + CRLF
        cQryMax += "     ISNULL(MAX(" + cCpoSX8X + "), '') AS ULTIMO " + CRLF 
        cQryMax += " FROM  " + CRLF
        cQryMax += "     " + RetSQLName('SZJ') + " SZJ " + CRLF
        cQryMax += " WHERE  " + CRLF
        cQryMax += "     ZJ_FILIAL = '" + FWxFilial('SZJ') + "' " + CRLF
        cQryMax += "     AND ZJ_NUMERO NOT LIKE 'LANC%' " + CRLF
        cQryMax += "     AND SZJ.D_E_L_E_T_ = ' ' " + CRLF
        TCQuery cQryMax New Alias "QRY_MAX"
         
        //Se tiver dados e se não tiver vazio
        If ! QRY_MAX->(EoF()) .And. ! Empty(QRY_MAX->ULTIMO)
            cCodRet := Soma1(QRY_MAX->ULTIMO)
        EndIf
        QRY_MAX->(DbCloseArea())
         
    EndIf
     
    RestArea(aArea)
Return cCodRet
