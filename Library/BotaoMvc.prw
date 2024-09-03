//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
 
//Variveis Estaticas
Static cTitulo := "Artistas (com botões na ViewDef)"
Static cAliasMVC := "SZ7"
 
/*/{Protheus.doc} User Function zMVC07
Cadastro de Artistas (com botões na ViewDef)
@author Daniel Atilio
@since 11/02/2022
@version 1.0
/*/
 
User Function zMVC07()
    Local aArea   := GetArea()
    Local oBrowse
    Private aRotina := {}
 
    //Definicao do menu
    aRotina := MenuDef()
 
    //Instanciando o browse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
 
    //Ativa a Browse
    oBrowse:Activate()
 
    RestArea(aArea)
Return Nil
 
Static Function MenuDef()
    Local aRotina := {}
 
    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC07" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.zMVC07" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.zMVC07" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.zMVC07" OPERATION 5 ACCESS 0
 
Return aRotina
 
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCommit := Nil
    Local bCancel := Nil
 
 
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("zMVC07M", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZD1MASTER", /*cOwner*/, oStruct)
    oModel:SetDescription("Modelo de dados - " + cTitulo)
    oModel:GetModel("ZD1MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})
Return oModel
 
Static Function ViewDef()
    Local oModel := FWLoadModel("zMVC07")
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView
 
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZD1", oStruct, "ZD1MASTER")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_ZD1", "TELA")
 
    //Adiciona botões direto no Outras Ações da ViewDef
    oView:addUserButton("* Botão em Tudo",                 "MAGIC_BMP", {|| Alert("Teste 1")}, /*cToolTip*/, /*nShortCut*/, /*aOptions*/,                                     /*lShowBar*/)
    oView:addUserButton("* Botão Somente Inclusão",        "MAGIC_BMP", {|| Alert("Teste 2")}, /*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_INSERT},                         /*lShowBar*/)
    oView:addUserButton("* Botão Somente Alteração",       "MAGIC_BMP", {|| Alert("Teste 3")}, /*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_UPDATE},                         /*lShowBar*/)
    oView:addUserButton("* Botão na Inclusão e Alteração", "MAGIC_BMP", {|| Alert("Teste 4")}, /*cToolTip*/, /*nShortCut*/, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}, /*lShowBar*/)
Return oView
