//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe414
Retorna os feriados (conforme database do sistema)
@type Function
@author Atilio
@since 28/03/2023
@obs 
 
    Função RetFeriados
    Parâmetros
        Função não tem Parâmetros
    Retorno
        Retorna um array com a lista de feriados (conforme database do sistema)
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe414()
    Local aArea     := FWGetArea()
    Local aFeriados := {}
 
    //Busca os feriados
    aFeriados := RetFeriados()
 
    //Exibe uma mensagem
    FWAlertInfo("Foi encontrado " + cValToChar(Len(aFeriados)) + " feriado(s) conforme a database " + dToC(dDataBase), "Teste RetFeriados")
 
    FWRestArea(aArea)
Return
