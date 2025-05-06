//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

/*/{Protheus.doc} PCPM180
description Programação de Materiais
@type function
@version 1.0
@author Paulo Lenzi
@since 30/04/2025
@return variant, return_description
/*/
User Function PCPM180()
    Local aArea := FwGetArea()
    Private cGetProd  := PARAMIXB[1]
    Private cGetDesc  := PARAMIXB[2]
    Private cGetLocal := Space(02)

    Private nGetSLD   := PARAMIXB[3]
    Private nGetEmp   := PARAMIXB[4]
    Private nGetDisp  := PARAMIXB[5]
    Private nGetDspDia:= PARAMIXB[8]
    Private nGetMedia := PARAMIXB[6]
    Private nGetMedDia:= PARAMIXB[7]
    Private nGetLead  := 0
    // call da tela de Material
    PCP080Screen() 

    FwRestArea(aArea)
Return

/*/{Protheus.doc} PCP080Screen
description Tela de Tratamento da Programação de Materiais
@type function
@version 1.0
@author Paulo Lenzi
@since 30/04/2025
@return variant, return_description
/*/
Static Function PCP080Screen()  
    Local aArea     := FwGetArea()
    Local nLargBtn  := 50
    Local nLinhaObj := 0
    Local nLargPanel:= 0

    // Corpo da Tela
    Private oDlg
    Private oFwLayer
    Private oPantitulo
    Private oPanDados
    Private oPanGrid    
    Private oPanTotal

    //Cabeçalho
    Private oSayModulo, cSayModulo := 'PCP'
    Private oSayTitulo, cSayTitulo := 'Programação'
    Private oSaySubTit, cSaySubTit := 'Analise de Materias e Embalagem'

    //Tamanho da janela
    Private aSize := MsAdvSize(.F.)
    Private nJanLarg := aSize[5]
    Private nJanAltu := aSize[6]
    Private nUltLinha := nJanAltu - 30
    Private nPosLinha := 0

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
    Private cMascara := "@E 99,999,999.999"
    Private cMask    := "@E 9,999.999 %"
    Private oMarkBrowse

    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { "OK"            , "C", 02    , 0 })
    aAdd(aCampos, { "CODIGO"        , "C", 15    , 0 })
    aAdd(aCampos, { "DTMOV"         , "D", 08    , 0 })
    aAdd(aCampos, { "ENTRADA"       , "N", 12    , 3 })
    aAdd(aCampos, { "PREVISTO"      , "N", 12    , 3 })    
    aAdd(aCampos, { "SAIDA"         , "N", 12    , 3 })
    aAdd(aCampos, { "SLDPRE"        , "N", 15    , 3 })
    aAdd(aCampos, { "SLDREA"        , "N", 15    , 3 })
    aAdd(aCampos, { "PROJECAO"      , "N", 03    , 0 })
    aAdd(aCampos, { "ESTOQUE"       , "N", 03    , 0 })
    aAdd(aCampos, { "DTDISPO"       , "D", 08    , 0 })
    
    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"CODIGO","DTMOV"} )
    oTempTable:Create()  

    //Busca as colunas do browse
    aColunas := fCriaCols()

    //Cria a janela
    DEFINE MSDIALOG oDlg TITLE "Gerenciamento de Risco"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
  
        //Criando a camada
        oFwLayer := FwLayer():New()
        oFwLayer:init(oDlg,.F.)
  
        //Adicionando 3 linhas, a de título, a do corpo e a inferior
        oFWLayer:addLine("TITULO", 010, .F.)
        oFWLayer:addLine("CORPO",  088, .F.)
        oFWLayer:addLine("RODAPE", 002, .F.)
  
        //Adicionando as colunas das linhas
        oFWLayer:addCollumn("HEADERTEXT",   050, .T., "TITULO")
        oFWLayer:addCollumn("BLANKBTN",     030, .T., "TITULO")
        oFWLayer:addCollumn("BLANKPLAN",    010, .T., "TITULO")
        oFWLayer:addCollumn("BTNSAIR",      010, .T., "TITULO")
 
        oFWLayer:addCollumn("BLANKANTES",  001, .T., "CORPO")
        oFWLayer:addCollumn("COLDADOS",    039, .T., "CORPO")
        oFWLayer:addCollumn("COLGRIDS",    059, .T., "CORPO")
        oFWLayer:addCollumn("BLANKDEPOIS", 001, .T., "CORPO")

  
        //Criando os paineis
        oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TITULO")
        oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TITULO")
        oPanDados  := oFWLayer:GetColPanel("COLDADOS",   "CORPO")
        oPanGrid   := oFWLayer:GetColPanel("COLGRIDS",   "CORPO")
        oPanPlan   := oFWLayer:GetColPanel("BLANKPLAN",  "TITULO")
  
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
        //oGetProd:bValid := {|| fVldProd()}
        oGetProd:cF3 := "SB1"
        oGetProd:bHelp := {|| ShowHelpcpo('Ajuda',{"Digite o código do produto"},0)}

        nLinhaObj += 15
        oSayDesc  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Descrição"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDesc  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , cGetDesc := u, cGetDesc)}, oScroll, nTotEspCol - 9, 10, PesqPict("SB1", "B1_DESC"), /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSaydtini := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Saldo Estoque"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDtIni := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetSLD := u, nGetSLD)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSaydtFim := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Empenho"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDtFim := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetEmp := u, nGetEmp)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Disponivel"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetDisp := u, nGetDisp)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
        
        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Disponivel Dia"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetDspDia := u, nGetDspDia)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)        

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Media Consumo"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetMedia := u, nGetMedia)}, oScroll, nTotEspCol - 9, 10, cMascara, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Media Consumo Dia"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetMedDia := u, nGetMedDia)}, oScroll, nTotEspCol - 9, 10, cMascara, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 25
        nPosLinha := nLinhaObj  += 15
        oBtnProc := TButton():New(nLinhaObj,  001 + nTotCol01, "Processar", oPanDados, {|| fPopula()}, nTotEspCol - 3, 018, , oFontBtn, , .T., , , , , , )
        oBtnProc:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")
       
    Activate MsDialog oDlg Centered
    oTempTable:Delete()

 FwRestArea(aArea)
