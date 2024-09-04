#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Controle de Tempos"
Static cAliasSZ7 := "SZ7"
Static cAliasSZ8 := "SZ8"
Static cAliasSZ9 := "SZ9"


User Function PCPM060()
    Local aArea   := FWGetArea()
    Local oBrowse

    Private aRotina := {}

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasSZ7)
    oBrowse:SetDescription(cTitulo)

    oBrowse:DisableDetails()
    oBrowse:Activate()

    FWRestArea(aArea)
Return Nil

Static Function MenuDef()
    Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PCPM060" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Abrir Contole" ACTION "U_PCP060C()" OPERATION 3 ACCESS 0 // Abrir o controle de tempo
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.PCPM060" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.PCPM060" OPERATION 5 ACCESS 0
 
Return aRotina


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

    oModel:GetModel( "SZ8DETAIL" ):SetUniqueLine( { "Z8_OP" } )
    oModel:GetModel( 'SZ8DETAIL' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'SZ8DETAIL' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'SZ8DETAIL' ):SetNoDeleteLine( .T. )
    oModel:GetModel( 'SZ8DETAIL' ):CanUpdateLine(.T.)

    oModel:GetModel( "SZ9DETAIL" ):SetUniqueLine( { "Z9_OP" } )
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

    oView:CreateHorizontalBox( "VwSZ7" , 20 )
    oView:CreateHorizontalBox( "VwSZ8" , 40 )
    oView:CreateHorizontalBox( "VwSZ9" , 40 )

    oView:SetOwnerView( "VIEW_SZ7" , "VwSZ7" )
    oView:SetOwnerView( "VIEW_SZ8" , "VwSZ8" )
    oView:SetOwnerView( "VIEW_SZ9" , "VwSZ9" )

    oView:addUserButton("Apontamento Horas",                 "MAGIC_BMP", {|| ApontHoras() }, /*cToolTip*/, /*nShortCut*/, /*aOptions*/,                                     /*lShowBar*/)
Return oView


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
			@ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL
		
		//Grupo Ações com o Botão
		@ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
			@ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL
		
	//Ativando a janela
	ACTIVATE MSDIALOG oDlgForm CENTERED

    FwRestArea(cArea)
Return


