#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function PCPM080()
    Local aArea := FwgetArea()
    Local aCampos       := {}
    Local oTmpTable     := Nil
    Local aColunas      := {}
    Local aOutrasAc     := {}
    Local cFontPad      := 'Tahoma'
    Local oFontGrid     := TFont():New(cFontPad,,-14)

    Private cAliasTmp := GetNextAlias()
    Private oMkBrow
    Private oDlgMark
    Private aMenuBt   := MenuDef()
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := aTamanho[5]
    Private nJanAltu := aTamanho[6] 
    Private cMascara := "@E 99,999,999,999.99"

    //Opções no Outras Ações
    aAdd(aOutrasAc, {'BMP', {|| fMarkTod()}, '* (Des) Marcar todos registros'})
      
    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'TMP_OK'    , 'C', 2,                    0}) //Flag para marcação
    aAdd(aCampos, { 'TMP_COD'   , 'C', TamSX3('B1_COD')[1],  0})
    aAdd(aCampos, { 'TMP_DESC'  , 'C', TamSX3('B1_DESC')[1], 0})
    aAdd(aCampos, { 'TMP_TIPO'  , 'C', TamSX3('B1_TIPO')[1], 0})
    aAdd(aCampos, { 'TMP_BASE'  , 'C', TamSX3('B1_XTPBASE')[1], 0})
    aAdd(aCampos, { 'TMP_SALDO' , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})
    aAdd(aCampos, { 'TMP_QEMP'  , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})
    aAdd(aCampos, { 'TMP_QDISP' , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})
    aAdd(aCampos, { 'TMP_QCONS' , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})    
    aAdd(aCampos, { 'TMP_QCOND' , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})    
    aAdd(aCampos, { 'TMP_QSTOK' , 'N', TamSX3('B2_QATU')[1], TamSX3('B2_QATU')[2]})        
    
    //Cria a tabela temporária
    oTmpTable:= FWTemporaryTable():New(cAliasTmp)
    oTmpTable:SetFields( aCampos )
    oTmpTable:Create()  

    //Popula a tabela temporária
    Processa({|| fPopula()}, 'Processando...')
 
    //Adiciona as colunas que serão exibidas no browse
    aColunas := fCriaCols()

  //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE 'Tela para Marcação de dados ' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Dados
        oMkBrow := FWMarkBrowse():New()
        oMkBrow:SetAlias(cAliasTmp)                
        oMkBrow:SetDescription('Produtos')
        oMkBrow:DisableFilter()
        oMkBrow:DisableConfig()
        oMkBrow:DisableSeek()
        oMkBrow:DisableSaveConfig()
        oMkBrow:SetFontBrowse(oFontGrid)
        oMkBrow:SetFieldMark('TMP_OK')
        oMkBrow:SetTemporary(.T.)
        oMkBrow:SetColumns(aColunas)
        oMkBrow:Activate()
    ACTIVATE MsDialog oDlgMark CENTERED
     
    //Deleta a temporária e desativa a tela de marcação
    oTmpTable:Delete()
    oMkBrow:DeActivate()

    FwRestArea(aArea)
Return

Static Function MenuDef()
    Local aMenuBt := {}     
    //Criação das opções
    ADD OPTION aMenuBt TITLE 'Gestão'  ACTION 'U_PCP080TRAN()'     OPERATION 2 ACCESS 0
Return aMenuBt
 

