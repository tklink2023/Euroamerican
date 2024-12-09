//Bibliotecas
#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"


User Function PCPM080()
    Local aArea := GetArea()
    Private cCadastro := "Programação PCP"
    MsgRun("Atualizando Movimentos  "+cCadastro+".....", "Aguardem...", {|| RunProc() })
    MsgRun("Atualizando Movimentos Diarios  "+cCadastro+".....", "Aguardem...", {|| RunDia() })
    PCP80TELA()
    RestArea(aArea)
Return

Static Function RunProc()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "PCP_"+getNextAlias()
   
      cQuery:="		Select B2_FILIAL	FILIAL                                                            "+CRLF
      cQuery+="				,B2_COD		CODIGO                                                            "+CRLF
      cQuery+="				,B1_DESC    DESCRICAO                                                         "+CRLF
      cQuery+="				,B2_LOCAL	ALMOX                                                             "+CRLF
      cQuery+="				,B2_QATU	   SALDO                                                             "+CRLF
      cQuery+="				,B2_QEMP	   EMP                                                               "+CRLF
      cQuery+="				,(B2_QATU - B2_QEMP) DISPO                                                    "+CRLF
      cQuery+="				,ISNULL(ROUND((SELECT DIstinct AVG(Produzido) OVER(PARTITION BY Ano) AS Media "+CRLF
      cQuery+="				  FROM ( Select	D4_COD as Produto,                                          "+CRLF
      cQuery+="								Year(D4_DATA) as Ano,                                             "+CRLF
      cQuery+="								Month(D4_DATA) as Mes,                                            "+CRLF
      cQuery+="								Sum(D4_QTDEORI) as Produzido                                      "+CRLF
      cQuery+="						 From  " + RetSqlName("SD4") + "  SD4                                   "+CRLF
      cQuery+="						 Where SD4.D_E_L_E_T_ = ' '                                             "+CRLF
      cQuery+="						 AND D4_FILIAL = B2_FILIAL                                              "+CRLF
      cQuery+="						 AND Year(D4_DATA) = Year(Getdate())                                    "+CRLF
      cQuery+="						 AND Month(D4_DATA) BETWEEN Month(GetDate())-6 AND Month(GetDate())     "+CRLF
      cQuery+="						 AND D4_COD = B2_COD                                                    "+CRLF
      cQuery+="						 Group By D4_COD, Year(D4_DATA),Month(D4_DATA) ) xxx),3),0) MEDIA       "+CRLF
      cQuery+="		From  " + RetSqlName("SB2") + "  SB2                                                "+CRLF
      cQuery+="		INNER JOIN  " + RetSqlName("SB1") + "  SB1 ON B1_COD = B2_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' '"+CRLF
      cQuery+="		Where SB2.D_E_L_E_T_ = ' '                                                          "+CRLF
      cQuery+="		AND B2_FILIAL ='"+xFilial("SB2")+"'                                                 "+CRLF
      cQuery+="		AND B2_LOCAL = B1_LOCPAD                                                            "+CRLF
      cQuery+="		ORDER BY 1,2,3                                                                      "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return
   endif
   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
   
         dbSelectArea("PZ2")
         PZ2->( dbSetOrder(1) )
         IF PZ2->( !dbSeek(xFilial("PZ2") + (cAlias)->CODIGO,.T. ))
            IF RecLock("PZ2",.T.)
               PZ2->PZ2_FILIAL  := xFilial("PZ2")
               PZ2->PZ2_COD     := (cAlias)->CODIGO
               PZ2->PZ2_DESCR   := (cAlias)->DESCRICAO
               PZ2->PZ2_LOCAL   := (cAlias)->ALMOX
               PZ2->PZ2_SALDO   := (cAlias)->SALDO
               PZ2->PZ2_EMP     := (cAlias)->EMP
               PZ2->PZ2_DISPO   := (cAlias)->DISPO
               PZ2->PZ2_MEDIA   := (cAlias)->MEDIA
               PZ2->PZ2_DEMAN   := IIF((cAlias)->MEDIA > 0 , (cAlias)->MEDIA / 30 ,0 )
               PZ2->PZ2_STOK    := IIF((cAlias)->DISPO > 0 ,(cAlias)->DISPO / 30 , 0 )
               PZ2->( MsUnlock() )
            Endif
         else
            IF RecLock("PZ2",.F.)
               PZ2->PZ2_SALDO   := (cAlias)->SALDO
               PZ2->PZ2_EMP     := (cAlias)->EMP
               PZ2->PZ2_DISPO   := (cAlias)->DISPO
               PZ2->PZ2_MEDIA   := (cAlias)->MEDIA
               PZ2->PZ2_DEMAN   := IIF((cAlias)->MEDIA > 0 , (cAlias)->MEDIA / 30 ,0 )
               PZ2->PZ2_STOK    := IIF((cAlias)->DISPO > 0 ,(cAlias)->DISPO / 30 , 0 )               
               PZ2->( MsUnlock() )
            Endif
            
         ENDIF

         (cAlias)->( dbSkip() )
   EndDo

   (calias)->(DbCloseArea()) 

    FwRestArea(aArea)   
