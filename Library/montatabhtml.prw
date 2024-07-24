//Bibliotecas
#Include "Totvs.ch"
 
/*/{Protheus.doc} User Function zExe350
Monta uma tabela em HTML conforme um array passado
@type Function
@author Atilio
@since 25/03/2023
@obs 
 
    Fun��o MontaTabelaHTML
    Par�metros
        Recebe um Array com os dados da tabela
        Define se na primeira linha ser� o cabe�alho
        Define a largura em pixels da tabela
    Retorno
        Retorna uma string com as tags montadas em HTML
 
    **** Apoie nosso projeto, se inscreva em https://www.youtube.com/TerminalDeInformacao ****
/*/
 
User Function zExe350()
    Local aArea     := FWGetArea()
    Local cMensagem := ""
    Local aDados    := {}
     
    //Abre a tabela de produtos
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //Filial + C�digo
    SB1->(DbGoTop())
 
    //Adiciona a linha de cabe�alho
    aAdd(aDados, {"C�digo", "Descri��o", "U.M."})
 
    //Enquanto houver dados no cadastro de produtos
    While ! SB1->(EoF())
        //Adiciona a linha no array
        aAdd(aDados, {SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM})
 
        SB1->(DbSkip())
    EndDo
     
    //Aciona a montagem do HTML passando o array, defindindo que tem cabe�alho e uma largura de 800 pixels
    cMensagem := MontaTabelaHTML(aDados, .T., "800")
 
    //Grava o html numa pasta do sistema operacional para testes
    MemoWrite("C:\spool\tabela.html", cMensagem)
 
    FWRestArea(aArea)
Return
