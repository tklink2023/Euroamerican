#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

#Define cEof    Chr(13)+Chr(10)


User Function PCPM110()
    Local cArea    := FwGetArea()
    Local aPergs   := {}
    Local nFator   := 0
    Local nCurva   := 0
 
    aAdd(aPergs, {1, "Digite o Fator : ",  nFator,  "@E 999,999", "Positivo()", "", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Digite % Curva :" ,  nCurva,  "@E 999,999", "Positivo()", "", ".T.", 80,  .F.})
    
    If ParamBox(aPergs, "Informe os parâmetros")
        If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
            MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| RunProc(MV_PAR01, MV_PAR02) })
        endif    
    EndIf    

    FwRestArea(cArea)
Return 

Static Function  RunProc(nFator, nCurva)
    Local cArea := FwGetArea()
    Local nMinCurvaA := nCurva
    Local nMaxCurvaA := nMinCurvaA * nFator
    Local nMinCurvaB := nCurva * 2   
    Local nMaxCurvaB := nMinCurvaB * nFator
    Local nMinCurvaC := nCurva * 3
    Local nMaxCurvaC := nMinCurvaC * nFator
    Local cAlias   := GetNextAlias()
    Local cQuery   := ''

    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'PCPE110.xml'  

    cQuery := "Select SG1.G1_COMP  COMPONENTE	"+CRLF
    cQuery += "     ,B2_COD		PRODUTO "+CRLF
    cQuery += "		,SB1.B1_DESC	DESCRICAO "+CRLF
    cQuery += "		,SB1.B1_UM		UM "+CRLF
    cQuery += "		,SB1.B1_PESO	PESO "+CRLF
    cQuery += "		,SB1.B1_LE  	REPOSICAO "+CRLF
    cQuery += "		,B2_LOCAL	ALMOX "+CRLF
    cQuery += "		,SB1.B1_TIPO	TIPO "+CRLF
    cQuery += "		,CASE WHEN SB1.B1_XCLASSI = 'L' THEN 'LINHA' ELSE 'ESPECIAL' END AS CLASSE "+CRLF
    cQuery += "	    ,CASE	WHEN SB1.B1_XTPBASE = 'A' THEN 'Agua' "+CRLF
    cQuery += "				WHEN SB1.B1_XTPBASE = 'S' THEN 'Solvente' "+CRLF
    cQuery += "				WHEN SB1.B1_XTPBASE = 'C' THEN 'Acrilico' "+CRLF
    cQuery += "				WHEN SB1.B1_XTPBASE = 'V' THEN 'Viniculo' "+CRLF
    cQuery += "				WHEN SB1.B1_XTPBASE = 'O' THEN 'Outros' "+CRLF
    cQuery += "				else 'Sem Tipo' end AS LINHA "+CRLF
    cQuery += "		,CASE WHEN SB1.B1_MSBLQL = '1' THEN 'Bloqueado' else 'Ativo' end SITUACAO "+CRLF
    cQuery += "		,SZ3.Z3_CURVA	AS CURVA "+CRLF
    cQuery += "		,ROUND(B2_CM1,2) AS CUSTO "+CRLF
    cQuery += "		,B2_QATU		 AS SALDO "+CRLF
    cQuery += "		,(SELECT SUM(SC6.C6_QTDVEN) - SUM(SC6.C6_QTDENT) FROM " + RetSqlName("SC6") + " AS SC6 WITH (NOLOCK) WHERE SC6.D_E_L_E_T_ = '' AND SC6.C6_FILIAL = B2_FILIAL	AND SC6.C6_PRODUTO = B2_COD	AND SC6.C6_LOCAL = B2_LOCAL	AND SC6.C6_BLQ NOT IN ('R')) AS PEDIDOS "+CRLF
    cQuery += "		,ISNULL((SELECT SUM(SC2.C2_QUANT - SC2.C2_QUJE) FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) WHERE SC2.D_E_L_E_T_ = '' AND  SC2.C2_FILIAL = B2_FILIAL AND SC2.C2_PRODUTO = B2_COD AND SC2.C2_QUJE = 0 AND SC2.C2_LOCAL = B2_LOCAL),0) AS ORDENS "+CRLF
    cQuery += "		,ROUND(ISNULL((SELECT SUM(SC6_1.C6_QTDVEN)/6 FROM " + RetSqlName("SC6") + " AS SC6_1 WITH (NOLOCK)  "+CRLF
    cQuery += "				 WHERE SC6_1.D_E_L_E_T_ = ''  "+CRLF
    cQuery += "				 AND SC6_1.C6_FILIAL = B2_FILIAL "+CRLF
    cQuery += "				 AND SC6_1.C6_LOCAL = B2_LOCAL  "+CRLF
    cQuery += "				 AND SC6_1.C6_DATFAT >= DATEADD(MONTH,-6,GETDATE())  "+CRLF
    cQuery += "				 AND SC6_1.C6_PRODUTO = B2_COD  "+CRLF
    cQuery += "				 AND SC6_1.C6_BLQ NOT IN ('R')),0),3) AS DEMANDAS "+CRLF
    cQuery += "from " + RetSqlName("SB2") + " SB2 "+CRLF
    cQuery += "  INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = ' ' AND SB1.B1_COD = SB2.B2_COD AND SB1.B1_TIPO = 'PA' AND B1_XTPBASE IN ('A','S','') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "  INNER JOIN " + RetSqlName("SZ3") + " AS SZ3 WITH (NOLOCK) ON SZ3.Z3_FILIAL = SB2.B2_FILIAL AND SZ3.Z3_COD = SB2.B2_COD AND SZ3.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "  INNER JOIN  " + RetSqlName("SG1") + " AS SG1 WITH (NOLOCK) ON SG1.G1_FILIAL = B2_FILIAL AND G1_COD = B2_COD  AND SG1.D_E_L_E_T_ = ' '"+CRLF
    cQuery += "  INNER JOIN  " + RetSqlName("SB1") + " AS SB1A WITH (NOLOCK) ON SB1A.B1_FILIAL = ' ' AND SB1A.B1_COD = SG1.G1_COMP AND SB1A.B1_TIPO = 'PI' AND SB1.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "Where SB2.D_E_L_E_T_ = ' ' "+CRLF
    cQuery += "AND B2_FILIAL = '0803' "+CRLF
    cQuery += "AND SB2.B2_LOCAL IN ('02','04','07','08','09') "+CRLF

    DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

    if (cAlias)->(Eof())
        (cAlias)->(DbCloseArea())
		Return
    ENDIF

     oFWMsExcel := FWMSExcel():New()  
         
    //Aba 01 - Produtos
    oFWMsExcel:AddworkSheet("Planejamento")
        //Criando a Tabela
    oFWMsExcel:AddTable("Planejamento","Produtos")
       // Criando os campos
    oFWMsExcel:AddColumn("Planejamento","Produtos","Componente",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Produto",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Descricao",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Unid.Medida",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Peso",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Reposicao",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Almox",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Tipo",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Classe",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Linha",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Situacao",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Curva",1)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Custo",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Saldo",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Pedidos",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Ordens",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Demandas",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Dem.Diaria",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Disponivel",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","EstoqueSeg",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","SaldoSeguro",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Estoque Minimo",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Estoque Medio",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Estoque Maximo",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Percentual",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","PA",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","PA Dia",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","PI",2,2)
    oFWMsExcel:AddColumn("Planejamento","Produtos","Valorizacao",2,2)

    While (cAlias)->( !Eof() )

        // Calculos
           nDemandaDiaria := (cAlias)->DEMANDAS / 30
           nDisponivel    := (cAlias)->SALDO - (cAlias)->PEDIDOS + (cAlias)->ORDENS
           nEstoqueSeg    := 0

           if (cAlias)->CURVA = 'A'
               nEstoqueSeg := nDemandaDiaria * nMinCurvaA
           ElseIf (cAlias)->CURVA = 'B'
                nEstoqueSeg := nDemandaDiaria * nMinCurvaB
           else
                nEstoqueSeg := nDemandaDiaria * nMinCurvaC
           endif
           
           nSaldoSeguro :=   nDisponivel - nEstoqueSeg
           
           nEstoqueMinimo := nEstoqueSeg
           
           nEstoqueMaximo := nEstoqueMinimo * nFator
           
           nEstoqueMedio  :=  (( nEstoqueMaximo - nEstoqueMinimo ) / 2) + nEstoqueSeg
           
           nPercentual    :=  (nSaldoSeguro / nEstoqueMaximo) * 100
           
           nQtdPA :=  nEstoqueMaximo - nSaldoSeguro
           
           nQtdPaDia := nSaldoSeguro / nDemandaDiaria
           
           nQtdPIKilo := nQtdPA * (cAlias)->PESO
           
           nValorizacao := nQtdPIKilo * (cAlias)->CUSTO

        // Excell
        oFWMsExcel:AddRow("Planejamento","Produtos",{   (cAlias)->COMPONENTE,;
                                                        (cAlias)->PRODUTO,;
                                                        (cAlias)->DESCRICAO,;
                                                        (cAlias)->UM,;
                                                        (cAlias)->PESO,;
                                                        (cAlias)->REPOSICAO,;
                                                        (cAlias)->ALMOX,;
                                                        (cAlias)->TIPO,;
                                                        (cAlias)->CLASSE,;
                                                        (cAlias)->LINHA,;
                                                        (cAlias)->SITUACAO,;
                                                        (cAlias)->CURVA,;
                                                        (cAlias)->CUSTO,;
                                                        (cAlias)->SALDO,;
                                                        (cAlias)->PEDIDOS,;
                                                        (cAlias)->ORDENS,;
                                                        (cAlias)->DEMANDAS,;
                                                        nDemandaDiaria,;
                                                        nDisponivel,;
                                                        nEstoqueSeg,;
                                                        nSaldoSeguro,;
                                                        nEstoqueMinimo,;
                                                        nEstoqueMedio,;
                                                        nEstoqueMaximo,;
                                                        nPercentual,;
                                                        nQtdPA,;
                                                        nQtdPaDia,;
                                                        nQtdPIKilo,;
                                                        nValorizacao})
          (cAlias)->( dbSkip() )
    EndDo
    (cAlias)->(DbCloseArea())

   //Aba 02 - Percentuais
    oFWMsExcel:AddworkSheet("Parametro") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
    oFWMsExcel:AddTable("Parametro","Indicadores")
        //Criando Colunas
    oFWMsExcel:AddColumn("Parametro","Indicadores","Fator",2,2) //1 = Modo Texto
    oFWMsExcel:AddColumn("Parametro","Indicadores","Min.Curva A",2,2) //2 = Valor sem R$
    oFWMsExcel:AddColumn("Parametro","Indicadores","Max.Curva A",2,2)
    oFWMsExcel:AddColumn("Parametro","Indicadores","Min.Curva B",2,2)
    oFWMsExcel:AddColumn("Parametro","Indicadores","Max.Curva B",2,2)
    oFWMsExcel:AddColumn("Parametro","Indicadores","Min.Curva C",2,2)
    oFWMsExcel:AddColumn("Parametro","Indicadores","Max.Curva C",2,2)
    oFWMsExcel:AddRow("Parametro","Indicadores",{nFator,nMinCurvaA,nMaxCurvaA,nMinCurvaB,nMaxCurvaB,nMinCurvaC,nMaxCurvaC})

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

    RestArea(cArea)
Return
//---------------------------------------------------------------------------------------------------------------------------------------//
// FINAL DO PROGRAMA
//---------------------------------------------------------------------------------------------------------------------------------------//