Return

/*/{Protheus.doc} fCriaCols
description Criação das colunas que será tratado na tela inicial
@type function
@version 1.0
@author Paulo Lenzi
@since 30/04/2025
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
    aAdd(aEstrut, {"CODIGO",    "Codigo",       "C", 15,   0, ""})
    aAdd(aEstrut, {"DTMOV",     "DATA",         "D", 08,   0, ""})
    aAdd(aEstrut, {"ENTRADA",   "NF.Entrada",   "N", 12,   3, cMascara})
    aAdd(aEstrut, {"PREVISTO",  "Ped.Compra",   "N", 12,   3, cMascara})
    aAdd(aEstrut, {"SAIDA",     "Empenhos",     "N", 12,   3, cMascara})
    aAdd(aEstrut, {"SLDPRE",     "Sld.Prev",    "N", 12,   3, cMascara})
    aAdd(aEstrut, {"SLDREA",     "Sld Real",    "N", 12,   3, cMascara})
    aAdd(aEstrut, {"PROJECAO",  "Projecao",     "N", 03,   0, ""})
    aAdd(aEstrut, {"ESTOQUE",   "Estoque",      "N", 03,   0, ""})
    aAdd(aEstrut, {"DTDISPO",   "Data",         "D", 08,   0, ""})
    

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
@since 21/01/2025
@return variant, return_description
/*/
Static Function fVldProd()
    Local lRet := .T.
    Local dDataFim := dDataBase
    Local aSaldos  := {}    
    Local nDiasMes := Day(LastDate(dDataFim))

    IF !Empty(cGetProd)
        dbSelectArea("SB1")
        SB1->( dbSetOrder(1) )
        IF SB1->(dbSeek(xFilial("SB1")+cGetProd) )
           cGetDesc     := SB1->B1_DESC
           cGetLocal    := SB1->B1_LOCPAD

           dbSelectArea("SB2")
           SB2->( dbSetOrder(1) )
           if SB2->( dbSeek( FWxFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.T. ) )
              aSaldos := CalcEst(SB1->B1_COD, SB1->B1_LOCPAD, dDataFim)

              nGetSld    := round(aSaldos[1],3) // SB2->B2_QATU
              nGetEmp    := SB2->B2_QEMP
              nGetDisp   := round((nGetSld - SB2->B2_QEMP) ,3) //SB2->B2_QATU - SB2->B2_QEMP
              nGetMedia  := PCP180MEDIA()
              nGetLead   := PCP180LEADTIME()
              nGetMedDia := round((nGetMedia / nDiasMes),3)
              nGetDspDia := round((nGetDisp / nDiasMes),3)

           endif
        else
            MsgAlert("Produto não encontrado")
            cGetDesc := "Produto não encontrado"
            lRet := .F.   
        ENDIF   
    Else
        lRet := .F.
    endif
Return lRet

/*/{Protheus.doc} PCP180MEDIA
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/01/2025
@return variant, return_description
/*/
Static Function PCP180MEDIA()
 Local aArea := FwGetArea()
 Local nRetorno := 0
 if ExistBlock("PCP180CMedia")
          aDados:= {cGetProd}
          nRetorno:=ExecBlock("PCP180CMedia",.F.,.F.,aDados)   
 Endif
 
 FwRestArea(aArea)
Return(nRetorno)

/*/{Protheus.doc} PCP180LEADTIME
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/01/2025
@return variant, return_description
/*/
Static Function PCP180LEADTIME()
 Local aArea := FwGetArea()
 Local nRetorno := 0
 if ExistBlock("PCP180CMedia")
          aDados:= {cGetProd}
          nRetorno:=ExecBlock("PCP180LEADTIME",.F.,.F.,aDados)   
 Endif
 
 FwRestArea(aArea)
Return(nRetorno)


