#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function PCPM062(cOp,cProduto)
    Local cArea := FwGetArea()
    Local oDlg  as Object
    Local oSay  as Object
    Local oBtOk as Object
    Local oGet  as Object


    Local nJanAltu  := GETMV("ES_ALTJAN")
	Local nJanLarg  := GETMV("ES_LARGJAN")
	Local nJanMeio := ((nJanLarg)/2)/2
	Local nTamBtn  := 048

    Local cTextHtml := ""
	Local lHtml := .T.
	Local bGrava  as block

    bGrava  := {|| FGrava(cOp,cProd,cOper,cRecurso,cTipo),oDlg:End() } 



    FwRestArea(cArea)
Return
