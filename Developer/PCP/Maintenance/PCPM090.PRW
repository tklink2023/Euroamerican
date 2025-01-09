//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"
/*/{Protheus.doc} PCPM090
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
User Function PCPM090()
    Local aArea := GetArea()
    PCP90Scren()
    RestArea(aArea)
Return

/*/{Protheus.doc} PCP90Scren
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function PCP90Scren()
    Local aArea := GetArea()
    Local nLargBtn := 50
    Local nLinhaObj := 0
    Local nLargPanel := 0
    // Corpo da TEla
    Private oDlg
    Private oFwLayer
    Private oPantitulo
    Private oPanDados
    Private oPanGrid    
    Private oPanTotal
 //Cabeçalho
    Private oSayModulo, cSayModulo := 'PCP'
    Private oSayTitulo, cSayTitulo := 'Ressuprimentos de Materiais'
    Private oSaySubTit, cSaySubTit := 'Movimentos de ressuprimentos de materiais'
    //Tamanho da janela
    Private aSize := MsAdvSize(.F.)
    Private nJanLarg := aSize[5]
    Private nJanAltu := aSize[6]
    //Fontes
    Private cFontUti    := "Tahoma"
    Private oFontMod    := TFont():New(cFontUti, , -38)
    Private oFontSub    := TFont():New(cFontUti, , -20)
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
    Private oFontSay    := TFont():New(cFontUti, , -12)
    //Grid 
    Private aCampos := {}
    Private cAliasTmp := "PCP_" + RetCodUsr()
    Private aColunas := {}
    Private cMascara := "@E 99,999,999,999.999"
    Private oMarkBrowse
    Private cGetProd := Space(15)
    Private cGetDesc := Space(50)
    Private nGetPerc := Space(3)
    Private dGetDtIni := Ctod("  /  /  ")
    Private dGetDtFim := Ctod("  /  /  ")
    Private nGetDias := 0
    Private nGetMedia:= 0
    Private nGetDesvio := 0
    Private nGetEstSeg := 0
    Private nGetStokMax := 0
    Private nGetSldIni := 0
    Private nGetRessup := 0
    Private nGetstkMedio := 0   
    Private cOperacao := "1"  // PAs
        
    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { "OK"        , "C", 2    , 0 })
    aAdd(aCampos, { "EMISSAO"       , "D", 8    , 0 })
    aAdd(aCampos, { "QUANTIDADE"    , "N", 18   , 3 })
    aAdd(aCampos, { "ENTRADA"       , "N", 18   , 3 })
    aAdd(aCampos, { "SALDO"         , "N", 18   , 3 })
    aAdd(aCampos, { "ENTREGA"       , "D", 8    , 0 })
    aAdd(aCampos, { "PREVISTO"      , "N", 18   , 3 })
    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"EMISSAO"} )
    oTempTable:Create()  

    //Busca as colunas do browse
    aColunas := fCriaCols()

    //Cria a janela
    DEFINE MSDIALOG oDlg TITLE "Ressuprimentos de Materias"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
  
        //Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(oDlg,.F.)
  
        //Adicionando 3 linhas, a de título, a do corpo e a inferior
        oFWLayer:addLine("TITULO", 010, .F.)
        oFWLayer:addLine("CORPO",  088, .F.)
        oFWLayer:addLine("RODAPE", 002, .F.)
  
        //Adicionando as colunas das linhas
        oFWLayer:addCollumn("HEADERTEXT",   050, .T., "TITULO")
        oFWLayer:addCollumn("BLANKBTN",     040, .T., "TITULO")
        oFWLayer:addCollumn("BTNSAIR",      010, .T., "TITULO")
 
        oFWLayer:addCollumn("BLANKANTES",  001, .T., "CORPO")
        oFWLayer:addCollumn("COLDADOS",    039, .T., "CORPO")
        oFWLayer:addCollumn("COLGRIDS",    059, .T., "CORPO")
        oFWLayer:addCollumn("BLANKDEPOIS", 001, .T., "CORPO")
  
        //Criando os paineis
        oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TITULO")
        oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TITULO")
        oPanDados  := oFWLayer:GetColPanel("COLDADOS",   "CORPO")
        oPanGrid   := oFWLayer:GetColPanel("COLGRIDS",    "CORPO")

  
        //Títulos e SubTítulos
        oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
        oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(014, 045, {|| cSaySubTit}, oPanHeader, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
  
        //Criando os botões
        oBtnSair := TButton():New(006, 001, "Fechar",             oPanSair, {|| oDlg:End()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )
  
        
 
        //Cria os componentes da segunda coluna
        @ 001, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE oPanDados:nHeight / 2, oPanDados:nWidth / 2 OF oPanDados

        nLinhaObj := 5
        nLargPanel := (oPanDados:nWidth) / 2
        nTotEspCol := (nLargPanel/3)

        nTotCol01  := 003 + nTotEspCol * 0
        nTotCol02  := 003 + nTotEspCol * 1
        
        oSayProd   := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Produto"},   oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetProd   := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , cGetProd := u, cGetProd)}, oScroll, nTotEspCol - 9, 10, PesqPict("SB1", "B1_COD"), /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
        oGetProd:bValid := {|| fVldProd()}
        oGetProd:cF3 := "SB1"
        oGetProd:bHelp := {|| ShowHelpcpo('Ajuda',{"Digite o código do produto"},0)}

        nLinhaObj += 15
        oSayDesc  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Descrição"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDesc  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , cGetDesc := u, cGetDesc)}, oScroll, nTotEspCol - 9, 10, PesqPict("SB1", "B1_DESC"), /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayPerc  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "% Segurança"},         oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetPerc  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetPerc := u, nGetPerc)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)   
        oGetPerc:bValid := {|| fVldPerc()}
        oGetPerc:cF3 := "XXY"
        oGetPerc:bHelp := {|| ShowHelpcpo('Ajuda',{"Digite o Percentual de Seguranca"},0)}

        nLinhaObj += 15
        oSaydtini := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Data Inicial"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDtIni := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , dGetDtIni := u, dGetDtIni)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
        oGetDtIni:bValid := {|| fGeraDtFinal()}

        nLinhaObj += 15
        oSaydtFim := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Data Final"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDtFim := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , dGetDtFim := u, dGetDtFim)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Lead Time"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetDias := u, nGetDias)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
        oGetDias:bValid := {|| fleadtime()}

        nLinhaObj += 25
        oBtnProc := TButton():New(nLinhaObj,  001 + nTotCol01, "Processar informações", oPanDados, {|| PCP80CALC()}, nTotEspCol - 3, 018, , oFontBtn, , .T., , , , , , )
        oBtnProc:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")
 
        nLinhaObj += 25
        oSayMedia  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Media"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetMedia  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetMedia := u, nGetMedia)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDesvio  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Desvio"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDesvio  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetDesvio := u, nGetDesvio)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayEstSego  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Estoque Seguranca"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetEstSego  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetEstSeg := u, nGetEstSeg)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayRessup  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Ponto Ressuprimento"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetRessup  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetRessup := u, nGetRessup)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSaysldini  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Estoque Inical"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetsldini  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetsldini := u, nGetsldini)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSaystokMax  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Estoque Maximo"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetstokMax  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetStokMax := u, nGetStokMax)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSaysldini  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Estoque Medio"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetsldini  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetstkMedio := u, nGetstkMedio)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)


        nLinhaObj += 25
        oBtnProc := TButton():New(nLinhaObj,  001 + nTotCol01, "Projetar dados", oPanDados, {|| IIF(cOperacao=="1",fPopula(),fEntrada()) }, nTotEspCol - 3, 018, , oFontBtn, , .T., , , , , , )
        oBtnProc:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

        nLinhaObj += 25
        oBtnProc := TButton():New(nLinhaObj,  001 + nTotCol01, "Grafico", oPanDados, {||IIF(cOperacao=="1", U_PCP90GRMED(cGetProd,Year(dGetDtFim)),U_PCP91GRMED(cGetProd,Year(dGetDtFim)))}, nTotEspCol - 3, 018, , oFontBtn, , .T., , , , , , )
        
        oBtnProc:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")

    Activate MsDialog oDlg Centered
    oTempTable:Delete()
    RestArea(aArea)