/*/{Protheus.doc} fPopula
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/01/2025
@return variant, return_description
/*/
Static Function fPopula()
    Local aArea         := FwgetArea()
    Local cQuery  as character 
    Local cAlias        := "PCP_"+getNextAlias() 
    Local cAnoAtual     := cvaltochar(Year(dDataBase))
    Local cMesAtual     := cvaltochar(Month(dDataBase))
    Local aDados        := {}
    Local AB            := 0
    Local dDtRecuperada := cTod(" /  /   ")  //cToD("01/"+cMesAtual+"/"+cAnoAtual)  

    if oMarkBrowse != nil
        oMarkBrowse:DeActivate()
    endif

    cQuery:="SELECT CODIGO,DATA,ENTRADA,PREVISAO,EMPENHO  "+CRLF
    cQuery+="FROM ( "+CRLF
    cQuery+="    SELECT C7_PRODUTO AS CODIGO, CAST(C7_DATPRF AS DATE) AS DATA,0 AS ENTRADA,SUM(C7_QUANT) AS PREVISAO,0 AS EMPENHO "+CRLF
    cQuery+="    FROM " + RetSqlName("SC7") + " SC7 "+CRLF
    cQuery+="    INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C7_PRODUTO AND B1_TIPO IN ('EM', 'MP') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="    WHERE  "+CRLF
    cQuery+="        SC7.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="        AND C7_FILIAL =  '"+xFilial("SC7")+"' "+CRLF
    cQuery+="        AND C7_PRODUTO = '"+cGetProd+"' "+CRLF
    cQuery+="        AND YEAR(C7_DATPRF) = '"+cAnoAtual+"' "+CRLF
    cQuery+="        AND MONTH(C7_DATPRF) >= "+cMesAtual+" "+CRLF
    cQuery+="    GROUP BY C7_PRODUTO, C7_DATPRF "+CRLF
    cQuery+=" UNION ALL "+CRLF
    cQuery+="    SELECT D4_COD AS CODIGO,CAST(D4_DATA AS DATE) AS DATA,0 AS ENTRADA,0 AS PREVISAO,SUM(D4_QTDEORI) AS EMPENHO "+CRLF
    cQuery+="    FROM " + RetSqlName("SD4") + " SD4 "+CRLF
    cQuery+="    INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D4_COD AND B1_TIPO IN ('EM', 'MP') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="    INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND B2_QATU > 0  AND SB2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="    WHERE  "+CRLF
    cQuery+="        SD4.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="        AND D4_FILIAL =  '"+xFilial("SC7")+"' "+CRLF
    cQuery+="        AND D4_COD = '"+cGetProd+"' "+CRLF
    cQuery+="        AND YEAR(D4_DATA) ='"+cAnoAtual+"' "+CRLF
    cQuery+="        AND MONTH(D4_DATA) >= "+cMesAtual+" "+CRLF
    cQuery+="    GROUP BY D4_COD, D4_DATA "+CRLF
    cQuery+="UNION ALL  "+CRLF
    cQuery+="    SELECT D1_COD AS CODIGO, CAST(D1_DTDIGIT AS DATE) AS DATA,SUM(D1_QUANT) ENTRADA, 0  AS PREVISÃO,0 AS EMPENHO   "+CRLF
    cQuery+="    FROM SD1100 SD1  "+CRLF
    cQuery+="    INNER JOIN SB1100 SB1 ON B1_COD = D1_COD AND B1_TIPO IN ('EM', 'MP') AND SB1.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="    WHERE    "+CRLF
    cQuery+="        SD1.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="        AND D1_FILIAL =  '"+xFilial("SD1")+"' "+CRLF
    cQuery+="        AND D1_COD = '"+cGetProd+"' "+CRLF     
    cQuery+="        AND YEAR(D1_DTDIGIT) = '"+cAnoAtual+"' "+CRLF
    cQuery+="        AND MONTH(D1_DTDIGIT) >=  "+cMesAtual+" "+CRLF
    cQuery+="    GROUP BY D1_COD, D1_DTDIGIT 
    cQuery+=") AS ARQ "+CRLF
    cQuery+="ORDER BY CODIGO, DATA "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            MsgAlert("Não tem movimentação para esse produto") 
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
        aAdd(aDados, {(cAlias)->CODIGO,;     // 1 Codigo do Produto
                      (cAlias)->DATA,;       // 2 Ano
                      (cAlias)->ENTRADA,;    // 3 Entrada (SD1)
                      (cAlias)->PREVISAO,;   // 4 Previsao (SC7)
                      (cAlias)->EMPENHO,;    // 5 Empenhos (SD4)
                      0,;                    // 6 Saldo Previsto
                      0})                    // 7 Saldo Real
        (cAlias)->(dbskip())
    ENDDO

    //-------------------------------------------
    // Ajustando as Datas de Entrada no Movimento de Saída
    //----------------------------------------- 

    if len(aDados) > 0
       FOR AB:= 1 TO LEN(aDados)
            if AB = 1
               aDados[AB][6] := aDados[AB][4]  - IIF(aDados[AB][5]>0,aDados[AB][5],0)    // Calculo do Saldo Previsto
               aDados[AB][7] := aDados[AB][3]  - IIF(aDados[AB][5]>0,aDados[AB][5],0)    // Calculo do Saldo Real
            else
               aDados[AB][6] := (aDados[AB-1][6] + aDados[AB][4]) - aDados[AB][5]  // Calculo do Saldo Previsto
               aDados[AB][7] := (aDados[AB-1][7] + aDados[AB][3]) - aDados[AB][5]  // Calculo do Saldo Real
            endif           
       NEXT  
    endif

   //-------------------------------------------
    // Gravando os dados na Temporária
    //----------------------------------------- 

    if len(aDados) > 0
       FOR AB:= 1 TO LEN(aDados)
           dbSelectArea(cAliasTmp)
           (cAliasTmp)->( dbSetOrder(1))
           if (cAliasTmp)->( !dbSeek( aDados[AB][1]+Dtos(aDados[AB][2]) ),.T.)
                dDtRecuperada :=  aDados[AB][2] //cTod(strZero(aDados[AB][4],2)+"/"+strZero(aDados[AB][3],2)+"/"+cvaltochar(aDados[AB][2]))
                IF RecLock(cAliasTmp, .T.)
                    (cAliasTmp)->OK         := ""
                    (cAliasTmp)->CODIGO     := aDados[AB][1]
                    (cAliasTmp)->DTMOV      := aDados[AB][2]
                    (cAliasTmp)->ENTRADA    := aDados[AB][3]
                    (cAliasTmp)->PREVISTO   := aDados[AB][4]
                    (cAliasTmp)->SAIDA      := aDados[AB][5]
                    (cAliasTmp)->SLDPRE     := aDados[AB][6]
                    (cAliasTmp)->SLDREA     := aDados[AB][7]
                    (cAliasTmp)->PROJECAO   :=  IIF(aDados[AB][6]<=0,0, round(aDados[AB][6] / nGetMedDia,0))
                    (cAliasTmp)->ESTOQUE    :=  IIF(aDados[AB][6]<=0,0, (cAliasTmp)->PROJECAO - nGetLead )
                    (cAliasTmp)->DTDISPO    :=  iif((cAliasTmp)->ESTOQUE > 0, dDtRecuperada + (cAliasTmp)->ESTOQUE, dDtRecuperada)
                    
                    (cAliasTmp)->(MsUnlock())
                Endif         
            else
                IF RecLock(cAliasTmp, .F.)
                    (cAliasTmp)->ENTRADA    := aDados[AB][3]
                    (cAliasTmp)->PREVISTO   := aDados[AB][4]
                    (cAliasTmp)->SAIDA      := aDados[AB][5]
                    (cAliasTmp)->SLDPRE      := aDados[AB][6]
                    (cAliasTmp)->SLDREA      := aDados[AB][7]
                    (cAliasTmp)->PROJECAO   := round(aDados[AB][6] / nGetMedDia,0)
                    (cAliasTmp)->ESTOQUE    := (cAliasTmp)->PROJECAO - nGetLead
                    (cAliasTmp)->DTDISPO    := iif((cAliasTmp)->ESTOQUE > 0, dDtRecuperada + (cAliasTmp)->ESTOQUE, dDtRecuperada)                   
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

        oMarkBrowse:AddButton("Ordens Producao"   ,{||PCP180ORDENS((cAliasTmp)->CODIGO,(cAliasTmp)->DTMOV,(cAliasTmp)->ENTRADA,(cAliasTmp)->SAIDA), oMarkBrowse:Refresh(), oMarkBrowse:Refresh()},,2,,.F.)
        oMarkBrowse:AddButton("Pedido de Compras" ,{||PCP180PED((cAliasTmp)->CODIGO,(cAliasTmp)->DTMOV,(cAliasTmp)->PREVISTO,(cAliasTmp)->SAIDA), oMarkBrowse:Refresh(), oMarkBrowse:Refresh()},,2,,.F.)
        oMarkBrowse:AddButton("Nota de Entrada"   ,{||PCP180NFE((cAliasTmp)->CODIGO,(cAliasTmp)->DTMOV,(cAliasTmp)->PREVISTO,(cAliasTmp)->SAIDA), oMarkBrowse:Refresh(),   oMarkBrowse:Refresh()},,2,,.F.)        
        oMarkBrowse:AddButton("Exporta Excell"    ,{||PCP180PLA((cAliasTmp)->CODIGO,(cAliasTmp)->DTMOV,(cAliasTmp)->ENTRADA,(cAliasTmp)->SAIDA), oMarkBrowse:Refresh(), oMarkBrowse:Refresh()},,2,,.F.)
        oMarkBrowse:Activate()

  (calias)->(DbCloseArea()) 
  FwRestArea(aArea)
