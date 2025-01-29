//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)
 
 
User Function PCPE080()
    Local aArea        := GetArea()
    Local cQuery        := ""
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'PCPE080.xml'

    Private cPerg 		:= PADR("PCPE080",10)
    Pergunte(cPerg,.T.)	 
    //Pegando os dados

    nMeses    := DateDiffMonth(MV_PAR01, MV_PAR02)+1

    cQuery :="Select B2_FILIAL	FILIAL "+cEof
    cQuery +="		,B2_COD		PRODUTO "+cEof
    cQuery +="		,B1_DESC	DESCRICAO "+cEof
    cQuery +="		,B1_TIPO    TIPO "+cEof
    cQuery +="		,B2_LOCAL	ARMAZEM "+cEof
    cQuery +="		,B2_QATU	SALDO "+cEof
    cQuery +="		,B2_QEMP	EMPENHO "+cEof
    cQuery +="		,(B2_QATU - B2_QEMP) DISPONIVEL "+cEof
    cQuery +="		,B2_CM1	    CUSTO "+cEof
    cQuery +="		,(B2_CM1 * B2_QATU) TOTAL "+cEof
    cQuery +="		,(Select ISNULL(SUM(D3_QUANT),0) / "+cValtoChar(nMeses)+" QTDE from SD3100  SD3 WHERE SD3.D_E_L_E_T_ = ' '  AND D3_FILIAL = B2_FILIAL AND D3_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' AND  D3_TM > '500'  AND D3_LOCAL = B2_LOCAL  AND D3_COD = B2_COD ) CONSUMO "+cEof
    cQuery +="from  "+RetSqlName("SB2")+"  SB2 "+cEof
    cQuery +="INNER JOIN  "+RetSqlName("SB1")+"  SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="WHERE SB2.D_E_L_E_T_ = ' ' "+cEof
    cQuery +="AND B2_FILIAL = '"+xFilial("SB2")+"' "+cEof
    cQuery +="AND B1_TIPO IN ( 'EM','MP','PI') "+cEof
    //cQuery +="AND B2_COD = 'MP.0167' "+cEof
    cQuery +="ORDER BY B2_FILIAL,B2_COD,B2_LOCAL,B1_TIPO "+cEof

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
        oFWMsExcel:AddColumn("Consumo","Produtos","Empresa",1,1)    //1 = Modo Texto
        oFWMsExcel:AddColumn("Consumo","Produtos","Produto",1,1)    //1 = Modo Texto
        oFWMsExcel:AddColumn("Consumo","Produtos","Descricao",1,1)  //1 = Modo Texto
        oFWMsExcel:AddColumn("Consumo","Produtos","Tipo",1,1)       //1 = Modo Texto
        oFWMsExcel:AddColumn("Consumo","Produtos","Local",1,1)      //1 = Modo Texto

        oFWMsExcel:AddColumn("Consumo","Produtos","Saldo",2,2)      //2 = Valor sem R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Empenho",2,2)    //2 = Valor sem R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Disponivel",2,2) //2 = Valor sem R$

        oFWMsExcel:AddColumn("Consumo","Produtos","Custo",2,2)      //3 = Valor com R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Total",2,2)      //3 = Valor com R$

        oFWMsExcel:AddColumn("Consumo","Produtos","Consumo",2,2)        //2 = Valor sem R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Cons.Diario",2,2)    //2 = Valor sem R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Dias.Estoque",2,2)   //2 = Valor sem R$
        oFWMsExcel:AddColumn("Consumo","Produtos","Dias.Diponivel",2,2) //2 = Valor sem R$

        //Criando as Linhas

        While !(QRYPRO->(EoF()))
            oFWMsExcel:AddRow("Consumo","Produtos",{;
                                                                    QRYPRO->FILIAL,;
                                                                    QRYPRO->PRODUTO,;
                                                                    QRYPRO->DESCRICAO,;
                                                                    QRYPRO->TIPO,;
                                                                    QRYPRO->ARMAZEM,;
                                                                    QRYPRO->SALDO,;
                                                                    QRYPRO->EMPENHO,;
                                                                    QRYPRO->DISPONIVEL,;
                                                                    QRYPRO->CUSTO,;
                                                                    QRYPRO->TOTAL,;
                                                                    QRYPRO->CONSUMO,;
                                                                    (QRYPRO->CONSUMO/30),;
                                                                    (QRYPRO->SALDO/(QRYPRO->CONSUMO/30)),;
                                                                    (QRYPRO->DISPONIVEL/(QRYPRO->CONSUMO/30));
                                                                     })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo    
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return