Return


/*/{Protheus.doc} fCriaCols
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, {"EMISSAO", "Emissao",             "D", 08,   0, ""})
    aAdd(aEstrut, {"QUANTIDADE", "Quantidade",       "N", 18,   3, cMascara})
    aAdd(aEstrut, {"ENTRADA", "Entrada",             "N", 18,   3, cMascara})
    aAdd(aEstrut, {"SALDO", "Saldo",                 "N", 18,   3, cMascara})
    aAdd(aEstrut, {"ENTREGA", "Entrega",             "D", 08,   0, ""})
    aAdd(aEstrut, {"PREVISTO", "Previsto",           "N", 18,   3, cMascara})

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasTmp)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
  
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas


/*/{Protheus.doc} fVldProd
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fVldProd()
    Local lRet := .T.
    
    IF !Empty(cGetProd)
        dbSelectArea("SB1")
        SB1->( dbSetOrder(1) )
        IF SB1->(dbSeek(xFilial("SB1")+cGetProd) )
           cGetDesc := SB1->B1_DESC
           cOperacao := IIF(SB1->B1_TIPO == "PA", "1", "2")
        else
            MsgAlert("Produto não encontrado")
            cGetDesc := "Produto não encontrado"
            lRet := .F.   
        ENDIF   
    Else
        lRet := .F.
    endif