Return


/*/{Protheus.doc} PCP180USADO
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/01/2025
@return variant, return_description
/*/
Static Function PCP180ORDENS(cProduto,dDataMov,QTDENTRADA,QTDSAIDA)
 Local aArea        := FwGetArea()
 lOCAL cAliasTmp    := "TMP_" + RetCodUsr()
 local aFields      as array
 Local aCols        as array
 Local dtProd       := dtoc(dDataMov)
 Local cAnoSel      := cvaltochar(Year(dDataMov))
 Local cMesSel      := cvaltochar(Month(dDataMov))
 Local cDiaSel      := cvaltochar(Day(dDataMov))

 IF QTDSAIDA <= 0
    MsgAlert("Não ha quantidade de saída para demostrar")
    FwRestArea(aArea)
    Return   
 endif

 if oMarkBrowse != nil
        oMarkBrowse:DeActivate()
 endif

 aFields := {}

 Aadd( aFields, { "OP","ORDEM","C",11,0,""} )
 Aadd( aFields, { "LOTE","LOTE","C",06,0,""} )
 Aadd( aFields, { "PRODUTO","PRODUTO","C",15,0,""} )
 Aadd( aFields, { "QUANTIDADE","QUANTIDADE","N",15,3,""} )
 Aadd( aFields, { "PREVISTO","PREVISTO","C",08,0,""} )

 cQuery := "SELECT	D4_OP,SUBSTRING(D4_OP,1,6) LOTE,D4_PRODUTO,D4_QTDEORI,C2_DATPRF  "+CRLF          
 cQuery += "FROM " + RetSqlName("SD4") + " SD4             "+CRLF
 cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D4_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' '  "+CRLF
 cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND  B2_LOCAL = D4_LOCAL AND B2_QATU > 0 AND  SB2.D_E_L_E_T_ = ' ' "+CRLF
 cQuery += "INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = D4_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP AND C2_PRODUTO = D4_PRODUTO AND SC2.D_E_L_E_T_ = ' ' "+CRLF
 cQuery += "Where SD4.D_E_L_E_T_ = ' '  "+CRLF                   
 cQuery += "AND D4_FILIAL =  '"+xFilial("SD4")+"'      "+CRLF     
 cQuery += "AND YEAR(D4_DATA) = '"+cValtoChar(cAnoSel)+"' "+CRLF         
 cQuery += "AND MONTH(D4_DATA)= "+cValtoChar(cMesSel)+"  "+CRLF
 cQuery += "and DAY(D4_DATA) = "+cValtoChar(cDiaSel)+"  "+CRLF
 cQuery += "AND D4_COD = '"+cProduto+"' "+CRLF

 DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)

 TCSetField(cAliasTmp, "C2_DATPRF", "D")

 IF (cAliasTmp)->(Eof())
             MsgAlert("Não tem movimentação nesse dia") 
            (cAliasTmp)->(DbCloseArea())   
            FwRestArea(aArea)
            Return
 endif

 aCols := {}
 dbSelectArea(cAliasTmp)
 (cAliasTmp)->( dbgotop())
  DO WHILE !(cAliasTmp)->(Eof())
        aAdd(aCols,  {(cAliasTmp)->D4_OP,(cAliasTmp)->LOTE, (cAliasTmp)->D4_PRODUTO, (cAliasTmp)->D4_QTDEORI,Dtoc((cAliasTmp)->C2_DATPRF)})
        (cAliasTmp)->(dbskip())
  ENDDO
  (cAliasTmp)->(DbCloseArea()) 



  @ nPosLinha, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE (oPanDados:nHeight / 2) / 2, oPanDados:nWidth / 2 OF oPanDados

    //Criando o browse da temporária
   oMarkBrowse := FwBrowse():New()
   oMarkBrowse:SetOwner(oScroll)
   oMarkBrowse:SetDataArray()
   oMarkBrowse:SetArray(aCols)
   oMarkBrowse:SetFieldFilter(aFields)
   oMarkBrowse:SetUseFilter()
   oMarkBrowse:SetDescription("Lotes Producao do Dia : " + dtProd)
   oMarkBrowse:DisableSeek()
   oMarkBrowse:DisableReport()
   oMarkBrowse:DisableConfig()
   oMarkBrowse:DisableLocate()
   oMarkBrowse:SetEditCell(.T., {|| .T.}) 

    oMarkBrowse:addColumn({"OP", {||aCols[oMarkBrowse:At(),1]}, GetSx3Cache("D4_OP","X3_TIPO"), pesqPict("SB8","D4_OP") , 1, tamSx3("D4_OP")[1] ,, .T. ,, .F.,, "XD4_OP",, .F., .T.,, "XD4_OP"})

   oMarkBrowse:addColumn({"Lote", {||aCols[oMarkBrowse:At(),2]}, GetSx3Cache("B8_LOTECTL","X3_TIPO"), pesqPict("SB8","B8_LOTECTL") , 1, tamSx3("B8_LOTECTL")[1] ,, .T. ,, .F.,, "XB8_LOTECTL",, .F., .T.,, "XB8_LOTECTL"})

   oMarkBrowse:addColumn({"Produto", {||aCols[oMarkBrowse:At(),3]}, GetSx3Cache("B1_COD","X3_TIPO"), pesqPict("SB1","B1_COD") , 1, tamSx3("B1_COD")[1] ,, .T. ,, .F.,, "XB1_COD",, .F., .T.,, "XB1_COD"})

   oMarkBrowse:addColumn({"Quantidade", {|| aCols[oMarkBrowse:At(),4]}, GetSx3Cache("B2_COD","X3_TIPO"), pesqPict("SB2","B2_QATU") , 1, tamSx3("B2_QATU")[1] ,, .T. ,, .F.,, "XB2_QATU",, .F., .T.,, "XB2_QATU"})

   oMarkBrowse:addColumn({"Data Prevista", {|| aCols[oMarkBrowse:At(),5]}, GetSx3Cache("C2_DATPRF","X3_TIPO"), pesqPict("SC2","C2_DATPRF") , 1, tamSx3("C2_DATPRF")[1] ,, .T. ,, .F.,{|| PCP180SC2(aCols[oMarkBrowse:At(),1],aCols[oMarkBrowse:At(),5])}, "XC2_DATPRF",, .F., .T.,, "XC2_DATPRF"})
 
   oMarkBrowse:Activate()

 FwRestArea(aArea)
