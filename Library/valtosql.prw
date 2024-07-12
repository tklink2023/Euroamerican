//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe525
Fun��o que pega uma vari�vel e ja converte para ser usada em um filtro no SQL (adicionando ap�strofos)
@type Function
@author Atilio
@since 06/04/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6814752
@obs 
 
    Fun��o ValToSQL
    Par�metros
        Recebe a vari�vel ou express�o a ser validada
    Retorno
        Retorna a express�o j� pronta para ser usada no filtro com os ap�strofos
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe525()
    Local aArea      := FWGetArea()
    Local cQuery     := ""
    Local cFilAux    := "01"
    Local dDataAux   := MonthSub(Date(), 1)
 
    //Monta a query
    cQuery := " SELECT " + CRLF
    cQuery += "     F2_DOC, F2_EMISSAO, F2_VALBRUT " + CRLF
    cQuery += " FROM " + CRLF
    cQuery += "     " + RetSQLName("SF2") + " SF2 " + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += "     F2_FILIAL = " + ValToSQL(cFilAux) + " " + CRLF
    cQuery += "     AND F2_EMISSAO >= " + ValToSQL(dDataAux) + " " + CRLF
    cQuery += "     AND SF2.D_E_L_E_T_ = '' " + CRLF
 
    //Exibe o resultado
    FWAlertInfo(cQuery, "Teste ValToSQL")
 
    FWRestArea(aArea)
Return
