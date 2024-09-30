#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

//--[ Posicao exata da pagina A4]
#Define nTopPage 30
#Define nIniCol 20
#Define nMaxLinha 820
#Define nMaxColuna 550

/*/{Protheus.doc} PCPAMB
description Rotina de impressao da Ficha de apontamento
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param cOrdem, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
User Function PCPAMB(cOrdem,cProduto)
   Local aDados := {}
   //Ambiente()

  if ExistBlock("PCPR064")
      aDados:= {cOrdem,cProduto}
      ExecBlock("PCPR064",.F.,.F.,aDados)   
   Endif

Return

User Function PCPR064()
    Local cArea  := FwGetArea()
    Local cPatch := GetTempPath()
    Local nLinha   := 0
    Local cOrdem   := PARAMIXB[1]
    Local cProduto := PARAMIXB[2]

    Private oPrn as object
    Private cArqPrn := "OP_Apo_" + dToS(Date()) + "_" + StrTran(Time(), ':', '-')
    Private nTamLinha := GPixel(45)
    Private nTamPag   := GPixel(65)

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

    Private oBrush1     := TBrush():New( , CLR_LIGHTGRAY)

    lAdjustToLegacy := .F. 
    lDisableSetup  := .T.

    oPrn:=FWMSPrinter():New(cArqPrn, IMP_PDF, lAdjustToLegacy,cPatch, lDisableSetup, , @oPrn, "", , , , .T.)
    oPrn:SetResolution(72)
    oPrn:SetPortrait()
    oPrn:SetPaperSize(DMPAPER_A4)
    oPrn:SetMargin(60, 60, 60, 60) 
    oPrn:cPathPDF := cPatch 
    //---[ Impressao do layout inicial da pagina]
    
    nLinha := PCP60Cabec(cOrdem,cProduto)
    nLinha := PCP64APO(nLinha+10,cOrdem,cProduto)   
    nLinha := PCP64STOP(nLinha+10,cOrdem,cProduto) 

    oPrn:EndPage()
    oPrn:Preview()

    FwRestArea(cArea)

Return

/*/{Protheus.doc} PCP60Cabec
description Cabeçalho da Ficha de apontamento
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param cOrdem, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function PCP60Cabec(cOrdem,cProduto)
    Local cArea  := FwGetArea()
    Local nCabTopPag := nTopPage
    Local nColTopPag := nIniCol
    Local cLogoEmp   := IIF(FwCodFil()='0200',"logoeuro.bmp","lgmid08.png")
    Local nLimite    := 0
    
    nCabTopPag := nCabTopPag + 10
    nColTopPag := nColTopPag + 10

    oPrn:StartPage()
    //--[ Borda da Pagina ]
    oPrn:Box(nTopPage,nIniCol,nMaxLinha,nMaxColuna)
    //--[ Logo da Empresa ]
    oPrn:SayBitmap(nCabTopPag ,nColTopPag,GetSrvProfString("Startpath","")+cLogoEmp,55,17)
    
    nCabTopPag := nCabTopPag + 10
    nColTopPag := nColTopPag + 100
    oPrn:Say(nCabTopPag,nColTopPag,FWEmpName("10")+" "+FWFilialName(),oFont16n,,CLR_BLACK) 

    //--[ Quadro dos dados da Ordem de Fabricacao]
    nCabTopPag := nCabTopPag + 10
    nLimite    := nCabTopPag + 80
    oPrn:Box(nCabTopPag,nIniCol,nLimite,nMaxColuna)

    nCabTopPag := nCabTopPag + 20

    dbSelectArea("SZ7")
    SZ7->( dbSetOrder(1))
    IF SZ7->( dbSeek( xFilial("SZ7")+ cOrdem + cProduto , .T. )) 
       oPrn:Say(nCabTopPag,nIniCol + 5,"Ordem Producao : "+SZ7->Z7_OP,oFont07,,CLR_BLACK) 
       oPrn:Say(nCabTopPag,nIniCol + 150,"Produto: "+SZ7->Z7_PRODUTO,oFont07,,CLR_BLACK)
       oPrn:Say(nCabTopPag,nIniCol + 250,Posicione("SB1",1,xFilial("SB1")+SZ7->Z7_PRODUTO,"B1_DESC"),oFont07,,CLR_BLACK)

       nCabTopPag := nCabTopPag + 10
       oPrn:Say(nCabTopPag,nIniCol + 5 ,"Emissao : "+dToc(SZ7->Z7_EMISSAO),oFont07,,CLR_BLACK) 
       oPrn:Say(nCabTopPag,nIniCol + 100,"Prevista : "+dtoc(SZ7->Z7_DATPRI),oFont07,,CLR_BLACK) 
       oPrn:Say(nCabTopPag,nIniCol + 250,"Tempo Gasto : "+SZ7->Z7_GASTO,oFont07,,CLR_BLACK)
       oPrn:Say(nCabTopPag,nIniCol + 370,"Operacao : "+SZ7->Z7_OPERAC,oFont07,,CLR_BLACK)
       oPrn:Say(nCabTopPag,nIniCol + 480,"Situacao : "+SZ7->Z7_SITUAC,oFont07,,CLR_BLACK)

    Endif
    FwRestArea(cArea)
Return(nCabTopPag)


