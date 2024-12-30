//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

Static cTitulo    := "Movimento de Gerenciamento de Risco"
Static cAliasPZ2  := "PZ2"
Static cAliasPZ3  := "PZ3"

User Function PCPM080()
    Local aArea := GetArea()
    Pcp80Screen()
    RestArea(aArea)
Return

Static Function Pcp80Screen()
    Local aArea := FwGetArea()
    Local oBrowse := FWMBrowse():New()

    Private aRotina := {}

    oBrowse:SetAlias(cAliasPZ2)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetail()
     oBrowse:AddButton("Empenhos",{|| U_PCP80EMP(PZ2->PZ2_FILIAL,PZ2->PZ2_COD), oBrowse:Refresh()  },,2,,.F.)
    oBrowse:Refresh()

    oBrowse:Activate()

    FwRestArea(aArea)
Return Nil

Static Function MenuDef()
  Local aRotina := {}
    ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PCPM080" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Movimentos" ACTION "U_PCP080C()" OPERATION 3 ACCESS 0 
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.PCPM080" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.PCPM080" OPERATION 5 ACCESS 0
Return(aRotina)

Static Function ModelDef()
    Local oStrPz2 := FWFormStruct(1, cAliasPZ2)
    Local oStrPz3 := FWFormStruct(1, cAliasPZ3)
    Local aPZ3Rel		:= {}
    Local bPre := Nil
    Local bPos := Nil
    Local bCancel := Nil

    oModel := MPFormModel():New("TPCPM080", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("PZ2MASTER", /*cOwner*/, oStrPz2)
    oModel:AddGrid("PZ3DETAIL","PZ2MASTER",oStrPz3,,,,,) 

    aAdd(aPZ3Rel, {'PZ3_FILIAL' ,	'PZ2_FILIAL'} )
    aAdd(aPZ3Rel, {'PZ3_PROD'   ,	'PZ2_COD'} )

    oModel:SetRelation('PZ3DETAIL', aPZ3Rel, PZ3->(IndexKey(1)))

    oModel:GetModel( "PZ3DETAIL" ):SetUniqueLine( { "PZ3_PROD","PZ3_ANO","PZ3_MES","PZ3_DIA" } )
    oModel:GetModel( 'PZ3DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'PZ3DETAIL' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'PZ3DETAIL' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'PZ3DETAIL' ):CanUpdateLine(.T.)

   oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)
	oModel:GetModel('PZ2MASTER'):SetDescription(cTitulo)
	oModel:GetModel('PZ3DETAIL'):SetDescription('Operações')

Return oModel


Static Function ViewDef()
    Local oModel := FWLoadModel("PCPM080")
    Local oStrPz2 := FWFormStruct(2, cAliasPZ2)
    Local oStrPz3 := FWFormStruct(2, cAliasPZ3)

    Local oView

    oStrPz3:RemoveField( 'PZ3_PROD' )
    oStrPz3:RemoveField( 'PZ3_ANO' )


    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_PZ2", oStrPz2, "PZ2MASTER")
    oView:AddGrid("VIEW_PZ3",oStrPz3,"PZ3DETAIL")

    oView:CreateHorizontalBox( "VwPZ2" , 30 )
    oView:CreateHorizontalBox( "VwPZ3" , 70 )
    
    oView:SetOwnerView( "VIEW_PZ2" , "VwPZ2" )
    oView:SetOwnerView( "VIEW_PZ3" , "VwPZ3" )

 
Return oView

