#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Controle de Tempos"
Static cAliasSZ7 := "SZ7"
Static cAliasSZ8 := "SZ8"
Static cAliasSZ9 := "SZ9"

/*/{Protheus.doc} PCPM060
description Programa que controla o tempo de produtção 
@type function User
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
User Function PCPM060()
    Local aArea   := FWGetArea()
    Local oBrowse
    Local cAutoriz:= GetMv("ES_P60MENU")

    Private aRotina := {}

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasSZ7)
    oBrowse:SetDescription(cTitulo)
    oBrowse:GetTimer()
    oBrowse:DisableDetails()
    if !cUserName $ cAutoriz // Atraves de parametro ES_P60MENU determina quem tem acesso as opções abaixo
        oBrowse:SetFilterDefault( " SZ7->Z7_STATUS <> 'C' " )
    endif   
    oBrowse:AddLegend("SZ7->Z7_STATUS == 'A' .AND. SZ7->Z7_PARADA == '2' ", 'GREEN',   'Aberto Apontamento',     '1')
    oBrowse:AddLegend("SZ7->Z7_STATUS == 'B' .AND. SZ7->Z7_PARADA == '2' ", 'YELLOW',   'Sendo Apontado',        '1')
    oBrowse:AddLegend("SZ7->Z7_STATUS == 'B' .AND. SZ7->Z7_PARADA == '1' ", 'BLACK',    'Apontamento Parado',    '1')
    oBrowse:AddLegend("SZ7->Z7_STATUS == 'C' .AND. SZ7->Z7_PARADA == '2' ", 'RED',     'Encerrado Apontado',     '1')
    
    oBrowse:AddButton("Apontamento",{|| U_PCPM061(SZ7->Z7_NUM+SZ7->Z7_ITEM+SZ7->Z7_SEQUEN,SZ7->Z7_PRODUTO), oBrowse:Refresh()  },,2,,.F.)
    oBrowse:AddButton("Paradas"    ,{|| U_PCPM062(SZ7->Z7_NUM+SZ7->Z7_ITEM+SZ7->Z7_SEQUEN,SZ7->Z7_PRODUTO), oBrowse:Refresh()  },,2,,.F.)
    oBrowse:AddButton("Impressao"  ,{|| U_PCPAMB(SZ7->Z7_NUM+SZ7->Z7_ITEM+SZ7->Z7_SEQUEN,SZ7->Z7_PRODUTO), oBrowse:Refresh()  },,2,,.F.)
    oBrowse:Refresh()

    oBrowse:Activate()

    FWRestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
description Rotina para tratar as opções do programa
@type function Static
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
Static Function MenuDef()
    Local aRotina := {}
    Local cAutoriz:= GetMv("ES_P60MENU")

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PCPM060" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Abrir Contole" ACTION "U_PCP060C()" OPERATION 3 ACCESS 0 // Abrir o controle de tempo
    if cUserName $ cAutoriz // Atraves de parametro ES_P60MENU determina quem tem acesso as opções abaixo
        ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.PCPM060" OPERATION 4 ACCESS 0
        ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.PCPM060" OPERATION 5 ACCESS 0
    Endif
Return aRotina

/*/{Protheus.doc} ModelDef
description Rotina de preparação dos campos a serem apresentados no programa
@type function Static
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
Static Function ModelDef()
    Local oStrSZ7 := FWFormStruct(1, cAliasSZ7)
    Local oStrSZ8 := FWFormStruct(1, cAliasSZ8)
    Local oStrSZ9 := FWFormStruct(1, cAliasSZ9)
   	Local aSZ8Rel		:= {}
    Local aSZ9Rel		:= {}
    Local oModel
    Local bPre := Nil
    Local bPos := Nil
    Local bCancel := Nil
    //Cria o modelo de dados para cadastro
    oModel := MPFormModel():New("TLPCPM060", bPre, bPos, /*bCommit*/, bCancel)
    oModel:AddFields("SZ7MASTER", /*cOwner*/, oStrSZ7)
    oModel:AddGrid("SZ8DETAIL","SZ7MASTER",oStrSZ8,,,,,)  
    oModel:AddGrid("SZ9DETAIL","SZ7MASTER",oStrSZ9,,,,,)  

    aAdd(aSZ8Rel, {'Z8_FILIAL',	'Z7_FILIAL'} )
	aAdd(aSZ8Rel, {'Z8_OP',	'Z7_OP'}) 
    aAdd(aSZ8Rel, {'Z8_PRODUTO',	'Z7_PRODUTO'}) 

    aAdd(aSZ9Rel, {'Z9_FILIAL',	'Z7_FILIAL'} )
	aAdd(aSZ9Rel, {'Z9_OP',	'Z7_OP'}) 
    aAdd(aSZ9Rel, {'Z9_PRODUTO',	'Z7_PRODUTO'}) 

	oModel:SetRelation('SZ8DETAIL', aSZ8Rel, SZ8->(IndexKey(1))) 
    oModel:SetRelation('SZ9DETAIL', aSZ9Rel, SZ9->(IndexKey(1))) 

    oModel:GetModel( "SZ8DETAIL" ):SetUniqueLine( { "Z8_OP","Z8_PRODUTO","Z8_OPERAC","Z8_RECUR","Z8_FERRAM" } )
    oModel:GetModel( 'SZ8DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'SZ8DETAIL' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'SZ8DETAIL' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'SZ8DETAIL' ):CanUpdateLine(.T.)

    oModel:GetModel( "SZ9DETAIL" ):SetUniqueLine( { "Z9_OP","Z9_PRODUTO","Z9_OPERAC" } )
    oModel:GetModel( 'SZ9DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'SZ9DETAIL' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'SZ9DETAIL' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'SZ9DETAIL' ):CanUpdateLine(.T.)

    oModel:SetPrimaryKey({})

    oModel:SetDescription(cTitulo)
	oModel:GetModel('SZ7MASTER'):SetDescription(cTitulo)
	oModel:GetModel('SZ8DETAIL'):SetDescription('Operações')
    oModel:GetModel('SZ9DETAIL'):SetDescription('Paradas')
 
Return oModel

/*/{Protheus.doc} ViewDef
description Rotina que apresenta os dados em tela
@type function Static
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
Static Function ViewDef()
    Local oModel := FWLoadModel("PCPM060")
    Local oStrSZ7 := FWFormStruct(2, cAliasSZ7)
    Local oStrSZ8 := FWFormStruct(2, cAliasSZ8)
    Local oStrSZ9 := FWFormStruct(2, cAliasSZ9)
    Local oView

    oStrSZ8:RemoveField( 'Z8_OP' )
    oStrSZ8:RemoveField( 'Z8_PRODUTO' )

    oStrSZ9:RemoveField( 'Z9_OP' )
    oStrSZ9:RemoveField( 'Z9_PRODUTO' )

    //Cria a visualizacao do cadastro
    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_SZ7", oStrSZ7, "SZ7MASTER")
    oView:AddGrid("VIEW_SZ8",oStrSZ8,"SZ8DETAIL")
    oView:AddGrid("VIEW_SZ9",oStrSZ9,"SZ9DETAIL")

    oView:CreateHorizontalBox( "VwSZ7" , 30 )
    oView:CreateHorizontalBox( "VwSZ8" , 40 )
    oView:CreateHorizontalBox( "VwSZ9" , 30 )

    oView:SetOwnerView( "VIEW_SZ7" , "VwSZ7" )
    oView:SetOwnerView( "VIEW_SZ8" , "VwSZ8" )
    oView:SetOwnerView( "VIEW_SZ9" , "VwSZ9" )
 
Return oView

/*/{Protheus.doc} PCP060C
description rotina que trata do imput dos dados da Ordem de Produção
@type function
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
User Function PCP060C()
    Local cArea := FwGetArea()

 	Private oDlgForm
	Private oGrpForm
	Private oGetForm
	Private cGetForm := Space(11)
	Private oGrpAco
	Private oBtnExec
	//Tamanho da Janela
	Private nJanLarg := 500
	Private nJanAltu := 120
	Private nJanMeio := ((nJanLarg)/2)/2
	Private nTamBtn  := 048
    
	//Criando a janela
	DEFINE MSDIALOG oDlgForm TITLE "Informe o numero da OP" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
		//Grupo Fórmula com o Get
		@ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "Numero OP: " OF oDlgForm COLOR 0, 16777215 PIXEL
		@ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 F3 "SC2" OF oDlgForm COLORS 0, 16777215 PIXEL
		
		//Grupo Ações com o Botão
		@ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
		@ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta(),oDlgForm:End()) PIXEL
		
	//Ativando a janela
	ACTIVATE MSDIALOG oDlgForm CENTERED

    FwRestArea(cArea)
Return

/*/{Protheus.doc} fExecuta
description Rotina a importação das informações referente a ordem de Produção
@type function Static
@version 1.0
@author Paulo Lenzi
@since 13/09/2024
@return variant, return_description
/*/
Static Function fExecuta()
	Local cArea  := FwGetArea()
    Local cNumop := Substring(cGetForm,1,6)
    Local cItem  := Substring(cGetForm,7,2)
    Local cSequen:= Substring(cGetForm,9,3)

    if ExistBlock("PCPM063")
        aDados:= {cNumop,cItem, cSequen}
        ExecBlock("PCPM063",.F.,.F.,aDados)   
    Endif

    FwRestArea(cArea)
Return

/*/{Protheus.doc} CalcHoras
description Rotina que faz o tratamento de dias e horas
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@return variant, return_description
/*/
User Function CalcHoras()
    Local cArea         := FwGetArea()
    Local dDataInicio   := PARAMIXB[1]
    Local hHoraInicio   := PARAMIXB[2]
    Local dDataFinal    := PARAMIXB[3]
    Local hHoraFinal    := PARAMIXB[4]
    Local cOrdemProd    := PARAMIXB[5]
    Local cProduto      := PARAMIXB[6]
    Local cOperacao     := PARAMIXB[7]
    Local cTipo         := PARAMIXB[8]
    Local cAlias        := PARAMIXB[9]
    Local cResult       := ""
    Local cHoras        := 0
    Local cMinutos      := 0
    Local cGasto        := 0
    Local nCalcHoras    := 0 
    Local lSit          := PCP60POS(cOrdemProd,cProduto)
    Local cDescOperacao := " "

    if cTipo = "F"  // Esse Tipo Refere-se ao lançamento Final do registro
       if dDataInicio = dDataFinal  // Quando das data de inicio e fim são igual o tratamento será dado apenas nas horas
          nCalcHoras := SubHoras( hHoraFinal,hHoraInicio )
       else
          cResult := AtTotHora( dDataInicio,hHoraInicio,dDataFinal, hHoraFinal )

          if Val(Substring(cResult,1,at("D",cResult)-1)) > 0   // confere se tem valor em dias
             cHoras := Val(Substring(cResult,1,at("D",cResult)-1)) * 24
          Endif

          if val(Substring(cResult,at("D",cResult)+1,at(":",cResult)-at("D",cResult)-1)) > 0  // confere se tem valor em horas
             cHoras := cHoras + hrs2min(val(Substring(cResult,at("D",cResult)+1,at(":",cResult)-at("D",cResult)-1))) 
          endif

          if Val(Substring(cResult,at(":",cResult)+1,10)) > 0 // confere se tem valor em minutos
             cMinutos := Val(Substring(cResult,at(":",cResult)+1,10))  +   Hrs2Min(cHoras)
          endif   
         
       endif

      cGasto := IIF(nCalcHoras > 0 , nCalcHoras,Min2Hrs(cMinutos))
 

      IF cAlias = "SZ8"
            dbSelectArea("SZ8")
            SZ8->( dbSetOrder(1) )
            IF SZ8->( dbSeek( xFilial("SZ8")+cOrdemProd+cProduto+cOperacao,.T.) )
                IF RECLOCK("SZ8",.F.)
                    SZ8->Z8_GASTO := cValtoChar(cGasto)
                    SZ8->( MsUnlock() )
                ENDIF
            ENDIF

      else
            dbSelectArea("SZ9")
            SZ9->( dbSetOrder(1) )
            IF SZ9->( dbSeek( xFilial("SZ9")+cOrdemProd+cProduto+cOperacao,.T.) )
                IF RECLOCK("SZ9",.F.)
                    SZ9->Z9_GASTO := cValtoChar(cGasto)
                    SZ9->( MsUnlock() )
                ENDIF
            ENDIF
        
      ENDIF  

    Endif
    IF cAlias = "SZ8"
        cDescOperacao := Posicione("SZ8",1,xFilial("SZ8")+cOrdemProd+cProduto+cOperacao,"Z8_DESCR" )
    ENDIF    

    dbSelectArea("SZ7")
    SZ7->( dbSetOrder(1) )
    IF SZ7->( dbSeek( xFilial("SZ7")+cOrdemProd+cProduto,.T.) )
        IF RECLOCK("SZ7",.F.)
            SZ7->Z7_STATUS := IIF(lSit,"C","B")
            SZ7->Z7_DATRF  := IIF(lSit,dDataBase,ctod("  /  / "))
            SZ7->Z7_OPERAC := cOperacao
            SZ7->Z7_DESCOPE:= cDescOperacao
            SZ7->Z7_SITUAC := IIF(cTipo="I","INICIO","FINAL")
            SZ7->Z7_PARADA := IIF(cAlias="SZ9",IIF(cTipo=="I","1","2"),"2" )
            SZ7->Z7_GASTO := cValtoChar(val(SZ7->Z7_GASTO)+cGasto)
            SZ7->( MsUnlock() )
        ENDIF
    ENDIF
   
    FwRestArea(cArea)
Return

/*/{Protheus.doc} PCP60POS
description Rotina que tras o posicionamento da situação das operações
@type function
@version 1.0
@author Paulo Lenzi
@since 30/09/2024
@param cOp, character, param_description
@param cProduto, character, param_description
@return variant, return_description
/*/
Static Function PCP60POS(cOp,cProduto)
    Local cArea := FwGetArea()
    Local cAlias:= GetNextAlias()
    Local lRet  := .F.

    BeginSQL Alias cAlias
        Select Z8_DATAFIM
        FROM %Table:SZ8% SZ8
        WHERE SZ8.%NotDel%
        and Z8_FILIAL =  %xFilial:SZ8%
        AND Z8_OP = %Exp:cOp%
		AND Z8_PRODUTO = %Exp:cProduto%
        AND Z8_DATAFIM = ' '
		ORDER BY Z8_OPERAC
    EndSQL

    if (cAlias)->( Eof())
            lRet := .T.
            FwRestArea(cArea)
            (cAlias)->(DbCloseArea())
	        RETURN(lRet)
    Endif        
   FwRestArea(cArea)
  (cAlias)->(DbCloseArea())

Return(lRet)
//========================================================================================================================================================================//
// FIM DA PROGRAMAÇÃO DO FONTE PCPM060
//========================================================================================================================================================================//
