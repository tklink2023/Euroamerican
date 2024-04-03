//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define NMINLIN	    030
#Define NMINCOL	    020
#Define NMAXLIN   	820
#Define NMAXCOL   	580
#Define QBRXLIN   	745
 
#Define NCOLN01     080
#Define NCOLN05     125 
#Define NCOLN02     210
#Define NCOLN03     310
#Define NCOLN04     410 
#Define NCOLBOX     100 

#Define NCOLSEQ     045 
#Define NCOL501     115
#Define NCOL502     320 
#Define NCOL503     380
#Define NCOL504     450

//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)

/*/{Protheus.doc} PCPR173
description Impressao Grafica da Nova Ordem de Produção
@type function User
@version 1.0
@author Paulo Lenzi
@since 12/03/2024
@return variant, return_description
/*/
User Function PCPR173()
    Local aArea    := GetArea()
    Local aSays    := {}
    Local aButtons := {}
    Local cPerg    := "QEOP001"
    Local lOk          := .F.
    //Variáveis auxiliares
    Private dDataGer  := Date()
    Private cHoraGer  := Time()
    Private nLargura  := 0
    Private nAltura   := 0
    Private nTamLinha := 0
    Private nTamPag   := 0
    Private nFactorH  := 0
    Private nFactorV  := 0
    Private OpInicial := OpFinal := ""
    Private nPrimaLin := 0
    Private nSegunLin := 0
    Private lPrimalin := .T.
    Private lPr50     := .F.
    Private nLinQbr   := 0
    Private cAlias  := 'Qry' + getNextAlias()
    // Objectos da Impressao
    Private oPrn as object
    Private oBrush      := TBrush():New(,CLR_BLUE,,)
	Private oBrusCin    := TBrush():New(,CLR_HGRAY,,)
    // Fontes
    Private oFont06  := TFont():New( "Courier New",, 06,,.F.)
	Private oFont07n := TFont():New( "Arial",, 07,,.T.)
	Private oFont07  := TFont():New( "Arial",, 07,,.F.)
	Private oFont08n := TFont():New( "Arial",, 08,,.T.)
	Private oFont08  := TFont():New( "Arial",, 08,,.F.)
	Private oFont09  := TFont():New( "Arial",, 09,,.F.)
	Private oFont09n := TFont():New( "Arial",, 09,,.T.)
	Private oFont10n := TFont():New( "Arial",, 10,,.T.)
	Private oFont10  := TFont():New( "Arial",, 10,,.F.)
	Private oFont12n := TFont():New( "Arial",, 12,,.T.)
	Private oFont12  := TFont():New( "Arial",, 12,,.F.)
	Private oFont14n := TFont():New( "Arial",, 14,,.T.)
	Private oFont14  := TFont():New( "Arial",, 14,,.F.)
	Private oFont16n := TFont():New( "Arial",, 16,,.T.)
	Private oFont16  := TFont():New( "Arial",, 16,,.F.)
	Private oFontC7n := TFont():New( "Courier New",, 08,,.T.)
	Private oFontC7  := TFont():New( "Courier New",, 08,,.F.)
	Private oFontCAn := TFont():New( "Courier New",, 16,,.T.)
	Private oFontC10n:= TFont():New( "Courier New",, 10,,.T.)
    // Parametros 
    aAdd(aSays, "Esse programa tem como objetivo gerar")
    aAdd(aSays, "uma impressao da Ordem de Producao.")
    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )
    FormBatch("Gerar Ordem de Producao", aSays, aButtons)

    If lOk
        OpInicial := MV_PAR01
        OpFinal   := MV_PAR02
        Processa({|| fMontaOP()}, "Impressao da Ordem de Producao...")
    EndIf  

    RestArea(aArea)
Return
 
