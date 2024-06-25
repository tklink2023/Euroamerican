//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"
 
/*/{Protheus.doc} User Function zLancSB2
Exemplo de criação de informações do armazém
@type  Function
@author Atilio
@since 17/07/2023
/*/
User Function zLancSB2()
    Local aArea := FWGetArea()
     
    If FWAlertYesNo("Deseja criar a SB2 para todos os produtos no armazém 01?", "Continua?")
        Processa({|| fProcessa()}, "Processando")
    EndIf
     
    FWRestArea(aArea)
Return
 
Static Function fProcessa()
    Local aArea      := FWGetArea()
    Local cQueryAux  := ""
    Local nAtual     := 0
    Local nTotal     := 0
    Local cArmazem   := "01"
    //Backup da empresa e filial atual
    Local cEmpBkp    := cEmpAnt
    Local cFilBkp    := cFilAnt
    Local cNumEmpBkp := cNumEmp
    //Variável usada internamente no A120ChkAlmox
    Private l120Auto := .T.
 
    //Troca a filial para a que será criada as informações
    cFilAnt := "0201"
    cFilialEnt := cFilAnt
    cNumEmp := cEmpAnt + cFilAnt
    OpenFile(cNumEmp)
 
    //Busca todos os produtos que não estão bloqueados
    cQueryAux := "SELECT B1_COD FROM " + RetSQLName("SB1") + " SB1 WHERE B1_FILIAL = '" + FWxFilial("SB1") + "' AND B1_MSBLQL != '1' AND SB1.D_E_L_E_T_ = ' '"
    TCQuery cQueryAux New Alias "QRY_AUX"
 
    //Define o tamanho da régua
    Count To nTotal
    ProcRegua(nTotal)
    QRY_AUX->(DbGoTop())
 
    //Enquanto houver dados
    While ! QRY_AUX->(EoF())
         
        //Incrementa a régua
        nAtual++
        IncProc("Analisando produto '" + Alltrim(QRY_AUX->B1_COD) + "' (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
     
        //Aciona a checagem / criação do saldo no armazém para o produto
        A120ChkAlmox(QRY_AUX->B1_COD, cArmazem)
 
        QRY_AUX->(DbSkip())
    EndDo
    QRY_AUX->(DbCloseArea())
     
    //Volta o backup da filial
    cEmpAnt := cEmpBkp
    cFilAnt := cFilBkp
    cNumEmp := cEmpAnt + cFilAnt
    OpenFile(cNumEmp)
     
    FWRestArea(aArea)
Return