Return


/*/{Protheus.doc} PCP180PED
description
@type function
@version 1.0
@author Paulo Lenzi
@since 29/04/2025
@param cProduto, character, param_description
@param dDataMov, date, param_description
@param QTDENTRADA, variant, param_description
@param QTDSAIDA, variant, param_description
@return variant, return_description
/*/
Static Function PCP180PED(cProduto,dDataMov,QTDENTRADA,QTDSAIDA)
 Local aArea        := FwGetArea()
 lOCAL cAliasTmp    := "TMP_" + RetCodUsr()
 local aFields as array
 Local aCols   as array
 Local dtProd := dtoc(dDataMov)
 Local cAnoSel     := cvaltochar(Year(dDataMov))
 Local cMesSel     := cvaltochar(Month(dDataMov))
 Local cDiaSel     := cvaltochar(Day(dDataMov))

 IF QTDENTRADA <= 0
    MsgAlert("Não ha quantidade de Entrada para demostrar")
    FwRestArea(aArea)
    Return   
 endif

 if oMarkBrowse != nil
        oMarkBrowse:DeActivate()
 endif

 aFields := {}

 Aadd( aFields, { "PEDIDO","PEDIDO","C",06,0,""} )
 Aadd( aFields, { "EMISSAO","EMISSAO","C",08,0,""} )
 Aadd( aFields, { "FORNECE","FORNECEDOR","C",15,0,""} )
 Aadd( aFields, { "QUANTIDADE","QUANTIDADE","N",15,3,""} )
 Aadd( aFields, { "PREVISTO","PREVISTO","C",08,0,""} )
 Aadd( aFields, { "APROVADO","APROVADO","C",03,0,""} )
 Aadd( aFields, { "ENCERRADO","ENCERRADO","C",03,0,""} )

    cQuery := " Select	 C7_NUM PEDIDO  "+CRLF 
    cQuery += "		,C7_EMISSAO EMISSAO  "+CRLF 
    cQuery += "		,A2_NREDUZ FORNECEDOR  "+CRLF 
    cQuery += "		,C7_QUANT QUANTIDADE  "+CRLF 
    cQuery += "		,C7_DATPRF ENTREGA  "+CRLF 
    cQuery += "		,C7_CONAPRO APROVADO  "+CRLF 
    cQuery += "		,C7_ENCER ENCERRADO  "+CRLF 
    cQuery += "     ,SC7.R_E_C_N_O_ RECNO1  "+CRLF 
    cQuery += "FROM " + RetSqlName("SC7") + " SC7  "+CRLF 
    cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' '  "+CRLF 
    cQuery += "Where SC7.D_E_L_E_T_ = ' '  "+CRLF 
    cQuery += "AND C7_FILIAL =  '"+xFilial("SC7")+"'      "+CRLF 
    cQuery += "AND C7_PRODUTO =  '"+cProduto+"' "+CRLF
    cQuery += "AND YEAR(C7_DATPRF) = '"+cValtoChar(cAnoSel)+"' "+CRLF  
    cQuery += "AND MONTH(C7_DATPRF) = "+cValtoChar(cMesSel)+"  "+CRLF
    cQuery += "AND DAY(C7_DATPRF) = "+cValtoChar(cDiaSel)+"  "+CRLF

 DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)

 TCSetField(cAliasTmp, "C7_EMISSAO", "D")
 TCSetField(cAliasTmp, "C7_DATPRF", "D")

 IF (cAliasTmp)->(Eof())
             MsgAlert("Não tem movimentação nesse dia") 
            (cAliasTmp)->(DbCloseArea())   
            FwRestArea(aArea)
            Return
 endif

 aCols := {}
 dbSelectArea(cAliasTmp)
 (cAliasTmp)->( dbgotop())
  DO WHILE !(cAliasTmp)->(Eof())
        aAdd(aCols,  {  (cAliasTmp)->PEDIDO,;
                        dtoc(stod((cAliasTmp)->EMISSAO)),;
                        (cAliasTmp)->FORNECEDOR,;
                        (cAliasTmp)->QUANTIDADE,;
                        dtoc(stod((cAliasTmp)->entrega)),;
                        (cAliasTmp)->APROVADO,;
                        (cAliasTmp)->ENCERRADO,;
                        (cAliasTmp)->RECNO1})
        (cAliasTmp)->(dbskip())
  ENDDO
  (cAliasTmp)->(DbCloseArea()) 

  @ nPosLinha, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE (oPanDados:nHeight / 2) / 2, oPanDados:nWidth / 2 OF oPanDados

    //Criando o browse da temporária
   oMarkBrowse := FwBrowse():New()
   oMarkBrowse:SetOwner(oScroll)
   oMarkBrowse:SetDataArray()
   oMarkBrowse:SetArray(aCols)
   oMarkBrowse:SetFieldFilter(aFields)
   oMarkBrowse:SetUseFilter()
   oMarkBrowse:SetDescription("Pedido de Compras do Dia : " + dtProd)
   oMarkBrowse:DisableSeek()
   oMarkBrowse:DisableReport()
   oMarkBrowse:DisableConfig()
   oMarkBrowse:DisableLocate()
   oMarkBrowse:SetEditCell(.T., {|| .F.}) 

   oMarkBrowse:addColumn({"Pedido", {||aCols[oMarkBrowse:At(),1]}, GetSx3Cache("C7_NUM","X3_TIPO"), pesqPict("SC7","C7_NUM") , 1, tamSx3("C7_NUM")[1] ,, .T. ,, .F.,, "XC7_NUM",, .F., .T.,, "XC7_NUM"})

   oMarkBrowse:addColumn({"Emissao", {||aCols[oMarkBrowse:At(),2]}, GetSx3Cache("C7_EMISSAO","X3_TIPO"), pesqPict("SC7","C7_EMISSAO") , 1, tamSx3("C7_EMISSAO")[1] ,, .T. ,, .F.,, "XC7_EMISSAO",, .F., .T.,, "XC7_EMISSAO"})

   oMarkBrowse:addColumn({"Fornecedor", {||aCols[oMarkBrowse:At(),3]}, GetSx3Cache("A2_NREDUZ","X3_TIPO"), pesqPict("SA2","A2_NREDUZ") , 1, tamSx3("A2_NREDUZ")[1] ,, .T. ,, .F.,, "XA2_NREDUZ",, .F., .T.,, "XBA2_NREDUZ"})

   oMarkBrowse:addColumn({"Quantidade", {|| aCols[oMarkBrowse:At(),4]}, GetSx3Cache("B2_COD","X3_TIPO"), pesqPict("SB2","B2_QATU") , 1, tamSx3("B2_QATU")[1] ,, .T. ,, .F.,, "XB2_QATU",, .F., .T.,, "XB2_QATU"})

   oMarkBrowse:addColumn({"Data Prevista", {|| aCols[oMarkBrowse:At(),5]}, GetSx3Cache("C2_DATPRF","X3_TIPO"), pesqPict("SC2","C2_DATPRF") , 1, tamSx3("C2_DATPRF")[1] ,, .T. ,, .F.,{|| AlteraPC(aCols[oMarkBrowse:At(),8],2)}, "XC2_DATPRF",, .F., .T.,, "XC2_DATPRF"})

   oMarkBrowse:Activate()

 FwRestArea(aArea)
