//Bibliotecas
#Include "Totvs.ch"
 
#DEFINE POS_GTIN 0001
#DEFINE POS_PROD 0002
 
/*/{Protheus.doc} zGTIN
Funcao para importar os codigos do GTIN conforme csv
@author Atilio
@since 14/11/2019
@version 1.0
@type function
/*/
 
User Function zGTIN()
    Local aArea    := GetArea()
    Local cTmp := GetTempPath()
    Local cArquivo := "C:\TOTVS\GTIN\" + Space(100)
 
    //Mostra a tela para selecionar CSV
    cArquivo:= tFileDialog( "CSV files (*.csv) ",;
        'Selecao de Arquivos',, cTmp, .F., )
 
    //Se tiver selecionado o arquivo
    If ! Empty(cArquivo)
        Processa({|| GeraDados(cArquivo)}, 'Processando...')
    EndIf
     
    RestArea(aArea)
Return
 
Static Function GeraDados(cArquivo)
    Local nAtual       := 0
    Local nTotal       := 0
    Local cDiretorio   := ""
    Local cArqNew      := ""
    Local cConteudo    := ""
    Local cLinAux      := ""
    Local cArqPuro
    Local nCont        := 0
     
    //Se a extensão for csv e for um arquivo válido
    If ! Empty(cArquivo) .And. ".csv" $ cArquivo .And. File(cArquivo)
         
        cArquivo   := Alltrim(cArquivo)
        cDiretorio := SubStr(cArquivo, 1, RAt('\', cArquivo))
        cArqPuro   := StrTran(cArquivo, cDiretorio, "")
        cArqPuro   := StrTran(cArqPuro, ".csv", "")
        cArqNew    := "importado_" + cArqPuro + "_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + ".txt"
         
        DbSelectArea("SB1")
        SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
        DbSelectArea('SB5')
        SB5->(DbSetOrder(1)) //B5_FILIAL + B5_COD
         
        //Abre o arquivo e pega o total de linhas
        oFile := FWFileReader():New(cArquivo)
        aLinhas := oFile:GetAllLines()
        nTotal := Len(aLinhas)
         
        //Método GoTop não funciona, deve fechar e abrir novamente o arquivo
        oFile:Close()
        oFile := FWFileReader():New(cArquivo)
        oFile:Open()
         
        //Percorre todas as linhas
        While (oFile:HasLine())
            //Incrementa a régua
            nAtual++
            IncProc("Analisando linha " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
             
            //Lê a linha atual
            cLinAux := oFile:GetLine()
             
            //Quebra a linha em um array, e separa o que é gtin e o que é código do produto
            aLinAux := StrTokArr(cLinAux, ";")
            cGTIN := aLinAux[POS_GTIN]
            cProd := Upper(aLinAux[POS_PROD])
             
            //Se encontrar o produto
            If SB1->(DbSeek(FWxFilial('SB1') + cProd))
                cConteudo += "Produto - " + cProd + ', cod.barra - ' + cGTIN + CRLF
                 
                RecLock('SB1', .F.)
                    SB1->B1_CODGTIN := cGTIN
                SB1->(MsUnlock())
                nCont++
 
                //Se encontrar o complemento do produto
                If SB5->(DbSeek(FWxFilial('SB5') + SB1->B1_COD))
                    RecLock('SB5', .F.)
                        B5_2CODBAR := cGTIN
                    SB5->(MsUnlock())
                EndIf
            Else
                cConteudo += "Produto nao encontrado! - " + cProd + CRLF
            EndIf
             
        Enddo
         
        //Fecha o arquivo e finaliza o processamento
        oFile:Close()
         
        MemoWrite(cDiretorio + cArqNew, cConteudo)
         
        MsgInfo(cValToChar(nCont) + " produtos processados, arquivo de log gerado: " + cDiretorio + cArqNew, "Atencao")
     
    Else
     
        MsgStop("Arquivo invalido!", "Atencao")
         
    Endif
     
Return
