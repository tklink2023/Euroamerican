//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe479
Atualiza as definições de uma tabela no Cache do DBAccess
@type Function
@author Atilio
@since 03/04/2023
@see https://tdn.totvs.com/display/tec/TCRefresh
@obs 
 
    TCRefresh
    Parâmetros
        + cTable     , Caractere      , Nome da tabela a ser analisada
    Retorno
        Função não tem retorno
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe479()
    Local aArea   := FWGetArea()
    Local cTabela := ""
 
    //Aciona o refresh para o cadastro de produtos
    cTabela := RetSQLName("SB1")
    TCRefresh(cTabela)
 
    //Exibe uma mensagem
    FWAlertInfo("Foi executado o refresh para a tabela " + cTabela, "Teste TCRefresh")
 
    FWRestArea(aArea)
Return