Return lRet

/*/{Protheus.doc} fVldPerc
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fVldPerc()
    Local lRet      := .T.
    Local nValor    := 0
    nValor := U_PCP80PERC(nGetPerc)
    IF nValor = "0"
        MsgAlert("Percentual de Segurança desconhecido")
        lRet := .F.
    ENDIF    
Return lRet

/*/{Protheus.doc} fGeraDtFinal
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fGeraDtFinal()
    Local lRet := .T.
    IF dGetDtIni != Ctod("  /  /  ")
        dGetDtFim := dGetDtIni + 30
    ELSE
        MsgAlert("Data Inicial não informada")
        lRet := .F.
    ENDIF  
Return(lRet) 


/*/{Protheus.doc} fleadtime
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fleadtime()
    Local lRet := .T.
   
    IF nGetDias == 0
        MsgAlert("Não pode informar zero para o Lead Time")
        lRet := .F.
    ENDIF  

Return(lRet) 


/*/{Protheus.doc} PCP80CALC
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function PCP80CALC()
    Local aArea := GetArea()
    Local nPerct := U_PCP80PERC(nGetPerc)
    if cOperacao == "1"
        nGetMedia := U_PCP80AVG(cGetProd,dGetDtIni,dGetDtFim)
        nGetDesvio:= U_PCP80DVP(cGetProd,dGetDtIni,dGetDtFim)
    else
        nGetMedia := U_PCP90AVG(cGetProd,dGetDtIni,dGetDtFim)
        nGetDesvio:= U_PCP90DVP(cGetProd,dGetDtIni,dGetDtFim)
    endif    
    nGetEstSeg:= U_PCP80SEG(nGetDesvio,nGetDias,nGetMedia,nPerct)
    nGetsldini:= U_PCP80SLDINI(cGetProd)
    nGetRessup:= (nGetMedia * nGetDias) + nGetEstSeg
    nGetStokMax:= (nGetMedia + nGetEstSeg) * nGetDias
    nGetstkMedio := ((nGetStokMax - nGetEstSeg)/2)+nGetEstSeg
    RestArea(aArea) 
Return