Return


Static Function PCP180NFE(cProduto,dDataMov,QTDENTRADA,QTDSAIDA)
    Local aArea        := FwGetArea()
    lOCAL cAliasTmp    := "TMP_" + RetCodUsr()
    local aFields as array
    Local aCols   as array
    Local dtProd := dtoc(dDataMov)
    Local cAnoSel     := cvaltochar(Year(dDataMov))
    Local cMesSel     := cvaltochar(Month(dDataMov))
    Local cDiaSel     := cvaltochar(Day(dDataMov))

    if oMarkBrowse != nil
            oMarkBrowse:DeActivate()
    endif

    aFields := {}

    Aadd( aFields, { "NOTA"        ,"NOTA"         ,"C",09,0,""} )
    Aadd( aFields, { "SERIE"       ,"SERIE"        ,"C",03,0,""} )
    Aadd( aFields, { "EMISSAO"     ,"EMISSAO"      ,"D",08,0,""} )
    Aadd( aFields, { "ENTRADA"     ,"ENTRADA"      ,"D",08,0,""} )
    Aadd( aFields, { "FORNECE"     ,"FORNECEDOR"   ,"C",15,0,""} )
    Aadd( aFields, { "QUANTIDADE"  ,"QUANTIDADE"   ,"N",15,3,""} )'
 
    cQuery := "Select D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,A2_NREDUZ,D1_EMISSAO,D1_DTDIGIT,SUM(D1_QUANT) QTDE"+CRLF 
    cQuery += "from  " + RetSqlName("SD1") + " SD1 "+CRLF 
    cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF 
    cQuery += "Where SD1.D_E_L_E_T_ = ' ' "+CRLF 
    cQuery += "AND D1_FILIAL = '"+xFilial("SD1")+"'  "+CRLF 
    cQuery += "AND D1_COD = '"+cProduto+"' "+CRLF
    cQuery += "AND YEAR(D1_DTDIGIT) = '"+cValtoChar(cAnoSel)+"' "+CRLF  
    cQuery += "AND MONTH(D1_DTDIGIT) = "+cValtoChar(cMesSel)+"  "+CRLF
    cQuery += "AND DAY(D1_DTDIGIT) = "+cValtoChar(cDiaSel)+"  "+CRLF
    cQuery += "GROUP BY  D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,A2_NREDUZ,D1_EMISSAO,D1_DTDIGIT "+CRLF 

     DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)

    TCSetField(cAliasTmp, "D1_EMISSAO", "D")
    TCSetField(cAliasTmp, "D1_DTDIGIT", "D")

    IF (cAliasTmp)->(Eof())
                MsgAlert("Não tem movimentação nesse dia") 
                (cAliasTmp)->(DbCloseArea())   
                FwRestArea(aArea)
                Return
    endif

    aCols := {}
    
    dbSelectArea(cAliasTmp)
    (cAliasTmp)->( dbgotop())
    DO WHILE !(cAliasTmp)->(Eof())
            aAdd(aCols,  {  (cAliasTmp)->D1_DOC,;
                            (cAliasTmp)->D1_SERIE,;
                            dtoc((cAliasTmp)->D1_EMISSAO),;
                            dtoc((cAliasTmp)->D1_DTDIGIT),;
                            (cAliasTmp)->A2_NREDUZ,;
                            (cAliasTmp)->QTDE})
            (cAliasTmp)->(dbskip())
    ENDDO
    (cAliasTmp)->(DbCloseArea()) 

  @ nPosLinha, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE (oPanDados:nHeight / 2) / 2, oPanDados:nWidth / 2 OF oPanDados

    //Criando o browse da temporária
   oMarkBrowse := FwBrowse():New()
   oMarkBrowse:SetOwner(oScroll)
   oMarkBrowse:SetDataArray()
   oMarkBrowse:SetArray(aCols)
   oMarkBrowse:SetFieldFilter(aFields)
   oMarkBrowse:SetUseFilter()
   oMarkBrowse:SetDescription("Nota de Entrada no dia : " + dtProd)
   oMarkBrowse:DisableSeek()
   oMarkBrowse:DisableReport()
   oMarkBrowse:DisableConfig()
   oMarkBrowse:DisableLocate()
   oMarkBrowse:SetEditCell(.T., {|| .F.}) 

   oMarkBrowse:addColumn({"Nota", {||aCols[oMarkBrowse:At(),1]}, GetSx3Cache("D1_DOC","X3_TIPO"), pesqPict("SD1","D1_DOC") , 1, tamSx3("D1_DOC")[1] ,, .T. ,, .F.,, "XD1_DOC",, .F., .T.,, "XD1_DOC"})

   oMarkBrowse:addColumn({"Serie", {||aCols[oMarkBrowse:At(),2]}, GetSx3Cache("D1_SERIE","X3_TIPO"), pesqPict("SD1","D1_SERIE") , 1, tamSx3("D1_SERIE")[1] ,, .T. ,, .F.,, "XD1_SERIE",, .F., .T.,, "XD1_SERIE"})

   oMarkBrowse:addColumn({"Emissao", {||aCols[oMarkBrowse:At(),3]}, GetSx3Cache("C7_EMISSAO","X3_TIPO"), pesqPict("SC7","C7_EMISSAO") , 1, tamSx3("C7_EMISSAO")[1] ,, .T. ,, .F.,, "XC7_EMISSAO",, .F., .T.,, "XC7_EMISSAO"})

   oMarkBrowse:addColumn({"Entrada", {||aCols[oMarkBrowse:At(),4]}, GetSx3Cache("C7_EMISSAO","X3_TIPO"), pesqPict("SC7","C7_EMISSAO") , 1, tamSx3("C7_EMISSAO")[1] ,, .T. ,, .F.,, "XC7_EMISSAO",, .F., .T.,, "XC7_EMISSAO"})

   oMarkBrowse:addColumn({"Fornecedor", {||aCols[oMarkBrowse:At(),5]}, GetSx3Cache("A2_NREDUZ","X3_TIPO"), pesqPict("SA2","A2_NREDUZ") , 1, tamSx3("A2_NREDUZ")[1] ,, .T. ,, .F.,, "XA2_NREDUZ",, .F., .T.,, "XBA2_NREDUZ"})

   oMarkBrowse:addColumn({"Quantidade", {|| aCols[oMarkBrowse:At(),6]}, GetSx3Cache("B2_COD","X3_TIPO"), pesqPict("SB2","B2_QATU") , 1, tamSx3("B2_QATU")[1] ,, .T. ,, .F.,, "XB2_QATU",, .F., .T.,, "XB2_QATU"})

   oMarkBrowse:Activate()

 FwRestArea(aArea)
