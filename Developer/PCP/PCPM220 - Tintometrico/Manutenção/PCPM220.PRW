//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

/*/{Protheus.doc} PCPM220
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/02/2025
@return variant, return_description
/*/
User Function PCPM220()
Local aArea := FwGetArea()
Private oBrowse := FwMBrowse():New()
    oBrowse:SetAlias("SZ5")
    oBrowse:SetDescription("Transferencias do Tintometrico")
    oBrowse:AddLegend( "SZ5->Z5_STATUS == 'AB'", "GREEN",  "Em Aberto" )
    oBrowse:AddLegend( "SZ5->Z5_STATUS == 'TR'", "RED",    "Tranferido" )
    oBrowse:AddLegend( "SZ5->Z5_STATUS == 'OP'", "BLACK",  "Gerado OP" )
    oBrowse:Activate()
FwRestArea(aArea)
Return

/*/{Protheus.doc} MenuDef
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/02/2025
@return variant, return_description
/*/
Static Function MenuDef()
Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.PCPM220'	OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.PCPM220'	OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.PCPM220'	OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.PCPM220'	OPERATION 5 ACCESS 0
    ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.PCPM220'	OPERATION 9 ACCESS 0
    ADD OPTION aMenu TITLE 'TransFerir'	ACTION 'U_PCPRUNPROC()'   	OPERATION 9 ACCESS 0

Return(aMenu)

