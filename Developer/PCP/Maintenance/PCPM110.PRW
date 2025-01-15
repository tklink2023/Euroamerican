//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
   
//Variáveis Estáticas
Static cTitulo := "Geração de Ordens de Producao"

User Function PCPM110()
     Local aArea   := GetArea()
    Local oBrowse
    //Cria um browse para a ZAF
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("PZ4")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
       
    RestArea(aArea)
Return

Static Function MenuDef()
    Local aRot := {}
       
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.PCPM110' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.PCPM110' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.PCPM110' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.PCPM110' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 3 campos, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel      := NIL
    Local oStruCab     := FWFormStruct(1, 'PZ4', {|cCampo| AllTRim(cCampo) $ "PZ4_NUM"})
    Local oStruGrid := fModStruct()
  
    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('PCPM110M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )
  
    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldPZ4', NIL, oStruCab)
    oModel:AddGrid('MdGridPZ4', 'MdFieldPZ4', oStruGrid, , )
  
    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridPZ4', {;
            {'PZ4_FILIAL', 'xFilial("PZ4")'},;
            {"PZ4_COD",  "PZ4_COD"},;
            {"PZ4_LOCAL", "PZ4_LOCAL"},;
            {"PZ4_ITEM",  "PZ4_ITEM"};
        }, PZ4->(IndexKey(1)))
      
    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridPZ4"):SetMaxLine(9999)
    oModel:SetDescription("Relacao de Produtos para gerar as OPs")
    oModel:SetPrimaryKey({"PZ4_FILIAL", "PZ4_NUM", "PZ4_COD","PZ4_ITEM"})
  
Return oModel
  
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('PCPM110')
    Local oStruCab  := FWFormStruct(2, "PZ4", {|cCampo| AllTRim(cCampo) $ "PZ4_NUM"})
    Local oStruGRID := fViewStruct()
  
    //Define que no cabeçalho não terá separação de abas (SXA)
    oStruCab:SetNoFolder()
  
    //Cria o View
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
  
    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZAF, e uma Grid vinculando com MdGridZAF
    oView:AddField('VIEW_PZ4', oStruCab, 'MdFieldPZ4')
    oView:AddGrid ('GRID_PZ4', oStruGRID, 'MdGridPZ4' )
  
    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
  
    //Vincula o MAIN com a VIEW_ZAF e a GRID com a GRID_ZAF
    oView:SetOwnerView('VIEW_PZ4', 'MAIN')
    oView:SetOwnerView('GRID_PZ4', 'GRID')
    oView:EnableControlBar(.T.)
  
    //Define o campo incremental da grid como o ZAF_ITEM
    oView:AddIncrementField('GRID_PZ4', 'PZ4_ITEM')
Return oView
  
//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'PZ4')
Return oStruct
  
//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local cCampoCom := "PZ4_NUM;"
    Local oStruct
  
    //Irá filtrar, e trazer todos os campos, menos os que tiverem na variável cCampoCom
    oStruct := FWFormStruct(2, "PZ4", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct
  
//Função que faz a validação da grid
Static Function fValidGrid(oModel)
    Local lRet     := .T.
    Local nDeletados := 0
    Local nLinAtual :=0
    Local oModelGRID := oModel:GetModel('MdGridPZ4')
    //Local oModelMain := oModel:GetModel('MdFieldPZ4')
    //Local nValorMain := oModelMain:GetValue("ZAF_VALOR")
    Local nValorGrid := 0
    Local cPictVlr   := PesqPict('PZ4', 'PZ4_QTDE')
  
    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:Length() 
        //Posiciona na linha
        oModelGRID:GoLine(nLinAtual) 
          
        //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
        If oModelGRID:IsDeleted()
            nDeletados++
        Else
            nValorGrid += NoRound(oModelGRID:GetValue("PZ4_QTDE"), 4)
        EndIf
    Next nLinAtual
  
    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If oModelGRID:Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
    EndIf
  
    If lRet
        //Se o valor digitado no cabeçalho (valor da NF), não bater com o valor de todos os abastecimentos digitados (valor dos itens da Grid), irá mostrar uma mensagem alertando, porém irá permitir salvar (do contrário, seria necessário alterar lRet para falso)
        If nValorMain != nValorGrid
            //lRet := .F.
            MsgAlert("O valor do cabeçalho (" + Alltrim(Transform(nValorMain, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Atenção")
        EndIf
    EndIf
  
Return lRet
//---------------------------------------------------------------------------------------------------------------------------------------//
// FINAL DO PROGRAMA
//---------------------------------------------------------------------------------------------------------------------------------------//


