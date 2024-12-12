//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"


User Function PCPM080()
    Local aArea := GetArea()
    PCP080Tela()
    RestArea(aArea)
Return

Static Function PCP080Tela()
    Local nLargBtn      := 50
    Local nLinhaObj     := 0
    Local nLargPanel    := 0
    //Objetos e componentes gerais
    Private oDlgExemp
    Private oFwLayer
    Private oPanTitulo
    Private oPanGrid
    Private oPanBlk1

    Private oPanCheck
    
    Private oPanTotal
    Private cMascara := "@E 999,999,999.999"
    Private cMascTmp := "@R 9999"
    Private aCabecDet:={}
    //Cabeçalho
    Private oSayModulo, cSayModulo := 'PCP'
    Private oSayTitulo, cSayTitulo := 'Planejamento Produção
    Private oSaySubTit, cSaySubTit := 'Movimentações MP e EM'
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
    Private oMarkBrowse
    Private oBrowser1
    //Componentes da segunda coluna
    Private oSayChkDes
    Private oSayChkPer
    Private oSayChkVlr
    //Componentes da terceira coluna
    Private oSayTot, cSayTot := "Total marcado:",             oGetTot, nGetTot := 0
    Private oSayApu, cSayApu := "% Apurado:",                 oGetApu, nGetApu := 0
    Private oSayPro, cSayPro := "Total que será processado:", oGetPro, nGetPro := 0
    Private oBtnProc, oBtnPrev
   
    //Adiciona as colunas que serão criadas na temporária 
    // Paulo Lenzi - 04/12/2024 fase 1
    aAdd(aCampos, { "OK"        , "C", 2    , 0 })
    aAdd(aCampos, { "CODIGO"    , "C", 15   , 0 })
    aAdd(aCampos, { "DESCR"     , "C", 50   , 0 })
    aAdd(aCampos, { "ALMOX"     , "C", 2   , 0 })
    aAdd(aCampos, { "SALDO"     , "N", 15   , 3 })
    aAdd(aCampos, { "EMPEN"     , "N", 15   , 3 })
    aAdd(aCampos, { "DISPO"     , "N", 15   , 3 })    
    aAdd(aCampos, { "MEDIA"     , "N", 15   , 3 })
    aAdd(aCampos, { "DEMAN"     , "N", 15   , 3 })
    aAdd(aCampos, { "COBERT"    , "N", 15   , 3 })

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:Create()  
   
    //Busca as colunas do browse
    aColunas := fCriaCols()
   
    //Popula a tabela temporária
    Processa({|| fPopula()}, "Processando...")
   
    //Cria a janela
    DEFINE MSDIALOG oDlgExemp TITLE "Planejamento de Producao"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
   
        //Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(oDlgExemp,.F.)
   
        //Adicionando 3 linhas, a de título, a superior e a do calendário
        oFWLayer:addLine("TITULO", 010, .F.)
        oFWLayer:addLine("CORPO",  088, .F.)
        oFWLayer:addLine("RODAPE", 002, .F.)
   
        //Adicionando as colunas das linhas
        oFWLayer:addCollumn("HEADERTEXT",   050, .T., "TITULO")
        oFWLayer:addCollumn("BLANKBTN",     040, .T., "TITULO")
        oFWLayer:addCollumn("BTNSAIR",      010, .T., "TITULO")
  
        oFWLayer:addCollumn("BLANKANTES",   001, .T., "CORPO")
        oFWLayer:addCollumn("COLGRID",      046, .T., "CORPO")
        oFWLayer:addCollumn("COLBLK1",      046, .T., "CORPO")
        oFWLayer:addCollumn("COLTOTAL",     006, .T., "CORPO")
        oFWLayer:addCollumn("BLANKDEPOIS",  001, .T., "CORPO")
   
        //Criando os paineis
        oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TITULO")
        oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TITULO")
        oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "CORPO")
        oPanBlk1   := oFWLayer:GetColPanel("COLBLK1",    "CORPO")

        //oPanCheck  := oFWLayer:GetColPanel("COLCHECK",   "CORPO")

        oPanTotal  := oFWLayer:GetColPanel("COLTOTAL",   "CORPO")
   
        //Títulos e SubTítulos
        oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
        oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(014, 045, {|| cSaySubTit}, oPanHeader, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
   
        //Criando os botões
        oBtnSair := TButton():New(006, 001, "Fechar",             oPanSair, {|| oDlgExemp:End()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , )
   
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
  
        //Cria os componentes da segunda coluna
        @ 001, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE oPanBlk1:nHeight / 2, oPanBlk1:nWidth / 2 OF oPanBlk1
          
        nLinhaObj := 1
        nLargPanel := (oPanBlk1:nWidth) / 2
        nTotEspCol := (nLargPanel/3)

        aAdd(aCabecDet,"Dia")
        aAdd(aCabecDet,"Quant")

        oBrowser1 := TCBROWSE():NEW(nLinhaObj,045,oPanBlk1:nWidth / 2  - 5,oPanBlk1:nHeight / 2,,aCabecDet,{20,30,30,30,30,30,30,10},oPanBlk1,,,,,,,,,,,, .F. ,"", .T. ,, .F. ,, .T. , .T. )         
  
        //Cria os componentes da terceira coluna
        nLargPanel := (oPanTotal:nWidth) / 2
        nLinhaObj  := 30
  
        nLinhaObj += 20
        oBtnProc := TButton():New(nLinhaObj, 003, "Grafico",      oPanTotal, {|| Alert("botão 1")}, nLargPanel - 3, 018, , oFontBtn, , .T., , , , , , )
        nLinhaObj += 25
        oBtnPrev := TButton():New(nLinhaObj, 003, "Ordens",         oPanTotal, {|| Alert("botão 2")}, nLargPanel - 3, 018, , oFontBtn, , .T., , , , , , )
  
    Activate MsDialog oDlgExemp Centered
    oTempTable:Delete()
Return
   
Static Function fCriaCols()
    Local nAtual   := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
       
    //Adicionando campos que serão mostrados na tela
    // Paulo Lenzi - 04/12/2024 fase 2
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, {"CODIGO", "Codigo",        "C", 15,   0, ""})
    aAdd(aEstrut, {"DESCR" , "Descricao",     "C", 50,   0, ""})
    aAdd(aEstrut, {"ALMOX", "Local",          "C", 02,   0, ""})
    aAdd(aEstrut, {"SALDO", "Saldo",          "N", 15,   3, cMascara})
    aAdd(aEstrut, {"EMPEN", "Empenho",        "N", 15,   3, cMascara})
    aAdd(aEstrut, {"DISPO", "Disponivel",     "N", 15,   3, cMascara})
    aAdd(aEstrut, {"MEDIA", "Media",          "N", 15,   3, cMascara}) 
    aAdd(aEstrut, {"DEMAN", "Demanda",        "N", 10,   0, cMascTmp})    
    aAdd(aEstrut, {"COBERT","Dias",           "N", 10,   0, cMascTmp})    
   
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
   
Static Function fPopula()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "B"+getNextAlias()      
    cQuery:="Select	 B2_FILIAL	FILIAL "+CRLF
    cQuery+="		,B2_COD		CODIGO "+CRLF
    cQuery+="		,SUBSTRING(B1_DESC,1,49)    DESCRICAO "+CRLF
    cQuery+="		,B2_LOCAL	ALMOX "+CRLF
    cQuery+="		,B2_QATU	SALDO "+CRLF
    cQuery+="		,B2_QEMP	EMPENHO "+CRLF
    cQuery+="		,ROUND((B2_QATU - B2_QEMP),3) DISPO "+CRLF
    cQuery+="		,ISNULL(ROUND((SELECT DIstinct AVG(Produzido) OVER(PARTITION BY Ano) AS Media "+CRLF
    cQuery+="		  FROM ( Select	D4_COD as Produto, "+CRLF
    cQuery+="						Year(D4_DATA) as Ano, "+CRLF
    cQuery+="						Month(D4_DATA) as Mes, "+CRLF
    cQuery+="						Sum(D4_QTDEORI) as Produzido "+CRLF
    cQuery+="				 From " + RetSqlName("SD4") + " SD4 "+CRLF
    cQuery+="				 Where SD4.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="				 AND D4_FILIAL = B2_FILIAL "+CRLF
    cQuery+="				 AND Year(D4_DATA) = Year(Getdate()) "+CRLF
    cQuery+="				 AND Month(D4_DATA) BETWEEN Month(GetDate())-6 AND Month(GetDate()) "+CRLF
    cQuery+="				 AND D4_COD = B2_COD "+CRLF
    cQuery+="				 Group By D4_COD, Year(D4_DATA),Month(D4_DATA) ) xxx),3),0) MEDIA "+CRLF
    cQuery+="From " + RetSqlName("SB2") + " SB2 "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = B2_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="Where SB2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="AND B2_FILIAL = '0803' "+CRLF
    cQuery+="AND B2_LOCAL = B1_LOCPAD "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
    IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return
    endif

    dbselectArea(cAlias)
    (cAlias)->( dbGoTop() )
    While (cAlias)->( !Eof())

            RecLock(cAliasTmp, .T.)
            (cAliasTmp)->OK     := ""
            (cAliasTmp)->CODIGO  := (cAlias)->CODIGO
            (cAliasTmp)->DESCR  := (cAlias)->DESCRICAO
            (cAliasTmp)->ALMOX  := (cAlias)->ALMOX
            (cAliasTmp)->SALDO  := (cAlias)->SALDO
            (cAliasTmp)->EMPEN  := (cAlias)->EMPENHO
            (cAliasTmp)->DISPO  := (cAlias)->DISPO
            (cAliasTmp)->MEDIA  := (cAlias)->MEDIA
            (cAliasTmp)->DEMAN  := IIF((cAlias)->MEDIA>0, ROUND(((cAlias)->MEDIA / 30 ),0) ,0 )
            (cAliasTmp)->COBERT := IIF((cAlias)->DISPO>0, ROUND(((cAlias)->DISPO / 30),0),0)

            (cAliasTmp)->(MsUnlock())
            (cAlias)->( dbSkip() )
    
    EndDo
     (calias)->(DbCloseArea()) 
Return
