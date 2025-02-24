#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

/*/{Protheus.doc} PCPG020
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/02/2025
@return variant, return_description
/*/
User Function PCPG020()
    Local aArea         := FWGetArea()
    Local lRet          := .T.
    Local cCodTm        := CTM 
    Local cCodProd      := AllTrim(aCols[n][nposcod])
    Local cLote         := AllTrim(aCols[n][nposlotctl])
    Local nQtde         := aCols[n][nposquant]
    Local cLocal        := AllTrim(aCols[n][nposlocal])
    Local dtValid       := aCols[n][nposdvalid]                                                                                                   
    Local nQtdEmp       := Posicione("SB8",6,xFilial("SB8")+cCodProd+cLocal+DTOS(dtValid)+cLote,"B8_SALDO")

    Private aCampos := {}
    Private cAliasTmp := "PCP_" + RetCodUsr()
    Private aColunas := {}
    Private cMascara := "@E 99,999,999,999.999"
    Private cMask    := "@E 9,999.999 %"
    Private oMarkBrowse


    aAdd(aCampos, { "OK"            , "C", 02    , 0 })
    aAdd(aCampos, { "LOTE"          , "C", 06    , 0 })
    aAdd(aCampos, { "PRODUTO"       , "C", 15    , 0 })
    aAdd(aCampos, { "ALMOX"         , "C", 02    , 0 })
    aAdd(aCampos, { "DATA"          , "D", 08    , 0 })
    aAdd(aCampos, { "VALIDADE"      , "D", 08    , 0 })
    aAdd(aCampos, { "SALDO"         , "N", 15    , 2 })

    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"LOTE","PRODUTO"} )
    oTempTable:Create()  
    
    aColunas := fCriaCols()

    
    IF cCodTm == "400"
        if ExistBlock("PCP020Com")
                   aDados:= {cCodProd,cLocal,dtValid,nQtde,nQtdEmp}
                   ExecBlock("PCP020Com",.F.,.F.,aDados)   
        Endif           
    endif

    oTempTable:Delete()
    FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP020Comp
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/02/2025
@return variant, return_description
/*/
User Function PCP020Comp()
     Local aArea         := FWGetArea()
     Local lRet          := .T.

     Local cProduto :=  PARAMIXB[1]
     Local cLocal   :=  PARAMIXB[2] 
     Local cData    :=  PARAMIXB[3]
     Local nQtde    :=  PARAMIXB[4]
     Local nQtdeEmp :=  PARAMIXB[5]
     // Comparação das Quantidade
     IF nQtde > nQtdeEmp
        MsgStop("Quantidade maior que a disponível no Lote")
        lRet := .F.
     Endif
     if cData < DATE()
        MsgStop("Data de Validade menor que a data atual")
        lRet := .F.
     endif   
     if !lRet
        if ExistBlock("PCP020CALL")
                    aDados:= {cProduto,cLocal}
                    ExecBlock("PCP020CALL",.F.,.F.,aDados)   
            Endif         
     Endif   

     FwRestArea(aArea)
Return(lRet)

/*/{Protheus.doc} PCP020CALL
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/02/2025
@return variant, return_description
/*/
User Function PCP020CALL()
     Local aArea         := FWGetArea()
     Local cProduto :=  PARAMIXB[1]
     Local cLocal   :=  PARAMIXB[2] 
     Local cAlias   := GetNextAlias()
     Local cQuery   := '' 

    cQuery :="Select B8_LOTECTL,B8_PRODUTO,B8_LOCAL,B8_DATA,B8_DTVALID,B8_SALDO "+cEof 
    cQuery +="from "+ RetSqlName("SB8")+" SB8 "+cEof 
    cQuery +="Where SB8.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="AND B8_FILIAL = '"+xFilial("SB8")+"' "+cEof 
    cQuery +="AND B8_PRODUTO = '"+cProduto+"' "+cEof 
    cQuery +="AND B8_LOCAL = '"+cLocal+"' "+cEof 
    cQuery +="AND B8_SALDO > 0 "+cEof 

    cQuery := ChangeQuery(cQuery)

    If !Empty(Select(cAlias))
        DbSelectArea(cAlias)
        (cAlias)->(dbCloseArea())
    Endif
                
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	TCSetField(cAlias, "B8_DATA" , "D")	
    
    if (cAlias)->( Eof())
                if ExistBlock("XRegistroLog")
                   aDados:= {"Gerando dados da Query",FunName(),UsrFullName( ),"Nao foi encontrados dados na Query"}
                   ExecBlock("XRegistroLog",.F.,.F.,aDados)   
                Endif        
                FwRestArea(cArea)
                RETURN
    Endif

    While (cAlias)->(!EOF())
        IF RecLock(cAliasTmp, .T.)
            (cAliasTmp)->OK         := ""
            (cAliasTmp)->LOTE       := (cAlias)->B8_LOTECTL
            (cAliasTmp)->PRODUTO    := (cAlias)->B8_PRODUTO
            (cAliasTmp)->ALMOX      := (cAlias)->B8_LOCAL
            (cAliasTmp)->DATA       := (cAlias)->B8_DATA
            (cAliasTmp)->VALIDADE   := (cAlias)->B8_DTVALID
            (cAliasTmp)->SALDO      := (cAlias)->B8_SALDO
            (cAliasTmp)->(MsUnlock())
        ENDIF 


        (cAlias)->(DbSkip())
    Enddo
    (cAlias)->(DbCloseArea())

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
    //oMarkBrowse:SetOwner(oPanGrid)

    oMarkBrowse:AddButton("Ordens Producao"   ,{||PCP020EXEC(), oMarkBrowse:Refresh(), oMarkBrowse:Refresh()},,2,,.F.)

    oMarkBrowse:Activate()


    FwRestArea(aArea)
Return

/*/{Protheus.doc} fCriaCols
description
@type function
@version 1.0
@author Paulo Lenzi
@since 21/02/2025
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
    aAdd(aEstrut, {"OK", "Ok",             "C", 02,   0, ""})
    aAdd(aEstrut, { "LOTE"  , GetSx3Cache("B8_LOTECTL","X3_TIPO"), GetSx3Cache("B8_LOTECTL","X3_TAMANHO"), GetSx3Cache("B8_LOTECTL","X3_DECIMAL")  })
    aAdd(aEstrut, { "PRODUTO"  , GetSx3Cache("B1_COD","X3_TIPO"), GetSx3Cache("B1_COD","X3_TAMANHO"), GetSx3Cache("B1_COD","X3_DECIMAL")  })
    aAdd(aEstrut, { "LOCAL"  , GetSx3Cache("B8_LOCAL","X3_TIPO"), GetSx3Cache("B8_LOCAL","X3_TAMANHO"), GetSx3Cache("B8_LOCAL","X3_DECIMAL")  })
    aAdd(aEstrut, { "DATA"  , "D", 8, 0 })
    aAdd(aEstrut, { "VALIDADE"  , "D", 8, 0 })
    aAdd(aEstrut, { "SALDO"  , "N", 15, 2 })
   
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
//---------------------------------------------------------------------------//
// Final do Programa
//---------------------------------------------------------------------------//