/*/{Protheus.doc} fPopula
description
@type function
@version 1.0
@author Paulo Lenzi
@since 08/01/2025
@return variant, return_description
/*/
Static Function fPopula()
    Local aArea   := FwgetArea()
    Local cQuery  as character 
    Local cAlias  := "PCP_"+getNextAlias() 
    Local afields := {} ; aDados := {}
    Local AB
    Local XY
    Local nPos := 0

    Local nSldProc    := nGetsldini
    Local nQtdRessupr := nGetRessup
    Local nQtdStokMax := nGetStokMax
    Local nQtdAbast   := 0
    Local nQtdSoma    := 0

    cQuery:="Select D2_COD,D2_EMISSAO,SUM(D2_QUANT) QTD   "+CRLF
    cQuery+="From " + RetSqlName("SD2") + " SD2   "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = SUBSTRING(D2_FILIAL,1,2) AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="Where SD2.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="AND D2_FILIAL = '"+xFilial("SD2")+"'   "+CRLF
    cQuery+="AND D2_EMISSAO BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"'   "+CRLF
    cQuery+="AND D2_COD = '"+cGetProd+"'   "+CRLF
    cQuery+="GROUP BY D2_COD,D2_EMISSAO   "+CRLF
    cQuery+="ORDER BY D2_COD,D2_EMISSAO   "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    TCSetField(cAlias, "D2_EMISSAO", "D")

    IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(0)
    endif
    
    //-------------------------------------------
    // Dados do Movimento de Saída
    //----------------------------------------- 

    dbSelectArea(cAlias)
    (cAlias)->( dbgotop())
    DO WHILE !(cAlias)->(Eof())

        nQtdAbast := 0
        DtPrevisto:= Ctod("  /  /  ") 

        nSldAnt  := nSldProc
        if nSldAnt < 0
               nSldAnt := (nSldAnt * -1) 
        endif


        nSldProc := (nSldProc - (cAlias)->QTD ) 
    

        nQtdSoma := nQtdSoma + (cAlias)->QTD

        if nSldProc <= nQtdRessupr 
         
            nQtdAbast  :=  (nQtdStokMax - nSldAnt ) - nQtdSoma
            DtPrevisto :=  DataValida((cAlias)->D2_EMISSAO + nGetDias)
            aAdd(afields, { (cAlias)->D2_EMISSAO, (cAlias)->QTD, 0, nSldProc, DtPrevisto, nQtdAbast})
            nQtdSoma   := 0
            aAdd(aDados, { DtPrevisto, 0, nQtdAbast, 0, Ctod("  /  /  "), 0})
            
             (cAlias)->(dbskip())
             Loop

        Endif

        aAdd(afields, { (cAlias)->D2_EMISSAO, (cAlias)->QTD, 0, nSldProc, DtPrevisto, nQtdAbast})
        (cAlias)->(dbskip())
    ENDDO

    //-------------------------------------------
    // Ajustando as Datas de Entrada no Movimento de Saída
    //----------------------------------------- 

 
    if len(aDados) > 0
       FOR AB:= 1 TO LEN(aDados)
       
          nPos := aScan(afields,{|x| x[1] == aDados[AB][1] })
          if nPos > 0
            afields[nPos][3] := afields[nPos][3] + aDados[AB][3]
            nSldProc := (afields[nPos-1][4] - afields[nPos][2]) + afields[nPos][2] 
            afields[nPos][4] := nSldProc
          else

            FOR XY:= 1 TO 10
              nPos := aScan(afields,{|x| x[1] == (aDados[AB][1])+xy })
              if nPos > 0
                 afields[nPos][3] := afields[nPos][3] + aDados[AB][3]
                 nSldProc := (afields[nPos-1][4] - afields[nPos][2]) + afields[nPos][2] 
                 afields[nPos][4] := nSldProc
                 exit
              endif                  
            NEXT

          endif

       NEXT  
    endif

    //-------------------------------------------
    // Ajustando Saldo dos movimento de Saída
    //----------------------------------------- 

    nSldProc := nGetsldini
    if len(afields) > 0
       FOR AB:= 1 TO LEN(afields)

            nSldProc := (nSldProc - afields[AB][2] )  + afields[AB][3]

            afields[AB][4] := nSldProc

            if afields[AB][4] > nGetRessup
               aFields[AB][5] := Ctod("  /  /  ")                
               afields[AB][6] := 0              
            endif    

       NEXT  
    endif

   //-------------------------------------------
    // Gravando os dados na Temporária
    //----------------------------------------- 

    if len(afields) > 0
       FOR AB:= 1 TO LEN(afields)
           dbSelectArea(cAliasTmp)
           (cAliasTmp)->( dbSetOrder(1))
           if (cAliasTmp)->( !dbSeek( afields[AB][1] ),.T.)
        
                IF RecLock(cAliasTmp, .T.)
                    (cAliasTmp)->OK     := ""
                    (cAliasTmp)->EMISSAO    := afields[AB][1]
                    (cAliasTmp)->QUANTIDADE := afields[AB][2]
                    (cAliasTmp)->ENTRADA    := afields[AB][3]
                    (cAliasTmp)->SALDO      := afields[AB][4]
                    (cAliasTmp)->ENTREGA    := afields[AB][5]  
                    (cAliasTmp)->PREVISTO   := afields[AB][6]
                    (cAliasTmp)->(MsUnlock())
                Endif         
            else
                IF RecLock(cAliasTmp, .F.)
                    (cAliasTmp)->QUANTIDADE := afields[AB][2]
                    (cAliasTmp)->ENTRADA    := afields[AB][3]
                    (cAliasTmp)->SALDO      := afields[AB][4]
                    (cAliasTmp)->ENTREGA    := afields[AB][5]  
                    (cAliasTmp)->PREVISTO   := afields[AB][6]
                    (cAliasTmp)->(MsUnlock())
                Endif   
            endif    
       NEXT

    endif
    
         //Cria a grid
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:DisableFilter()
        oMarkBrowse:DisableConfig()
        oMarkBrowse:DisableReport()
        oMarkBrowse:DisableSeek()
        oMarkBrowse:DisableSaveConfig()
        oMarkBrowse:SetFontBrowse(oFontSay)
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:Activate()

  (calias)->(DbCloseArea()) 
  FwRestArea(aArea)
