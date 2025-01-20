#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"
#DEFINE cTitulo   "Lançamentos de Programação PCP"

User Function PCPM110()
    Local aArea   := FwGetArea()

    Private oDlg
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

    DEFINE MSDIALOG oDlg TITLE "Geração das Ordens de Produção"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL

    Activate MsDialog oDlg Centered
    FwRestArea(aArea)
Return



//---------------------------------------------------------------------------------------------------------------------------------------//
// FINAL DO PROGRAMA
//---------------------------------------------------------------------------------------------------------------------------------------//


