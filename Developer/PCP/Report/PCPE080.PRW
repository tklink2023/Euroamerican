//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)
 
/*/{Protheus.doc} PCPE080
description
@type function
@version 1.0
@author Paulo Lenzi
@since 13/02/2025
@return variant, return_description
/*/
 User Function PCPE080()
      Local aArea           := GetArea()
      Private cPerg 		:= PADR("PCPE080",10)
      Private aIndicadores  := {}
      Private aColsMP       := {}
      Private aColsEM       := {}
      Private aColsPI       := {}
      Private aColsPA       := {}
      Private corfundo      := "#000666"
      Private corResalta    := "#c7a7cf"
      Private nPosOrd       := GetMv("MV_PCPE080")

      Pergunte(cPerg,.T.)	 
      MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| RunProc() })
      RestArea(aArea)    
 Return
 
/*/{Protheus.doc} RUNPROC
description
@type function
@version 1.0
@author Paulo Lenzi
@since 13/02/2025
@return variant, return_description
/*/
Static Function RUNPROC()
    Local aArea         := GetArea()
    Local cQuery        := ""
    Local oFWMsExcel
    Local oExcel
    Local cArquivo      := GetTempPath()+'PCPE080.xml'
    Local Ny            := 0 
    Local nConsDia      := 0
    Local nEstoque      := 0
    Local nDiasDisp     := 0

    Private nTotalSlow  := 0
    Private nTotalGeral := 0
    Private aBrowse     := {}
     
    aAdd(aIndicadores,{"MP",0,0,0}) 
    aAdd(aIndicadores,{"EM",0,0,0})
    aAdd(aIndicadores,{"PI",0,0,0})
    aAdd(aIndicadores,{"PA",0,0,0})


    //Pegando os dados
   
    cQuery :="Select B2_FILIAL	EMPRESA "+cEof 
    cQuery +="		,B2_COD		PRODUTO  "+cEof
    cQuery +="		,B1_DESC	DESCRICAO  "+cEof
    cQuery +="		,B1_TIPO    TIPO  "+cEof
    cQuery +="		,B2_LOCAL	ARMAZEM  "+cEof
    cQuery +="		,B2_QATU	SALDO  "+cEof
    cQuery +="		,B2_QEMP	EMPENHO  "+cEof
    cQuery +="		,CASE WHEN (B2_QATU - B2_QEMP) < 0 THEN 0 ELSE ROUND((B2_QATU - B2_QEMP),3) END DISPONIVEL  "+cEof
    cQuery +="		,B2_CM1	    CUSTO  "+cEof
    cQuery +="		,ROUND((B2_CM1 * B2_QATU),2) TOTAL "+cEof  
    cQuery +="	    ,ISNULL((Select SUM(D4_QTDEORI) / DATEDIFF(Month,  '"+DtoS(MV_PAR01)+"','"+DtoS(MV_PAR02)+"')  QTDE "+cEof  
    cQuery +="		            from  "+RetSqlName("SD4")+"   SD4 "+cEof  
    cQuery +="		            WHERE SD4.D_E_L_E_T_ = ' '"+cEof    
    cQuery +="		            AND D4_FILIAL = B2_FILIAL "+cEof  
    cQuery +="		            AND D4_DATA BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "+cEof  
    cQuery +="		            AND D4_LOCAL = B2_LOCAL  "+cEof  
    cQuery +="		            AND D4_COD IN (SB1.B1_COD,(SELECT Z4_CODDES FROM  "+RetSqlName("SZ4")+"  SZ4 WHERE Z4_FILIAL = B2_FILIAL AND Z4_COD = B2_COD AND SZ4.D_E_L_E_T_ = ' ') ) ),0)  CONSUMO "+cEof  
    cQuery +="      ,B1_XTPCOMP  COMPRA "+cEof
	cQuery +="      ,ISNULL((SELECT SUM(SC6_1.C6_QTDVEN)/ DATEDIFF(Month, '"+DtoS(MV_PAR01)+"','"+DtoS(MV_PAR02)+"') FROM  "+RetSqlName("SC6")+" AS SC6_1 WITH (NOLOCK)   "+cEof
    cQuery +="					WHERE SC6_1.D_E_L_E_T_ = ''   "+cEof
    cQuery +="					  AND SC6_1.C6_FILIAL = SB2.B2_FILIAL  "+cEof
    cQuery +="					  AND SC6_1.C6_LOCAL = SB2.B2_LOCAL   "+cEof
    cQuery +="					  AND SC6_1.C6_DATFAT  BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'  "+cEof
    cQuery +="					  AND SC6_1.C6_PRODUTO = SB2.B2_COD   "+cEof
    cQuery +="					  AND SC6_1.C6_BLQ NOT IN ('R')),0) AS DEMANDA  "+cEof
    cQuery +="from   "+RetSqlName("SB2")+"   SB2  "+cEof
    cQuery +="INNER JOIN  "+RetSqlName("SB1")+"  SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="WHERE SB2.D_E_L_E_T_ = ' '  "+cEof
    cQuery +="AND B2_FILIAL = '"+xFilial("SB2")+"'  "+cEof
    cQuery +="AND B1_TIPO IN ( 'EM','MP','PI','PA')  "+cEof
    cQuery +="AND B2_QATU > 0 "+cEof
    cQuery +="ORDER BY TOTAL DESC "+cEof

    If  Select("QRYPRO") > 0
            DbSelectArea("QRYPRO")
            DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
    //Aba 01 - Teste
    oFWMsExcel:AddworkSheet("Consumo") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("Consumo","Produtos")
    //Criando Colunas
    oFWMsExcel:AddColumn("Consumo","Produtos","Empresa",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("Consumo","Produtos","Produto",1,1)        //1 = Modo Texto  2
    oFWMsExcel:AddColumn("Consumo","Produtos","Descricao",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("Consumo","Produtos","Tipo",1,1)           //1 = Modo Texto  4
    oFWMsExcel:AddColumn("Consumo","Produtos","Local",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("Consumo","Produtos","Custo",3,3)          //3 = Valor com R$ 6
    oFWMsExcel:AddColumn("Consumo","Produtos","Consumo",2,2)        //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("Consumo","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("Consumo","Produtos","Saldo",2,2)          //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("Consumo","Produtos","Total",3,3)          //3 = Valor com R$ 10
    oFWMsExcel:AddColumn("Consumo","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("Consumo","Produtos","Empenho",2,2)        //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("Consumo","Produtos","Disponivel",2,2)     //2 = Valor sem R$ 14
    oFWMsExcel:AddColumn("Consumo","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$ 15
    oFWMsExcel:AddColumn("Consumo","Produtos","SlowMov Qtd",2,2)    //2 = Valor sem R$ 16
    oFWMsExcel:AddColumn("Consumo","Produtos","SlowMov R$",3,3)     //3 = Valor com R$ 17
    oFWMsExcel:AddColumn("Consumo","Produtos","SlowMov Dia",2,2)    //2 = Valor sem R$ 18
    oFWMsExcel:AddColumn("Consumo","Produtos","SlowMov %",2,2)      //2 = Valor sem R$ 19
    
        //Criando as Linhas
    nTotalSlow  := 0
    nTotalGeral := 0
    nTotalCons  := 0

    While !(QRYPRO->(EoF()))
        // Projecao do consumo nessa parte é normal pois é o consumo do mês
        nConsumo := Round(IIF(QRYPRO->TIPO = 'PA',QRYPRO->DEMANDA,QRYPRO->CONSUMO),3)
        nConsDia := nConsumo/30
        nEstoque := IIF(QRYPRO->SALDO > 0 .and. nConsumo > 0, QRYPRO->SALDO / nConsDia, 0 )
        nDiasDisp := IIF(QRYPRO->DISPONIVEL > 0 .and. nConsumo > 0 ,QRYPRO->DISPONIVEL/nConsDia,0)
        nPosicao  := (QRYPRO->TOTAL * nDiasDisp)  //IIF(QRYPRO->COMPRA = 'P' .AND. QRYPRO->TIPO = 'EM' , (QRYPRO->TOTAL * nDiasDisp),0)
        // Calculo do SlowMoving passa a ser considerado 2 vezes o consumo
        nQtSlow   := IIF(QRYPRO->SALDO - (nConsumo * 2 ) < 0,0, QRYPRO->SALDO - (nConsumo * 2) )  // conforme orientações Alex o consumo passa a ser 2 vezes o consumo
        nVlrSlow  := ( nQtSlow *  QRYPRO->CUSTO )
        nDiaSlow  := (nQtSlow / 30 )
        nPerct    := (nQtSlow / QRYPRO->SALDO ) * 100

        n90Dias   := IIF( (QRYPRO->SALDO - (nConsumo * 3)) < 0, 0 , QRYPRO->SALDO - (nConsumo * 3) ) 
        nVlr90Dias:= IIF(n90Dias = 0,0,(n90Dias * QRYPRO->CUSTO ) )
        nDias90   := IIF(n90Dias = 0,0,(n90Dias / 30 ))
        nDiasPerct:= IIF(n90Dias = 0,0,(n90Dias / QRYPRO->SALDO ) * 100)

        aAdd(aBrowse,{ cvaltochar(QRYPRO->EMPRESA),;                                                                                // 1 - Filial
                       cValtochar(QRYPRO->PRODUTO),;                                                                                // 2 - Produto
                       QRYPRO->DESCRICAO,;                                                                                          // 3 - Descrição
                       QRYPRO->TIPO,;                                                                                               // 4 - Tipo
                       cValtoChar(QRYPRO->ARMAZEM),;                                                                                // 5 - Local
                       QRYPRO->CUSTO,;                                                                                              // 6 - Custo                       
                       nConsumo,;                                                                                                   // 7 - Consumo                       
                       nConsDia,;                                                                                                   // 8 - Cons.Diario
                       QRYPRO->SALDO,;                                                                                              // 9 - Saldo
                       QRYPRO->TOTAL,;                                                                                              // 10 - Total
                       nEstoque,;                                                                                                   // 11 - Dias.Estoque
                       QRYPRO->EMPENHO,;                                                                                            // 12 - Empenho
                       QRYPRO->DISPONIVEL,;                                                                                         // 13 - Disponivel
                       nDiasDisp,;                                                                                                  // 14 - Dias.Diponivel
                       nQtSlow,;                                                                                                    // 15 - SlowMov Qtd
                       nVlrSlow,;                                                                                                   // 16 - SlowMov R$
                       nDiaSlow,;                                                                                                   // 17 - SlowMov Dia
                       n90Dias,;                                                                                                    // 18 - Consumo 60Dias
                       nPerct,;                                                                                                     // 19 - Percentual         
                       nPosicao,;                                                                                                   // 20 - Posição
                       QRYPRO->COMPRA})                                                                                             // 21 - Tipo de Compras

        
        nTotalSlow  += nVlrSlow
        
        nTotalCons  += nVlr90Dias
        
        nTotalGeral += QRYPRO->TOTAL

        nPos := aScan(aIndicadores,{ |x| x[1] == QRYPRO->TIPO } ) 
        if nPos > 0
            aIndicadores[nPos][2] += QRYPRO->TOTAL
            aIndicadores[nPos][3] += nVlrSlow  
            aIndicadores[nPos][4] += nVlr90Dias 
        endif

        IF QRYPRO->TIPO = 'MP'
            aAdd(aColsMP, { cvaltochar(QRYPRO->EMPRESA),;                                                                                // 1 - Filial
                       cValtochar(QRYPRO->PRODUTO),;                                                                                // 2 - Produto
                       QRYPRO->DESCRICAO,;                                                                                          // 3 - Descrição
                       QRYPRO->TIPO,;                                                                                               // 4 - Tipo
                       cValtoChar(QRYPRO->ARMAZEM),;                                                                                // 5 - Local
                       QRYPRO->CUSTO,;                                                                                              // 6 - Custo                       
                       nConsumo,;                                                                                                   // 7 - Consumo                       
                       nConsDia,;                                                                                                   // 8 - Cons.Diario
                       QRYPRO->SALDO,;                                                                                              // 9 - Saldo
                       QRYPRO->TOTAL,;                                                                                              // 10 - Total
                       nEstoque,;                                                                                                   // 11 - Dias.Estoque
                       QRYPRO->EMPENHO,;                                                                                            // 12 - Empenho
                       QRYPRO->DISPONIVEL,;                                                                                         // 13 - Disponivel
                       nDiasDisp,;                                                                                                  // 14 - Dias.Diponivel
                       nQtSlow,;                                                                                                    // 15 - SlowMov Qtd
                       nVlrSlow,;                                                                                                   // 16 - SlowMov R$
                       nDiaSlow,;                                                                                                   // 17 - SlowMov Dia
                       n90Dias,;                                                                                                    // 18 - Consumo 60Dias
                       nPerct,;                                                                                                     // 19 - Percentual         
                       nPosicao})                                                                                                   // 20 - Podsicao

        ELSEIF QRYPRO->TIPO = 'EM'
            aAdd(aColsEM,  { cvaltochar(QRYPRO->EMPRESA),;                                                                                // 1 - Filial
                       cValtochar(QRYPRO->PRODUTO),;                                                                                // 2 - Produto
                       QRYPRO->DESCRICAO,;                                                                                          // 3 - Descrição
                       QRYPRO->TIPO,;                                                                                               // 4 - Tipo
                       cValtoChar(QRYPRO->ARMAZEM),;                                                                                // 5 - Local
                       QRYPRO->CUSTO,;                                                                                              // 6 - Custo                       
                       nConsumo,;                                                                                                   // 7 - Consumo                       
                       nConsDia,;                                                                                                   // 8 - Cons.Diario
                       QRYPRO->SALDO,;                                                                                              // 9 - Saldo
                       QRYPRO->TOTAL,;                                                                                              // 10 - Total
                       nEstoque,;                                                                                                   // 11 - Dias.Estoque
                       QRYPRO->EMPENHO,;                                                                                            // 12 - Empenho
                       QRYPRO->DISPONIVEL,;                                                                                         // 13 - Disponivel
                       nDiasDisp,;                                                                                                  // 14 - Dias.Diponivel
                       nQtSlow,;                                                                                                    // 15 - SlowMov Qtd
                       nVlrSlow,;                                                                                                   // 16 - SlowMov R$
                       nDiaSlow,;                                                                                                   // 17 - SlowMov Dia
                       n90Dias,;                                                                                                    // 18 - Consumo 60Dias
                       nPerct,;                                                                                                     // 19 - Percentual         
                       nPosicao,;                                                                                                   // 20 - Podsicao
                        QRYPRO->COMPRA})                                                                                            // 20 - Tipo Compras

        ELSEIF QRYPRO->TIPO = 'PI'
             aAdd(aColsPI, { cvaltochar(QRYPRO->EMPRESA),;                                                                                // 1 - Filial
                       cValtochar(QRYPRO->PRODUTO),;                                                                                // 2 - Produto
                       QRYPRO->DESCRICAO,;                                                                                          // 3 - Descrição
                       QRYPRO->TIPO,;                                                                                               // 4 - Tipo
                       cValtoChar(QRYPRO->ARMAZEM),;                                                                                // 5 - Local
                       QRYPRO->CUSTO,;                                                                                              // 6 - Custo                       
                       nConsumo,;                                                                                                   // 7 - Consumo                       
                       nConsDia,;                                                                                                   // 8 - Cons.Diario
                       QRYPRO->SALDO,;                                                                                              // 9 - Saldo
                       QRYPRO->TOTAL,;                                                                                              // 10 - Total
                       nEstoque,;                                                                                                   // 11 - Dias.Estoque
                       QRYPRO->EMPENHO,;                                                                                            // 12 - Empenho
                       QRYPRO->DISPONIVEL,;                                                                                         // 13 - Disponivel
                       nDiasDisp,;                                                                                                  // 14 - Dias.Diponivel
                       nQtSlow,;                                                                                                    // 15 - SlowMov Qtd
                       nVlrSlow,;                                                                                                   // 16 - SlowMov R$
                       nDiaSlow,;                                                                                                   // 17 - SlowMov Dia
                       n90Dias,;                                                                                                    // 18 - Consumo 60Dias
                       nPerct,;                                                                                                     // 19 - Percentual         
                       nPosicao})                                                                                                   // 20 - Podsicao

         ELSEIF QRYPRO->TIPO = 'PA'
             aAdd(aColsPA, { cvaltochar(QRYPRO->EMPRESA),;                                                                                // 1 - Filial
                       cValtochar(QRYPRO->PRODUTO),;                                                                                // 2 - Produto
                       QRYPRO->DESCRICAO,;                                                                                          // 3 - Descrição
                       QRYPRO->TIPO,;                                                                                               // 4 - Tipo
                       cValtoChar(QRYPRO->ARMAZEM),;                                                                                // 5 - Local
                       QRYPRO->CUSTO,;                                                                                              // 6 - Custo                       
                       nConsumo,;                                                                                                   // 7 - Consumo                       
                       nConsDia,;                                                                                                   // 8 - Cons.Diario
                       QRYPRO->SALDO,;                                                                                              // 9 - Saldo
                       QRYPRO->TOTAL,;                                                                                              // 10 - Total
                       nEstoque,;                                                                                                   // 11 - Dias.Estoque
                       QRYPRO->EMPENHO,;                                                                                            // 12 - Empenho
                       QRYPRO->DISPONIVEL,;                                                                                         // 13 - Disponivel
                       nDiasDisp,;                                                                                                  // 14 - Dias.Diponivel
                       nQtSlow,;                                                                                                    // 15 - SlowMov Qtd
                       nVlrSlow,;                                                                                                   // 16 - SlowMov R$
                       nDiaSlow,;                                                                                                   // 17 - SlowMov Dia
                       n90Dias,;                                                                                                    // 18 - Consumo 60Dias
                       nPerct,;                                                                                                     // 19 - Percentual         
                       nPosicao})                                                                                                   // 20 - Podsicao    
        ENDIF            


        QRYPRO->(DbSkip())
    EndDo    
    QRYPRO->(DbCloseArea())

    aSort(aBrowse, , ,   {|x, y| x[nPosOrd] > y[nPosOrd]  }) //Ordenando o Array 

    if len(aBrowse) > 0
       for Ny:=1 to len(aBrowse)

           oFWMsExcel:AddRow("Consumo","Produtos",{ aBrowse[Ny][1],;   // 1 - Filial
                                                    aBrowse[Ny][2],;  // 2 - Produto
                                                    aBrowse[Ny][3],;  // 3 - Descrição
                                                    aBrowse[Ny][4],;  // 4 - Tipo
                                                    aBrowse[Ny][5],;  // 5 - Local
                                                    aBrowse[Ny][6],;  // 6 - Custo 
                                                    aBrowse[Ny][7],;  // 7 - Consumo
                                                    aBrowse[Ny][8],;  // 8 - Consumo Diario
                                                    aBrowse[Ny][9],;  // 9 - Saldo
                                                    aBrowse[Ny][10],; // 10 - Total
                                                    aBrowse[Ny][11],; // 11 - Dias Estoque
                                                    aBrowse[Ny][12],; // 12 - Empenho
                                                    aBrowse[Ny][13],; // 13 - Disponivel
                                                    aBrowse[Ny][14],; // 14 - Dias Disponivel
                                                    aBrowse[Ny][15],; // 15 - SlowMov Qtd
                                                    aBrowse[Ny][16],; // 16 - SlowMov valor
                                                    aBrowse[Ny][17],; // 17 - SlowMov Dia
                                                    aBrowse[Ny][19]} )  // 19 - Percentual
            next

    Endif

     
    //Aba 02 - Percentuais
    oFWMsExcel:AddworkSheet("Percentual") //Não utilizar número junto com sinal de menos. Ex.: 1-
    oFWMsExcel:AddTable("Percentual","Indicadores")
    oFWMsExcel:AddColumn("Percentual","Indicadores","Tipo",2,2)         //1 = Modo Texto    
    oFWMsExcel:AddColumn("Percentual","Indicadores","Total",2,2)        //1 = Modo Texto
    oFWMsExcel:AddColumn("Percentual","Indicadores","SlowMoving",2,2)   //2 = Valor sem R$
    oFWMsExcel:AddColumn("Percentual","Indicadores","Percente",2,2)     //2 = Valor sem R$
    oFWMsExcel:AddColumn("Percentual","Indicadores","Cons 90Dias",2,2)  //2 = Valor sem R$
    oFWMsExcel:AddColumn("Percentual","Indicadores","%Perc",2,2)        //2 = Valor sem R$

    
    if len(aIndicadores) > 0
       for Ny:=1 to len(aIndicadores)
           oFWMsExcel:AddRow("Percentual","Indicadores",{aIndicadores[Ny][1],;                              // 1 - Tipo
                                                        aIndicadores[Ny][2],;                               // 2 - Total
                                                        aIndicadores[Ny][3],;                               // 3 - SlowMoving
                                                        ((aIndicadores[Ny][3]/aIndicadores[Ny][2])*100),;   // 4 - Percente
                                                        aIndicadores[Ny][4],;                               // 5 - Cons 60Dias
                                                        ((aIndicadores[Ny][4]/aIndicadores[Ny][2])*100)} )  // 6 - %Perc
       next
    Endif
    oFWMsExcel:AddRow("Percentual","Indicadores",{"Geral",nTotalGeral,nTotalSlow,(nTotalSlow/nTotalGeral)*100,nTotalCons,(nTotalCons/nTotalGeral)*100})

    oFWMsExcel:AddworkSheet("MATERIA PRIMA") //Não utilizar número junto com sinal de menos. Ex.: 1-

    //Criando a Tabela
    oFWMsExcel:AddTable("MATERIA PRIMA","Produtos")
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Empresa",1,1)        //1 = Modo Texto      1
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Produto",1,1)        //1 = Modo Texto      2
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Descricao",1,1)      //1 = Modo Texto      3
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Tipo",1,1)           //1 = Modo Texto      4
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Local",1,1)          //1 = Modo Texto      5
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Custo",3,3)          //3 = Valor com R$    6
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Consumo",2,2)        //2 = Valor sem R$    7
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$    8
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Saldo",2,2)          //2 = Valor sem R$    9
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Total",3,3)          //3 = Valor com R$    10
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$    11
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Empenho",2,2)        //2 = Valor sem R$    12
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Disponivel",2,2)     //2 = Valor sem R$    14
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$    15
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","SlowMov Qtd",2,2)    //2 = Valor sem R$    16
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","SlowMov R$",3,3)     //3 = Valor com R$    17
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","SlowMov Dia",2,2)    //2 = Valor sem R$    18
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","SlowMov %",2,2)    //2 = Valor sem R$      19
    oFWMsExcel:AddColumn("MATERIA PRIMA","Produtos","Prioridade",2,2) //2 = Valor sem R$        20

    aSort(aColsMP, , ,  {|x, y| x[nPosOrd] > y[nPosOrd]  }) //Ordenando o Array 

      if len(aColsMP) > 0
       for Ny:=1 to len(aColsMP)
            cStatus := iif(Ny<=20,"Sim","")
            oFWMsExcel:AddRow("MATERIA PRIMA","Produtos",{  aColsMP[Ny][1],;   // 1 - Filial
                                                            aColsMP[Ny][2],;  // 2 - Produto
                                                            aColsMP[Ny][3],;  // 3 - Descrição
                                                            aColsMP[Ny][4],;  // 4 - Tipo
                                                            aColsMP[Ny][5],;  // 5 - Local
                                                            aColsMP[Ny][6],;  // 6 - Custo 
                                                            aColsMP[Ny][7],;  // 7 - Consumo
                                                            aColsMP[Ny][8],;  // 8 - Consumo Diario
                                                            aColsMP[Ny][9],;  // 9 - Saldo
                                                            aColsMP[Ny][10],; // 10 - Total
                                                            aColsMP[Ny][11],; // 11 - Dias Estoque
                                                            aColsMP[Ny][12],; // 12 - Empenho
                                                            aColsMP[Ny][13],; // 13 - Disponivel
                                                            aColsMP[Ny][14],; // 14 - Dias Disponivel
                                                            aColsMP[Ny][15],; // 15 - SlowMov Qtd
                                                            aColsMP[Ny][16],; // 16 - SlowMov valor
                                                            aColsMP[Ny][17],; // 17 - SlowMov Dia
                                                            aColsMP[Ny][19],; // 19 - Percentual
                                                            cStatus} )        // 20 - Status
            
        NEXT
      Endif 

     oFWMsExcel:AddworkSheet("EMBALAGEM") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("EMBALAGEM","Produtos")
    //Criando Colunas
    oFWMsExcel:AddTable("EMBALAGEM","Produtos")
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Empresa",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Produto",1,1)        //1 = Modo Texto  2
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Descricao",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Tipo",1,1)           //1 = Modo Texto  4
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Local",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Custo",3,3)          //3 = Valor com R$ 6
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Consumo",2,2)        //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Saldo",2,2)          //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Total",3,3)          //3 = Valor com R$ 10
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Empenho",2,2)        //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Disponivel",2,2)     //2 = Valor sem R$ 14
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$ 15
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","SlowMov Qtd",2,2)    //2 = Valor sem R$ 16
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","SlowMov R$",3,3)     //3 = Valor com R$ 17
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","SlowMov Dia",2,2)    //2 = Valor sem R$ 18
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","SlowMov %",2,2)    //2 = Valor sem R$      19
    oFWMsExcel:AddColumn("EMBALAGEM","Produtos","Prioridade",2,2) //2 = Valor sem R$ 19

     aSort(aColsEM, , , {|x, y| x[nPosOrd] > y[nPosOrd]  }) //Ordenando o Array 
     cContaLinhas   := 1
      if len(aColsEM) > 0
       for Ny:=1 to len(aColsEM)
            if aColsEM[Ny][21] = "P"
                cStatus := iif(cContaLinhas<=20,"Sim","")
                oFWMsExcel:AddRow("EMBALAGEM","Produtos",{  aColsEM[Ny][1],;   // 1 - Filial
                                                                aColsEM[Ny][2],;  // 2 - Produto
                                                                aColsEM[Ny][3],;  // 3 - Descrição
                                                                aColsEM[Ny][4],;  // 4 - Tipo
                                                                aColsEM[Ny][5],;  // 5 - Local
                                                                aColsEM[Ny][6],;  // 6 - Custo 
                                                                aColsEM[Ny][7],;  // 7 - Consumo
                                                                aColsEM[Ny][8],;  // 8 - Consumo Diario
                                                                aColsEM[Ny][9],;  // 9 - Saldo
                                                                aColsEM[Ny][10],; // 10 - Total
                                                                aColsEM[Ny][11],; // 11 - Dias Estoque
                                                                aColsEM[Ny][12],; // 12 - Empenho
                                                                aColsEM[Ny][13],; // 13 - Disponivel
                                                                aColsEM[Ny][14],; // 14 - Dias Disponivel
                                                                aColsEM[Ny][15],; // 15 - SlowMov Qtd
                                                                aColsEM[Ny][16],; // 16 - SlowMov valor
                                                                aColsEM[Ny][17],; // 17 - SlowMov Dia
                                                                aColsEM[Ny][19],; // 19 - Percentual
                                                                cStatus} )        // 20 - Status
                                                                cContaLinhas++
           Endif                                                 

       NEXT
      Endif 

    oFWMsExcel:AddworkSheet("INTERMEDIARIO") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("INTERMEDIARIO","Produtos")
    //Criando Colunas
    oFWMsExcel:AddTable("INTERMEDIARIO","Produtos")
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Empresa",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Produto",1,1)        //1 = Modo Texto  2
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Descricao",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Tipo",1,1)           //1 = Modo Texto  4
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Local",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Custo",3,3)          //3 = Valor com R$ 6
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Consumo",2,2)        //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Saldo",2,2)          //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Total",3,3)          //3 = Valor com R$ 10
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Empenho",2,2)        //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Disponivel",2,2)     //2 = Valor sem R$ 14
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$ 15
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","SlowMov Qtd",2,2)    //2 = Valor sem R$ 16
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","SlowMov R$",3,3)     //3 = Valor com R$ 17
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","SlowMov Dia",2,2)    //2 = Valor sem R$ 18
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","SlowMov %",2,2)    //2 = Valor sem R$      19
    oFWMsExcel:AddColumn("INTERMEDIARIO","Produtos","Prioridade",2,2) //2 = Valor sem R$ 19

    aSort(aColsPI, , ,  {|x, y| x[nPosOrd] > y[nPosOrd]  }) //Ordenando o Array 

      if len(aColsPI) > 0
       for Ny:=1 to len(aColsPI)
            cStatus := iif(Ny<=20,"Sim","")
            oFWMsExcel:AddRow("INTERMEDIARIO","Produtos",{  aColsPI[Ny][1],;   // 1 - Filial
                                                            aColsPI[Ny][2],;  // 2 - Produto
                                                            aColsPI[Ny][3],;  // 3 - Descrição
                                                            aColsPI[Ny][4],;  // 4 - Tipo
                                                            aColsPI[Ny][5],;  // 5 - Local
                                                            aColsPI[Ny][6],;  // 6 - Custo 
                                                            aColsPI[Ny][7],;  // 7 - Consumo
                                                            aColsPI[Ny][8],;  // 8 - Consumo Diario
                                                            aColsPI[Ny][9],;  // 9 - Saldo
                                                            aColsPI[Ny][10],; // 10 - Total
                                                            aColsPI[Ny][11],; // 11 - Dias Estoque
                                                            aColsPI[Ny][12],; // 12 - Empenho
                                                            aColsPI[Ny][13],; // 13 - Disponivel
                                                            aColsPI[Ny][14],; // 14 - Dias Disponivel
                                                            aColsPI[Ny][15],; // 15 - SlowMov Qtd
                                                            aColsPI[Ny][16],; // 16 - SlowMov valor
                                                            aColsPI[Ny][17],; // 17 - SlowMov Dia
                                                            aColsPI[Ny][19],; // 19 - Percentual
                                                            cStatus} )        // 20 - Status
       NEXT
      Endif 

    oFWMsExcel:AddworkSheet("ACABADO") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("ACABADO","Produtos")
    //Criando Colunas
    oFWMsExcel:AddTable("ACABADO","Produtos")
    oFWMsExcel:AddColumn("ACABADO","Produtos","Empresa",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("ACABADO","Produtos","Produto",1,1)        //1 = Modo Texto  2
    oFWMsExcel:AddColumn("ACABADO","Produtos","Descricao",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("ACABADO","Produtos","Tipo",1,1)           //1 = Modo Texto  4
    oFWMsExcel:AddColumn("ACABADO","Produtos","Local",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("ACABADO","Produtos","Custo",3,3)          //3 = Valor com R$ 6
    oFWMsExcel:AddColumn("ACABADO","Produtos","Consumo",2,2)        //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("ACABADO","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("ACABADO","Produtos","Saldo",2,2)          //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("ACABADO","Produtos","Total",3,3)          //3 = Valor com R$ 10
    oFWMsExcel:AddColumn("ACABADO","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("ACABADO","Produtos","Empenho",2,2)        //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("ACABADO","Produtos","Disponivel",2,2)     //2 = Valor sem R$ 14
    oFWMsExcel:AddColumn("ACABADO","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$ 15
    oFWMsExcel:AddColumn("ACABADO","Produtos","SlowMov Qtd",2,2)    //2 = Valor sem R$ 16
    oFWMsExcel:AddColumn("ACABADO","Produtos","SlowMov R$",3,3)     //3 = Valor com R$ 17
    oFWMsExcel:AddColumn("ACABADO","Produtos","SlowMov Dia",2,2)    //2 = Valor sem R$ 18
    oFWMsExcel:AddColumn("ACABADO","Produtos","SlowMov %",2,2)    //2 = Valor sem R$      19
    oFWMsExcel:AddColumn("ACABADO","Produtos","Prioridade",2,2) //2 = Valor sem R$ 19

    aSort(aColsPA, , ,  {|x, y| x[nPosOrd] > y[nPosOrd]  }) //Ordenando o Array 

      if len(aColsPA) > 0
       for Ny:=1 to len(aColsPA)
            cStatus := iif(Ny<=20,"Sim","")
            oFWMsExcel:AddRow("ACABADO","Produtos",{  aColsPA[Ny][1],;   // 1 - Filial
                                                            aColsPA[Ny][2],;  // 2 - Produto
                                                            aColsPA[Ny][3],;  // 3 - Descrição
                                                            aColsPA[Ny][4],;  // 4 - Tipo
                                                            aColsPA[Ny][5],;  // 5 - Local
                                                            aColsPA[Ny][6],;  // 6 - Custo 
                                                            aColsPA[Ny][7],;  // 7 - Consumo
                                                            aColsPA[Ny][8],;  // 8 - Consumo Diario
                                                            aColsPA[Ny][9],;  // 9 - Saldo
                                                            aColsPA[Ny][10],; // 10 - Total
                                                            aColsPA[Ny][11],; // 11 - Dias Estoque
                                                            aColsPA[Ny][12],; // 12 - Empenho
                                                            aColsPA[Ny][13],; // 13 - Disponivel
                                                            aColsPA[Ny][14],; // 14 - Dias Disponivel
                                                            aColsPA[Ny][15],; // 15 - SlowMov Qtd
                                                            aColsPA[Ny][16],; // 16 - SlowMov valor
                                                            aColsPA[Ny][17],; // 17 - SlowMov Dia
                                                            aColsPA[Ny][19],; // 19 - Percentual
                                                            cStatus} )        // 20 - Status
       NEXT
      Endif 

IF MV_PAR03 = 1
    cQuery :="SELECT  PRODUTO, "+cEof 
    cQuery +="		SUM(JAN) JANEIRO, "+cEof  
    cQuery +="		SUM(FEV) FEVEREIRO, "+cEof 
    cQuery +="		SUM(MAR) MARCO, "+cEof 
    cQuery +="		SUM(ABR) ABRIL, "+cEof 
    cQuery +="		SUM(MAI) MAIO, "+cEof 
    cQuery +="		SUM(JUN) JUNHO, "+cEof 
    cQuery +="		SUM(JUL) JULHO, "+cEof 
    cQuery +="		SUM(AGO) AGOSTO, "+cEof 
    cQuery +="		SUM(SETE) SETEMBRO, "+cEof 
    cQuery +="		SUM(OUTO) OUTUBRO, "+cEof 
    cQuery +="		SUM(NOV) NOVEMBRO, "+cEof 
    cQuery +="		SUM(DEZ) DEZEMBRO  "+cEof 
    cQuery +="FROM( "+cEof 
    cQuery +="SELECT PRODUTO AS 'PRODUTO', "+cEof 
    cQuery +="		ISNULL([1],0)  AS 'JAN',  "+cEof 
    cQuery +="		ISNULL([2],0)  AS 'FEV',  "+cEof 
    cQuery +="		ISNULL([3],0)  AS 'MAR', "+cEof  
    cQuery +="		ISNULL([4],0)  AS 'ABR',  "+cEof 
    cQuery +="		ISNULL([5],0)  AS 'MAI',  "+cEof 
    cQuery +="		ISNULL([6],0)  AS 'JUN',  "+cEof 
    cQuery +="		ISNULL([7],0)  AS 'JUL', "+cEof  
    cQuery +="		ISNULL([8],0)  AS 'AGO', "+cEof  
    cQuery +="		ISNULL([9],0)  AS 'SETE', "+cEof  
    cQuery +="		ISNULL([10],0) AS 'OUTO', "+cEof  
    cQuery +="		ISNULL([11],0) AS 'NOV', "+cEof  
    cQuery +="		ISNULL([12],0) AS 'DEZ'  "+cEof  
    cQuery +="		FROM ( 	Select  "+cEof 
    cQuery +="					D4_COD PRODUTO, "+cEof 
    cQuery +="					YEAR(D4_DATA) ANO, "+cEof 
    cQuery +="					MONTH(D4_DATA) MES, "+cEof 
    cQuery +="					SUM(D4_QTDEORI) QTDE "+cEof 
    cQuery +="				from "+RetSqlName("SD4")+"  SD4 "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB1")+"  SB1 ON B1_COD = D4_COD AND B1_TIPO  IN ( 'EM','MP','PI') AND SB1.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				Where SD4.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				AND D4_FILIAL = '"+xFilial("SD4")+"' "+cEof 
    cQuery +="				AND YEAR(D4_DATA) = YEAR(GETDATE())-1 "+cEof 
    cQuery +="				AND MONTH(D4_DATA) > MONTH(GETDATE()) "+cEof 
    cQuery +="				GROUP BY D4_COD,YEAR(D4_DATA),MONTH(D4_DATA) "+cEof 
    cQuery +="				 ) ARQ "+cEof 
    cQuery +=" PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT  "+cEof 
    cQuery +=" WHERE PT.ANO = YEAR(GETDATE())-1  "+cEof 
    cQuery +=" union "+cEof 
    cQuery +=" SELECT PRODUTO AS 'PRODUTO', "+cEof 
    cQuery +="		ISNULL([1],0)  AS 'JAN',  "+cEof 
    cQuery +="		ISNULL([2],0)  AS 'FEV',  "+cEof 
    cQuery +="		ISNULL([3],0)  AS 'MAR',  "+cEof 
    cQuery +="		ISNULL([4],0)  AS 'ABR',  "+cEof 
    cQuery +="		ISNULL([5],0)  AS 'MAI',  "+cEof 
    cQuery +="		ISNULL([6],0)  AS 'JUN',  "+cEof 
    cQuery +="		ISNULL([7],0)  AS 'JUL',  "+cEof 
    cQuery +="		ISNULL([8],0)  AS 'AGO',  "+cEof 
    cQuery +="		ISNULL([9],0)  AS 'SETE',  "+cEof 
    cQuery +="		ISNULL([10],0) AS 'OUTO',  "+cEof 
    cQuery +="		ISNULL([11],0) AS 'NOV',  "+cEof 
    cQuery +="		ISNULL([12],0) AS 'DEZ'   "+cEof 
    cQuery +="		FROM ( 	Select  "+cEof 
    cQuery +="					D4_COD PRODUTO, "+cEof 
    cQuery +="					YEAR(D4_DATA) ANO, "+cEof 
    cQuery +="					MONTH(D4_DATA) MES, "+cEof 
    cQuery +="					SUM(D4_QTDEORI) QTDE "+cEof 
    cQuery +="				from "+RetSqlName("SD4")+" SD4 "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = D4_COD AND B1_TIPO  IN ( 'EM','MP','PI') AND SB1.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = D4_FILIAL AND B2_COD = D4_COD AND B2_LOCAL = D4_LOCAL AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				Where SD4.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				AND D4_FILIAL ='"+xFilial("SD4")+"'  "+cEof 
    cQuery +="				AND YEAR(D4_DATA) = YEAR(GETDATE())  "+cEof 
    cQuery +="				GROUP BY D4_COD,YEAR(D4_DATA),MONTH(D4_DATA)  "+cEof 
    cQuery +="				 ) ARQ  "+cEof 
    cQuery +=" PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT  "+cEof 
    cQuery +=" WHERE PT.ANO = YEAR(GETDATE()) "+cEof 
    cQuery +=" ) ARQ "+cEof 
    cQuery +=" GROUP BY PRODUTO "+cEof 
    cQuery +=" ORDER BY PRODUTO "+cEof 
    
    If  Select("QRYMED1") > 0
                DbSelectArea("QRYMED1")
                DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYMED1"


    oFWMsExcel:AddworkSheet("Demanda") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("Demanda","Produtos")
    //Criando Colunas
    oFWMsExcel:AddColumn("Demanda","Produtos","Produto",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("Demanda","Produtos","Janeiro",2,2)       //2 = Valor sem R$ 2
    oFWMsExcel:AddColumn("Demanda","Produtos","Fevereiro",2,2)     //2 = Valor sem R$ 3
    oFWMsExcel:AddColumn("Demanda","Produtos","Março",2,2)         //2 = Valor sem R$ 4
    oFWMsExcel:AddColumn("Demanda","Produtos","Abril",2,2)         //2 = Valor sem R$ 5
    oFWMsExcel:AddColumn("Demanda","Produtos","Maio",2,2)          //2 = Valor sem R$ 6
    oFWMsExcel:AddColumn("Demanda","Produtos","Junho",2,2)         //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("Demanda","Produtos","Julho",2,2)         //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("Demanda","Produtos","Agosto",2,2)        //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("Demanda","Produtos","Setembro",2,2)      //2 = Valor sem R$ 10
    oFWMsExcel:AddColumn("Demanda","Produtos","Outubro",2,2)       //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("Demanda","Produtos","Novembro",2,2)      //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("Demanda","Produtos","Dezembro",2,2)      //2 = Valor sem R$ 13
    While !(QRYMED1->(EoF()))
        oFWMsExcel:AddRow("Demanda","Produtos",{QRYMED1->PRODUTO,;
                                                        QRYMED1->JANEIRO,;
                                                        QRYMED1->FEVEREIRO,;
                                                        QRYMED1->MARCO,;
                                                        QRYMED1->ABRIL,;
                                                        QRYMED1->MAIO,;
                                                        QRYMED1->JUNHO,;
                                                        QRYMED1->JULHO,;
                                                        QRYMED1->AGOSTO,;
                                                        QRYMED1->SETEMBRO,;
                                                        QRYMED1->OUTUBRO,;
                                                        QRYMED1->NOVEMBRO,;
                                                        QRYMED1->DEZEMBRO})
        QRYMED1->(DbSkip())
    Enddo
    QRYMED1->(DbCloseArea())

    cQuery :=" SELECT  PRODUTO, "+cEof 
    cQuery +="		SUM(JAN) JANEIRO, "+cEof 
    cQuery +="		SUM(FEV) FEVEREIRO, "+cEof 
    cQuery +="		SUM(MAR) MARCO, "+cEof 
    cQuery +="		SUM(ABR) ABRIL, "+cEof 
    cQuery +="		SUM(MAI) MAIO, "+cEof 
    cQuery +="		SUM(JUN) JUNHO, "+cEof 
    cQuery +="		SUM(JUL) JULHO, "+cEof 
    cQuery +="		SUM(AGO) AGOSTO, "+cEof 
    cQuery +="		SUM(SETE) SETEMBRO, "+cEof 
    cQuery +="		SUM(OUTO) OUTUBRO, "+cEof 
    cQuery +="		SUM(NOV) NOVEMBRO, "+cEof 
    cQuery +="		SUM(DEZ) DEZEMBRO  "+cEof 
    cQuery +="FROM( "+cEof 
    cQuery +="SELECT PRODUTO AS 'PRODUTO', "+cEof 
    cQuery +="		ISNULL([1],0)  AS 'JAN',  "+cEof 
    cQuery +="		ISNULL([2],0)  AS 'FEV',  "+cEof 
    cQuery +="		ISNULL([3],0)  AS 'MAR',  "+cEof 
    cQuery +="		ISNULL([4],0)  AS 'ABR',  "+cEof 
    cQuery +="		ISNULL([5],0)  AS 'MAI',  "+cEof 
    cQuery +="		ISNULL([6],0)  AS 'JUN',  "+cEof 
    cQuery +="		ISNULL([7],0)  AS 'JUL',  "+cEof 
    cQuery +="		ISNULL([8],0)  AS 'AGO',  "+cEof 
    cQuery +="		ISNULL([9],0)  AS 'SETE',  "+cEof 
    cQuery +="		ISNULL([10],0) AS 'OUTO',  "+cEof 
    cQuery +="		ISNULL([11],0) AS 'NOV',  "+cEof 
    cQuery +="		ISNULL([12],0) AS 'DEZ'   "+cEof 
    cQuery +="		FROM ( 	Select  "+cEof 
    cQuery +="					C6_PRODUTO PRODUTO, "+cEof 
    cQuery +="					YEAR(C6_DATFAT) ANO, "+cEof 
    cQuery +="					MONTH(C6_DATFAT) MES, "+cEof 
    cQuery +="					SUM(C6_QTDVEN) QTDE "+cEof 
    cQuery +="				from "+RetSqlName("SC6")+" SC6 "+cEof 
    cQuery +="				INNER JOIN  "+RetSqlName("SB1")+" SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO  IN ('PA') AND SB1.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				INNER JOIN  "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = C6_FILIAL AND B2_COD = C6_PRODUTO AND B2_LOCAL = C6_LOCAL AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				Where SC6.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				AND C6_FILIAL = '"+xFilial("SC6")+"' "+cEof 
    cQuery +="				AND YEAR(C6_DATFAT) =YEAR(GETDATE())-1 "+cEof 
    cQuery +="				GROUP BY C6_PRODUTO,YEAR(C6_DATFAT),MONTH(C6_DATFAT) "+cEof 
    cQuery +="				 ) ARQ "+cEof 
    cQuery +=" PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT  "+cEof 
    cQuery +=" WHERE PT.ANO = YEAR(GETDATE())-1 "+cEof 
    cQuery +=" union "+cEof 
    cQuery +=" SELECT PRODUTO AS 'PRODUTO', "+cEof 
    cQuery +="		ISNULL([1],0)  AS 'JAN',  "+cEof 
    cQuery +="		ISNULL([2],0)  AS 'FEV',  "+cEof  
    cQuery +="		ISNULL([3],0)  AS 'MAR',  "+cEof 
    cQuery +="		ISNULL([4],0)  AS 'ABR',  "+cEof 
    cQuery +="		ISNULL([5],0)  AS 'MAI',  "+cEof 
    cQuery +="		ISNULL([6],0)  AS 'JUN',  "+cEof 
    cQuery +="		ISNULL([7],0)  AS 'JUL',  "+cEof 
    cQuery +="		ISNULL([8],0)  AS 'AGO',  "+cEof 
    cQuery +="		ISNULL([9],0)  AS 'SETE',  "+cEof 
    cQuery +="		ISNULL([10],0) AS 'OUTO',  "+cEof 
    cQuery +="		ISNULL([11],0) AS 'NOV',  "+cEof 
    cQuery +="		ISNULL([12],0) AS 'DEZ'   "+cEof 
    cQuery +="		FROM ( 	Select  "+cEof 
    cQuery +="					C6_PRODUTO PRODUTO, "+cEof 
    cQuery +="					YEAR(C6_DATFAT) ANO, "+cEof 
    cQuery +="					MONTH(C6_DATFAT) MES, "+cEof 
    cQuery +="					SUM(C6_QTDVEN) QTDE "+cEof 
    cQuery +="				from "+RetSqlName("SC6")+" SC6 "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = C6_PRODUTO AND B1_TIPO  IN ( 'PA') AND SB1.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				INNER JOIN "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = C6_FILIAL AND B2_COD = C6_PRODUTO AND B2_LOCAL = C6_LOCAL AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				Where SC6.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="				AND C6_FILIAL =  '"+xFilial("SC6")+"' "+cEof 
    cQuery +="				AND YEAR(C6_DATFAT) = YEAR(GETDATE()) "+cEof 
    cQuery +="				GROUP BY C6_PRODUTO,YEAR(C6_DATFAT),MONTH(C6_DATFAT) "+cEof 
    cQuery +="				 ) ARQ "+cEof 
    cQuery +=" PIVOT ( SUM(QTDE) FOR MES IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]  ) ) AS  PT  "+cEof 
    cQuery +=" WHERE PT.ANO = YEAR(GETDATE())  "+cEof 
    cQuery +=" ) ARQ "+cEof 
    cQuery +=" GROUP BY PRODUTO "+cEof 
    cQuery +=" ORDER BY PRODUTO "+cEof 

    If  Select("QRYMED2") > 0
                DbSelectArea("QRYMED2")
                DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYMED2"

    oFWMsExcel:AddworkSheet("Vendas") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("Vendas","Produtos")
    //Criando Colunas
    oFWMsExcel:AddColumn("Vendas","Produtos","Produto",1,1)        //1 = Modo Texto  1
    oFWMsExcel:AddColumn("Vendas","Produtos","Janeiro",2,2)       //2 = Valor sem R$ 2
    oFWMsExcel:AddColumn("Vendas","Produtos","Fevereiro",2,2)     //2 = Valor sem R$ 3
    oFWMsExcel:AddColumn("Vendas","Produtos","Março",2,2)         //2 = Valor sem R$ 4
    oFWMsExcel:AddColumn("Vendas","Produtos","Abril",2,2)         //2 = Valor sem R$ 5
    oFWMsExcel:AddColumn("Vendas","Produtos","Maio",2,2)          //2 = Valor sem R$ 6
    oFWMsExcel:AddColumn("Vendas","Produtos","Junho",2,2)         //2 = Valor sem R$ 7
    oFWMsExcel:AddColumn("Vendas","Produtos","Julho",2,2)         //2 = Valor sem R$ 8
    oFWMsExcel:AddColumn("Vendas","Produtos","Agosto",2,2)        //2 = Valor sem R$ 9
    oFWMsExcel:AddColumn("Vendas","Produtos","Setembro",2,2)      //2 = Valor sem R$ 10
    oFWMsExcel:AddColumn("Vendas","Produtos","Outubro",2,2)       //2 = Valor sem R$ 11
    oFWMsExcel:AddColumn("Vendas","Produtos","Novembro",2,2)      //2 = Valor sem R$ 12
    oFWMsExcel:AddColumn("Vendas","Produtos","Dezembro",2,2)      //2 = Valor sem R$ 13

    While !(QRYMED2->(EoF()))
        oFWMsExcel:AddRow("Vendas","Produtos",{QRYMED2->PRODUTO,;
                                                        QRYMED2->JANEIRO,;
                                                        QRYMED2->FEVEREIRO,;
                                                        QRYMED2->MARCO,;
                                                        QRYMED2->ABRIL,;
                                                        QRYMED2->MAIO,;
                                                        QRYMED2->JUNHO,;
                                                        QRYMED2->JULHO,;
                                                        QRYMED2->AGOSTO,;
                                                        QRYMED2->SETEMBRO,;
                                                        QRYMED2->OUTUBRO,;
                                                        QRYMED2->NOVEMBRO,;
                                                        QRYMED2->DEZEMBRO})
        QRYMED2->(DbSkip())
    Enddo
     QRYMED2->(DbCloseArea())
ENDIF

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)      //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
    RestArea(aArea)
Return

