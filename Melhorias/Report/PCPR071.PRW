#include "totvs.ch"
#Include "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'

#DEFINE cEof  CHAR(13)+CHAR(10)

/*/{Protheus.doc} PCPR071
description Relatorio de quebra por produto, status e cliente
@type function
@version 1.0
@author Paulo Lenzi
@since 28/11/2024
@return variant, return_description
/*/
User Function PCPR071()
    Private oReport
    Private cPerg 	:= PADR("PCPR070",10)
    Private cTitulo := OemToAnsi("Relação dos Produtos Barrados")
    Private aCols   := {}
    oReport := ReportDef()
    oReport:PrintDialog()
Return


/*/{Protheus.doc} ReportDef
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/11/2024
@return variant, return_description
/*/
Static Function ReportDef() 
  
    Local oSection1
    Local oSection2
    Local oSection3

    Local aOrdem 	:={}
    Local cDesc 	:= cTitulo

    Pergunte(cPerg,.F.)	 

    oReport:= TReport():New("PCPR071",cTitulo,cPerg, {|oReport| ReportPrint(oReport)},cDesc)
    oReport:SetLandscape() 
    oReport:SetTotalInLine(.F.)
    oReport:lParamPage := .T.
    
    //--------------------------------------------------------//
    // Seção 01 - Dados do Produto
    //--------------------------------------------------------//

    oSection1 := TRSection():New(oReport,"",{"SZB"},aOrdem)
    oSection1:SetHeaderPage()

    TRCell():New(oSection1,'PRODUTO'	,'SZB', GetSx3Cache("ZB_COD","X3_TITULO")     	   	    ,PesqPict('SZB',"ZB_COD")	,TamSX3("ZB_COD") [1]+1,,) 
    TRCell():New(oSection1,'DESCPROD'   ,'SZB', GetSx3Cache("ZB_DESC","X3_TITULO")     		   	,PesqPict('SZB',"ZB_DESC")	,TamSX3("ZB_DESC") [1]+1,,) 
    TRCell():New(oSection1,'CLASSE'		,'SZB', GetSx3Cache("ZB_CLASSE","X3_TITULO")   		   	,PesqPict('SZB',"ZB_TIPO")  ,TamSX3("ZB_TIPO") [1]+1,,) 
    TRCell():New(oSection1,'TIPO'		,'SZB', GetSx3Cache("ZB_TIPO","X3_TITULO")    		   	,PesqPict('SZB',"ZB_CLASSE"),TamSX3("ZB_CLASSE") [1]+1,,) 

   //--------------------------------------------------------//
   // Seção 02 - Dados do Produto
   //--------------------------------------------------------//

    oSection2 := TRSection():New(oSection1,"Status",{"SZB"},aOrdem)

    TRCell():New(oSection2,'STATUS'		,'SZB', GetSx3Cache("ZB_STATUS","X3_TITULO")    	   	,PesqPict('SZB',"ZB_STATUS"),TamSX3("ZB_STATUS") [1]+1,,) 

   //--------------------------------------------------------//
   // Seção 02 - Dados do Produto
   //--------------------------------------------------------//

    oSection3 := TRSection():New(oSection1,"Clientes",{"SZB"},aOrdem)

    TRCell():New(oSection3,'NOME'		,'SZB', GetSx3Cache("ZB_NOME","X3_TITULO")     		   	,PesqPict('SZB',"ZB_NOME")	,TamSX3("ZB_NOME") [1]+1,,) 
    TRCell():New(oSection3,'QUANT'		,'SZB', GetSx3Cache("ZB_QTD","X3_TITULO")     		   	,PesqPict('SZB',"ZB_QTD")	,TamSX3("ZB_QTD") [1]+1,,) 

    TRCell():New(oSection3,'SLDE'		,'SZB', GetSx3Cache("ZB_SLDE","X3_TITULO")      	   	,PesqPict('SZB',"ZB_SALDO")	,TamSX3("ZB_SALDO") [1]+1,,) 
    TRCell():New(oSection3,'SLDA'		,'SZB', GetSx3Cache("ZB_SLDA","X3_TITULO")      	   	,PesqPict('SZB',"ZB_SALDO")	,TamSX3("ZB_SALDO") [1]+1,,) 

    TRCell():New(oSection3,'SALDO'		,'SZB', GetSx3Cache("ZB_SALDO","X3_TITULO")     	   	,PesqPict('SZB',"ZB_SALDO")	,TamSX3("ZB_SALDO") [1]+1,,) 
    TRCell():New(oSection3,'Total'		,'SZB', GetSx3Cache("ZB_TOTAL","X3_TITULO")     	   	,PesqPict('SZB',"ZB_TOTAL")	,TamSX3("ZB_TOTAL") [1]+1,,) 
    TRCell():New(oSection3,'Dispo'     ,'SZB', GetSx3Cache("ZB_QTAPU","X3_TITULO")     	      ,PesqPict('SZB',"ZB_QTAPU")	,TamSX3("ZB_QTAPU") [1]+1,,) 

