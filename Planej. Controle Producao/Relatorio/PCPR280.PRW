#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

#Define NMINLIN	    030
#Define NMINCOL	    020
#Define NMAXLIN   	820
#Define NMAXCOL   	580
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)

#Define NQBLINHA     810
// Colunas para operacoes 20 / 40 
#Define NCOLN01     025
#Define NCOLN02     050
#Define NCOLN03     090


#Define NFAXN01     130
#Define NFAXN02     180
#Define NFAXN03     260
#Define NFAXN04     350
#Define NFAXN05     450

#Define NCOLBX1     100 
#Define NCOLBX2     310 
// Colunas para a Operação 50
#Define NCOLSEQ     045 
#Define NCOL501     115
#Define NCOL502     320 
#Define NCOL503     380
#Define NCOL504     450
// Colunas para Analise de Resutado
#Define NCOLES1     020
#Define NCOLES2     120
#Define NCOLES3     200
#Define NCOLES4     260
#Define NCOLES5     320
#Define NCOLES6     380

/*/{Protheus.doc} PCPR280
description Programa de Impressão do novo layout de Ordem de Producao
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@return variant, return_description
/*/
User Function PCPR280(cOpenvio)
    Local cArea     := FwGetArea()
    Local aRet      := {}
    Local aPergs    := {}
    Local oSay      := Nil

    Local cNumOpDE    := Space(11)
    Local cNumOpATE    := Space(11)
    // Variaveis principais do relatorio
    Private nNumOpde  := Space(11)
    Private nNumOpate := Space(11)

    Private cArqPrn := "OP_Print_" + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-')
    Private cAlias  := 'Qry' + getNextAlias()
    Private oPrn as object
    Private nTamLinha := GPixel(45)
    Private nTamPag   := GPixel(65)
    Private aDados    := {}
    Private nLinQB    := 0
    Private lAssina   := .T.
    Private nPag      := 1
    Private lQuadro   := .T.
    Private lTpFolha  := "V"

    // Fontes para impressao grafica
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
    if !Empty(cOpenvio)
        cNumOpDE  := alltrim(cOpenvio)
        cNumOpATE := alltrim(cOpenvio)
    Endif

    aAdd( aPergs ,{1,"Numero da OP de"		, cNumOpde   		, ,'.T.',"SC2"   	,'.T.'	,50, .T.})
    aAdd( aPergs ,{1,"Numero da OP ate"		, cNumOpate   		, ,'.T.',"SC2"   	,'.T.'	,50, .T.})

	If ParamBox(aPergs ,"Parametros do Relatorio",aRet)     
		nNumOpde  := aRet[1]
        nNumOpate := aRet[2]
        FWMsgRun(, {|oSay| ExecRun(oSay) }, "Processando", "Buscando informações")
	Else
		MsgAlert("Encerrado")
        FwRestArea(cArea)
		Return
	EndIf
    FwRestArea(cArea)
Return