/*/{Protheus.doc} ModelDef
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/02/2025
@return variant, return_description
/*/
Static Function ModelDef()
Local oStruct1 := FwFormStruct(1,"SZ5")
Local oModel

    oModel := MpFormModel():New("PPCPM220",/*Pre-Validacao*/, {|| .T.},/*Commit*/,/*Cancel*/)
    oModel:AddFields("ID_MODEL_ENCH_DIVNEG",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

    oModel:SetPrimaryKey({"Z5_FILIAL","Z5_COD"})
    oModel:SetDescription("Transferencias do Tintometrico")
    oModel:GetModel("ID_MODEL_ENCH_DIVNEG"):SetDescription("Transferencias do Tintometrico")

Return(oModel)

/*/{Protheus.doc} ViewDef
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/02/2025
@return variant, return_description
/*/
Static Function ViewDef()
Local oStruct1 	:= FwFormStruct(2,"SZ5")
Local oModel 	:= FwLoadModel("PCPM220")
Local oView		:= FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("ID_VIEW_ENCH_DIVNEG",oStruct1,"ID_MODEL_ENCH_DIVNEG")
    oView:EnableTitleView('ID_VIEW_ENCH_DIVNEG','Transferencias do Tintometrico')

Return(oView)

/*/{Protheus.doc} PCPRUNPROC
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/03/2025
@return variant, return_description
/*/
User Function PCPRUNPROC()
       Local lSit := .T.
       MsgRun("Gerando Movimentacao.    Aguarde.....", "Processando", {||  lSit :=PCPM220TRA() })
       if lSit 
            MsgAlert("Movimento OK")
       else
            MsgAlert("Problemas na Gravação do Movimento ")
       endif      
Return

/*/{Protheus.doc} PCPM220TRA
description
@type function
@version 1.0
@author Paulo Lenzi
@since 26/02/2025
@return variant, return_description
/*/
Static Function PCPM220TRA()
    Local aArea     := FwGetArea()
    Local aAuto     := {}
    Local aItens    := {}
    Local QtdCols   := 1
    Local cUm       := Posicione("SB1",1,xFilial("SB1")+SZ5->Z5_COD,"B1_UM")
    Local cGrupo    := Posicione("SB1",1,xFilial("SB1")+SZ5->Z5_COD,"B1_GRUPO")
    Local nOpcAuto  := 3
    Local nSaldo    := Posicione("SB2",1,xFilial("SB2")+SZ5->Z5_COD+SZ5->Z5_LOCAL,"B2_QATU")
    Local aSaldos   := CalcEst(SZ5->Z5_COD, SZ5->Z5_ARMAZ, dDataBase)
    Local nSeqNum   := ""
    Local Nx        := 0
    Local cEndTnt   := GetMv("ES_ENDTNT")
    Local lRet      := .T.
    
    Private lMsErroAuto := .F.

    // verifica se o saldo é suficiente
        if nSaldo < SZ5->Z5_QUANT
            MsgStop("Saldo Insuficiente")
            Return
        endif
        
        IF aSaldos[1] = 0
                If ExistBlock("PCPM220SLD")
                    aDados:= {SZ5->Z5_COD,SZ5->Z5_ARMAZ,SZ5->Z5_QUANT}
                    ExecBlock("PCPM220SLD",.F.,.F.,aDados)   
                Endif        
        endif

        //Numero sequencial
        nSeqNum:=nextnumero("SD3",2,"D3_DOC",.t.)

        //Cabecalho a Incluir
        aadd(aAuto,{nSeqNum,dDataBase}) //Cabecalho

        For Nx:=1 to QtdCols

            aItens := { {"D3_DOC",nSeqNum               ,Nil},;  
                        {"D3_ITEM",cValtoChar(Nx)       ,Nil},;
                        {"D3_FILIAL",xFilial("SD3")     ,Nil},;   
                        {"D3_TM","499"                  ,Nil},;   
                        {"D3_COD",SZ5->Z5_COD           ,Nil},;  // Original 1
                        {"D3_DESCRI",SZ5->Z5_DESCR      ,Nil},;  // Original 2
                        {"D3_UM",cUm                    ,Nil},;  // Original 3
                        {"D3_LOCAL",SZ5->Z5_LOCAL       ,Nil},;  // Original 4
                        {"D3_LOCALIZ",SZ5->Z5_LOCALIZ   ,Nil},;  // Original 5
                        {"D3_EMISSAO",dDataBase         ,Nil},;  // Original 5
                        {"D3_COD",SZ5->Z5_COD           ,Nil},;  // Destino 6
                        {"D3_DESCRI",SZ5->Z5_DESCR      ,Nil},;  // Destino 7
                        {"D3_UM",cUm                    ,Nil},;  // Destino 8
                        {"D3_LOCAL",SZ5->Z5_ARMAZ       ,Nil},;  // Destino 9  
                        {"D3_LOCALIZ",cEndTnt           ,Nil},;  // Destino 10
                        {"D3_NUMSERI",""                ,Nil},;  // Geral 11
                        {"D3_LOTECTL",SZ5->Z5_LOTECTL   ,Nil},;  // Geral 12
                        {"D3_NUMLOTE",space(6)          ,Nil},;  // Geral 13
                        {"D3_DTVALID",SZ5->Z5_DTVALID   ,Nil},;  // Geral 14
                        {"D3_POTENCI",0                 ,Nil},;  // Geral 15
                        {"D3_QUANT",SZ5->Z5_QUANT       ,Nil},;  // Geral 16
                        {"D3_QTSEGUM",criavar("D3_QTSEGUM")  ,Nil},; // Geral 17
                        {"D3_ESTORNO","N"               ,Nil},;  // Geral 18
                        {"D3_NUMSEQ",""                 ,Nil},;  // Geral 19
                        {"D3_LOTECTL",SZ5->Z5_LOTECTL   ,Nil},;  // Geral 20
                        {"D3_DTVALID",SZ5->Z5_DTVALID   ,Nil},;  // Geral 21
                        {"D3_ITEMGRD",space(3)          ,Nil},;  // Geral 22
                        {"D3_CONTA","111414001"         ,Nil},;  // Geral 24 *
                        {"D3_GRUPO",cGrupo              ,Nil},;  // Geral 25 *
                        {"D3_OBSERVA","PCPM220"         ,Nil},;  // Geral 23
                        {"D3_USUARIO",cUserName         ,Nil}}  // Geral 26 *
        NEXT

        aAdd(aAuto,aItens)

        Begin Transaction
        MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

        if lMsErroAuto 
            MostraErro()
            DisarmTransaction()
            lRet := .F.
        else
            if Reclock("SZ5",.F.,.T.)
                SZ5->Z5_STATUS := "TR"
                SZ5->(MsUnlock())
            endif    
        EndIf
        End Transaction

    FwRestArea(aArea)
Return(lRet) 

/*/{Protheus.doc} PCPM220SLD
description
@type function
@version 1.0
@author Paulo Lenzi
@since 27/02/2025
@return variant, return_description
/*/
User Function PCPM220SLD()
Local aArea := FwGetArea()
Local aVetor := {}
Local cCodProd  := PARAMIXB[1]
Local cLocal    := PARAMIXB[2]
Local nSaldo    := 0 //PARAMIXB[3]

Private lMsErroAuto := .F.     


    DbSelectArea("SB9")
    DbSetOrder(1)
    IF SB9->(DbSeek(xFilial("SB9")+cCodProd+cLocal,.T.))
        FwRestArea(aArea)
        Return
    ENDIF 

    aVetor :={;
        {"B9_FILIAL", FWxFilial('SB9'), Nil},;
        {"B9_COD",    cCodProd,         Nil},;
        {"B9_LOCAL",  cLocal,           Nil},;
        {"B9_QINI",   nSaldo,           Nil};
    }
    
    //Iniciando transação e executando saldos iniciais
    Begin Transaction
        MSExecAuto({|x, y| Mata220(x, y)}, aVetor, 3)
        
        //Se houve erro, mostra mensagem
        If lMsErroAuto
            MostraErro()
            DisarmTransaction()
        EndIf
    End Transaction
FwRestArea(aArea)
Return


//------------------------------------------------------------------------------------------------------
// FIM DO PROGRAMA
//------------------------------------------------------------------------------------------------------
