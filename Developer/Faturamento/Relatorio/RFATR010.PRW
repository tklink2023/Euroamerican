//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

User Function RFATR010()
    Local aArea   := GetArea()
    Local aSays    := {}
    Local aButtons := {}
    Local cPerg    := "NFSIGW"
    Local lOk      := .F.   
    Local cAlias   := GetNextAlias()
    Local cNota1 := cNota2 := cSerie := ""

    Default cPasta  := "C:\DANFE_PDF\"

	If !lIsDir(cPasta)
        msgAlert("Sera criada no seu computador a pasta DANFE_PDF onde vai ser gravadas os PDFs...")
	    MakeDir(cPasta)
    EndIf   


    //Popula as linhas que serão mostradas na tela
    aAdd(aSays, "Esse programa tem como objetivo gerar")
    aAdd(aSays, "uma impressao da DANFE.")
    
    //Botões da tela, cada botão tem um Bloco de Código
    aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
    aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
    aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )
    
    //Chama a tela principal
    FormBatch("Gerar DANFE / XML", aSays, aButtons)
    
    //Se foi confirmado a tela
    If !lOk
           RestArea(aArea)
           Return
    EndIf  	
    
    cNota1 := MV_PAR01
    cNota2 := MV_PAR02
    cSerie := MV_PAR03

    BeginSQL Alias cAlias
		SELECT  F2_DOC, F2_SERIE
		FROM %Table:SF2% SF2
		WHERE SF2.%NotDel%
		and F2_FILIAL =  %xFilial:SF2%
        and F2_DOC BETWEEN  %exp:cNota1% AND %exp:cNota2%
        and F2_SERIE = %exp:cSerie%
    EndSQL  

    if (cAlias)->(Eof())
        MsgAlert("Sem dados para o Grafico")
		Return
    ENDIF

    While ! (cAlias)->(EoF())
        u_zGerDanfe((cAlias)->F2_DOC, (cAlias)->F2_SERIE, cPasta)
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

    RestArea(aArea)
Return


User Function zGerDanfe(cNota, cSerie, cPasta)
    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
    Local dDataDe   := sToD("20190101")
    Local dDataAt   := Date()
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
    Default cNota   := ""
    Default cSerie  := ""
    Default cPasta  := GetTempPath()
       
    //Se existir nota
    If ! Empty(cNota)
        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
           
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
           
        //Gera o XML da Nota
        cArquivo := cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
        u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
           
        //Define as perguntas da DANFE
        Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
        MV_PAR04 := 2                          //NF de Saida
        MV_PAR05 := 1                          //Frente e Verso = Sim
        MV_PAR06 := 2                          //DANFE simplificado = Nao
        MV_PAR07 := dDataDe                    //Data De
        MV_PAR08 := dDataAt                    //Data Até
           
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)
           
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
           
        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := cPasta                
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.
           
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
           
        //Chamando a impressão da danfe no RDMAKE
        RptStatus({|lEnd| u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
        oDanfe:Print()
    EndIf
       
    RestArea(aArea)
Return

User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return
