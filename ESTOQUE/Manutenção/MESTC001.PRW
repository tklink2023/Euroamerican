//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Permissoes de acessos"
Static cAliasMVC := "SZ3"


User Function MESTC001()
    Local aArea   := FWGetArea()
    Local oBrowse

    Private aRotina := {}

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
    oBrowse:Activate()

    FWRestArea(aArea)
Return Nil

Static Function MenuDef()
    Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MESTC001" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.MESTC001" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.MESTC001" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.MESTC001" OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE "Copiar" ACTION "VIEWDEF.MESTC001" OPERATION 9 ACCESS 0

Return aRotina


Static Function ModelDef()
    Local oStruct := FWFormStruct(1, cAliasMVC)
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCancel := Nil
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("TLMESTC001", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("SZ3MASTER", /*cOwner*/, oStruct)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("SZ3MASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({'Z3_FILIAL,Z3_CODIGO'})
Return oModel

Static Function ViewDef()
    Local oModel := FWLoadModel("MESTC001")
    Local oStruct := FWFormStruct(2, cAliasMVC)
    Local oView
    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SZ3", oStruct, "SZ3MASTER")
    oView:CreateHorizontalBox("TELA" , 100 )
    oView:SetOwnerView("VIEW_SZ3", "TELA")
Return oView