Static Function fExecuta()
	Local cArea  := FwGetArea()
    Local cAlias := GetNextAlias()

    BeginSQL Alias cAlias
        Select C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_EMISSAO,C2_PRODUTO,C2_QUANT,C2_QUJE,C2_DATPRF,C2_DATRF, G2_OPERAC, G2_RECURSO, G2_DESCRI
        FROM %Table:SC2% SC2
        INNER JOIN %Table:SG2% SG2 ON G2_FILIAL = C2_FILIAL AND G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ = ' '
        WHERE SC2.%NotDel%
        and C2_FILIAL =  %xFilial:SC2%
        AND C2_NUM+C2_ITEM+C2_SEQUEN = %Exp:cGetForm%
    EndSQL
    if (cAlias)->( Eof())
            MsgAlert("Não tem Ordem de Producao","ATENÇÃO")
            FwRestArea(cArea)
	        RETURN
    Endif    

    While (cAlias)->(!EOF())
           dbSelectArea("SZ7")

           SZ7->( dbSetOrder(1) )
           IF SZ7->( !dbSeek( (cAlias)->C2_FILIAL+(cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN+(cAlias)->C2_PRODUTO,.T. ) ) 
                   IF RecLock("SZ7",.T.)
                      SZ7->Z7_FILIAL    :=  (cAlias)->C2_FILIAL
                      SZ7->Z7_OP        :=  (cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN
                      SZ7->Z7_PRODUTO   :=  (cAlias)->C2_PRODUTO
                      SZ7->Z7_QTPROD    :=  (cAlias)->C2_QUANT
                      SZ7->( MsUnlock() )
                   ENDIF
           ENDIF

           dbSelectArea("SZ8")
           SZ8->( dbSetOrder(1) )
           IF SZ8->( !dbSeek( (cAlias)->C2_FILIAL+(cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN+(cAlias)->C2_PRODUTO+(cAlias)->G2_OPERAC+(cAlias)->G2_RECURSO,.T. ) ) 
                   IF RecLock("SZ8",.T.)
                      SZ8->Z8_FILIAL    :=  (cAlias)->C2_FILIAL
                      SZ8->Z8_OP        :=  (cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN
                      SZ8->Z8_PRODUTO   :=  (cAlias)->C2_PRODUTO
                      SZ8->Z8_OPERAC    :=  (cAlias)->G2_OPERAC
                      SZ8->Z8_RECUR     :=  (cAlias)->G2_RECURSO
                      SZ7->( MsUnlock() )
                   ENDIF
           ENDIF

          (cAlias)->(dbSkip() )
    End
    (cAlias)->(DbCloseArea())

    FwRestArea(cArea)
Return



Static Function fAutoriza()
    Local aArea := GetArea()
    Local oGrpLog
    Local oBtnConf
    Private lRetorno := .F.
    Private oDlgPvt
    //Says e Gets
    Private oSayUsr
    Private oGetUsr, cGetUsr := Space(25)
    Private oSayPsw
    Private oGetPsw, cGetPsw := Space(20)
    Private oGetErr, cGetErr := ""
    //Dimensões da janela
    Private nJanLarg := 200
    Private nJanAltu := 200
      
    //Criando a janela
    DEFINE MSDIALOG oDlgPvt TITLE "Login" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Grupo de Login
        @ 003, 001     GROUP oGrpLog TO (nJanAltu/2)-1, (nJanLarg/2)-3         PROMPT "Login: "     OF oDlgPvt COLOR 0, 16777215 PIXEL
            //Label e Get de Usuário
            @ 013, 006   SAY   oSayUsr PROMPT "Usuário:"        SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 020, 006   MSGET oGetUsr VAR    cGetUsr           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL
          
            //Label e Get da Senha
            @ 033, 006   SAY   oSayPsw PROMPT "Senha:"          SIZE 030, 007 OF oDlgPvt                    PIXEL
            @ 040, 006   MSGET oGetPsw VAR    cGetPsw           SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 PIXEL PASSWORD
          
            //Get de Log, pois se for Say, não da para definir a cor
            @ 060, 006   MSGET oGetErr VAR    cGetErr        SIZE (nJanLarg/2)-12, 007 OF oDlgPvt COLORS 0, 16777215 NO BORDER PIXEL
            oGetErr:lActive := .F.
            oGetErr:setCSS("QLineEdit{color:#FF0000; background-color:#FEFEFE;}")
          
            //Botões
            @ (nJanAltu/2)-18, 006 BUTTON oBtnConf PROMPT "Confirmar"             SIZE (nJanLarg/2)-12, 015 OF oDlgPvt ACTION (fVldUsr()) PIXEL
            oBtnConf:SetCss("QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }")
    ACTIVATE MSDIALOG oDlgPvt CENTERED
      
    //Se a rotina foi confirmada e deu certo, atualiza o usuário e a senha
    If lRetorno
        cUsrLog := Alltrim(cGetUsr)
        cPswLog := Alltrim(cGetPsw)
    EndIf
      
    RestArea(aArea)
Return lRetorno
  
/*---------------------------------------------------------------------*
 | Func:  fVldUsr                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/09/2015                                                   |
 | Desc:  Função para validar se o usuário existe                      |
 *---------------------------------------------------------------------*/
  
Static Function fVldUsr()
    Local cUsrAux := Alltrim(cGetUsr)
    Local cPswAux := Alltrim(cGetPsw)
    Local cCodAux := ""
      
    //Pega o código do usuário
    RPCClearEnv()
    If RpcSetEnv("10", "0803", cUsrAux, cPswAux)
        cCodAux := RetCodUsr()
        lRetorno := .T.
       
     //Senão atualiza o erro e retorna para a rotina
     Else
         cGetErr := "Usuário e/ou senha inválidos!"
         oGetErr:Refresh()
    EndIf
      
    //Se o retorno for válido, fecha a janela
    If lRetorno
        oDlgPvt:End()
    EndIf
Return


Static Function ApontHoras()
    Local cArea := FwGetArea()
    //Local cCSS       := "QPushButton { background-color: #f4f4f4}"
    Local oModel     := FwModelActive()
    Local oView      := FWViewActive()
    Local oModelGrid := Nil
    Local nLinha

    oModelGrid:= oModel:getModel("SZ8DETAIL")

        For nLinha := 1 To oModelGrid:Length()

            oModelGrid:GoLine(1)

        Next nLinha

    oView:refresh("SZ8DETAIL")

    FwRestArea(cArea)
Return