Return(oReport)

/*/{Protheus.doc} ReportPrint
description
@type function
@version 1.0
@author Paulo Lenzi
@since 28/11/2024
@param oReport, object, param_description
@return variant, return_description
/*/
Static Function ReportPrint(oReport)   
    Local oSection1 	:= oReport:Section(1) 
    Local oSection2 	:= oReport:Section(1):Section(1)
    Local oSection3 	:= oReport:Section(1):Section(2) 
    Local cCodigo       := ""
    Local cStatus       := ""
    Local cQuer1        := ""
    Local cQuer2        := ""
    Local nQuant        := 0
    Local nPercentual   := 0
    Local nSomaPerc     := 0.00
  
    dbSelectArea("SZB")
    ("SZB")->( dbSetOrder(2) )
    ("SZB")->( dbGoTop() )
    //IF ("SZB")->( dbSeek( xFilial("SZB")+Alltrim(MV_PAR01) ) )

     oReport:SetMeter(SZB->(LastRec()))
    
      // While ("SZB")->( !Eof() ) .and. SZB->ZB_PERIODO = Alltrim(MV_PAR01) .AND. !oReport:Cancel()
       While ("SZB")->( !Eof() )  .AND. !oReport:Cancel()
             oReport:IncMeter()
             If oReport:Cancel()
                    Exit
             EndIf        

              IF UPPER(SZB->ZB_SITUA) <> 'BARRADO'
                   dbSelectArea("SZB")
                   SZB->( dbSkip())
                   LOOP
              ENDIF
                //----------------//
                // Secao 01
                //----------------//

             if SZB->ZB_COD <> cCodigo
                oSection1:Init()
                if !Empty(cCodigo)
                   oReport:SkipLine() 
                endif
                
                oSection1:Cell("PRODUTO" 	 ):SetValue((SZB->ZB_COD)) 
                oSection1:Cell("DESCPROD" 	 ):SetValue((SZB->ZB_DESC))		
                oSection1:Cell("CLASSE" 	 ):SetValue((SZB->ZB_CLASSE))		
                oSection1:Cell("TIPO" 	     ):SetValue((SZB->ZB_TIPO))		
                
                oSection1:PrintLine()   
                cCodigo :=  SZB->ZB_COD   
                cStatus := ""      
             Endif

            //----------------//
            // Secao 02
            //----------------//

             IF SZB->ZB_STATUS <> cStatus
                oSection2:Init()
                if !Empty(cStatus)
                    oReport:SkipLine() 
                endif                
                oSection2:Cell("STATUS"	     ):SetValue((SZB->ZB_STATUS))	
                oSection2:PrintLine()
                cStatus := SZB->ZB_STATUS
                oSection3:Init()
             endif
        //----------------//
        // Secao 03
        //----------------//
        oSection3:Cell("NOME"):SetValue((SZB->ZB_NOME))	
        oSection3:Cell("QUANT"):SetValue((SZB->ZB_QTD))	

        oSection3:Cell("SLDE"):SetValue((SZB->ZB_SLDE))	
        oSection3:Cell("SLDA"):SetValue((SZB->ZB_SLDA))	

        oSection3:Cell("SALDO"):SetValue((SZB->ZB_SALDO))	
        oSection3:Cell("Total"):SetValue((SZB->ZB_TOTAL))	
        oSection3:Cell("Dispo"):SetValue((SZB->ZB_QTAPU))	

       
        oSection3:PrintLine()
        oReport:IncMeter()

        ("SZB")->( dbSkip() )
       EndDo
    

   nQuant := CalcTotal()

    oReport:SkipLine() 
    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:PrintText("| TOTAL DE STATUS                                                                   |",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())

    // Abater os percentuais dos outros tipos
    cQuera:= "Select ZB_STATUS,ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuera+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuera+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuera+= "AND ZB_FILIAL = '0803' "+cEof
    cQuera+= "AND UPPER(ZB_STATUS)  NOT IN ('BARRADO','LIBERADO') "+cEof
    cQuera+= "GROUP BY ZB_STATUS "+cEof
    cQuera+= "ORDER BY ZB_STATUS "+cEof

    If  Select("QRYPER") > 0
            DbSelectArea("QRYPER")
            DbCloseArea()
    Endif

    TCQuery cQuera New Alias "QRYPER"

    nSomaPerc := 0.00
    DbSelectArea("QRYPER")
    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPER->(EoF()))    
      nSomaPerc   += (QRYPER->QUANT/nQuant)*100
      nPercentual := (QRYPER->QUANT/nQuant)*100
      oReport:PrintText(Alltrim(QRYPER->ZB_STATUS)+" - Quantidade: "+cValtoChar(QRYPER->QUANT)+"  - Percentual: "+cValtoChar( Round(nPercentual,2))  )      
      QRYPER->(DbSkip())  
    Enddo
   
    // Apenas os BLOQUEADOS E LIBERADOS
    cQuer1:= "Select ZB_SITUA,ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuer1+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuer1+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuer1+= "AND ZB_FILIAL = '0803' "+cEof
    cQuer1+= "GROUP BY ZB_SITUA "+cEof
    cQuer1+= "ORDER BY ZB_SITUA "+cEof
    If  Select("QRYSTA") > 0
            DbSelectArea("QRYSTA")
            DbCloseArea()
    Endif
    TCQuery cQuer1 New Alias "QRYSTA"

    DbSelectArea("QRYSTA")
    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYSTA->(EoF()))    
      nPercentual := (QRYSTA->QUANT/nQuant)*100
      IF ALLTRIM(QRYSTA->ZB_SITUA) = 'BARRADO'
         nPercentual := nPercentual - nSomaPerc
      ENDIF
      oReport:PrintText(Alltrim(QRYSTA->ZB_SITUA)+"  -  Quantidade: "+cValtoChar(QRYSTA->QUANT)+" - Percentual: "+cValtoChar( Round(nPercentual,2))  )
      QRYSTA->(DbSkip())  
    Enddo

    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:SkipLine()   

     // Listar as Classes
    cQuer2:= "Select ZB_CLASSE,ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuer2+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuer2+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuer2+= "AND ZB_FILIAL = '0803' "+cEof
    //cQuer2+= "AND RTRIM(ZB_PERIODO) = '"+Alltrim(MV_PAR01)+"'  "+cEof
    cQuer2+= "AND upper(ZB_SITUA) = 'BARRADO'   "+cEof
    cQuer2+= "GROUP BY ZB_CLASSE "+cEof
    cQuer2+= "ORDER BY ZB_CLASSE "+cEof

    If  Select("QRYBLQ") > 0
            DbSelectArea("QRYBLQ")
            DbCloseArea()
    Endif

   TCQuery cQuer2 New Alias "QRYBLQ"
    
    oReport:SkipLine() 

    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:PrintText("| TOTAL DE CLASSE                                                                   |",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())

   nQuant := CalcBloq()

   DbSelectArea("QRYBLQ")
    //Criando as Linhas... Enquanto não for fim da query
    While !(QRYBLQ->(EoF()))
      nPercentual := (QRYBLQ->QUANT/nQuant)*100
      oReport:PrintText(Alltrim(QRYBLQ->ZB_CLASSE)+" Quantidade: "+cValtoChar(QRYBLQ->QUANT)+" Percentual: "+cValtoChar( Round(nPercentual,2))  )
      QRYBLQ->(DbSkip())  
    Enddo
    oReport:PrintText("+-----------------------------------------------------------------------------------+",,oSection1:Cell("PRODUTO"):ColPos())
    oReport:SkipLine() 

    oSection3:Finish()
    oSection2:Finish()
    oSection1:Finish()

    oReport:ThinLine() 
   