Return

/*/{Protheus.doc} fEntrada
description
@type function
@version 1.0
@author Paulo Lenzi
@since 09/01/2025
@return variant, return_description
/*/
Static Function fEntrada()
    Local aArea   := FwgetArea()
    Local cQuery  as character 
    Local cAlias  := "PCP_"+getNextAlias() 
    Local afields := {} ; aDados := {}
    Local AB
    Local XY
    Local nPos := 0


    Local nSldProc    := nGetsldini
    Local nQtdRessupr := nGetRessup
    Local nQtdStokMax := nGetStokMax
    Local nQtdAbast   := 0
    Local nQtdSoma    := 0

    cQuery:="Select D1_COD,D1_DTDIGIT,SUM(D1_QUANT) QTD   "+CRLF
    cQuery+="From " + RetSqlName("SD1") + " SD1   "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_FILIAL = SUBSTRING(D1_FILIAL,1,2) AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND F4_DUPLIC = 'S' AND SF4.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="Where SD1.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="AND D1_FILIAL = '"+xFilial("SD1")+"'   "+CRLF
    cQuery+="AND D1_DTDIGIT BETWEEN '"+DtoS(dGetDtIni)+"' AND '"+DtoS(dGetDtFim)+"'   "+CRLF
    cQuery+="AND D1_COD = '"+cGetProd+"'   "+CRLF
    cQuery+="GROUP BY D1_COD,D1_DTDIGIT   "+CRLF
    cQuery+="ORDER BY D1_COD,D1_DTDIGIT   "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
    TCSetField(cAlias, "D1_DTDIGIT", "D")

    IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return(0)
    endif
    
    //-------------------------------------------
    // Dados do Movimento de Saída
    //----------------------------------------- 

    dbSelectArea(cAlias)
    (cAlias)->( dbgotop())
    DO WHILE !(cAlias)->(Eof())
        
        nSldProc := (nSldProc - (cAlias)->QTD ) 
        nQtdAbast := 0
        DtPrevisto:= Ctod("  /  /  ") 

        if nSldProc <= nQtdRessupr 
            nQtdAbast  :=  (nQtdStokMax - (nSldProc * -1)) - nQtdSoma
            DtPrevisto :=  DataValida((cAlias)->D1_DTDIGIT + nGetDias)
            aAdd(afields, { (cAlias)->D1_DTDIGIT, (cAlias)->QTD, 0, nSldProc, DtPrevisto, nQtdAbast})

            nSldProc   :=  nQtdAbast
            nQtdSoma   := 0
            aAdd(aDados, { DtPrevisto, 0, nQtdAbast, nSldProc, Ctod("  /  /  "), 0})
            
             (cAlias)->(dbskip())
             Loop

        Endif

        aAdd(afields, { (cAlias)->D1_DTDIGIT, (cAlias)->QTD, 0, nSldProc, DtPrevisto, nQtdAbast})
        nQtdSoma := nQtdSoma + (cAlias)->QTD
        (cAlias)->(dbskip())
    ENDDO

    //-------------------------------------------
    // Ajustando as Datas de Entrada no Movimento de Saída
    //----------------------------------------- 

 
      if len(aDados) > 0
       FOR AB:= 1 TO LEN(aDados)
       
          nPos := aScan(afields,{|x| x[1] == aDados[AB][1] })
          if nPos > 0
            afields[nPos][3] := afields[nPos][3] + aDados[AB][3]
            nSldProc := (afields[nPos-1][4] - afields[nPos][2]) + afields[nPos][2] 
            afields[nPos][4] := nSldProc
          else

            FOR XY:= 1 TO 10
              nPos := aScan(afields,{|x| x[1] == (aDados[AB][1])+xy })
              if nPos > 0
                 afields[nPos][3] := afields[nPos][3] + aDados[AB][3]
                 nSldProc := (afields[nPos-1][4] - afields[nPos][2]) + afields[nPos][2] 
                 afields[nPos][4] := nSldProc
                 exit
              endif                  
            NEXT

          endif

       NEXT  
    endif

    //-------------------------------------------
    // Ajustando Saldo dos movimento de Saída
    //----------------------------------------- 

    nSldProc := nGetsldini
    if len(afields) > 0
       FOR AB:= 1 TO LEN(afields)

            nSldProc := (nSldProc + afields[AB][3] )  - afields[AB][2]
            afields[AB][4] := nSldProc

            if nSldProc > nGetRessup
               aFields[AB][5] := Ctod("  /  /  ")                
               afields[AB][6] := 0              
            endif    

       NEXT  
    endif

   //-------------------------------------------
    // Gravando os dados na Temporária
    //----------------------------------------- 

    if len(afields) > 0
       FOR AB:= 1 TO LEN(afields)
           dbSelectArea(cAliasTmp)
           (cAliasTmp)->( dbSetOrder(1))
           if (cAliasTmp)->( !dbSeek( afields[AB][1] ),.T.)
        
                IF RecLock(cAliasTmp, .T.)
                    (cAliasTmp)->OK     := ""
                    (cAliasTmp)->EMISSAO    := afields[AB][1]
                    (cAliasTmp)->QUANTIDADE := afields[AB][2]
                    (cAliasTmp)->ENTRADA    := afields[AB][3]
                    (cAliasTmp)->SALDO      := afields[AB][4]
                    (cAliasTmp)->ENTREGA    := afields[AB][5]  
                    (cAliasTmp)->PREVISTO   := afields[AB][6]
                    (cAliasTmp)->(MsUnlock())
                Endif         
            else
                IF RecLock(cAliasTmp, .F.)
                    (cAliasTmp)->QUANTIDADE := afields[AB][2]
                    (cAliasTmp)->ENTRADA    := afields[AB][3]
                    (cAliasTmp)->SALDO      := afields[AB][4]
                    (cAliasTmp)->ENTREGA    := afields[AB][5]  
                    (cAliasTmp)->PREVISTO   := afields[AB][6]
                    (cAliasTmp)->(MsUnlock())
                Endif   
            endif    
       NEXT

    endif
    
         //Cria a grid
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:DisableFilter()
        oMarkBrowse:DisableConfig()
        oMarkBrowse:DisableReport()
        oMarkBrowse:DisableSeek()
        oMarkBrowse:DisableSaveConfig()
        oMarkBrowse:SetFontBrowse(oFontSay)
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:Activate()

  (calias)->(DbCloseArea()) 
  FwRestArea(aArea)
Return
//---------------------------------------------------------------------------------------------------------------------------------------//
// FINAL DO PROGRAMA
//---------------------------------------------------------------------------------------------------------------------------------------//


