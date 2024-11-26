//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define cEof    Chr(13)+Chr(10)
User Function PCPP070()
   Local aArea   := FWGetArea()
   Local aResult    := {}
 
    //Somente se a pergunta for confirmada, irá executar a procedure
    If FWAlertYesNo("Deseja executar a procedure", "Continua?")
        aResult:=TCSPExec("[BI]..P_PCP_Transfer")
        IF empty(aResult)
          Conout('Erro na execução da Stored Procedure : '+TcSqlError())
        Else
            Conout("Retorno String : "+aResult[1])
            Conout("Retorno Numerico : "+str(aResult[2]))
            FWAlertInfo("Processo finalizado", "Teste TCSPExec")
            MsgRun("Gerando a Planilha.    Aguarde.....", "Processando", {|| PP070RUN() })
        Endif
    EndIf
    FWRestArea(aArea)
Return

Static Function PP070RUN()
  Local aArea        := GetArea()
  Local cQuery       := ""
  Local oFWMsExcel
  Local oExcel
  Local cArquivo    := GetTempPath()+'PCPP070.xml'  

  cQuery :="Select * from [BI]..PCP_Transfer "+cEof

  If  Select("QRYPRO") > 0
            DbSelectArea("QRYPRO")
            DbCloseArea()
    Endif

   TCQuery cQuery New Alias "QRYPRO"

    oFWMsExcel:AddworkSheet("Relacao Produtos")
        //Criando a Tabela
    oFWMsExcel:AddTable("Relacao Produtos","Produtos")
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Empresa",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Codigo",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Descricao",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Armazem",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","UN",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Peso",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Almoxarifado",1)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Saldo",2,2)
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Tipo",1)    
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Vendas",2,2)    
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Ops",2,2)    
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Media",2,2)    
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Curva",1)     
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Tipo",1)        
    oFWMsExcel:AddColumn("Relacao Produtos","Produtos","Status",1)
    DbSelectArea("QRYPRO")
        //Criando as Linhas... Enquanto não for fim da query
    While !(QRYPRO->(EoF()))
            oFWMsExcel:AddRow("Relacao Produtos","Produtos",{;
                                                                    QRYPRO->EMPRESA,;
                                                                    QRYPRO->PRODUTO_COD,;
                                                                    QRYPRO->PRODUTO,;
                                                                    QRYPRO->ARMAZEM,;
                                                                    QRYPRO->UNIDADEMEDIDA,;                      
                                                                    QRYPRO->PESO,;
                                                                    QRYPRO->ALMOXARIFADO,;
                                                                    QRYPRO->SALDOATUAL,;
                                                                    QRYPRO->TIPO,;
                                                                    QRYPRO->QTDPEDIDOSVENDA,;
                                                                    QRYPRO->OPSABERTO,;
                                                                    QRYPRO->DEMANDAVENDAMED6MESES,;
                                                                    QRYPRO->CURVA,;
                                                                    QRYPRO->CLASSEPRODUTO,;
                                                                    QRYPRO->TIPODECLASSE,;
                                                                    QRYPRO->SITUACAO;
                                                                     })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
    EndDo

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