/*/{Protheus.doc} fMontaOP
description Rotina para iniciar a impressao da OP
@type function
@version 1.0
@author Paulo Lenzi
@since 12/03/2024
@return variant, return_description
/*/
 Static Function fMontaOP()
    Local cArea := FwGetArea()
    Local cPatch:= GetTempPath()
    Local cTable:= "OP_Print_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')
    lOCAL lPrima := .T.
    Local nLinha := 0
    Local cQuery  as character 
    Local cOperacao := " "
  
    lAdjustToLegacy := .F. 
    lDisableSetup  := .T.

    oPrn:=FWMSPrinter():New(cTable, IMP_PDF, lAdjustToLegacy,cPatch, lDisableSetup, , @oPrn, "", , , , .T.)
    oPrn:SetResolution(72)
    oPrn:SetPortrait()
    oPrn:SetPaperSize(DMPAPER_A4)
    oPrn:SetMargin(60, 60, 60, 60) 
    oPrn:cPathPDF := cPatch 
    
    nLargura  := OPRN:NPAGEHEIGHT
    nAltura   := OPRN:NPAGEWIDTH
    nTamLinha := GPixel(45)
    nTamPag   := GPixel(65)
    nFactorH  := OPRN:NFACTORHOR
    nFactorV  := OPRN:NFACTORVERT

    cQuery:="Select DISTINCT "+CRLF
    cQuery+="		C2_FILIAL , C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO,C2_QUANT, C2_UM, C2_REVISAO,C2_ORDSEP,D4_TRT,D4_COD, D4_QTDEORI,G2_OPERAC, G2_DESCRI,Z0_SEQINI,Z0_SEQFIN,B1_REVATU "+CRLF
    cQuery+="       ,ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'Envase Manual') INSTRUCAO "+CRLF
    cQuery+="From " + RetSqlName("SC2") + " SC2 "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C2_PRODUTO AND B1_MSBLQL = '2' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SD4") + " SD4 ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND SD4.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SG2") + " SG2 ON G2_FILIAL = C2_FILIAL AND G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SH1") + " SH1 ON H1_CODIGO = G2_RECURSO AND SH1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SHB") + " SHB ON HB_COD = G2_CTRAB  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SZ0") + " SZ0 ON Z0_PRODUTO = G2_PRODUTO AND  Z0_OPERAC = G2_OPERAC AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="Where SC2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="AND C2_FILIAL = '0803' "+CRLF
    cQuery+="AND C2_NUM+C2_ITEM+C2_SEQUEN  BETWEEN '"+OpInicial+"' and '"+OpFinal+"' "+CRLF
    cQuery+="AND G2_OPERAC IN ('20', '30','40','50') "+CRLF
    cQuery+="AND D4_TRT BETWEEN Z0_SEQINI AND Z0_SEQFIN "+CRLF
    cQuery+="ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, G2_OPERAC,D4_TRT  "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      MsAlert("Nao tem dados para imprimir",'ATENCAO')
      (cAlias)->(DbCloseArea())   
      FwRestArea(cArea)                          
      Return        
   endif

   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())

         if lPrima
            IF ExistBlock("PrtCabecOP")
               aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
              nLinha:= ExecBlock("PrtCabecOP",.F.,.F.,aParam2)
            Endif
            lPrima := .F.
         Endif

         IF nLinha >= QBRXLIN
            if !lPrimalin
                //oPrn:Line( nSegunLin, NCOLN01, nLinha, NCOLN01)    
                //oPrn:Line( nSegunLin, NCOLN02, nLinha, NCOLN02)    
                //oPrn:Line( nSegunLin, NCOLN03, nLinha, NCOLN03)    
                //oPrn:Line( nSegunLin, NCOLN04, nLinha, NCOLN04) 
                //oPrn:Line( nSegunLin, NCOLN05, nLinha, NCOLN05)     
            Endif         
            IF ExistBlock("PrtCabecOP")
               aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
               ExecBlock("PrtCabecOP",.F.,.F.,aParam2)
            Endif
            oPrn:EndPage()
			oPrn:StartPage()

         Endif

         IF (cAlias)->G2_OPERAC <>  cOperacao
            IF ExistBlock("FQuebraImp")
               aParam2 := {(cAlias)->G2_OPERAC,(cAlias)->G2_DESCRI,(cAlias)->Z0_SEQINI,(cAlias)->Z0_SEQFIN,nLinha,cOperacao,(cAlias)->INSTRUCAO}
               nLinha :=  ExecBlock("FQuebraImp",.F.,.F.,aParam2)
            Endif
            cOperacao := (cAlias)->G2_OPERAC
          Endif

        IF (cAlias)->G2_OPERAC == '50'
                nLinha := nLinha + 10
                
                oPrn:say(nLinha, NMINCOL+10,Transform((cAlias)->C2_ITEM,"@R 99"),oFont07n,,CLR_BLACK)   
                oPrn:say(nLinha, NCOLSEQ+05, (cAlias)->D4_TRT,oFont07n,,CLR_BLACK) 
                oPrn:say(nLinha, NCOLSEQ+20, (cAlias)->D4_COD,oFont07n,,CLR_BLACK) 
                oPrn:say(nLinha, NCOL501+05, Posicione("SB1",1,xFilial("SB1")+(cAlias)->D4_COD,"B1_DESC"),oFont07n,,CLR_BLACK)      
                   
                oPrn:say(nLinha, NCOL502+05,Transform((cAlias)->D4_QTDEORI,"@E 9999999.99"),oFont07n,,CLR_BLACK) 
                lPr50 := .T.
           
        ELSE
                nLinha := nLinha + 10
                nLargCol := GetTextWidth(oFont07, (cAlias)->D4_TRT)
                oPrn:say(nLinha, NMINCOL+10, (cAlias)->D4_TRT,oFont07n,,CLR_BLACK)   
                oPrn:say(nLinha, NMINCOL+nLargCol+5, (cAlias)->D4_COD,oFont07n,,CLR_BLACK)           
                oPrn:say(nLinha, NMINCOL+65,Transform((cAlias)->D4_QTDEORI,"@E 9999999.99"),oFont07n,,CLR_BLACK) 
         ENDIF
         nLinha := nLinha + 10
         oPrn:Line( nLinha, NMINCOL, nLinha, nTamLinha,,"-4")

        (cAlias)->( dbSkip() )

   EndDo  

   if !lPrimalin
        if lPr50
            oPrn:Line( nSegunLin, NCOLSEQ, nLinha, NCOLSEQ) 
            oPrn:Line( nSegunLin, NCOL501, nLinha, NCOL501)    
            oPrn:Line( nSegunLin, NCOL502, nLinha, NCOL502) 
            oPrn:Line( nSegunLin, NCOL503, nLinha, NCOL503)    
            oPrn:Line( nSegunLin, NCOL504, nLinha, NCOL504)  
        else
            oPrn:Line( nSegunLin, NCOLN01, nLinha, NCOLN01)    
            oPrn:Line( nSegunLin, NCOLN02, nLinha, NCOLN02)    
            oPrn:Line( nSegunLin, NCOLN03, nLinha, NCOLN03)    
            oPrn:Line( nSegunLin, NCOLN04, nLinha, NCOLN04) 
            oPrn:Line( nSegunLin, NCOLN05, nLinha, NCOLN05)     
       endif
   Endif

   IF nLinha >= QBRXLIN
      IF ExistBlock("PrtCabecOP")
        aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
        nLinha:= ExecBlock("PrtCabecOP",.F.,.F.,aParam2)
      Endif
      nLinha := nLinha + 10
      oPrn:Line( nLinha, NMINCOL, nLinha, nTamLinha)  
      nLinha := nLinha + 10
    Endif

    Fassinatura(nLinha)
  
    oPrn:EndPage()
    oPrn:Preview()
    (calias)->(DbCloseArea()) 

    FwRestArea(cArea)
 Return


