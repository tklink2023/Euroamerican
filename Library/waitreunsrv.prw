//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zExe528
Executa uma aplica��o no sistema operacional onde esta rodando o AppServer
@type Function
@author Atilio
@since 06/04/2023
@obs 
 
    Fun��o WaitRunSrv
    Par�metros
        Nome do aplicativo que ser� executado
        Determina se ir� aguardar a aplica��o encerrar (.T.) ou n�o (.F.)
        Pasta raiz do aplicativo
    Retorno
        Retorna .T. se deu certo a execu��o ou .F. se n�o
 
    Exemplo do comando dentro desse nosso .bat de exemplo:
        getmac > C:\spool\teste_mac_address_wait.txt
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe528()
    Local aArea      := FWGetArea()
    Local lWait      := .F.
    Local cPrograma  := ""
 
    //Define as vari�veis que ser�o usadas na execu��o
    lWait       := .T.
    cPrograma   := "C:\spool\programa_teste.bat"
     
    //Tenta executar a aplica��o e mostra uma mensagem
    If ! WaitRunSrv(cPrograma, lWait , "C:\" )
        FWAlertError("Erro na execu��o do aplicativo �s " + Time(), "Teste WaitRunSrv")
    Else
        FWAlertSuccess("Sucesso na execu��o do aplicativo no servidor �s " + Time(), "Teste WaitRunSrv")
    EndIf
 
    FWRestArea(aArea)
Return