Static Function fCriaCols()
    Local nAtual       := 0 
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
    //[7] - Editável? .T. = sim, .F. = não
    aAdd(aEstrut, { 'TMP_COD'   , 'Produto',    'C', TamSX3('B1_COD')[1],       0, '',     .F.})
    aAdd(aEstrut, { 'TMP_DESC'  ,'Descricao',   'C', TamSX3('B1_DESC')[1],      0, '',    .F.})
    aAdd(aEstrut, { 'TMP_TIPO'  , 'Tipo',       'C', TamSX3('B1_TIPO')[1],      0, '',     .F.})
    aAdd(aEstrut, { 'TMP_BASE'  , 'Base',       'C', TamSX3('B1_COD')[1],       0, '',  .F.})
    aAdd(aEstrut, { 'TMP_SALDO' ,'Saldo',       'N', TamSX3('B2_QATU')[1],      2, cMascara,     .F.})
    aAdd(aEstrut, { 'TMP_QEMP'  ,'Empenho',     'N', TamSX3('B2_QATU')[1],      2, cMascara,     .F.})
    aAdd(aEstrut, { 'TMP_QDISP' ,'Disponivel' , 'N', TamSX3('B2_QATU')[1],      2, cMascara,     .F.})
    aAdd(aEstrut, { 'TMP_QCONS' ,'Consumo'    , 'N', TamSX3('B2_QATU')[1],      2, cMascara,     .F.})    
    aAdd(aEstrut, { 'TMP_QCOND' ,'Cons.Dia'   , 'N', TamSX3('B2_QATU')[1],      2, cMascara,     .F.})    
    aAdd(aEstrut, { 'TMP_QSTOK' ,'Est.Dia'    , 'N', TamSX3('B2_QATU')[1],      2, '',     .F.})    

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
 
        //Se for ser possível ter o duplo clique
        If aEstrut[nAtual][7]
            oColumn:SetEdit(.T.)
            oColumn:SetReadVar(aEstrut[nAtual][1])
            //oColumn:SetValid({|| fSuaValid()})
        EndIf
 
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas

Static Function fMarkTod()
    //Percorre todos os registros
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        //Atualiza o registro atual
        RecLock(cAliasTmp, .F.)
            (cAliasTmp)->TMP_OK := ! (cAliasTmp)->TMP_OK
        (cAliasTmp)->(MsUnlock())
 
        (cAliasTmp)->(DbSkip())
    EndDo
 
    //Volta pro topo, e atualiza a tela
    (cAliasTmp)->(DbGoTop())
    oFWBrowse:Refresh()
Return