/*/{Protheus.doc} PrtCabecOP
description
@type function
@version 1.0
@author Paulo Lenzi
@since 12/03/2024
@return variant, return_description
/*/
User Function PrtCabecOP()
    Local cTxtCabec     := "ORDEM DE PRODUCAO"

    Local nLintopCabec  := NMINLIN
    Local nColtopCabec  := NMINCOL
    Local nlinbtCabec   := nTamPag+80
    Local nColBtCabec   := nTamLinha
    Local CFilOrig      := PARAMIXB[1]
    Local cNumOP        := PARAMIXB[2]
    Local cItem         := PARAMIXB[3]
    Local cSequen       := PARAMIXB[4]
    Local cProduto      := PARAMIXB[5]
    Local cOpsepara     := PARAMIXB[6]
    Local cQuant        := PARAMIXB[7]
    Local cUM           := PARAMIXB[8]
    Local cRevisao      := PARAMIXB[9]
   
    Local cDescr        := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
    Local LogoCabec     := IIF(CFilOrig='0200',"logoeuro.bmp","logoqualy.bmp")

    oPrn:StartPage()
    oPrn:Box(nLintopCabec,nColtopCabec,nlinbtCabec,nColBtCabec)

    nLintopCabec := nLintopCabec + 10
    oPrn:SayBitmap(nLintopCabec ,nColtopCabec+10,GetSrvProfString("Startpath","")+LogoCabec,55,17)
    oPrn:SayAlign(nLintopCabec  ,nColtopCabec+50, cTxtCabec, oFont12n, 240, 20, COR_CINZA, PAD_CENTER, 0)    

    nLintopCabec := nLintopCabec + 35
    oPrn:Say(nLintopCabec,nColtopCabec+05,"LOTE:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,cNumOP+cItem+cSequen,oFont07,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+155,"ORDEM SEP:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+200,cOpsepara,oFont07,,CLR_BLACK) 

    nLintopCabec := nLintopCabec + 10
    oPrn:Say(nLintopCabec,nColtopCabec+05,"PRODUTO:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,cProduto+" "+cDescr,oFont07,,CLR_BLACK) 
       
    nLintopCabec := nLintopCabec + 10
    oPrn:Say(nLintopCabec,nColtopCabec+05,"QTDE PREV:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,Transform(cQuant,"@E 999999.999999"),oFont07,,CLR_BLACK)     
    oPrn:Say(nLintopCabec,nColtopCabec+155,cUM,oFont07,,CLR_BLACK)  
    oPrn:Say(nLintopCabec,nColtopCabec+230,"QTDE REAL: _____________________",oFont07n,,CLR_BLACK)  
    oPrn:Say(nLintopCabec+5,nColtopCabec+480,"Rev:"+cRevisao,oFont07n,,CLR_BLACK) 

    Quadro02()

Return(nLintopCabec)

/*/{Protheus.doc} Quadro02
description
@type function
@version 1.0
@author Paulo Lenzi
@since 01/04/2024
@return variant, return_description
/*/
Static Function Quadro02()
    Local nLintopCabec  := NMINLIN
    Local nColtopCabec  := NMINCOL
    Local nColBtCabec   := nTamLinha
    Local nColAjuste    := 0
    Local cDtExt        := "DATA:             /                 /      "    
    // Quadro menor do cabeçalho
    oPrn:Box(nLintopCabec+10,nColtopCabec+350,nLintopCabec+065,nColBtCabec-10)
    oPrn:Say(nLintopCabec+20,nColtopCabec+395,"PMP QUALYVINIL",oFont07n,,CLR_BLACK)
    oPrn:Say(nLintopCabec+30,nColtopCabec+355,"    EQUIPAMENTO           SEQUÊNCIA",oFont06,,CLR_BLACK)
    oPrn:say(nLintopCabec+60, nColtopCabec+355, cDtExt,oFont07n,,CLR_BLACK)   

    oPrn:Line(nLintopCabec+25,nColtopCabec+350, nLintopCabec+25, nColBtCabec-10)
    oPrn:Line(nLintopCabec+35,nColtopCabec+350, nLintopCabec+35, nColBtCabec-10)
    oPrn:Line(nLintopCabec+50,nColtopCabec+350, nLintopCabec+50, nColBtCabec-10)

    nColAjuste := nColtopCabec + 420
    oPrn:Line(nLintopCabec+25,nColAjuste,nLintopCabec+50,nColAjuste)

Return


/*/{Protheus.doc} GPixel
description
@type function
@version 1.0
@author Paulo Lenzi
@since 12/03/2024
@param _nMm, variant, param_description
@return variant, return_description
/*/
Static Function GPixel(_nMm)
_nRet:=(_nMm/25.4)*300
Return(_nRet)

/*/{Protheus.doc} FQuebraImp
description
@type function
@version 1.0
@author Paulo Lenzi
@since 01/04/2024
@return variant, return_description
/*/
User Function  FQuebraImp()
       Local cOper         := PARAMIXB[1]
       Local cDescr        := PARAMIXB[2]
       Local cInicial      := PARAMIXB[3]
       Local cFinal        := PARAMIXB[4]
       Local nLintopCabec  := PARAMIXB[5] 
       Local cOperacao     := PARAMIXB[6]
       Local cInstrucao    := PARAMIXB[7]       
       Local nColtopCabec  := NMINCOL
       Local nColBtCabec   := nTamLinha
       Local nQtdLin       := 4
       Local ab
       Local nTamInstru    := Len(Alltrim(cInstrucao))
       Local cInstr1       := ' '
       Local cInstr2       := ' '
      
      

       IF nTamInstru >= 122
          cInstr1 := Substr(cInstrucao,1,at(".",cInstrucao) )
          cInstr2 := Substr(cInstrucao,at(".",cInstrucao)+1,100 )
       Endif
     
       if Empty(cOperacao)
            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)                 
       else 
            if lPrimaLin
                for ab:=1 to nQtdLin
                        nLintopCabec := nLintopCabec + 20
                        oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
                Next  
            Endif
        Endif

        if cOper = '50'

            oPrn:Line( nSegunLin, NCOLN01, nLintopCabec, NCOLN01)    
            oPrn:Line( nSegunLin, NCOLN02, nLintopCabec, NCOLN02)    
            oPrn:Line( nSegunLin, NCOLN03, nLintopCabec, NCOLN03)    
            oPrn:Line( nSegunLin, NCOLN04, nLintopCabec, NCOLN04) 
            oPrn:Line( nSegunLin, NCOLN05, nLintopCabec, NCOLN05)   

            IF ExistBlock("PrtCabecOP")
                aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
                nLintopCabec:= ExecBlock("PrtCabecOP",.F.,.F.,aParam2)
            Endif
            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, NMINCOL, nLintopCabec, nTamLinha)  
            nLintopCabec := nLintopCabec + 10
        endif

        nLintopCabec := nLintopCabec + 10
        oPrn:say(nLintopCabec, nColtopCabec+50,  cOper       ,oFont07,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+80,  cDescr      ,oFont07,,CLR_BLACK)  
        IF nTamInstru < 122
                    oPrn:say(nLintopCabec, nColtopCabec+150, cInstrucao  ,oFont07,,CLR_BLACK) 
                    oPrn:say(nLintopCabec, nColtopCabec+380, "Seq Inical ",oFont07,,CLR_BLACK)  
                    oPrn:say(nLintopCabec, nColtopCabec+410, transform(cInicial,"@E 999"),oFont07,,CLR_BLACK)  
                    oPrn:say(nLintopCabec, nColtopCabec+450, "Seq Final ",oFont07,,CLR_BLACK)  
                    oPrn:say(nLintopCabec, nColtopCabec+480, transform(cFinal,"@E 999"),oFont07,,CLR_BLACK)  
        else
                oPrn:say(nLintopCabec, nColtopCabec+150, cInstr1  ,oFont07,,CLR_BLACK) 
                oPrn:say(nLintopCabec, nColtopCabec+380, "Seq Inical ",oFont07,,CLR_BLACK)  
                oPrn:say(nLintopCabec, nColtopCabec+410, transform(cInicial,"@E 999"),oFont07,,CLR_BLACK)  
                oPrn:say(nLintopCabec, nColtopCabec+450, "Seq Final ",oFont07,,CLR_BLACK)  
                oPrn:say(nLintopCabec, nColtopCabec+480, transform(cFinal,"@E 999"),oFont07,,CLR_BLACK)  
                nLintopCabec := nLintopCabec + 10
                oPrn:say(nLintopCabec, nColtopCabec+150, cInstr2  ,oFont07,,CLR_BLACK) 
        Endif      


       nLintopCabec := nLintopCabec + 10
       
       oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)    

       if Empty(cOperacao)
            nPrimaLin := nLintopCabec
            nLintopCabec := nLintopCabec + 10
            oPrn:say(nLintopCabec, NMINCOL+5    , "TRT"         ,oFont07n,,CLR_BLACK)  
            oPrn:say(nLintopCabec, NMINCOL+23   , "CODIGO"      ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NMINCOL+65   , "FORMULA"     ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+120  , "ALTERACAO LAB",oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+220  , "PRODUCAO"    ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+330  , "LOTE"        ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+400  , "EXTRA FORMULA",oFont07n,,CLR_BLACK)   

            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
       else
         
         if lPrimaLin .and. cOper <> '050'
             oPrn:Line( nPrimaLin, NCOLN01, nLintopCabec-20, NCOLN01) 
             oPrn:Line( nPrimaLin, NCOLN02, nLintopCabec-20, NCOLN02)  
             oPrn:Line( nPrimaLin, NCOLN03, nLintopCabec-20, NCOLN03)  
             oPrn:Line( nPrimaLin, NCOLN04, nLintopCabec-20, NCOLN04) 
             oPrn:Line( nPrimaLin, NCOLN05, nLintopCabec-20, NCOLN05)   
             nLinQbr := nLintopCabec             
             lPrimaLin := .F.  
         Endif

         nSegunLin := nLintopCabec 
        if cOper = '50'
            nLintopCabec := nLintopCabec + 10
            oPrn:say(nLintopCabec, NMINCOL+05   , "SEQ"         ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOLSEQ+05   , "TRT"         ,oFont07n,,CLR_BLACK)  
            oPrn:say(nLintopCabec, NCOLSEQ+20   , "CODIGO"      ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL501+05   , "DESCRICAO"   ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL502+05   , "QTDE PREV."  ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL503+05   , "LOTE"        ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NCOL504+05   , "QTDE REAL"   ,oFont07n,,CLR_BLACK) 
            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)         
        else
            nPrimaLin := nLintopCabec
            nLintopCabec := nLintopCabec + 10
            oPrn:say(nLintopCabec, NMINCOL+5    , "TRT"         ,oFont07n,,CLR_BLACK)  
            oPrn:say(nLintopCabec, NMINCOL+23   , "CODIGO"      ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NMINCOL+65   , "FORMULA"     ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+120  , "ALTERACAO LAB",oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+220  , "PRODUCAO"    ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+330  , "LOTE"        ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NMINCOL+400  , "EXTRA FORMULA",oFont07n,,CLR_BLACK)   

            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
        Endif               
                   
        Endif      

      