Return

/*/{Protheus.doc} PCP180SC2
description
@type function
@version 1.0
@author Paulo Lenzi
@since 30/04/2025
@param cNumOP, character, param_description
@param dDataPrev, date, param_description
@return variant, return_description
/*/
Static Function PCP180SC2(cNumOP,dDataPrev)
    Local aArea         := FWGetArea()
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 281
    Local nJanLargur    := 318 
    Local cJanTitulo    := 'Exemplo TGet'
    Local lDimPixels    := .T. 
    Local lCentraliz    := .T. 
    Local nObjLinha     := 0
    Local nObjColun     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0
    Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt 
    Private bBlocoIni   := {|| /*fSuaFuncao()*/ } //Aqui voce pode acionar funcoes customizadas que irao ser acionadas ao abrir a dialog 
    // 
    //objeto2 
    Private oSayObj2 
    Private cSayObj2    := 'Ordem :'

    Private oGetObj3 
    Private xGetObj3    := cNumOP //Se o get for data para inicilizar use dToS(''), se for numerico inicie com 0  
    //objeto0 
    Private oSayObj0 
    Private cSayObj0    := 'Prevista para:' 
    //objeto1 
    Private oGetObj1 
    Private xGetObj1    := dDataPrev // sToD("") //Se o get for data para inicilizar use dToS(''), se for numerico inicie com 0  
    //objeto14 
    Private oBtnObj14 
    Private cBtnObj14    := 'Confirma' 
    Private bBtnObj14    := {|| CorrigeOP(cNumOP,xGetObj1)}  

    if oDialogPvt != nil
            oDialogPvt:DeActivate()
    endif

    //Cria a dialog
    oDialogPvt := TDialog():New(0, 0, nJanAltura, nJanLargur, cJanTitulo, , , , , , nCorFundo, , , lDimPixels)

        //objeto2 - usando a classe TSay
        nObjLinha := 4
        nObjColun := 4
        nObjLargu := 40
        nObjAltur := 6
        oSayObj2  := TSay():New(nObjLinha, nObjColun, {|| cSayObj2}, oDialogPvt, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //objeto3 - usando a classe TGet
        nObjLinha := 3
        nObjColun := 49
        nObjLargu := 100
        nObjAltur := 10

        oGetObj3  := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj3 := u, xGetObj3)}, oDialogPvt, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        //oGetObj3:cPlaceHold := 'Digite aqui um texto...'   //Texto que sera exibido no campo antes de ter conteudo
        //oGetObj3:cF3        := 'Codigo da consulta padrao' //Codigo da consulta padrao / F3 que sera habilitada
        //oGetObj3:bValid     := {|| fFuncaoVld()}           //Funcao para validar o que foi digitado
        oGetObj3:lReadOnly  := .F.                         //Para permitir o usuario clicar mas nao editar o campo
        //oGetObj3:lActive    := .F.                         //Para deixar o campo inativo e o usuario nao conseguir nem clicar
        //oGetObj3:Picture      := '@!'                        //Mascara / Picture do campo

        //objeto0 - usando a classe TSay
        nObjLinha := 19
        nObjColun := 4
        nObjLargu := 45
        nObjAltur := 6
        oSayObj0  := TSay():New(nObjLinha, nObjColun, {|| cSayObj0}, oDialogPvt, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)
 
        //objeto1 - usando a classe TGet
        nObjLinha := 18
        nObjColun := 49
        nObjLargu := 100
        nObjAltur := 10
        oGetObj1  := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj1 := u, xGetObj1)}, oDialogPvt, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels)
        //oGetObj1:cPlaceHold := 'Digite aqui um texto...'   //Texto que sera exibido no campo antes de ter conteudo
        //oGetObj1:cF3        := 'Codigo da consulta padrao' //Codigo da consulta padrao / F3 que sera habilitada
        //oGetObj1:bValid     := {|| fFuncaoVld()}           //Funcao para validar o que foi digitado
        //oGetObj1:lReadOnly  := .T.                         //Para permitir o usuario clicar mas nao editar o campo
        //oGetObj1:lActive    := .F.                         //Para deixar o campo inativo e o usuario nao conseguir nem clicar
        //oGetObj1:Picture      := '@!'                        //Mascara / Picture do campo
 
        //objeto14 - usando a classe TButton
        nObjLinha := 116
        nObjColun := 2
        nObjLargu := (nJanLargur/2) - 4
        nObjAltur := 15
        oBtnObj14  := TButton():New(nObjLinha, nObjColun, cBtnObj14, oDialogPvt, bBtnObj14, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)
 
     
    //Ativa e exibe a janela
    oDialogPvt:Activate(, , , lCentraliz, , , bBlocoIni)
 
    FWRestArea(aArea)