Static Function fPopula()
    Local aArea := FwgetArea()
    Local cAlias    := "PCP_"+getNextAlias() 
    Local cQuery    := ""

    cQuery:="WITH AliasProdutos AS ( "+CRLF
    cQuery+="    SELECT  "+CRLF
    cQuery+="        Z4_FILIAL, "+CRLF 
    cQuery+="        Z4_COD,  "+CRLF
    cQuery+="        Z4_CODDES "+CRLF
    cQuery+="    FROM " + RetSqlName("SZ4") + " "+CRLF
    cQuery+="    WHERE D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="), "+CRLF
    cQuery+="BaseCodigos AS ( "+CRLF
    cQuery+="    SELECT "+CRLF
    cQuery+="        SB2.B2_FILIAL, "+CRLF
    cQuery+="        SB2.B2_COD, "+CRLF
    cQuery+="        ISNULL(AP.Z4_CODDES, SB2.B2_COD) AS CODBASE "+CRLF
    cQuery+="    FROM " + RetSqlName("SB2") + " SB2 "+CRLF
    cQuery+="    LEFT JOIN AliasProdutos AP "+CRLF
    cQuery+="        ON AP.Z4_FILIAL = SB2.B2_FILIAL  "+CRLF
    cQuery+="       AND AP.Z4_COD = SB2.B2_COD "+CRLF
    cQuery+="    WHERE SB2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="      AND SB2.B2_FILIAL =  '"+xFilial("SB2")+"'  "+CRLF
    cQuery+="      AND SB2.B2_LOCAL = '02' "+CRLF
    cQuery+="      AND SB2.B2_QATU > 0 "+CRLF
    cQuery+="), "+CRLF
    cQuery+="Consumo AS ( "+CRLF
    cQuery+="    SELECT   "+CRLF
    cQuery+="        SD4.D4_FILIAL,  "+CRLF
    cQuery+="        ISNULL(AP.Z4_CODDES, SD4.D4_COD) AS CODBASE, "+CRLF
    cQuery+="        SUM(SD4.D4_QTDEORI) / NULLIF(DATEDIFF(MONTH, DATEADD(MONTH, -6, GETDATE()), GETDATE()), 0) AS CONSUMO_MENSAL   "+CRLF
    cQuery+="    FROM " + RetSqlName("SD4") + " SD4 "+CRLF
    cQuery+="    LEFT JOIN AliasProdutos AP  "+CRLF
    cQuery+="        ON AP.Z4_FILIAL = SD4.D4_FILIAL  "+CRLF
    cQuery+="       AND AP.Z4_COD = SD4.D4_COD "+CRLF
    cQuery+="    WHERE SD4.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="      AND SD4.D4_LOCAL IN ('02') "+CRLF
    cQuery+="      AND SD4.D4_DATA BETWEEN DATEADD(MONTH, -6, GETDATE()) AND GETDATE()  "+CRLF
    cQuery+="    GROUP BY SD4.D4_FILIAL, ISNULL(AP.Z4_CODDES, SD4.D4_COD) "+CRLF
    cQuery+="), "+CRLF
    cQuery+="Empenhos AS ( "+CRLF
    cQuery+="    SELECT  "+CRLF
    cQuery+="        SD4.D4_FILIAL, "+CRLF
    cQuery+="        ISNULL(AP.Z4_CODDES, SD4.D4_COD) AS CODBASE, "+CRLF
    cQuery+="        SUM(SD4.D4_QUANT) AS QTEMP "+CRLF
    cQuery+="    FROM " + RetSqlName("SD4") + " SD4 "+CRLF
    cQuery+="    LEFT JOIN AliasProdutos AP  "+CRLF
    cQuery+="        ON AP.Z4_FILIAL = SD4.D4_FILIAL  "+CRLF
    cQuery+="       AND AP.Z4_COD = SD4.D4_COD "+CRLF
    cQuery+="    WHERE SD4.D_E_L_E_T_ = ' '   "+CRLF
    cQuery+="      AND SD4.D4_LOCAL IN ('02')  "+CRLF
    cQuery+="      AND SD4.D4_QUANT > 0 "+CRLF
    cQuery+="    GROUP BY SD4.D4_FILIAL, ISNULL(AP.Z4_CODDES, SD4.D4_COD) "+CRLF
    cQuery+=")"+CRLF
    cQuery+="SELECT "+CRLF
    cQuery+="    BC.B2_FILIAL, "+CRLF
    cQuery+="    BC.B2_COD,  "+CRLF
    cQuery+="    SB1.B1_DESC, "+CRLF
    cQuery+="    SB1.B1_TIPO, "+CRLF
    cQuery+="    CASE  "+CRLF
    cQuery+="        WHEN SB1.B1_XTPBASE = 'A' THEN 'AGUA' "+CRLF
    cQuery+="        WHEN SB1.B1_XTPBASE = 'S' THEN 'SOLVENTE' "+CRLF
    cQuery+="        ELSE ' ' "+CRLF
    cQuery+="    END AS TIPO, "+CRLF
    cQuery+="    SUM(SB2.B2_QATU) AS B2_QATU, "+CRLF
    cQuery+="    ISNULL(E.QTEMP, 0) AS B2_QEMP, "+CRLF
    cQuery+="    SUM(SB2.B2_QATU) - ISNULL(E.QTEMP, 0) AS DISPONIVEL, "+CRLF
    cQuery+="    ISNULL(C.CONSUMO_MENSAL, 0) AS CONSUMO_MENSAL, "+CRLF
    cQuery+="    ISNULL(C.CONSUMO_MENSAL / 30.0, 0) AS CONSUMO_DIARIO, "+CRLF
    cQuery+="    CASE "+CRLF
    cQuery+="        WHEN ISNULL(C.CONSUMO_MENSAL / 30.0, 0) > 0 THEN  "+CRLF
    cQuery+="            (SUM(SB2.B2_QATU) - ISNULL(E.QTEMP, 0)) / (C.CONSUMO_MENSAL / 30.0) "+CRLF
    cQuery+="        ELSE NULL "+CRLF
    cQuery+="    END AS ESTOQUE_DIAS "+CRLF
    cQuery+="FROM BaseCodigos BC "+CRLF
    cQuery+="JOIN " + RetSqlName("SB2") + " SB2  "+CRLF
    cQuery+="    ON SB2.B2_FILIAL = BC.B2_FILIAL  "+CRLF
    cQuery+="   AND SB2.B2_COD = BC.B2_COD  "+CRLF
    cQuery+="   AND SB2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="JOIN " + RetSqlName("SB1") + " SB1  "+CRLF
    cQuery+="    ON SB1.B1_COD = BC.B2_COD  "+CRLF
    cQuery+="   AND SB1.B1_TIPO = 'EM'   "+CRLF
    cQuery+="   AND SB1.B1_XTPCOMP = 'P'  "+CRLF
    cQuery+="   AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="LEFT JOIN Consumo C  "+CRLF
    cQuery+="    ON C.D4_FILIAL = BC.B2_FILIAL AND C.CODBASE = BC.CODBASE "+CRLF
    cQuery+="LEFT JOIN Empenhos E  "+CRLF
    cQuery+="    ON E.D4_FILIAL = BC.B2_FILIAL AND E.CODBASE = BC.CODBASE "+CRLF
    cQuery+="GROUP BY  "+CRLF
    cQuery+="    BC.B2_FILIAL, "+CRLF
    cQuery+="    BC.B2_COD, "+CRLF
    cQuery+="    SB1.B1_DESC, "+CRLF
    cQuery+="    SB1.B1_TIPO, "+CRLF
    cQuery+="    SB1.B1_XTPBASE, "+CRLF
    cQuery+="    C.CONSUMO_MENSAL, "+CRLF
    cQuery+="    E.QTEMP "+CRLF
    cQuery+="ORDER BY DISPONIVEL "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
            lRet := .F.
            (cAlias)->(DbCloseArea())   
            FWAlertError( 'Não tem movimento ', 'Sem Movimentação' )
            FwRestArea(aArea)
            Return
    endif  

    dbSelectArea(cAlias) 
    (cAlias)->( dbGoTop() )
    While (cAlias)->(!EOF())
      RecLock(cAliasTmp, .T.)
            (cAliasTmp)->TMP_OK     := Space(02) 
            (cAliasTmp)->TMP_COD    := (cAlias)->B2_COD 
            (cAliasTmp)->TMP_DESC   := (cAlias)->B1_DESC
            (cAliasTmp)->TMP_TIPO   := (cAlias)->B1_TIPO 
            (cAliasTmp)->TMP_BASE   := (cAlias)->TIPO
            (cAliasTmp)->TMP_SALDO  := (cAlias)->B2_QATU
            (cAliasTmp)->TMP_QEMP   := (cAlias)->B2_QEMP
            (cAliasTmp)->TMP_QDISP  := round(((cAlias)->B2_QATU-(cAlias)->B2_QEMP),2)
            (cAliasTmp)->TMP_QCONS  := round((cAlias)->CONSUMO_MENSAL,2)
            (cAliasTmp)->TMP_QCOND  := round((cAlias)->CONSUMO_DIARIO,2)
            (cAliasTmp)->TMP_QSTOK  := Round((cAlias)->ESTOQUE_DIAS,0)

        (cAliasTmp)->(MsUnlock())
    
        (cAlias)->(dbSkip() )
    End
    (cAlias)->(DbCloseArea())     

  
   FwRestArea(aArea)
Return

User Function PCP080TRAN
  Local aArea := FwgetArea()
  Local cProduto := (cAliasTmp)->TMP_COD 
  Local cDescr   := (cAliasTmp)->TMP_DESC
  Local nSaldo   := (cAliasTmp)->TMP_SALDO
  Local nQEmp    := (cAliasTmp)->TMP_QEMP 
  Local nDisp    := (cAliasTmp)->TMP_QDISP
  Local nConsumo := (cAliasTmp)->TMP_QCONS
  Local nDisCons := (cAliasTmp)->TMP_QCOND
  Local nStkDia  :=  (cAliasTmp)->TMP_QSTOK

  If ExistBlock("PCPM180")
     aDados:= {cProduto,cDescr,nSaldo,nQEmp,nDisp,nConsumo,nDisCons,nStkDia}
     ExecBlock("PCPM180",.F.,.F.,aDados)   
  Endif        

  FwRestArea(aArea)
Return
