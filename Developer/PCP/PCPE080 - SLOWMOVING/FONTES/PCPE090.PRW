//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)

/*/{Protheus.doc} PCPE090
description
@type function
@version 1.0
@author Paulo Lenzi
@since 02/04/2025
@return variant, return_description
/*/
User Function PCPE090()
   Local aArea    := GetArea()
   Private cPerg  := PADR("PCPE090",10)
   Pergunte(cPerg,.T.)	 
   MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| RunProc() })
   RestArea(aArea)
Return 

/*/{Protheus.doc} RunProc
description
@type function
@version 1.0
@author Paulo Lenzi
@since 02/04/2025
@return variant, return_description
/*/
Static Function RunProc()
    Local aArea := FwGetArea()
    Local oFWMsExcel
    Local oExcel
    Local cArquivo      := GetTempPath()+'PCPE090.xml'    
    Local nTotalR01     := 0
    Local nSlowR01      := 0
    Local nTotalR02     := 0
    Local nSlowR02      := 0

    Private aCampos := {}
    Private cTemp := "TMP_" + RetCodUsr()


    aAdd(aCampos, { "TMP_FILIAL"    , "C", 10    , 0 })
    aAdd(aCampos, { "TMP_TIPO"      , "C", 02    , 0 })
    aAdd(aCampos, { "TMP_TOT01"     , "N", 18    , 2 })
    aAdd(aCampos, { "TMP_VLR01"     , "N", 18    , 2 })
    aAdd(aCampos, { "TMP_TOT02"     , "N", 18    , 2 })
    aAdd(aCampos, { "TMP_VLR02"     , "N", 18    , 2 })
        
    oTempTable:= FWTemporaryTable():New(cTemp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("ind1",{"TMP_FILIAL","TMP_TIPO"} )
    oTempTable:Create()  

    PCP80FS01(MV_PAR01,MV_PAR02)

    PCP80FS02(MV_PAR01,MV_PAR03)

    oFWMsExcel := FWMSExcel():New()

    oFWMsExcel:AddworkSheet("Comparacao") //Não utilizar número junto com sinal de menos. Ex.: 1-

    oFWMsExcel:AddTable("Comparacao","Sintetico")

    oFWMsExcel:AddColumn("Comparacao","Sintetico","Tipo",2,2)         //1 = Modo Texto    
    oFWMsExcel:AddColumn("Comparacao","Sintetico","Total Dia :" + Dtoc(MV_PAR02),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","Slow Dia :" + Dtoc(MV_PAR02),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","% Dia :" + Dtoc(MV_PAR02),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","Total Dia :" + Dtoc(MV_PAR03),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","Slow Dia :" + Dtoc(MV_PAR03),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","% Dia :" + Dtoc(MV_PAR03),2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Comparacao","Sintetico","% Comparacao",2,2)        //1 = Modo Texto



    dbSelectArea(cTemp)
    (cTemp)->( dbGoTop() )
    While (cTemp)->( !Eof() )
          oFWMsExcel:AddRow("Comparacao","Sintetico",{(cTemp)->TMP_TIPO,;                              // 1 - Tipo
                                                        (cTemp)->TMP_TOT01,;                             // 2 - Total ESTOQUE
                                                        (cTemp)->TMP_VLR01,;                             // 2 - Total SLOW
                                                        (((cTemp)->TMP_VLR01/(cTemp)->TMP_TOT01)*100),;  // 2 - Percentual
                                                        (cTemp)->TMP_TOT02,;                             // 2 - Total ESTOQUE
                                                        (cTemp)->TMP_VLR02,;                             // 2 - Total SLOW
                                                        (((cTemp)->TMP_VLR02/(cTemp)->TMP_TOT02)*100),;  // 2 - Percentual
                                                        (((cTemp)->TMP_VLR02/(cTemp)->TMP_VLR01)*100)} ) // 4 - Percente
                     
            nTotalR01 := nTotalR01 + (cTemp)->TMP_TOT01
            nSlowR01  := nSlowR01 + (cTemp)->TMP_VLR01

            nTotalR02 := nTotalR02 + (cTemp)->TMP_TOT02
            nSlowR02  := nSlowR02 + (cTemp)->TMP_VLR02

          (cTemp)->( dbskip()  )
    EndDo 
    
    oFWMsExcel:AddRow("Comparacao","Sintetico",{"Geral",nTotalR01,nSlowR01,(nSlowR01/nTotalR01)*100,nTotalR02,nSlowR02,(nSlowR02/nTotalR02)*100,(nSlowR02/nSlowR01)*100})

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()            //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)      //Abre uma planilha
    oExcel:SetVisible(.T.)               //Visualiza a planilha
    oExcel:Destroy()                     //Encerra o processo do gerenciador de tarefas
    oTempTable:Delete()
    RestArea(aArea)

Return

/*/{Protheus.doc} PCP80FS01
description
@type function
@version 1.0
@author Paulo Lenzi
@since 02/04/2025
@param datainicio, date, param_description
@param datafim, date, param_description
@return variant, return_description
/*/
Static function PCP80FS01(datainicio,datafim)
  Local aArea   := FwgetArea()
  Local cQuery  as character 
  Local cAlias  := getNextAlias() 
  Local aSaldos  := {}
  Local nValor   := 0
  Local nQtdSlow := 0
  Local nVrlSlow := 0

  cQuery:="SELECT  B2_FILIAL "+CRLF
  cQuery+="		,B2_COD "+CRLF
  cQuery+="		,B1_TIPO "+CRLF
  cQuery+="		,B2_LOCAL "+CRLF
  cQuery+="		,B2_QATU "+CRLF
  cQuery+="		,B2_CM1 "+CRLF
  cQuery+="   ,ROUND((B2_CM1 * B2_QATU),2) TOTAL "+CRLF
  cQuery+="		,ISNULL(((Select SUM(D4_QTDEORI)/ DATEDIFF(Month,  '"+DtoS(datainicio)+"','"+DtoS(datafim)+"')  QTDE "+cEof  
  cQuery+="		            from  " + RetSqlName("SD4") + "   SD4  "+CRLF
  cQuery+="		            WHERE SD4.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="		            AND D4_FILIAL = B2_FILIAL "+CRLF
  cQuery+="		            AND D4_DATA BETWEEN '"+DtoS(datainicio)+"' AND '"+DtoS(datafim)+"' "+cEof  
  cQuery+="		            AND D4_LOCAL = B2_LOCAL  "+CRLF
  cQuery+="		            AND D4_COD IN (SB2.B2_COD,(SELECT Z4_CODDES FROM  SZ4100  SZ4 WHERE Z4_FILIAL = B2_FILIAL AND Z4_COD = B2_COD AND SZ4.D_E_L_E_T_ = ' ')))*3),0) "+CRLF
  cQuery+="				AS CONSUMO "+CRLF
  cQuery+="FROM " + RetSqlName("SB2") + " SB2 "+CRLF
  cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = B2_COD AND B1_TIPO IN ('EM','MP','PI','PA') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="WHERE SB2.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="AND B2_FILIAL = '"+xFilial("SB2")+"' "+CRLF
  cQuery+="AND B2_QATU > 0 "+CRLF
  cQuery+="ORDER BY B2_FILIAL,B2_COD,B1_TIPO,B2_LOCAL "+CRLF

  DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

   IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return
    endif

  dbSelectArea(cAlias)
  (cAlias)->( dbgotop() )
  DO WHILE (cAlias)->(!Eof())
 
    aSaldos := CalcEst((cAlias)->B2_COD, (cAlias)->B2_LOCAL, datafim)
    nValor  := (aSaldos[1] * aSaldos[08] )
    nQtdSlow:= IIF(aSaldos[1] - (cAlias)->CONSUMO <0,0, aSaldos[1] - (cAlias)->CONSUMO  )
    nVrlSlow := nQtdSlow * aSaldos[08]

    dbSelectArea(cTemp)
    (cTemp)->( dbSetOrder(1))
    if  MsSeek( Alltrim((cAlias)->B2_FILIAL)+Space(10-len(Alltrim((cAlias)->B2_FILIAL))) + (cAlias)->B1_TIPO ) 
        IF RecLock(cTemp, .F.)
                    (cTemp)->TMP_TOT01  := (cTemp)->TMP_TOT01 + nValor
                    (cTemp)->TMP_VLR01  := (cTemp)->TMP_VLR01   +  nVrlSlow
           (cTemp)->(MsUnlock())
        Endif   
    else
        IF RecLock(cTemp, .T.)
                    (cTemp)->TMP_FILIAL := (cAlias)->B2_FILIAL
                    (cTemp)->TMP_TIPO   := (cAlias)->B1_TIPO
                    (cTemp)->TMP_TOT01  := + nValor
                    (cTemp)->TMP_VLR01  :=  nVrlSlow
            (cTemp)->(MsUnlock())
        Endif         
    endif    

    (cAlias)->(dbskip())

  ENDDO

  (cAlias)->(DbCloseArea())

  RestArea(aArea)
Return

/*/{Protheus.doc} PCP80FS02
description
@type function
@version 1.0
@author Paulo Lenzi
@since 02/04/2025
@param datainicio, date, param_description
@param datafim, date, param_description
@return variant, return_description
/*/
Static function PCP80FS02(datainicio,datafim)
  Local aArea   := FwgetArea()
  Local cQuery  as character 
  Local cAlias  := "PCP_"+getNextAlias() 
  Local aSaldos  := {}
  Local nValor   := 0
  Local nQtdSlow := 0
  Local nVrlSlow := 0

  cQuery:="SELECT  B2_FILIAL "+CRLF
  cQuery+="		,B2_COD "+CRLF
  cQuery+="		,B1_TIPO "+CRLF
  cQuery+="		,B2_LOCAL "+CRLF
  cQuery+="		,B2_QATU "+CRLF
  cQuery+="		,B2_CM1 "+CRLF
  cQuery+="   ,ROUND((B2_CM1 * B2_QATU),2) TOTAL "+CRLF
  cQuery+="		,ISNULL(((Select SUM(D4_QTDEORI)/ DATEDIFF(Month,  '"+DtoS(datainicio)+"','"+DtoS(datafim)+"')  QTDE "+cEof  
  cQuery+="		            from  " + RetSqlName("SD4") + "   SD4  "+CRLF
  cQuery+="		            WHERE SD4.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="		            AND D4_FILIAL = B2_FILIAL "+CRLF
  cQuery+="		            AND D4_DATA BETWEEN '"+DtoS(datainicio)+"' AND '"+DtoS(datafim)+"' "+cEof  
  cQuery+="		            AND D4_LOCAL = B2_LOCAL  "+CRLF
  cQuery+="		            AND D4_COD IN (SB2.B2_COD,(SELECT Z4_CODDES FROM  SZ4100  SZ4 WHERE Z4_FILIAL = B2_FILIAL AND Z4_COD = B2_COD AND SZ4.D_E_L_E_T_ = ' ')))*3),0) "+CRLF
  cQuery+="				AS CONSUMO "+CRLF
  cQuery+="FROM " + RetSqlName("SB2") + " SB2 "+CRLF
  cQuery+="INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = B2_COD AND B1_TIPO IN ('EM','MP','PI','PA') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="WHERE SB2.D_E_L_E_T_ = ' ' "+CRLF
  cQuery+="AND B2_FILIAL = '"+xFilial("SB2")+"' "+CRLF
  cQuery+="AND B2_QATU > 0 "+CRLF
  cQuery+="ORDER BY B2_FILIAL,B2_COD,B1_TIPO,B2_LOCAL "+CRLF

  DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

   IF (cAlias)->(Eof())
            (cAlias)->(DbCloseArea())   
            FwRestArea(aArea)
            Return
    endif

  dbSelectArea(cAlias)
  (cAlias)->( dbgotop() )
  DO WHILE (cAlias)->(!Eof())
 
    aSaldos := CalcEst((cAlias)->B2_COD, (cAlias)->B2_LOCAL, datafim)
    nValor  := (aSaldos[1] * aSaldos[08] )
    nQtdSlow:= IIF(aSaldos[1] - (cAlias)->CONSUMO <0,0, aSaldos[1] - (cAlias)->CONSUMO  )
    nVrlSlow := nQtdSlow * aSaldos[08]

    dbSelectArea(cTemp)
    (cTemp)->( dbSetOrder(1))
    if  MsSeek( Alltrim((cAlias)->B2_FILIAL)+Space(10-len(Alltrim((cAlias)->B2_FILIAL))) + (cAlias)->B1_TIPO ) 
        IF RecLock(cTemp, .F.)
                    (cTemp)->TMP_TOT02  := (cTemp)->TMP_TOT02 + nValor
                    (cTemp)->TMP_VLR02  := (cTemp)->TMP_VLR02   +  nVrlSlow
           (cTemp)->(MsUnlock())
        Endif   
    else
        IF RecLock(cTemp, .T.)
                    (cTemp)->TMP_FILIAL := (cAlias)->B2_FILIAL
                    (cTemp)->TMP_TIPO   := (cAlias)->B1_TIPO
                    (cTemp)->TMP_TOT02  := + nValor
                    (cTemp)->TMP_VLR02  :=  nVrlSlow
            (cTemp)->(MsUnlock())
        Endif         
    endif    

    (cAlias)->(dbskip())

  ENDDO

  (cAlias)->(DbCloseArea())

  RestArea(aArea)
Return