Return


Static Function RunDia()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "PCP_"+getNextAlias()
   
      cQuery:="SELECT CODIGO,Ano,MES,Dia,Qtd "+CRLF
      cQuery+=",AVG(Qtd) OVER(PARTITION BY Ano, MES) AS Media "+CRLF
      cQuery+="FROM ( "+CRLF
      cQuery+="SELECT "+CRLF
      cQuery+="		D4_COD			AS CODIGO, "+CRLF
      cQuery+="        DAY(D4_DATA)	AS Dia, "+CRLF
      cQuery+="        MONTH(D4_DATA)	AS MES, "+CRLF
      cQuery+="        YEAR(D4_DATA)	AS Ano, "+CRLF
      cQuery+="        Sum(D4_QTDEORI) as Qtd "+CRLF
      cQuery+="    FROM " + RetSqlName("SD4") + "  SD4 "+CRLF
      cQuery+="	INNER JOIN " + RetSqlName("SB1") + "  SB1 ON B1_COD = D4_COD AND B1_TIPO IN ( 'EM','MP') AND SB1.D_E_L_E_T_ = ' ' "+CRLF
      cQuery+="	Where SD4.D_E_L_E_T_ = ' ' "+CRLF
      cQuery+="	AND D4_FILIAL = '0803' "+CRLF
      cQuery+="	AND YEAR(D4_DATA) = YEAR(GetDate()) "+CRLF
      cQuery+="    GROUP BY D4_COD, YEAR(D4_DATA), MONTH(D4_DATA), DAY(D4_DATA) "+CRLF
      cQuery+=") a "+CRLF
      cQuery+="ORDER BY CODIGO, Ano, MES, Dia "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)

   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return
   endif
   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
   
         dbSelectArea("PZ3")
         PZ3->( dbSetOrder(1) )
         IF PZ3->( !dbSeek(xFilial("PZ3") + (cAlias)->CODIGO + cValtoChar((cAlias)->Ano) + cValtoChar((cAlias)->MES) + cValtoChar((cAlias)->Dia) ,.T. ))
            IF RecLock("PZ3",.T.)
               PZ3->PZ3_FILIAL  := xFilial("PZ3")
               PZ3->PZ3_PROD    := (cAlias)->CODIGO
               PZ3->PZ3_ANO     := cValtoChar((cAlias)->Ano)
               PZ3->PZ3_MES     := cValtoChar((cAlias)->MES)
               PZ3->PZ3_DIA     := cValtoChar((cAlias)->Dia)
               PZ3->PZ3_QTD     := (cAlias)->Qtd
               PZ3->( MsUnlock() )
            Endif
         else
            IF RecLock("PZ3",.F.)
               PZ3->PZ3_QTD     := (cAlias)->Qtd
               PZ3->( MsUnlock() )
            Endif
            
         ENDIF

         (cAlias)->( dbSkip() )
   EndDo

   (calias)->(DbCloseArea()) 

    FwRestArea(aArea)   
Return

