//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

User Function PCPM180()
    Local aArea := FwGetArea()
    PCP080Screen() 
    FwRestArea(aArea)
Return

Static Function PCP080Screen()  
 Local aArea := FwGetArea()
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
    Private oSayTitulo, cSayTitulo := 'Gestao de Risco'
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
    Private cMascara := "@E 99,999,999,999.999"
    Private oMarkBrowse

    // Variaveis da Tela
    Private cGetProd  := Space(15)
    Private cGetDesc  := Space(50)
    Private cGetLocal := Space(02)

    Private nGetSLD   := 0
    Private nGetEmp   := 0
    Private nGetDisp  := 0
    Private nGetDspDia:= 0
    Private nGetMedia := 0
    Private nGetMedDia:=0
    Private nGetLead  := 0

    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { "MES"           , "C", 10    , 0 })
    aAdd(aCampos, { "Dia"           , "C", 02    , 0 })
    aAdd(aCampos, { "QUANTIDADE"    , "N", 18    , 3 })

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"MES","DIA"} )
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
        oGetProd:bValid := {|| fVldProd()}
        oGetProd:cF3 := "SB1"
        oGetProd:bHelp := {|| ShowHelpcpo('Ajuda',{"Digite o código do produto"},0)}

        nLinhaObj += 15
        oSayDesc  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Descrição"}, oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDesc  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , cGetDesc := u, cGetDesc)}, oScroll, nTotEspCol - 9, 10, PesqPict("SB1", "B1_DESC"), /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayPerc  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Almoxarifado"},         oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetPerc  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , cGetLocal := u, cGetLocal)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)   

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
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetMedia := u, nGetMedia)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Media Consumo Dia"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetMedDia := u, nGetMedDia)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)

        nLinhaObj += 15
        oSayDias  := TSay():New(nLinhaObj, 001 + nTotCol01, {|| "Lead Time"},     oScroll, "", oFontSay,  , , , .T., RGB(031, 073, 125), , nTotEspCol, 10, , , , , , .F., , )
        oGetDias  := TGet():New(nLinhaObj, 001 + nTotCol02, {|u| Iif(PCount() > 0 , nGetLead := u, nGetLead)}, oScroll, nTotEspCol - 9, 10, /*cMascara*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)


        nLinhaObj += 25
        nPosLinha := nLinhaObj  += 15
        oBtnProc := TButton():New(nLinhaObj,  001 + nTotCol01, "Processar", oPanDados, {|| PCP180USADO()}, nTotEspCol - 3, 018, , oFontBtn, , .T., , , , , , )
        oBtnProc:SetCSS("TButton { font: bold;     background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #0D9CBF);    color: #FFFFFF;     border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:focus {    padding:0px; outline-width:1px; outline-style:solid; outline-color: #51DAFC; outline-radius:3px; border-color:#369CB5;}TButton:hover {    color: #FFFFFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #3DAFCC, stop: 1 #1188A6);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:pressed {    color: #FFF;     background-color : qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,stop: 0 #1188A6, stop: 1 #3DAFCC);    border-width: 1px;     border-style: solid;     border-radius: 3px;     border-color: #369CB5; }TButton:disabled {    color: #FFFFFF;     background-color: #4CA0B5; }")
       
    Activate MsDialog oDlg Centered
    oTempTable:Delete()

 FwRestArea(aArea)
Return


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
    aAdd(aEstrut, {"MES", "Mes",             "C", 10,   0, ""})
    aAdd(aEstrut, {"DIA", "Dia",             "C", 02,   0, ""})
    aAdd(aEstrut, {"QUANTIDADE", "Quantidade",       "N", 18,   3, cMascara})
    
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
              nGetDisp   := round(SaldoSB2(),3) //SB2->B2_QATU - SB2->B2_QEMP
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

Static Function PCP180MEDIA()
 Local aArea := FwGetArea()
 Local nRetorno := 0
 if ExistBlock("PCP180CMedia")
          aDados:= {cGetProd}
          nRetorno:=ExecBlock("PCP180CMedia",.F.,.F.,aDados)   
 Endif
 
 FwRestArea(aArea)
Return(nRetorno)

Static Function PCP180LEADTIME()
 Local aArea := FwGetArea()
 Local nRetorno := 0
 if ExistBlock("PCP180CMedia")
          aDados:= {cGetProd}
          nRetorno:=ExecBlock("PCP180LEADTIME",.F.,.F.,aDados)   
 Endif
 
 FwRestArea(aArea)
Return(nRetorno)


Static Function PCP180USADO()
 Local aArea        := FwGetArea()
 lOCAL cAliasTmp    := "TMP_" + RetCodUsr()
 Local oBrowse
 Local aHeader := {'Produto','Descricao'}
 local aFields as array
 Local aCols   as array
 local oColumn as object

 if oBrowse != nil
        oBrowse:DeActivate()
 endif

 aFields := {}

 Aadd( aFields, { "PRODUTO","PRODUTO","C",15,0,""} )
 Aadd( aFields, { "DESCRICAO","DESCRICAO","C",40,0,""} )

 cQuery:="Select DISTINCT G1_COD, B1_DESC "+CRLF
 cQuery+="from SG1100 SG1 "+CRLF
 cQuery+="INNER JOIN SB1100 SB1 ON B1_COD = G1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
 cQuery+="WHERE SG1.D_E_L_E_T_ = ' ' "+CRLF
 cQuery+="AND G1_FILIAL =  '"+xFilial("SG1")+"'  "+CRLF
 cQuery+="AND G1_COMP = '"+cGetProd+"' "+CRLF
 DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .T., .T.)

 IF (cAliasTmp)->(Eof())
            (cAliasTmp)->(DbCloseArea())   
            FwRestArea(aArea)
            Return
 endif

 aCols := {}
 dbSelectArea(cAliasTmp)
 (cAliasTmp)->( dbgotop())
  DO WHILE !(cAliasTmp)->(Eof())
        aAdd(aCols, {(cAliasTmp)->G1_COD,;
                     (cAliasTmp)->B1_DESC})
        (cAliasTmp)->(dbskip())
  ENDDO
  (cAliasTmp)->(DbCloseArea()) 

  @ nPosLinha, 001 SCROLLBOX oScroll VERTICAL HORIZONTAL SIZE (oPanDados:nHeight / 2) / 2, oPanDados:nWidth / 2 OF oPanDados

    //Criando o browse da temporária
   oBrowse := FwBrowse():New()
   oBrowse:SetOwner(oScroll)
   oBrowse:SetDataArray()
   oBrowse:SetArray(aCols)
   oBrowse:SetFieldFilter(aFields)
   oBrowse:SetUseFilter()
   oBrowse:SetDescription("Onde é usado")
   oBrowse:DisableSeek()
   oBrowse:DisableReport()
   oBrowse:DisableConfig()
   oBrowse:DisableLocate()

  oColumn := FWBrwColumn():New()
  oColumn:SetData( &(" { || aCols[oBrowse:At(),1]}"))
  oColumn:SetTitle(aHeader[1])
  oColumn:SetSize(2)
  oBrowse:SetColumns({oColumn})

  oColumn := FWBrwColumn():New()
  oColumn:SetData( &(" { || aCols[oBrowse:At(),2]}"))
  oColumn:SetTitle(aHeader[2])
  oColumn:SetSize(40)
  oBrowse:SetColumns({oColumn})

  oBrowse:Activate()

 FwRestArea(aArea)
Return


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
