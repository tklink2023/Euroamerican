//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe097
Verifica se um campo é obrigatório no Protheus
@type Function
@author Atilio
@since 11/12/2022
@obs 
    Função CpoObrigat
    Parâmetros
        + Nome do campo
    Retorno
        + .T. se o campo for obrigatório ou .F. se não
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe097()
    Local aArea     := FWGetArea()
    Local cCampo    := "B1_DESC"
 
    //Testa se o campo é obrigatório
    If CpoObrigat(cCampo)
        FWAlertSuccess("O campo é obrigatório", "Teste CpoObrigat")
    Else
        FWAlertError("O campo não é obrigatório", "Teste CpoObrigat")
    EndIf
 
    FWRestArea(aArea)
Return