/*/{Protheus.doc} ExecRun
description Rotina de execução da Query
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@param oSay, object, param_description
@return variant, return_description
/*/
Static Function ExecRun(oSay)
    Local cQuery  as character 
    Local cPatch        := GetTempPath()
    Local nLinha        := 10
    Local cNumeroOP     := ""
    Local cNumSC2       := ""
    Local TipoRecurso   := ""
    Local cTpRecursos   := GETMV("ES_TPRECUR")
    Local lAnalisy      := .F.


    cQuery:="Select DISTINCT "+CRLF
    cQuery+="		C2_FILIAL , C2_NUM, C2_ITEM, C2_SEQUEN, C2_PRODUTO,C2_QUANT, C2_UM, C2_REVISAO,C2_ORDSEP,D4_TRT,D4_COD, D4_QTDEORI,G2_OPERAC, G2_DESCRI,ISNULL(Z0_SEQINI,0) AS Z0_SEQINI,ISNULL(Z0_SEQFIN,999)  AS Z0_SEQFIN,B1_REVATU "+CRLF
    cQuery+="       ,ISNULL(RTRIM(LTRIM(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),Z0_DESCRIC)))),'Envase Manual') INSTRUCAO "+CRLF
    cQuery+="From " + RetSqlName("SC2") + " SC2 "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = C2_PRODUTO AND B1_MSBLQL = '2' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SD4") + " SD4 ON D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND SD4.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SG2") + " SG2 ON G2_FILIAL = C2_FILIAL AND G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SH1") + " SH1 ON H1_CODIGO = G2_RECURSO AND SH1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="INNER JOIN " + RetSqlName("SHB") + " SHB ON HB_COD = G2_CTRAB  AND SH1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="LEFT JOIN  " + RetSqlName("SZ0") + " SZ0 ON Z0_PRODUTO = G2_PRODUTO AND  Z0_OPERAC = G2_OPERAC AND SZ0.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="Where SC2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery+="AND C2_FILIAL = '0803' "+CRLF
    cQuery+="AND C2_NUM+C2_ITEM+C2_SEQUEN  BETWEEN '"+nNumOpDE+"' AND  '"+nNumOpATE+"' "+CRLF
    cQuery+="AND D4_TRT BETWEEN ISNULL(Z0_SEQINI,0) AND ISNULL(Z0_SEQFIN,999) "+CRLF
    cQuery+="ORDER BY C2_NUM, C2_ITEM, C2_SEQUEN, G2_OPERAC,D4_TRT  "+CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    IF (cAlias)->(Eof())
      MsgAlert("Nao tem dados para imprimir",'ATENCAO')
      (cAlias)->(DbCloseArea())   
      Return        
    endif    


    lAdjustToLegacy := .F. 
    lDisableSetup  := .T.

    oPrn:=FWMSPrinter():New(cArqPrn, IMP_PDF, lAdjustToLegacy,cPatch, lDisableSetup, , @oPrn, "", , , , .T.)
    oPrn:SetResolution(72)
    oPrn:SetPortrait()
    oPrn:SetPaperSize(DMPAPER_A4)
    oPrn:SetMargin(60, 60, 60, 60) 
    oPrn:cPathPDF := cPatch 

    dbselectArea(cAlias)
    (cAlias)->( dbGoTop() )
    While (cAlias)->( !Eof())
        // Não imprimir o primeiro item da primeira sequencia
      
         IF (cAlias)->G2_OPERAC = '10'
               (cAlias)->( dbSkip() )
               Loop
         ENDIF
        // Ponto para Quebra de Linhas
        IF NQBLINHA <= nLinha
            ImpColunas(TipoRecurso,nlinha-10)
            if ExistBlock("PrnCabec")
                 aDados := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
                aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
                nLinha:= ExecBlock("PrnCabec",.F.,.F.,aParam2)   
           Endif
           nLinQB := nLinha 
           if ExistBlock("PrnOperac")
              aParam3 := {(cAlias)->G2_OPERAC,(cAlias)->G2_DESCRI,(cAlias)->Z0_SEQINI,(cAlias)->Z0_SEQFIN,(cAlias)->INSTRUCAO,nLinha}
              nLinha:= ExecBlock("PrnOperac",.F.,.F.,aParam3)  
           Endif
        Endif

        // Ponto de Quebra quando é outra Ordem de Produção
        if cNumeroOP <> (cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN

           // Imprime as linha de colunas
           if !Empty(cNumeroOP)      
                 nLinha:=FGeraLinhas(nLinha)
                 ImpColunas(TipoRecurso,nlinha-10)
           Endif
            // Imprime o quadro de assinaturas
            if !Empty(TipoRecurso) .and. TipoRecurso $ cTpRecursos
                  if lAssina
                       Fassinatura(nLinha)
                       lAssina := .F. 
                   ENDIF
            endif
            // Imprime o quadro de Resumo de analises 
           if !Empty(TipoRecurso) .and. TipoRecurso $ cTpRecursos
            IF ExistBlock("Analisy")
                ExecBlock("Analisy",.F.,.F.,aDados)
                lAnalisy := .T.
            Endif
           Endif

           IF (cAlias)->C2_NUM <> cNumSC2
              if !Empty(cNumSC2)
                 lAssina:= .T.
                 if !Empty(TipoRecurso) .and. TipoRecurso $ cTpRecursos
                        if lAssina
                            Fassinatura(nLinha)
                            lAssina := .F. 
                        ENDIF
                 endif
  				 oPrn:EndPage()
                 IF lTpFolha = "F"
                     oPrn:StartPage()
                     lTpFolha := "V"
                 ENDIF
                 nPag := 1
              endif
           Endif

           // Imprime o Cabecalho
           if ExistBlock("PrnCabec")
                    aParam2 := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
                    nLinha:= ExecBlock("PrnCabec",.F.,.F.,aParam2)          
                   TipoRecurso:= ""         
           Endif  

           cNumeroOP := (cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN
           cNumSc2   := (cAlias)->C2_NUM

        Endif

        // Quebra por tipo de operacao
        if TipoRecurso <> (cAlias)->G2_OPERAC
           If !Empty(cNumeroOP)      
                 ImpColunas(TipoRecurso,nlinha-10)
           Endif
           // imprime descricao do tipo de operacao
           if ExistBlock("PrnOperac")
              aParam3 := {(cAlias)->G2_OPERAC,(cAlias)->G2_DESCRI,(cAlias)->Z0_SEQINI,(cAlias)->Z0_SEQFIN,(cAlias)->INSTRUCAO,nLinha}
              nLinha:= ExecBlock("PrnOperac",.F.,.F.,aParam3)  
           Endif
           TipoRecurso := (cAlias)->G2_OPERAC
        Endif
   
        // Impressao dos detalhes
        if TipoRecurso $ cTpRecursos
            aDados := {(cAlias)->C2_FILIAL,(cAlias)->C2_NUM,(cAlias)->C2_ITEM,(cAlias)->C2_SEQUEN,(cAlias)->C2_PRODUTO,(cAlias)->C2_ORDSEP,(cAlias)->C2_QUANT,(cAlias)->C2_UM,(cAlias)->C2_REVISAO}
            oPrn:say(nLinha, NCOLN01, (cAlias)->D4_TRT,oFont09n,,CLR_BLACK)   
            oPrn:say(nLinha, NCOLN02, (cAlias)->D4_COD,oFont09n,,CLR_BLACK)           
            oPrn:say(nLinha, NFAXN01+5, Transform((cAlias)->D4_QTDEORI,"@E 9999999.99"),oFont09n,,CLR_BLACK) 
        endif
        if TipoRecurso $ "50"
            oPrn:say(nLinha, NMINCOL+10,Transform((cAlias)->C2_ITEM,"@R 99"),oFont09n,,CLR_BLACK)   
            oPrn:say(nLinha, NCOLSEQ+05, (cAlias)->D4_TRT,oFont09n,,CLR_BLACK) 
            oPrn:say(nLinha, NCOLSEQ+20, (cAlias)->D4_COD,oFont09n,,CLR_BLACK) 
            oPrn:say(nLinha, NCOL501+05, Posicione("SB1",1,xFilial("SB1")+(cAlias)->D4_COD,"B1_DESC"),oFont09n,,CLR_BLACK)                         
            oPrn:say(nLinha, NCOL502+05,Transform((cAlias)->D4_QTDEORI,"@E 9999999.99"),oFont09n,,CLR_BLACK) 
        endif
        
        nLinha := nLinha + 10
        oPrn:Line( nLinha, NMINCOL, nLinha, nTamLinha,,"-4")
        nLinha:= nLinha + 10

        (cAlias)->( dbSkip() )      
    EndDo
     // impressão das colunas
     nLinha:=FGeraLinhas(nLinha)
     ImpColunas(TipoRecurso,nlinha-10)
     
    // Impressao do quadro de Resumo de Analise
    if len(aDados) > 0 .AND. TipoRecurso $ cTpRecursos
        IF ExistBlock("Analisy")
           ExecBlock("Analisy",.F.,.F.,aDados)
        Endif
    endif

    oPrn:EndPage()
    oPrn:Preview()
    (calias)->(DbCloseArea()) 
Return

/*/{Protheus.doc} PrnCabec
description Rotina de impressao de Cabeçalho
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@return variant, return_description
/*/
User Function PrnCabec()
    Local CFilOrig      := PARAMIXB[1]
    Local cNumOP        := PARAMIXB[2]
    Local cItem         := PARAMIXB[3]
    Local cSequen       := PARAMIXB[4]
    Local cProduto      := PARAMIXB[5]
    Local cOpsepara     := PARAMIXB[6]
    Local cQuant        := PARAMIXB[7]
    Local cUM           := PARAMIXB[8]
    Local cRevisao      := PARAMIXB[9]

    Local cTxtCabec     := "ORDEM DE PRODUCAO"
    Local cDescr        := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
    Local LogoCabec     := IIF(CFilOrig='0200',"logoeuro.bmp","lgmid08.png")
   
    Local nLintopCabec  := NMINLIN
    Local nColtopCabec  := NMINCOL
    Local nlinbtCabec   := nTamPag+75
    Local nColBtCabec   := nTamLinha

    IF nPag = 1
       lQuadro := .T.
    ENDIF
    
    oPrn:StartPage()
    oPrn:Box(nLintopCabec,nColtopCabec,nlinbtCabec,nColBtCabec)

    nLintopCabec := nLintopCabec + 10
    oPrn:SayBitmap(nLintopCabec ,nColtopCabec+10,GetSrvProfString("Startpath","")+LogoCabec,55,17)
    if lQuadro
        oPrn:SayAlign(nLintopCabec  ,nColtopCabec+50, cTxtCabec, oFont12n, 240, 20, CLR_BLACK, PAD_CENTER, 0)    
    else
         oPrn:SayAlign(nLintopCabec  ,NCOLES2, cTxtCabec, oFont12n, 240, 20, CLR_BLACK, PAD_CENTER, 0)    
    endif        

    nLintopCabec := nLintopCabec + 35
    oPrn:Say(nLintopCabec,nColtopCabec+05,"LOTE:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,cNumOP+"."+cItem+"."+cSequen,oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+155,"ORDEM SEP:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+200,cOpsepara,oFont07n,,CLR_BLACK) 
    if lQuadro
            oPrn:Say(nLintopCabec,nColtopCabec+310,"Pag: "+Transform(nPag,"@R 999"),oFont07n,,CLR_BLACK) 
    else
            oPrn:Say(nLintopCabec,nColtopCabec+480,"Pag: "+Transform(nPag,"@R 999"),oFont07n,,CLR_BLACK) 
    endif            

    nLintopCabec := nLintopCabec + 10
    oPrn:Say(nLintopCabec,nColtopCabec+05,"PRODUTO:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,cProduto+" "+cDescr,oFont07n,,CLR_BLACK) 
       
    nLintopCabec := nLintopCabec + 10
    oPrn:Say(nLintopCabec,nColtopCabec+05,"QTDE PREV:",oFont07n,,CLR_BLACK) 
    oPrn:Say(nLintopCabec,nColtopCabec+55,Transform(cQuant,"@E 999999.99"),oFont07n,,CLR_BLACK)     
    oPrn:Say(nLintopCabec,nColtopCabec+155,cUM,oFont07,,CLR_BLACK)  
    oPrn:Say(nLintopCabec,nColtopCabec+230,"QTDE REAL: _____________________",oFont07n,,CLR_BLACK)  
    oPrn:Say(nLintopCabec+5,nColtopCabec+480,"Rev:"+cRevisao,oFont07n,,CLR_BLACK) 
    if lQuadro
        Quadro02()
        lQuadro := .F.
    endif   
    nLintopCabec := nLintopCabec + 10
    oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
    nLintopCabec := nLintopCabec + 10
    nPag := nPag + 1
    IF lTpFolha = "F"
       lTpFolha = "V"
    else
       lTpFolha = "F"
    ENDIF   
Return(nLintopCabec)

/*/{Protheus.doc} Quadro02
description Imprime o Quadro no Cabeçalho
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
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
description conversao para pixel
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@param _nMm, variant, param_description
@return variant, return_description
/*/
Static Function GPixel(_nMm)
_nRet:=(_nMm/25.4)*300
Return(_nRet)

/*/{Protheus.doc} PrnOperac
description Imprime linha de quebra para tipos de operação
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@return variant, return_description
/*/
User Function PrnOperac()
    Local cOper     := PARAMIXB[1]
    Local cDescr    := PARAMIXB[2]
    Local cSeqInicio:= PARAMIXB[3]
    Local cSeqFinal := PARAMIXB[4]
    Local cInstrucao:= PARAMIXB[5]
    Local nLintopCabec := PARAMIXB[6]
    Local QbTexto1  := ""
    Local QbTexto2  := ""
    Local nColtopCabec  := NMINCOL
    Local nColBtCabec   := nTamLinha
    Local cTpRecursos   := GETMV("ES_TPRECUR")

    if len(cInstrucao) >= 122
       QbTexto1 :=  Substr(cInstrucao,1,at(".",cInstrucao) )
       QbTexto2 :=  Substr(cInstrucao,at(".",cInstrucao)+1,100 )
    Endif

    oPrn:say(nLintopCabec, nColtopCabec+50,  cOper       ,oFont07n,,CLR_BLACK)  
    oPrn:say(nLintopCabec, nColtopCabec+80,  cDescr      ,oFont07n,,CLR_BLACK)  

    if Empty(QbTexto1)
        oPrn:say(nLintopCabec, nColtopCabec+150, cInstrucao  ,oFont07n,,CLR_BLACK) 
        oPrn:say(nLintopCabec, nColtopCabec+380, "Seq Inical ",oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+410, transform(cSeqInicio,"@E 999"),oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+450, "Seq Final ",oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+480, transform(cSeqFinal,"@E 999"),oFont07n,,CLR_BLACK)  
    else
        oPrn:say(nLintopCabec, nColtopCabec+150, QbTexto1  ,oFont07n,,CLR_BLACK) 
        oPrn:say(nLintopCabec, nColtopCabec+380, "Seq Inical ",oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+410, transform(cSeqInicio,"@E 999"),oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+450, "Seq Final ",oFont07n,,CLR_BLACK)  
        oPrn:say(nLintopCabec, nColtopCabec+480, transform(cSeqFinal,"@E 999"),oFont07n,,CLR_BLACK)  
        nLintopCabec := nLintopCabec + 10
        oPrn:say(nLintopCabec, nColtopCabec+150, QbTexto2  ,oFont07,,CLR_BLACK) 
    Endif

    nLintopCabec := nLintopCabec + 10
    nLinQB       := nLintopCabec
    oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
    nLintopCabec := nLintopCabec + 10    
    // Cabeçalhos das colunas
    IF cOper $ cTpRecursos

            oPrn:say(nLintopCabec, NMINCOL+5    ,"TRT"             ,oFont07n,,CLR_BLACK)  
            oPrn:say(nLintopCabec, NMINCOL+25   ,"Codigo"          ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NFAXN01+5    ,"Qtde Prev."      ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NFAXN02+10   ,"ALteração P&D"   ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NFAXN03+20   ,"Producao"        ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NFAXN04+40   ,"Lote"            ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NFAXN05+15   ,"Extra Formula"   ,oFont07n,,CLR_BLACK)              

            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)
            nLintopCabec := nLintopCabec + 10
    Endif
    if cOper = '50'
            oPrn:say(nLintopCabec, NMINCOL+05   , "SEQ"         ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOLSEQ+05   , "TRT"         ,oFont07n,,CLR_BLACK)  
            oPrn:say(nLintopCabec, NCOLSEQ+20   , "CODIGO"      ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL501+05   , "DESCRICAO"   ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL502+05   , "QTDE PREV."  ,oFont07n,,CLR_BLACK) 
            oPrn:say(nLintopCabec, NCOL503+05   , "LOTE"        ,oFont07n,,CLR_BLACK)   
            oPrn:say(nLintopCabec, NCOL504+05   , "QTDE REAL"   ,oFont07n,,CLR_BLACK) 
            nLintopCabec := nLintopCabec + 10
            oPrn:Line( nLintopCabec, nColtopCabec, nLintopCabec, nColBtCabec)    
            nLintopCabec := nLintopCabec + 10
    endif

Return(nLintopCabec)

/*/{Protheus.doc} Analisy
description 
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@return variant, return_description
/*/
User Function Analisy()
    Local CFilOrig      := PARAMIXB[1]
    Local cNumOP        := PARAMIXB[2]
    Local cItem         := PARAMIXB[3]
    Local cSequen       := PARAMIXB[4]
    Local cProduto      := PARAMIXB[5]
    Local cOpsepara     := PARAMIXB[6]
    Local cQuant        := PARAMIXB[7]
    Local cUM           := PARAMIXB[8]
    Local cRevisao      := PARAMIXB[9]    
    
    Local cQuery        := " "
    Local cLimite       := " "
    Local cEnsaio       := " "
    Local nLinInicio    := 0  
    Local nLinFinal     := 0
    Local cQtLinhas     := 3
    Local AB
    Local ctmp    := 'TMP' + getNextAlias()

    cQuery := "SELECT QPJ_ITEM, QPJ_ENSAIO, QPJ_DUNMED, " + CRLF
	cQuery += "       UPPER(QPJ_DESENS) ENSAIO,QPJ_LINF LIMINF, " + CRLF
	cQuery += "       QPJ_LSUP LIMSUP, QPJ_TEXTO TEXTO, " + CRLF
	cQuery += "       CASE WHEN QP1_TIPO = 'C' " + CRLF
	cQuery += "       THEN 'Calculado' ELSE 'Digitado' END TIPO, " + CRLF
	cQuery += "       QP1_QTDE, QP1_METODO " + CRLF
	cQuery += "FROM " + RetSqlName("QPJ") + " QPJ (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("QP1") + " QP1 (NOLOCK) " + CRLF
	cQuery += "	 ON QP1_FILIAL = '" + xFilial("QP1") + "' " + CRLF
	cQuery += "  AND QPJ_ENSAIO = QP1_ENSAIO " + CRLF
	cQuery += "  AND QP1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE QPJ_FILIAL = '" + xFilial("QPJ") + "' " + CRLF
	cQuery += "	AND QPJ_PROD = '" + cProduto + "' " + CRLF
	cQuery += "AND QPJ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY QPJ_PROD, QPJ_ITEM " + CRLF
    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .T., .T.)
 
   IF (cTmp)->(Eof())
      (cTmp)->(DbCloseArea())                           
      Return        
   endif

    IF ExistBlock("PrnCabec")
        aParam2 := {CFilOrig,cNumOP,cItem,cSequen,cProduto,cOpsepara,cQuant,cUM,cRevisao}
        nLin:= ExecBlock("PrnCabec",.F.,.F.,aParam2)
    Endif

    nLin := nLin + 10
    oPrn:say(nLin, NCOLES3+5  , "RESULTADOS DE ANALISE"        ,oFont07n,,CLR_BLACK)  
    nLin := nLin + 10
    oPrn:Line( nLin, NMINCOL, nLin, nTamLinha) 
    nLinInicio := nLin 
    nLin := nLin + 10

    oPrn:say(nLin, NCOLES1+5  , "Ensaios"        ,oFont07n,,CLR_BLACK)  
    oPrn:say(nLin, NCOLES2+5  , "Limites"        ,oFont07n,,CLR_BLACK) 
    oPrn:say(nLin, NCOLES3+5  , "1a. Amostra"    ,oFont07n,,CLR_BLACK)   
    oPrn:say(nLin, NCOLES4+5  , "2a. Amostra"    ,oFont07n,,CLR_BLACK)   
    oPrn:say(nLin, NCOLES5+5  , "3a. Amostra"    ,oFont07n,,CLR_BLACK)   
    oPrn:say(nLin, NCOLES6+5  , "Observacao LCQ" ,oFont07n,,CLR_BLACK)   
    nLin := nLin + 10
    oPrn:Line( nLin, NMINCOL, nLin, nTamLinha)  
    nLin := nLin + 10

   dbselectArea(cTmp)
   (cTmp)->( dbGoTop() )
   While (cTmp)->( !Eof())
       	cLimite := AllTrim(Transform( (cTmp)->LIMINF, PesqPict("QPJ","QPJ_LINF",14))) + " - " 
		cLimite += AllTrim(Transform( (cTmp)->LIMSUP, PesqPict("QPJ","QPJ_LSUP",14)))
		cLimite := Padl(cLimite, 15)

	    cEnsaio := Lower(AllTrim((cTmp)->ENSAIO))
		cEnsaio := Upper(Subs(cEnsaio, 1, 1)) + Subs(cEnsaio, 2, 50)
		cEnsaio := Padr(cEnsaio, 20)

        oPrn:say(nLin, NCOLES1+10,cEnsaio,oFont09n,,CLR_BLACK)   
        oPrn:say(nLin, NCOLES2+05, cLimite,oFont09n,,CLR_BLACK)   

        nLin := nLin+10
        oPrn:Line( nLin, NMINCOL, nLin, nTamLinha) 
        nLinFinal := nLin
        nLin := nLin+10
        (cTmp)->( DbSkip())
        
   End    

    FOR AB:=1 TO cQtLinhas    
        nLin := nLin+10
        oPrn:Line( nLin, NMINCOL, nLin, nTamLinha) 
        nLinFinal := nLin
        nLin := nLin+10
    NEXT
    
    oPrn:Line( nLinInicio, NCOLES1, nLin-10, NCOLES1) 
    oPrn:Line( nLinInicio, NCOLES2, nLin-10, NCOLES2)  
    oPrn:Line( nLinInicio, NCOLES3, nLin-10, NCOLES3)  
    oPrn:Line( nLinInicio, NCOLES4, nLin-10, NCOLES4) 
    oPrn:Line( nLinInicio, NCOLES5, nLin-10, NCOLES5)   
    oPrn:Line( nLinInicio, NCOLES6, nLin-10, NCOLES6)     
    Assinat02(nLinFinal)

Return
/*/{Protheus.doc} Assinat02
description
@type function
@version 1.0
@author Paulo Lenzi
@since 16/04/2024
@param nLinha, numeric, param_description
@return variant, return_description
/*/
Static Function Assinat02(nLinFinal)
     Local nLin := nLinFinal
     LOCAL cData1 := "Data Inicio:"
     LOCAL cData2 := "Data Final:"
     LOCAL cExtenso := "       /           /      "
     Local cAnalResp:= "Analista Resp:"
     Local cSuper := "Supervisor"
     nLin := nLin+10
     oPrn:say(nLin, NCOLES1+10,cData1,oFont09n,,CLR_BLACK) 
     oPrn:say(nLin, NCOLES2+10,cExtenso,oFont09n,,CLR_BLACK) 
     oPrn:say(nLin, NCOLES3+05,cAnalResp,oFont09n,,CLR_BLACK) 
     nLin := nLin+10
     oPrn:Line( nLin, NMINCOL, nLin, nTamLinha) 
     nLin := nLin+10
     oPrn:say(nLin, NCOLES1+10,cData2,oFont09n,,CLR_BLACK) 
     oPrn:say(nLin, NCOLES2+10,cExtenso,oFont09n,,CLR_BLACK) 
     oPrn:say(nLin, NCOLES3+05,cSuper,oFont09n,,CLR_BLACK) 
     nLin := nLin+10
     oPrn:Line( nLin, NMINCOL, nLin, nTamLinha)     
     oPrn:Line( nLinFinal, NCOLES2, nLin, NCOLES2) 
     oPrn:Line( nLinFinal, NCOLES3, nLin, NCOLES3)
     oPrn:Line( nLinFinal, NCOLES4, nLin, NCOLES4)
Return(nLin)

/*/{Protheus.doc} ImpColunas
description Impressao das colunas no formulario
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@param cOperacao, character, param_description
@param nLinha, numeric, param_description
@return variant, return_description
/*/
Static Function ImpColunas(cOperacao,nLinha)
       Local cTpRecursos   := GETMV("ES_TPRECUR")
       if cOperacao $ cTpRecursos
                    oPrn:Line( nLinQB, NFAXN01, nLinha, NFAXN01)    // TRT
                    oPrn:Line( nLinQB, NFAXN02, nLinha, NFAXN02)    // ALTERACAO
                    oPrn:Line( nLinQB, NFAXN03, nLinha, NFAXN03)    // PRODUCAO
                    oPrn:Line( nLinQB, NFAXN04, nLinha, NFAXN04)    // LOTE
                    oPrn:Line( nLinQB, NFAXN05, nLinha, NFAXN05)    // EXTRA
        endif
        if cOperacao $ '50'
                    oPrn:Line( nLinQB, NCOLSEQ, nLinha, NCOLSEQ) 
                    oPrn:Line( nLinQB, NCOL501, nLinha, NCOL501)    
                    oPrn:Line( nLinQB, NCOL502, nLinha, NCOL502) 
                    oPrn:Line( nLinQB, NCOL503, nLinha, NCOL503)    
                    oPrn:Line( nLinQB, NCOL504, nLinha, NCOL504)  
        endif 
Return

/*/{Protheus.doc} Fassinatura
description Impressao do Quadro de assinatura
@type function
@version 1.0
@author Paulo Lenzi
@since 12/04/2024
@param nLinha, numeric, param_description
@return variant, return_description
/*/
Static Function Fassinatura(nLinha)
    Local nPrLin := nLinha //+ 10

     nLinha := nPrLin
     oPrn:Box(nLinha,NCOLBX1,nLinha+100,nTamLinha-10)

     nLinha := nLinha + 10 
     oPrn:say(nLinha, NMINCOL+5, "SEPARADOR: "  ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBX1+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLBX2+5, "Data: "  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBX1, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "OPERADOR: "   ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBX1+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLBX2+5, "Data: "  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBX1, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "COLORISTA: "  ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBX1+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLBX2+5, "Data:"  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBX1, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "LIDER: "      ,oFont07n,,CLR_BLACK)  
     oPrn:say(nLinha, NCOLBX1+5, "Ass: "  ,oFont07n,,CLR_BLACK) 
     oPrn:say(nLinha, NCOLBX2+5, "Data:"  ,oFont07n,,CLR_BLACK) 
     nLinha := nLinha + 10
     oPrn:Line( nLinha, NCOLBX1, nLinha, nTamLinha-10,,"-4")

     nLinha := nLinha + 10
     oPrn:say(nLinha, NMINCOL+5, "OBSERVACAO: " ,oFont07n,,CLR_BLACK)  
     nLinha := nLinha + 10

     oPrn:Line( nPrLin, NCOLBX2, nLinha-20, NCOLBX2) 

Return
/*/{Protheus.doc} FGeraLinhas
description
@type function
@version 1.0
@author Paulo Lenzi
@since 16/04/2024
@param nLinhas, numeric, param_description
@return variant, return_description
/*/
Static Function FGeraLinhas(nLinhas)
  Local nQtLin := 3
  Local AB
  Local nLin := nLinhas

  FOR AB:=1 TO nQtLin
     nLin := nLin + 10
     oPrn:Line( nLin, NMINCOL, nLin, nTamLinha,,"-4")
     nLin := nLin + 10
   NEXT

Return(nLin)
// ==============================================================================================================================================//
// FIM - Paulo Lenzi - 12/04/2024 Programa PCPR280 - Novo LayOut para Ordem de Producao
//===============================================================================================================================================//