Static Function PCP80TELA()
   Local aArea := FwGetArea()
   Local oBrowse
   
   oBrowse := FWMBrowse():New()
   oBrowse:SetAlias("PZ2")
   oBrowse:SetDescription("Programação")
   oBrowse:Activate()

   FwRestArea(aArea)
Return

Static Function MenuDef()
   Local aRotina :={}
   
   ADD OPTION aRotina TITLE 'Pesquisar'  				ACTION "AxPesqui"        	OPERATION 1  ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 				ACTION "VIEWDEF.PCPM080" 	OPERATION 2  ACCESS 0 //"Visualizar"

   //ADD OPTION aRotina TITLE "Negociar"			      ACTION "U_FM020NEG()" 		OPERATION 9  ACCESS 0 //"Negociar  
   //ADD OPTION aRotina TITLE "Imprimir"			      ACTION "U_FM020PLAN()" 		OPERATION 9  ACCESS 0 //"Relatorio  

Return aRotina

Static Function ModelDef()
   local oModel as object
   local oStrctPZ2 as object
   local oStrctPZ3 as object
   
   oStrctPZ2 := FwFormStruct( 1, "PZ2" , /*bFiltro*/ )
   oStrctPZ3 := FwFormStruct( 1, "PZ3" , /*bFiltro*/ )
   oStrctPZ3:SetProperty('PZ3_QTD'   , MODEL_FIELD_WHEN     ,  {||.T.})
    
   oModel    := MPFormModel():New( "MdlMvcPZ2", /*bPre*/ , /*bPos*/, /*bCommit*/, /*bCancel*/ )
   oModel:SetOperation(MODEL_OPERATION_UPDATE)
   oModel:AddFields( "M01PZ2", /*Owner*/ , oStrctPZ2 , /*bPre*/ , /*bPos*/ , /*bLoad*/ )

   oModel:AddGrid( "M02PZ3", "M01PZ2" , oStrctPZ3 , /*bLinePre*/ , /*bLinePost*/ , /*bPre*/ , /*bLinePost*/ , /*bLoad*/ )   
   oModel:SetRelation(  "M02PZ3", {{ "PZ3_FILIAL" , xFilial("PZ3") } , { "PZ3_PROD" , "PZ2_COD" } }, PZ3->( IndexKey(1) ) )

   oModel:GetModel( "M02PZ3" ):SetUniqueLine( { "PZ3_PROD","PZ3_ANO","PZ3_MES","PZ3_DIA" } )
   oModel:GetModel( 'M02PZ3' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'M02PZ3' ):SetNoUpdateLine( .F. )
	oModel:GetModel( 'M02PZ3' ):SetNoDeleteLine( .T. )
   oModel:GetModel( 'M02PZ3' ):CanUpdateLine(.T.)

   oModel:SetDescription("Movimentacoes")
   oModel:GetModel('M02PZ3'):SetDescription('Titulos de Perda')

Return oModel

Static Function ViewDef()
    local oModel as object
    local oView as object
    local oStrctPZ2 as object
    local oStrctPZ3 as object

    oModel    := FwLoadModel( "PCPM080" )
    oView     := FwFormView():New() 
    oStrctPZ2 := FwFormStruct( 2 , "PZ2" , /*bFiltro*/ )
    oStrctPZ3 := FwFormStruct( 2 , "PZ3" , /*bFiltro*/ )
    
    oStrctSZB:RemoveField( 'PZ3_FILIAL' )
    oStrctSZB:RemoveField( 'PZ3_PROD' )
    
    oView:SetModel( oModel )
    oView:AddField( "V01PZ2" , oStrctPZ2 , "M01PZ2" )
    oView:AddGrid( "V02PZ3" , oStrctSZB , "M02PZ3" )
    
    oView:CreateHorizontalBox( "VwPZ2" , 50 )
    oView:CreateHorizontalBox( "VwPZ3" , 25 )
    
    oView:SetOwnerView( "V01PZ2" , "VwPZ2" )
    oView:SetOwnerView( "V02PZ3" , "M02PZ3" )
    
Return oView
