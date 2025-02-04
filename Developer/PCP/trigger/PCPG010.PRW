#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

User Function PCPG010()
    Local aArea         := FWGetArea()
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 187
    Local nJanLargur    := 253 
    Local cJanTitulo    := 'Percental a(s) empresa(s)'
    Local lDimPixels    := .T. 
    Local lCentraliz    := .T. 
    Local nObjLinha     := 0
    Local nObjColun     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0

    Private lRetorno      := " "

    Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt 
    Private bBlocoIni   := {|| /*fSuaFuncao()*/ } //Aqui voce pode acionar funcoes customizadas que irao ser acionadas ao abrir a dialog 
    //objeto0 
    Private oChkObj0 
    Private lChkObj0    := .F.  
    Private cChkObj0    := 'Euroamerican' 
    //objeto1 
    Private oChkObj1 
    Private lChkObj1    := .F.  
    Private cChkObj1    := 'QualyVinil' 
    //objeto2 
    Private oChkObj2 
    Private lChkObj2    := .F.  
    Private cChkObj2    := 'Phoenix' 
    //objeto3 
    Private oBtnObj3 
    Private cBtnObj3    := 'Confirmar' 
    Private bBtnObj3    := {|| lRetorno := IIF(lChkObj0,"0200,","")+IIF(lChkObj1,"0803,","")+IIF(lChkObj2,"0901,",""), oDialogPvt:End() }  

    //Cria a dialog
    oDialogPvt := TDialog():New(0, 0, nJanAltura, nJanLargur, cJanTitulo, , , , , , nCorFundo, , , lDimPixels)
     
        //objeto0 - usando a classe TCheckBox
        nObjLinha := 5
        nObjColun := 7
        nObjLargu := 110
        nObjAltur := 15
        oChkObj0  := TCheckBox():New(nObjLinha, nObjColun, cChkObj0, {|u| Iif(PCount() > 0 , lChkObj0 := u, lChkObj0)}, oDialogPvt, nObjLargu, nObjAltur, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , lDimPixels)
 
        //objeto1 - usando a classe TCheckBox
        nObjLinha := 25
        nObjColun := 7
        nObjLargu := 110
        nObjAltur := 15
        oChkObj1  := TCheckBox():New(nObjLinha, nObjColun, cChkObj1, {|u| Iif(PCount() > 0 , lChkObj1 := u, lChkObj1)}, oDialogPvt, nObjLargu, nObjAltur, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , lDimPixels)
 
        //objeto2 - usando a classe TCheckBox
        nObjLinha := 45
        nObjColun := 7
        nObjLargu := 110
        nObjAltur := 15
        oChkObj2  := TCheckBox():New(nObjLinha, nObjColun, cChkObj2, {|u| Iif(PCount() > 0 , lChkObj2 := u, lChkObj2)}, oDialogPvt, nObjLargu, nObjAltur, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , lDimPixels)
        //oChkObj2:lActive := .F.
 
        //objeto3 - usando a classe TButton
        nObjLinha := 70
        nObjColun := 7
        nObjLargu := 110
        nObjAltur := 15
        oBtnObj3  := TButton():New(nObjLinha, nObjColun, cBtnObj3, oDialogPvt, bBtnObj3, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)


    //Ativa e exibe a janela
    oDialogPvt:Activate(, , , lCentraliz, , , bBlocoIni)
     
    FWRestArea(aArea)
    SB1->B1_XPERTEN := lRetorno
    lRet := .T.
Return(lRetorno)


 