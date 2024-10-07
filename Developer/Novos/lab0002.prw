//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zInTst
Fun��o que valida se esta em base de testes
@type  Function
@author Atilio
@since 25/09/2024
@param nTipo, Num�rico, Se for 1 ir� validar pelo nome do ambiente (environment) se n�o vai validar pelo nome da base de dados no DbAccess
@return lEmTeste, L�gico, .T. se esta na base de testes e .F. se n�o est�
@example 
    [...]
     
    If u_zInTst(1)
        Alert("estou na base de testes")
    Else
        Alert("estou na base de produ��o)
    EndIf
 
    [...]
@obs Atualize as seguintes linhas do fonte:
    Linha 52 com o nome dos ambientes da base de teste
    Linha 77 com o nome da base no DbAccess
/*/
 
User Function zInTst(nTipo)
    Local aArea    := FWGetArea()
    Local lEmTeste := .F.
    Default nTipo  := 2
 
    //Se for para testar via nome de ambiente
    If nTipo == 1
        lEmTeste := fViaAmbiente()
 
    //Sen�o, pega pelo nome da base no DbAccess
    Else
        lEmTeste := fViaDbAccess()
    EndIf
 
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fViaDbAccess
Busca via DbAccess dentro do appserver.ini o nome da base se � a base de testes
@type  Static Function
@author Atilio
@since 25/09/2024
/*/
 
Static Function fViaAmbiente()
    Local aArea      := FWGetArea()
    Local cNomeAmb   := Alltrim(GetEnvServer()) + ";"
    Local cAmbTst    := "AMBTST;AMBTST2;AMBTST_JOB;" //Coloque aqui os nomes dos ambientes da base de testes
    Local lEmTeste   := .F.
 
    //Se o ambiente estiver na lista dos da base de testes
    If cNomeAmb $ cAmbTst
        lEmTeste := .T.
    EndIf
 
    FWRestArea(aArea)
Return lEmTeste
 
 
/*/{Protheus.doc} fViaDbAccess
Busca via DbAccess dentro do appserver.ini o nome da base se � a base de testes
@type  Static Function
@author Atilio
@since 25/09/2024
/*/
 
Static Function fViaDbAccess()
    Local aArea      := FWGetArea()
    Local cIniFile   := GetAdv97()
    Local cStrError  := "ERROR"
    Local cNomeBase  := ""
    Local cBaseTst   := "BASE_TST" //Coloque aqui o nome da sua base de testes que est� no DbAccess
    Local lEmTeste   := .F.
 
    //Busca o nome da base na se��o "DbAccess"
    cNomeBase := GetPvProfString("DbAccess", "Alias", cStrError, cIniFile)
 
    //Se n�o encontrou ou deu erro, ai vamos buscar novamente mas agora ao inv�s de "DbAccess" vamos usar a se��o "TopConnect"
    If Empty(cNomeBase) .Or. cNomeBase == cStrError
        cNomeBase := GetPvProfString("TopConnect", "Alias", cStrError, cIniFile)
        cPasso    := "2"
    EndIf
 
    //Se n�o encontrou ou deu erro, ai vamos buscar novamente mas agora ao inv�s de "TopConnect" vamos usar a se��o "TotvsDBAccess"
    If Empty(cNomeBase) .Or. cNomeBase == cStrError
        cNomeBase := GetPvProfString("TotvsDBAccess", "Alias", cStrError, cIniFile)
        cPasso    := "3"
    EndIf
 
    //Se mesmo assim n�o encontrou, vamos buscar direto do ambiente
    If Empty(cNomeBase) .Or. cNomeBase == cStrError
        cNomeBase := GetSrvProfString("DBAlias", cStrError)
        cPasso    := "4"
    EndIf
 
    //Se for a base de Homologa��o / Testes
    If cNomeBase == cBaseTst
        lEmTeste := .T.
    EndIf
 
    FWRestArea(aArea)
Return lEmTeste