Return

Static Function AlteraPC(nRecno,nOpc)
    Local aArea		:= GetArea()
    Local aAreaSC7	:= SC7->(GetArea())
    dbSelectArea("SC7")
    SC7->(dbGoto(nRecno))
    Mata120(1,/*aCabec*/,/*aItens*/,nOpc,.T.) 
	RestArea(aAreaSC7) 
	RestArea(aArea) 
Return .T.

/*/{Protheus.doc} CorrigeOP
description
@type function
@version 1.0
@author Paulo Lenzi
@since 30/04/2025
@param cNumOP, character, param_description
@param dDataPrev, date, param_description
@return variant, return_description
/*/
Static Function CorrigeOP(cNumOP,dDataPrev)
  Local aArea		:= GetArea()
  Local cQuery      := " "

  cQuery := "UPDATE  "+RetSqlName("SC2")+" SET C2_DATPRF = '"+Dtos(cTod(dDataPrev))+"'   "+CRLF 
  cQuery += "from  "+RetSqlName("SC2")+" SC2   "+CRLF 
  cQuery += "WHERE SC2.D_E_L_E_T_ = ' '   "+CRLF 
  cQuery += "AND C2_FILIAL = '"+xFilial("SC2")+"'   "+CRLF 
  cQuery += "AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+cNumOP+"'   "+CRLF 

   If TCSqlExec(cQuery) < 0
        FWAlertInfo("Falha: " + TCSQLError(), "Nao gravou a atualização")
        oMarkBrowse:Refresh(.T.)	   
        RestArea(aArea) 
        Return         
   ENDIF

  cQuery := "UPDATE  "+RetSqlName("SD4")+" SET D4_DATA = '"+Dtos(cTod(dDataPrev))+"'   "+CRLF 
  cQuery += "from  "+RetSqlName("SD4")+" SD4   "+CRLF 
  cQuery += "WHERE SD4.D_E_L_E_T_ = ' '   "+CRLF 
  cQuery += "AND D4_FILIAL = '"+xFilial("SD4")+"'   "+CRLF 
  cQuery += "AND D4_OP = '"+cNumOP+"'   "+CRLF 

   If TCSqlExec(cQuery) < 0
        FWAlertInfo("Falha: " + TCSQLError(), "Nao gravou a atualização")
        oMarkBrowse:Refresh(.T.)	   
        RestArea(aArea) 
        Return         
   Else
         MsgAlert("Atualizado com sucesso")
   EndIf
 
  RestArea(aArea) 
Return