/*/{Protheus.doc} PCP64APO
description Rotina do quadro de apontamentos de Produção
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param nCabTopPag, numeric, param_description
@param cOrdem, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function PCP64APO(nCabTopPag,cOrdem,cProduto)
      Local cArea  := FwGetArea()
      Local nLimite    := nCabTopPag + 60
      Local cAlias 	:= GetNextAlias()

    //--[ Borda dos dados de apontamento ]
    oPrn:Box(nCabTopPag,nIniCol,nLimite,nMaxColuna)
    nCabTopPag := nCabTopPag + 10
    oPrn:Say(nCabTopPag,nIniCol + 5,  "Apontamentos da Producao",oFont07n,,CLR_BLACK) 
    BeginSQL Alias cAlias
            Select *
            FROM %Table:SZ8% SZ8
            INNER JOIN %Table:SH1% SH1 ON H1_CODIGO = Z8_RECUR AND SH1.%NotDel%
            WHERE SZ8.%NotDel%
            and Z8_FILIAL =  %xFilial:SZ8%
            AND Z8_OP = %Exp:cOrdem%
            AND Z8_PRODUTO = %Exp:cProduto%
            ORDER BY Z8_OPERAC
        EndSQL
      TCSetField(cAlias, "Z8_DATAINI","D")
      TCSetField(cAlias, "Z8_DATAFIM","D")

    if (cAlias)->( Eof())
            (cAlias)->(DbCloseArea())
            FwRestArea(cArea)
	        RETURN(nLimite)
    Endif       
    
    nCabTopPag := nCabTopPag + 10
    oPrn:Say(nCabTopPag,nIniCol + 5,  "Op",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 20, "Recurso",oFont07n,,CLR_BLACK)
    oPrn:Say(nCabTopPag,nIniCol + 080,"Descricao",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 250,"Data Inicial",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 320,"Hora Inicial",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 370,"Data Final",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 420,"Hora Final",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 480,"Tempo Gasto",oFont07n,,CLR_BLACK)
            nCabTopPag := nCabTopPag + 10


    While (cAlias)->(!EOF())

            oPrn:Say(nCabTopPag,nIniCol + 5,  (cAlias)->Z8_OPERAC,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 20, (cAlias)->Z8_RECUR,oFont07,,CLR_BLACK)
            oPrn:Say(nCabTopPag,nIniCol + 080,(cAlias)->Z8_DESCR,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 250,DTOC((cAlias)->Z8_DATAINI),oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 320,(cAlias)->Z8_HORAINI,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 370,DTOC((cAlias)->Z8_DATAFIM),oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 420,(cAlias)->Z8_HORAFIM,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 480,(cAlias)->Z8_GASTO,oFont07,,CLR_BLACK)
            nCabTopPag := nCabTopPag + 10

          (cAlias)->(dbSkip() )
    End
    (cAlias)->(DbCloseArea())
     FwRestArea(cArea)
Return(nLimite)

/*/{Protheus.doc} PCP64STOP
description Rotina do quando de apontamento das paradas
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param nCabTopPag, numeric, param_description
@param cOrdem, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function PCP64STOP(nCabTopPag,cOrdem,cProduto)
      Local cArea  := FwGetArea()
      Local nLimite    := nCabTopPag + 60
      Local cAlias 	:= GetNextAlias()

    //--[ Borda dos dados de apontamento ]
    oPrn:Box(nCabTopPag,nIniCol,nLimite,nMaxColuna)
     nCabTopPag := nCabTopPag + 10
    oPrn:Say(nCabTopPag,nIniCol + 5,  "Apontamentos de Paradas ",oFont07n,,CLR_BLACK)     
    BeginSQL Alias cAlias
            Select *
            FROM %Table:SZ9% SZ9
            WHERE SZ9.%NotDel%
            and Z9_FILIAL =  %xFilial:SZ8%
            AND Z9_OP = %Exp:cOrdem%
            AND Z9_PRODUTO = %Exp:cProduto%
            ORDER BY Z9_OPERAC
        EndSQL
      TCSetField(cAlias, "Z9_DATAINI","D")
      TCSetField(cAlias, "Z9_DATAFIM","D")

    if (cAlias)->( Eof())
            (cAlias)->(DbCloseArea())
            FwRestArea(cArea)
	        RETURN(nLimite)
    Endif       
    
    nCabTopPag := nCabTopPag + 20
    oPrn:Say(nCabTopPag,nIniCol + 5,  "Op",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 080,"Motivo",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 250,"Data Inicial",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 320,"Hora Inicial",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 370,"Data Final",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 420,"Hora Final",oFont07n,,CLR_BLACK) 
    oPrn:Say(nCabTopPag,nIniCol + 480,"Tempo Gasto",oFont07n,,CLR_BLACK)
            nCabTopPag := nCabTopPag + 10


    While (cAlias)->(!EOF())

            oPrn:Say(nCabTopPag,nIniCol + 5,  (cAlias)->Z9_OPERAC,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 020,(cAlias)->Z9_MOTIVO,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 250,DTOC((cAlias)->Z9_DATAINI),oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 320,(cAlias)->Z9_HORAINI,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 370,DTOC((cAlias)->Z9_DATAFIM),oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 420,(cAlias)->Z9_HORAFIM,oFont07,,CLR_BLACK) 
            oPrn:Say(nCabTopPag,nIniCol + 480,(cAlias)->Z9_GASTO,oFont07,,CLR_BLACK)
            nCabTopPag := nCabTopPag + 10

          (cAlias)->(dbSkip() )
    End
    (cAlias)->(DbCloseArea())
      FwRestArea(cArea)
Return(nLimite)

Static Function GPixel(_nMm)
_nRet:=(_nMm/25.4)*300
Return(_nRet)


/*/{Protheus.doc} Ambiente
description Preparo de ambiente
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@return variant, return_description
/*/
Static Function Ambiente()
    Local cAutoEmp := "10"
    Local cAutoFil := "0803"
    RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
    If Select("SX2") <= 0
	    RpcSetEnv( cAutoEmp, cAutoFil )
    Endif    
Return
