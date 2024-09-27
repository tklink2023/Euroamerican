#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

User Function PCPR064(cOrdem,cProduto)
    Local cArea := FwGetArea()
    Local oReport
    oReport	    := ReportDef()
    oReport:PrintDialog()
    FwRestArea(cArea)
Return

User Function PrnOpCabec()
    Local cArea         := FwGetArea()
    Local cNumOP        := PARAMIXB[1]
    Local cProduto      := PARAMIXB[2]

    Local cTxtCabec     := "CONTROLE DE TEMPOS DA ORDEM DE PRODUCAO"
    Local LogoCabec     := "lgmid08.png"
   
    Local nLintopCabec  := NMINLIN
    Local nColtopCabec  := NMINCOL
    Local nlinbtCabec   := nTamPag+75
    Local nColBtCabec   := nTamLinha

    oPrn:StartPage()
    oPrn:Box(nLintopCabec,nColtopCabec,nlinbtCabec,nColBtCabec)

    nLintopCabec := nLintopCabec + SpcPadrao
    oPrn:SayBitmap(nLintopCabec ,nColtopCabec+10,GetSrvProfString("Startpath","")+LogoCabec,55,17)
    oPrn:SayAlign(nLintopCabec  ,NCOLCAB1, cTxtCabec, oFont12n, 240, 20, CLR_BLACK, PAD_CENTER, 0)    
    nLintopCabec := nLintopCabec + SpcPadrao

    dbSelectArea("SZ7")
    SZ7->( dbSetOrder(1) )
    IF  SZ7->( dbSeek( xFilial("SZ7")+cNumOP+cProduto,.T. ))
        nLintopCabec := nLintopCabec + SpcPadrao
        oPrn:Say(nLintopCabec,nColtopCabec+05,"LOTE:",oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD1,SZ7->Z7_NUM,oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD2,SZ7->Z7_ITEM,oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD3,SZ7->Z7_SEQUEN,oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD4,DTOC(SZ7->Z7_EMISSAO),oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD5,DTOC(SZ7->Z7_DATPRI),oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD6,DTOC(SZ7->Z7_DATPRF),oFont07n,,CLR_BLACK) 
                
        nLintopCabec := nLintopCabec + SpcPadrao
        oPrn:Say(nLintopCabec,nColtopCabec+05,"PRODUTO:",oFont07n,,CLR_BLACK) 
        oPrn:Say(nLintopCabec,NCOLCABD1,cProduto,oFont07n,,CLR_BLACK)       
        oPrn:Say(nLintopCabec,NCOLCABD4,Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),oFont07n,,CLR_BLACK)

    ENDIF
   


    nLintopCabec := nLintopCabec + SpcPadrao
    oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
    nLintopCabec := nLintopCabec + SpcPadrao

    FwRestArea(cArea)
Return(nLintopCabec)



Static Function GPixel(_nMm)
_nRet:=(_nMm/25.4)*300
Return(_nRet)

