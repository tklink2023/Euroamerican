//Bibliotecas
#Include "TOTVS.ch"

Static cTitulo     := "Pendencias"
Static cFiltro     := ""

User Function AfterLogin()
    Local aArea := FWGetArea()
 
    //Se estiver usando o módulo financeiro
    If nModulo == 2
       AftTelaCom()
    EndIf
 
    FWRestArea(aArea)
Return
  
Static Function AftTelaCom()
    Local aArea := FWGetArea()
    Local cQuery  as character 
    Local cAlias        := "PCP_"+getNextAlias() 
    //Local cPessoa := RetCodUsr()
    Local cId   := ParamIXB[1] //Id do usuário
    //Local cNome := ParamIXB[2] //Nome do usuário
    //Local oBrowse
    //Local aSeek       := {}
    Local aIndex      := {}

    Local aTamanho := MsAdvSize()
    Local nJanLarg := aTamanho[5] - 200
    Local nJanAltu := aTamanho[6] - 200
    Local oDlgProdut

    Private aRotina := {}
    Private oBrowse
    Private aCampos := {}
    Private aColunas := {}
    Private cAliasTmp := "PCP_" + RetCodUsr()
    Private cMascara := "@E 99,999,999.999"
    //Private aRotina := {}

    aAdd(aCampos, { "PEDIDO"        , "C", 06    , 0 })
    aAdd(aCampos, { "ITEM"          , "C", 03    , 0 })
    aAdd(aCampos, { "EMISSAO"       , "D", 08    , 0 })
    aAdd(aCampos, { "FORNECE"       , "C", 06    , 0 })
    aAdd(aCampos, { "LOJA"          , "C", 02    , 0 })
    aAdd(aCampos, { "RAZAO"         , "C", 30    , 0 })    
    aAdd(aCampos, { "PRODUTO"       , "C", 15    , 0 })
    aAdd(aCampos, { "QUANT"         , "N", 09    , 3 })
    aAdd(aCampos, { "PREVISTO"      , "D", 08    , 0 })
    aAdd(aCampos, { "ATRASO"        , "N", 03    , 0 })

    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"PEDIDO","ITEM","FORNECE","LOJA","PRODUTO"} )
    oTempTable:Create()  
    
    aColunas := fCriaCols()
    aAdd(aIndex, {"PEDIDO","ITEM","FORNECE","LOJA","PRODUTO"} ) 

    cQuery:="Select	C7_NUM "+CRLF
    cQuery+="		,C7_ITEM "+CRLF
    cQuery+="		,C7_EMISSAO "+CRLF
    cQuery+="		,C7_FORNECE "+CRLF
    cQuery+="		,C7_LOJA "+CRLF
    cQuery+="		,A2_NREDUZ "+CRLF
    cQuery+="		,C7_PRODUTO "+CRLF
    cQuery+="		,C7_QUANT "+CRLF
    cQuery+="		,C7_DATPRF "+CRLF
    cQuery+="		,C7_APROV "+CRLF
    cQuery+="		,C7_CONAPRO "+CRLF
    cQuery+="		,C7_USER "+CRLF
    cQuery+="From  " + RetSqlName("SC7") + "  SC7 "+CRLF
    cQuery+="INNER JOIN  " + RetSqlName("SB1") + "  SB1 ON B1_COD = C7_PRODUTO AND B1_TIPO = 'EM' AND B1_XTPCOMP = 'P' AND SB1.D_E_L_E_T_ =  ' ' "+CRLF
    cQuery+="INNER JOIN  " + RetSqlName("SA2") + "  SA2 ON A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="Where SC7.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="AND C7_FILIAL =  '"+xFilial("SC7")+"' "+CRLF
    cQuery+="AND C7_ENCER <> 'E' "+CRLF
    cQuery+="AND C7_DATPRF <= GETDATE()-30 "+CRLF
    cQuery+="AND C7_USER = '"+cId+"' "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    TCSetField(cAlias, "C7_DATPRF", "D")
    TCSetField(cAlias, "C7_EMISSAO", "D")

    IF (cAlias)->(Eof())
       (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return
    endif

    dbSelectArea(cAlias)
    (cAlias)->( dbgotop())
    DO WHILE !(cAlias)->(Eof())
         dbSelectArea(cAliasTmp)
         (cAliasTmp)->( dbSetOrder(1))
         if (cAliasTmp)->( !dbSeek( (cAlias)->C7_NUM+(cAlias)->C7_FORNECE+(cAlias)->C7_LOJA+(cAlias)->C7_PRODUTO ),.T.)
             IF RecLock(cAliasTmp, .T.)
                (cAliasTmp)->PEDIDO      := (cAlias)->C7_NUM
                (cAliasTmp)->ITEM        := (cAlias)->C7_ITEM
                (cAliasTmp)->EMISSAO     := (cAlias)->C7_EMISSAO
                (cAliasTmp)->FORNECE     := (cAlias)->C7_FORNECE
                (cAliasTmp)->LOJA        := (cAlias)->C7_LOJA
                (cAliasTmp)->RAZAO       := (cAlias)->A2_NREDUZ
                (cAliasTmp)->PRODUTO     := (cAlias)->C7_PRODUTO
                (cAliasTmp)->QUANT       := (cAlias)->C7_QUANT
                (cAliasTmp)->PREVISTO    := (cAlias)->C7_DATPRF
                (cAliasTmp)->(MsUnlock())
             ENDIF
         ENDIF
        (cAlias)->(dbskip())
    ENDDO
    (calias)->(DbCloseArea()) 
     
    oDlgProdut := TDialog():New(0, 0, nJanAltu, nJanLarg, cTitulo, , , , , CLR_BLACK, RGB(250, 250, 250), , , .T.)

    //aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasTmp)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
    oBrowse:DisableReport()
    oBrowse:SetFilterDefault(cFiltro)
    oBrowse:SetOwner(oDlgProdut)
            //Ativa a Browse
    oBrowse:Activate(oDlgProdut)

    oDlgProdut:Activate(, , , .T., {|| .T.}, , {|| } )
    FWRestArea(aArea)
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

    aAdd(aEstrut, {"PEDIDO",    "Pedido",       "C", 06,   0, ""})
    aAdd(aEstrut, {"ITEM",      "Item",         "C", 03,   0, ""})
    aAdd(aEstrut, {"EMISSAO",   "Emissao",      "D", 08,   0, ""})
    aAdd(aEstrut, {"FORNECE",   "Fornecedor",   "C", 06,   0, ""})
    aAdd(aEstrut, {"LOJA",      "Loja",         "C", 02,   0, ""})
    aAdd(aEstrut, {"RAZAO",     "Razao",        "C", 30,   0, ""})
    aAdd(aEstrut, {"PRODUTO",   "Produto",      "C", 15,   0, ""})
    aAdd(aEstrut, {"QUANT",     "Quantidade",   "N", 12,   3, cMascara})
    aAdd(aEstrut, {"PREVISTO",  "Previsao",     "D", 08,   0, ""})
    aAdd(aEstrut, {"ATRASO",     "ATRASO",      "N", 03,   0, ""})
    

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

//Static Function MenuDef()
//    Local aRotina := {}
 
    //Adicionando opcoes do menu
    //ADD OPTION aRotina TITLE "Visualizar Produto" ACTION "VIEWDEF.MATA010" OPERATION 1 ACCESS 0
 
//Return aRotina
