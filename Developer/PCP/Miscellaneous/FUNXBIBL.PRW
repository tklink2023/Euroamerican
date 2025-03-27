#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#DEFINE cEof  CHAR(13)+CHAR(10)
//============================================================================================================
//
// Funções de Biblioteca
//
//============================================================================================================

/*/{Protheus.doc} Ambiente
description
@type function
@version 1.0
@author Paulo Lenzi
@since 19/02/2025
@return variant, return_description
/*/
User Function XEnvironment()
    Local cAutoEmp := PARAMIXB[1]
    Local cAutoFil := PARAMIXB[2]
    RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
    If Select("SX2") <= 0
	    RpcSetEnv( cAutoEmp, cAutoFil )
    Endif    
Return

/*/{Protheus.doc} RegLog
description
@type function
@version 1.0
@author Paulo Lenzi
@since 19/02/2025
@return variant, return_description
/*/
User Function XRegistroLog()
    Local cArea := FwGetArea()
    Local cMensagem :=  PARAMIXB[1]
    Local cProcesso :=  PARAMIXB[2]
    Local xcUser    :=  PARAMIXB[3]    
    Local cDetalhe  :=  PARAMIXB[4]
    Local cSubProc  :=  PARAMIXB[5]
    Local cIdMov    :=  PARAMIXB[6]

    dbSelectArea("CV8")
    If RecLock("CV8",.T.)
                CV8->CV8_FILIAL:= xFilial("CV8")
                CV8->CV8_DATA 	:= MsDate()
                CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
                CV8->CV8_PROC	:= cProcesso
                CV8->CV8_USER	:= xcUser
                CV8->CV8_INFO   := '2'
                CV8->CV8_MSG 	:= cMensagem
                CV8->CV8_DET    := cDetalhe
                CV8->CV8_SBPROC := cSubProc
                CV8->CV8_IDMOV  := cIdMov
                CV8->(MsUnlock())
    EndIf
     FwRestArea(cArea)
Return