Return(nLintopCabec)

/*/{Protheus.doc} Fassinatura
description
@type function
@version 1.0
@author Paulo Lenzi
@since 01/04/2024
@param nLinha, numeric, param_description
@return variant, return_description
/*/
Static Function Fassinatura(nLinha)
    Local nPrLin := nLinha + 10
     nLinha := nPrLin
     oPrn:Box(nLinha,NCOLBOX,nLinha+100,nTamLinha-10)

     nLinha := nLinha + 10 
     oPrn:say(nLinha, NMINCOL+5, "SEPARADOR: "  ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBOX+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLN03+5, "Data: "  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBOX, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "OPERADOR: "   ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBOX+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLN03+5, "Data: "  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBOX, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "COLORISTA: "  ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBOX+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLN03+5, "Data:"  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBOX, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "LIDER: "      ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBOX+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLN03+5, "Data:"  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBOX, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "OBSERVACAO: " ,oFont07n,,CLR_BLACK)  
     nLinha := nLinha + 10

     oPrn:Line( nPrLin, NCOLN03, nLinha-20, NCOLN03) 

Return


/*
SELECT QPJ_ITEM, QPJ_ENSAIO, QPJ_DUNMED,UPPER(QPJ_DESENS) ENSAIO,QPJ_LINF LIMINF,QPJ_LSUP LIMSUP, QPJ_TEXTO TEXTO, 
       CASE WHEN QP1_TIPO = 'C' THEN 'Calculado' ELSE 'Digitado' END TIPO, 
       QP1_QTDE, QP1_METODO 
FROM QPJ100 QPJ (NOLOCK) 
INNER JOIN QP1100 QP1 (NOLOCK) ON QP1_FILIAL = '08' AND QPJ_ENSAIO = QP1_ENSAIO AND QP1.D_E_L_E_T_ = ' ' 
WHERE QPJ_FILIAL = ' ' 
AND QPJ_PROD = '6300.001' 
AND QPJ.D_E_L_E_T_ = ' ' 
ORDER BY QPJ_PROD, QPJ_ITEM 

*/