Return NIL 


Static Function CalcTotal()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local lRet         := 0

    cQuery:= "Select ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuery+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuery+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "AND ZB_FILIAL = '0803' "+cEof
    //cQuery+= "AND RTRIM(ZB_PERIODO) = '"+Alltrim(MV_PAR01)+"'  "+cEof

    If  Select("QRYCAL") > 0
            DbSelectArea("QRYCAL")
            DbCloseArea()
    Endif

    TCQuery cQuery New Alias "QRYCAL"

    if !(QRYCAL->(EoF()))
       lRet := QRYCAL->Quant
    endif

    RestArea(aArea)
Return(lRet)

Static Function CalcBloq()
    Local aArea        := GetArea()
    Local cQuery       := ""
    Local lRet         := 0

    cQuery:= "Select ISNULL(SUM(ZB_QTD),0) QUANT "+cEof
    cQuery+= "from "+RetSqlName("SZB")+" SZB "+cEof
    cQuery+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
    cQuery+= "AND ZB_FILIAL = '0803' "+cEof
    cQuery+= "AND upper(ZB_SITUA) = 'BARRADO'   "+cEof
    //cQuery+= "AND RTRIM(ZB_PERIODO) = '"+Alltrim(MV_PAR01)+"'  "+cEof

    If  Select("QRYCAL") > 0
            DbSelectArea("QRYCAL")
            DbCloseArea()
    Endif

    TCQuery cQuery New Alias "QRYCAL"

    if !(QRYCAL->(EoF()))
       lRet := QRYCAL->Quant
    endif

    RestArea(aArea)
Return(lRet)

//--------------------------------------------------------------------------------------------------------------------------------------------------------//
// FIM DO PROGRAMA
//--------------------------------------------------------------------------------------------------------------------------------------------------------//