/*/{Protheus.doc} ConsultSBF
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/02/2025
@return variant, return_description
/*/
User Function ConsultSBF()
     Local cArea := FwGetArea()
     Local cProduto := IIF(INCLUI,M->Z5_COD,SZ5->Z5_COD)
     Local cQuery   as character 
     Local cAlias   := "PCP_"+getNextAlias()    
 
     Local oDlgMark   as Object 
     Local oOk        := LoadBitmap( GetResources(), "LBOK" )
     Local oNo        := LoadBitmap( GetResources(), "LBNO" )
     Local aSize      := MsAdvSize()
     Local bOk 		:= {|| CalcCamp(aBrowse),oDlgMark:End()  }
     Local bCancel	:= {|| lRet:=Saidosistema()	,oDlgMark:End() }

    Private aBrowse    := {}
    Private oBrwMark as Object      

    oMainWnd:ReadClientCoors()
    nHeight := (oMainWnd:nHeight-50)/2
    nWidth  := (oMainWnd:nWidth-15)/2
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 

    cQuery:="SELECT BF_LOCALIZ,B8_LOTECTL,B8_DTVALID,B8_SALDO,BF_LOCAL "+cEof
    cQuery+="FROM  " + RetSqlName("SBF") + "  SBF "+cEof
    cQuery+="INNER JOIN  " + RetSqlName("SB8") + "  SB8 ON B8_FILIAL = BF_FILIAL AND B8_PRODUTO = BF_PRODUTO AND B8_LOCAL = BF_LOCAL AND B8_LOTECTL = BF_LOTECTL AND B8_SALDO > 0 AND SB8.D_E_L_E_T_ = ' ' "+cEof
    cQuery+="WHERE SBF.D_E_L_E_T_ = ' ' "+cEof
    cQuery+="AND BF_FILIAL =  '"+xFilial("SB8")+"'  "+cEof
    cQuery+="AND BF_PRODUTO = '"+Alltrim(cProduto)+"' "+cEof
    cQuery+="AND BF_LOCAL <> 'TT' "+cEof
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    TCSetField(cAlias, "B8_DTVALID", "D")

    IF (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())   
        FwRestArea(aArea)
        Return(aBrowse)
   endif

   While (cAlias)->( !Eof() )

        aAdd(aBrowse,{ .F.,(cAlias)->BF_LOCALIZ,cValtoChar((cAlias)->B8_LOTECTL),DTOC((cAlias)->B8_DTVALID)})

        (cAlias)->(DbSkip())
   Enddo
   (cAlias)->(DbCloseArea())


   oDlgMark := MSDialog():New(aSize[7],0, nHeight,nWidth,"Selecione a Localizacao",,,.F.,,,,,,.T.,,,.T. )

   oDlgMark:bInit := {||EnchoiceBar(oDlgMark,{|| FWMsgRun(, {|oDlgMark| U_PCP20CALC(oDlgMark) }, "Processando", "Processando a rotina...") ,oDlgMark:End()},{|| oDlgMark:End()},,)}
  
   oBrwMark := TCBrowse():New( aSize[7]+35,5, nHeight,nWidth,,{' ','Localizacao','Lote', 'Validade'},{010,050,050,010},oDlgMark,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )
   
   oBrwMark:SetArray( aBrowse )
   oBrwMark:bLine := {||{ iIf( aBrowse[oBrwMark:nAt][01], oOK, oNO ) ,;  	                // 1 Marcação
                               aBrowse[oBrwMark:nAt,02],;							        // 2 Localizacao
                               aBrowse[oBrwMark:nAt,03],;							        // 3 Lote
                               aBrowse[oBrwMark:nAt,04] } }                                 // 4 Data Validade

   oBrwMark:GoTop()
   oBrwMark:bLDblClick := { || fLDblClick() }
   oBrwMark:bHeaderClick := { || fHeadClick() }

   ACTIVATE MSDIALOG oDlgMark ON INIT EnchoiceBar(oDlgMark, bOk , bCancel) CENTERED
   FwRestArea(cArea)
Return

/*/{Protheus.doc} fLDblClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/02/2025
@return variant, return_description
/*/
Static Function fLDblClick()
    aBrowse[oBrwMark:nAt][1] := ( ! aBrowse[oBrwMark:nAt][1] )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
Return( NIL )

/*/{Protheus.doc} fHeadClick
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/02/2025
@return variant, return_description
/*/
Static Function fHeadClick()
    aEval( aBrowse, { |cValue,nIndex| aBrowse[nIndex][1] := ( ! aBrowse[nIndex][1] ) } )
    oBrwMark:Refresh()
    oBrwMark:DrawSelect()
Return( NIL )

/*/{Protheus.doc} Saidosistema
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/02/2025
@return variant, return_description
/*/
static function Saidosistema()

msgAlert("Abortando o Processo....")

return(.F.)

Static Function CalcCamp(aBrowse)
    Local Ny := 0

    IF LEN(aBrowse) > 0

            FOR Ny := 1 to LEN(aBrowse)
                if aBrowse[Ny][1]
                    IF INCLUI
                        M->Z5_LOCALIZ := aBrowse[Ny][2]
                        M->Z5_LOTECTL := aBrowse[Ny][3]
                        M->Z5_DTVALID := aBrowse[Ny][4]
                    else
                        SZ5->Z5_LOCALIZ := aBrowse[Ny][2]
                        SZ5->Z5_LOTECTL := aBrowse[Ny][3]
                        SZ5->Z5_DTVALID := aBrowse[Ny][4]
                    ENDIF 
                endif
            Next

    ENDIF

Return

//------------------------------------------------------------------------------------------------------------
// Programas de Gatilho
//------------------------------------------------------------------------------------------------------------


//============================================================================================================
//  
// FIM DO ARQUIVO
//
//============================================================================================================  
