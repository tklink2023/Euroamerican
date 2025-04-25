//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)
 

 User Function LABE010()
        Local aArea           := GetArea()
        Local aRet  	:= 	{}
	    Local aPergs	:= 	{}
        Local cDtIni    := Ctod('  /  /  ')
        Local cDtFim    := Ctod('  /  /  ')
        Local cTitulo   := "Calculo Estrutura"   
	    Local aSays		:= {}
	    Local aButtons	:= {}    
        lOCAL lOk

        Private cMvPar01
	    Private cMvPar02
        Private corfundo      := "#000666"
        Private corResalta    := "#c7a7cf"
        Private cLogErro := {}

	    aAdd( aPergs ,{1,"Da Data"					, cDtIni     	, PesqPict("SC2", "C2_Emissao"),'.T.',""   	,'.T.'	,50, .T.})
        aAdd( aPergs ,{1,"Ate a Data"				, cDtFim     	, PesqPict("SC2", "C2_Emissao"),'.T.',""   	,'.T.'	,50, .T.})
     
        If ParamBox(aPergs ,"Parametros para o relatorio",aRet)     
		    cMvPar01 := aRet[1]
		    cMvPar02 := aRet[2]
	    Else
		    MsgAlert("Encerrado")
		    Return
	   EndIf	

        AAdd(aSays,"Geração do Relatorio conforme os parametros selecionados")
	    AAdd(aSays,"Filtrando as datas de:"+Dtoc(cMvPar01)+" ate: "+Dtoc(cMvPar02))

        //aAdd(aButtons, { 5, .T., {|| Pergunte(cPerg, .T. ) } } )
        aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
        aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )

        FormBatch(cTitulo, aSays, aButtons)

        If lOk
            MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| RunProc() })
        EndIf

 
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
    Local cArquivo      := GetTempPath()+'LABE010.xml'
   //Pegando os dados


    cQuery :="Select D4_COD                 MATERIAL "+cEof 
    cQuery +="		,SB1.B1_DESC            DESCRICAO	 "+cEof 
    cQuery +="		,SUBSTRING(D4_OP,1,6)   LOTE "+cEof 
    cQuery +="		,D4_DATA                EMISSAO "+cEof 
    cQuery +="		,D4_QTDEORI             QUANTIDADE "+cEof 
    cQuery +="		,D4_PRODUTO             PRODUTO "+cEof 
    cQuery +="		,SB1X.B1_TIPO           TIPO "+cEof 
    cQuery +="		,C2_REVISAO             REVISAO "+cEof 
    cQuery +="		,SB1X.B1_DESC           XDESCPI "+cEof 		
    cQuery +="From "+RetSqlName("SD4")+" SD4 "+cEof 
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = D4_COD AND B1_TIPO = 'MP' AND SB1.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="INNER JOIN "+RetSqlName("SB1")+" SB1X ON SB1X.B1_COD = D4_PRODUTO AND SB1X.B1_TIPO = 'PI' AND SB1X.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = D4_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D4_OP AND C2_PRODUTO = D4_PRODUTO AND SC2.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="Where SD4.D_E_L_E_T_ = ' ' "+cEof 
    cQuery +="AND D4_FILIAL = '"+xFilial("SD4")+"'  "+cEof
    cQuery +="AND D4_DATA BETWEEN '"+DtoS(cMvPar01)+"' AND '"+DtoS(cMvPar02)+"' "+cEof  
    cQuery +="ORDER BY D4_COD,SUBSTRING(D4_OP,1,6) "+cEof 

    If  Select("QRYPRO") > 0
            DbSelectArea("QRYPRO")
            DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYPRO"
   TCSetField("QRYPRO", "D4_DATA", "D")

     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
    //Aba 01 - Teste
    oFWMsExcel:AddworkSheet("Materiais") //Não utilizar número junto com sinal de menos. Ex.: 1-
    //Criando a Tabela
    oFWMsExcel:AddTable("Materiais","Produtos")
    //Criando Colunas
    oFWMsExcel:AddColumn("Materiais","Produtos","Material",1,1)        //1 = Modo Texto  2
    oFWMsExcel:AddColumn("Materiais","Produtos","Descricao",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("Materiais","Produtos","Lote",1,1)      //1 = Modo Texto  3
    oFWMsExcel:AddColumn("Materiais","Produtos","Emissao",1,1)           //1 = Modo Texto  4
    oFWMsExcel:AddColumn("Materiais","Produtos","Quantidade",2,2)   //2 = Valor sem R$ 11

    oFWMsExcel:AddColumn("Materiais","Produtos","Produto",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("Materiais","Produtos","Tipo",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("Materiais","Produtos","Revisao",1,1)          //1 = Modo Texto  5
    oFWMsExcel:AddColumn("Materiais","Produtos","Nome",1,1)      //1 = Modo Texto  3

    While !(QRYPRO->(EoF()))
        // Projecao do consumo nessa parte é normal pois é o consumo do mês
           cDataImp := Substring(QRYPRO->EMISSAO,7,2)+"/"+Substring(QRYPRO->EMISSAO,5,2)+"/"+Substring(QRYPRO->EMISSAO,1,4)
           oFWMsExcel:AddRow("Materiais","Produtos",{ QRYPRO->MATERIAL,;   // 1 - 
                                                      QRYPRO->DESCRICAO,;  // 2 - Produto
                                                      QRYPRO->LOTE,;  // 3 - Descrição
                                                      cDataImp,;
                                                      QRYPRO->QUANTIDADE,;  // 4 - Tipo
                                                      QRYPRO->PRODUTO,;  // 5 - Local
                                                      QRYPRO->TIPO,;  // 6 - Custo 
                                                      QRYPRO->REVISAO,;  // 7 - Consumo
                                                      QRYPRO->XDESCPI } )  // 19 - Percentual

        QRYPRO->(DbSkip())
    EndDo    
    QRYPRO->(DbCloseArea())

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

