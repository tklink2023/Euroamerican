#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"

#DEFINE cEof  CHAR(13)+CHAR(10)

/*/{Protheus.doc} PCPM070
description Programa que ira substituir a planilha de programação TB-18 
@type function
@version 1.0
@author Paulo Lenzi
@since 07/11/2024
@return variant, return_description
/*/
User Function PCPM070()
    Local aArea      := FwgetArea()
    
    Local oDlgMark as Object 
    Local aSize      := MsAdvSize()
    local bSair   as block
    Local bGrava  as block
    Local bPrt1   as Block
    Local bExcel  as Block

    local oArea   as object
    local oBtn1   as object
    local oBtn2   as object
    local oBtn4   as object
 
    local oCenterPanel as object
    local oLayout as object
    local oPanel  as object
    local oOption as object
    local oSide   as object
   
    Private nPosCli := 01 ,nPosPed := 02 ,nPosItem := 03,nPosLead := 04 ,nPosPro := 05 ,nPosDesc := 06 ,nPosLocal := 07 ,nPosQtd := 08 ,nPosSld := 09 ,nPosTot := 10 ,nPosApu := 11 ,nPossta := 12,nPosDel := 13

    Private aBrowse     := {}
    Private oBrowse     := FwBrowse():New()
    Private dDataIni
    Private dDataFim
    Private nPosicao    := 2
       
    bSair  := {|| Iif(MsgYesNo('Deseja realmente sair?','Gerenciamento'),(oDlgMark:End()),NIL)}
    bGrava := {|| PM070FIL(aBrowse[oBrowse:nAt][nPosPro]) }
    bPrt1  := {|| U_PCPR071() }
    bExcel := {|| U_PCPE070() }
   
    MsgRun("Criando tabela de dados. Aguarde.....", "Processando", {|| RunProc() })

    MsgRun("Carregando dados. Aguarde.....", "Processando", {|| CallBase() })
      
    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

   Set Key VK_F12 To
	SetKey( VK_F12, { || pergunte("PCPM070",.T.) } )
   nPosicao := MV_PAR01

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 

    DEFINE MSDIALOG oDlgMark FROM 0,0 TO nHeight,nWidth TITLE "" PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

    oPanel := TPanel():New(0,0,,oDlgMark,,,,,,15,0,.F.,.F.)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT

    oArea := FWArea():New(000,000,nHeight/2,nWidth,oPanel,0)
    oArea:CreateBorder(2)

    oArea:AddSideBar ( 12, 1, "oSide" )
    oSide := oArea:GetSideBar("oSide")

    oArea:AddWindow ( 100, 100, "cId1" ,"Ações", 3 , 2,oSide, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oOption")
    oOption := oArea:GetPanel("oOption")

    oBtn1 := TButton():New( 1,202,'Observações' ,oOption, bGrava,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn1:Align := CONTROL_ALIGN_TOP

    oBtn8 := TButton():New( 1,202,'Relatorio Movimento' ,oOption, bPrt1,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn8:Align := CONTROL_ALIGN_TOP    

    oBtn4 := TButton():New( 1,202,'Exporta Excell' ,oOption, bExcel,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn4:Align := CONTROL_ALIGN_TOP

    oBtn2 := TButton():New( 1,202,'Sair'    ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_BOTTOM

    oArea:AddLayout ( "Default" )
    oLayout := oArea:GetLayout ( "Default" )

    oArea:AddWindow ( 100, 100, "cId2","Relação de Produtos Barrados", 3 , 3,oLayout, CONTROL_ALIGN_TOP )
    oArea:AddPanel(100,100,"oCenterPanel")
    oCenterPanel := oArea:GetPanel("oCenterPanel")

     if oBrowse != nil
        oBrowse:DeActivate()
     endif

    // Função de telas 
    
    oBrowse:SetOwner(oCenterPanel)
    oBrowse:setDataArray()
    oBrowse:setArray( aBrowse )
    oBrowse:disableConfig()
    oBrowse:disableReport()
    oBrowse:SetLocate()
    oBrowse:setInsert( .T. ) 
    oBrowse:Setdelete(.T.,{ || PM070DEL() } ) 
    oBrowse:SetBlkBackColor({|| IIf(aBrowse[oBrowse:nAt,nPosDel]=.T. , CLR_LIGHTGRAY , Nil )})

    oBrowse:addColumn({"Cliente" , {||aBrowse[oBrowse:nAt,nPosCli]}, GetSx3Cache("A1_NOME","X3_TIPO"), pesqPict("SA1","A1_NOME") , 1, tamSx3("A1_NOME")[1] ,, .T. ,, .F.,, "XA1_NOME",, .F., .T.,, "XA1_NOME"})
    oBrowse:addColumn({"Pedido"  , {||aBrowse[oBrowse:nAt,nPosPed]}, GetSx3Cache("C6_NUM","X3_TIPO"), pesqPict("SC6","C6_NUM") , 0, tamSx3("C6_NUM")[1] ,, .T. ,, .F.,, "XC6_NUM",, .F., .T.,, "XC6_NUM"})
    oBrowse:addColumn({"item"    , {||aBrowse[oBrowse:nAt,nPosItem]}, GetSx3Cache("C6_ITEM","X3_TIPO"), pesqPict("SC6","C6_ITEM") , 0, tamSx3("C6_ITEM")[1] ,, .T. ,, .F.,, "XC6_ITEM",, .F., .T.,, "XC6_ITEM"})
    oBrowse:addColumn({"Lead Time", {||aBrowse[oBrowse:nAt,nPosLead]}, GetSx3Cache("ZB_LEAD","X3_TIPO"), pesqPict("SZB","ZB_LEAD") ,0, tamSx3("ZB_LEAD")[1] ,, .T. ,, .F.,, "XLEADTIME",, .F., .T.,, "XLEADTIME"})
    oBrowse:addColumn({"Produto" , {||aBrowse[oBrowse:nAt,nPosPro]}, GetSx3Cache("C6_PRODUTO","X3_TIPO"), pesqPict("SC6","C6_PRODUTO") , 1, tamSx3("C6_PRODUTO")[1] ,, .T. ,, .F.,, "XC6_PRODUTO",, .F., .T.,, "XC6_PRODUTO"})
    oBrowse:addColumn({"Descrição", {||aBrowse[oBrowse:nAt,nPosDesc]}, GetSx3Cache("B1_DESC","X3_TIPO"), pesqPict("SB1","B1_DESC") , 1, tamSx3("B1_DESC")[1] ,, .T. ,, .F.,, "XB1_DESC",, .F., .T.,, "XB1_DESC"})    
    oBrowse:addColumn({"Local"    , {||aBrowse[oBrowse:nAt,nPosLocal]}, GetSx3Cache("C6_LOCAL","X3_TIPO"), pesqPict("SC6","C6_LOCAL") , 0, tamSx3("C6_LOCAL")[1] ,, .T. ,, .F.,, "XC6_LOCAL",, .F., .T.,, "XC6_LOCAL"})
    oBrowse:addColumn({"Quantidade", {||aBrowse[oBrowse:nAt,nPosQtd]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 2, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XC6_QTDVEN",, .F., .T.,, "XC6_QTDVEN"})
    oBrowse:addColumn({"Saldo"    , {||aBrowse[oBrowse:nAt,nPosSld]}, GetSx3Cache("B2_QATU","X3_TIPO"), pesqPict("SB2","B2_QATU") , 2, tamSx3("B2_QATU")[1] ,, .T. ,, .F.,, "XB2_QATU",, .F., .T.,, "XB2_QATU"})
    oBrowse:addColumn({"Total_Qtd", {||aBrowse[oBrowse:nAt,nPosTot]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 2, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XTOTALQTD",, .F., .T.,, "XTOTALQTD"})
    oBrowse:addColumn({"Disponivel" , {||aBrowse[oBrowse:nAt,nPosApu]}, GetSx3Cache("C6_QTDVEN","X3_TIPO"), pesqPict("SC6","C6_QTDVEN") , 2, tamSx3("C6_QTDVEN")[1] ,, .T. ,, .F.,, "XAPURADO",, .F., .T.,, "XAPURADO"})
    oBrowse:addColumn({"Status"   , {||aBrowse[oBrowse:nAt,nPossta]}, GetSx3Cache("A1_NREDUZ","X3_TIPO"), pesqPict("SA1","A1_NREDUZ") , 1, tamSx3("A1_NREDUZ")[1] ,, .T. ,, .F.,, "XSTATUS",, .F., .T.,, "XSTATUS"})

    oBrowse:acolumns[nPossta]:ledit     := .T.
    oBrowse:acolumns[nPossta]:cReadVar:= 'aBrowse[oBrowse:nAt,nPossta]'

    //oBrowse:setAfterAddLine( { || posIncLine()} )
    oBrowse:setEditCell( .T.,{ || PM070VLD() } )
    oBrowse:Refresh(.T.)	
    oBrowse:Activate()

    ACTIVATE MSDIALOG oDlgMark CENTERED

    FwRestArea(aArea)
Return

/*/{Protheus.doc} RunProc
description Rotina que atraves de Query grava as informações na tabela temporaria que servira na apresentação da tela
@type function
@version 1.0
@author Paulo Lenzi
@since 08/11/2024
@return variant, return_description
/*/
Static Function RunProc()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := "B"+getNextAlias()

   cQuery:="   SELECT A1_NOME NOME "+CRLF
   cQuery+="   ,PCP.Pedido "+CRLF
   cQuery+="   ,PCP.Item "+CRLF
   cQuery+="   ,PCP.Sequencia "+CRLF
   cQuery+="   ,PCP.Produto "+CRLF
   cQuery+="   ,PCP.Descrição  DESCR"+CRLF
   cQuery+="   ,PCP.Local ALMOX "+CRLF
   cQuery+="   ,PCP.QtdLiberar "+CRLF
   cQuery+="   ,PCP.DataLiberacao "+CRLF
   cQuery+="   ,PCP.DataEntrega "+CRLF
   cQuery+="   ,PCP.SaldoEnderecado "+CRLF
   cQuery+="   ,PCP.SaldoEnderecar "+CRLF
   cQuery+="   ,PCP.SaldoEstoque "+CRLF
   cQuery+="   ,PCP.TotalLiberado "+CRLF
   cQuery+="   ,PCP.SaldoDisponivel "+CRLF
   cQuery+="   ,PCP.Status Situacao"+CRLF
   cQuery+="   ,SC5.C5_CLIENT, SC5.C5_LOJACLI "+CRLF
   cQuery+="  ,DATEDIFF(DD,C5_EMISSAO, GETDATE())  LEAD  "+CRLF
   cQuery+="  ,CASE WHEN SB1.B1_XCLASSI = 'L' THEN 'LINHA' ELSE 'ESPECIAL' END AS Classe "+CRLF 
   cQuery+="  ,CASE WHEN SB1.B1_XTPBASE = 'A' THEN 'Agua'  "+CRLF
   cQuery+="			WHEN SB1.B1_XTPBASE = 'S' THEN 'Solvente'  "+CRLF
   cQuery+="			WHEN SB1.B1_XTPBASE = 'C' THEN 'Acrilico'  "+CRLF
   cQuery+="			WHEN SB1.B1_XTPBASE = 'V' THEN 'Viniculo'  "+CRLF
   cQuery+="			WHEN SB1.B1_XTPBASE = 'O' THEN 'Outros'  "+CRLF
   cQuery+="			else 'Sem Tipo' end AS Tipo  "+CRLF
   cQuery+="FROM dbo.V_PCP_AnaliseLiberacoesPV PCP "+CRLF
   cQuery+="INNER JOIN "+RetSqlName("SC5")+"  SC5 ON C5_FILIAL = PCP.Filial and C5_NUM = PCP.Pedido and SC5.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="INNER JOIN "+RetSqlName("SB1")+"  SB1 ON B1_COD = PCP.Produto and SB1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="INNER JOIN "+RetSqlName("SA1")+"  SA1 ON A1_FILIAL = PCP.Filial and A1_COD = SC5.C5_CLIENTE AND A1_LOJA = SC5.C5_LOJACLI and SA1.D_E_L_E_T_ = ' ' "+CRLF
   cQuery+="WHERE PCP.Filial = '0803' "+CRLF
   cQuery+="order by PCP.Pedido "+CRLF

   DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return
   endif


   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
         // Funcao que traz o total de quantidades

         dbSelectArea("SZB")
         ("SZB")->( dbSetOrder(1) )

         if  ("SZB")->( !dbSeek(xFilial("SZB")+(cAlias)->C5_CLIENT+(cAlias)->C5_LOJACLI+(cAlias)->Pedido+(cAlias)->Produto,.T.))

            IF RECLOCK("SZB",.T.)

               SZB->ZB_FILIAL  :=xFilial("SZB")
               SZB->ZB_CLIENTE := (cAlias)->C5_CLIENT
               SZB->ZB_LOJA    := (cAlias)->C5_LOJACLI
               SZB->ZB_NOME    := (cAlias)->NOME
               SZB->ZB_PEDIDO  := (cAlias)->Pedido
               SZB->ZB_ITEM    := (cAlias)->Item

               SZB->ZB_SEQ     := (cAlias)->Sequencia
               SZB->ZB_DTLIB   := stod((cAlias)->DataLiberacao)
               SZB->ZB_DTENT   := stod((cAlias)->DataEntrega)

               SZB->ZB_LEAD    := (cAlias)->LEAD

               SZB->ZB_COD     := (cAlias)->Produto
               SZB->ZB_DESC    := (cAlias)->DESCR
               SZB->ZB_LOCAL   := (cAlias)->ALMOX
               SZB->ZB_QTD     := (cAlias)->QtdLiberar

               SZB->ZB_SLDE    := (cAlias)->SaldoEnderecado
               SZB->ZB_SLDA    := (cAlias)->SaldoEnderecar
            
               SZB->ZB_PERIODO := AnoMes(dDataBase)
               SZB->ZB_SALDO   := (cAlias)->SaldoEstoque
               SZB->ZB_TOTAL   := (cAlias)->TotalLiberado
               SZB->ZB_QTAPU   := (cAlias)->SaldoDisponivel
               SZB->ZB_STATUS  := alltrim(Upper((cAlias)->Situacao))
               SZB->ZB_SITUA   := alltrim(Upper((cAlias)->Situacao))
               SZB->ZB_CLASSE  := (cAlias)->Classe
               SZB->ZB_TIPO    := (cAlias)->Tipo
               ("SZB")->( MsUnlock() )
            else
               IF RECLOCK("SZB",.F.)        
                  
                  SZB->ZB_QTD     := (cAlias)->QtdLiberar     
                  SZB->ZB_SLDE    := (cAlias)->SaldoEnderecado
                  SZB->ZB_SLDA    := (cAlias)->SaldoEnderecar                  
                  SZB->ZB_SALDO   := (cAlias)->SaldoEstoque
                  SZB->ZB_TOTAL   := (cAlias)->TotalLiberado
                  SZB->ZB_QTAPU   := (cAlias)->SaldoDisponivel
                  IF alltrim(Upper((cAlias)->Situacao)) = "LIBERADO"
                     SZB->ZB_STATUS  := alltrim(Upper((cAlias)->Situacao))
                  ENDIF   
                  SZB->ZB_SITUA   := alltrim(Upper((cAlias)->Situacao))

                 ("SZB")->( MsUnlock() ) 
               ENDIF  
            ENDIF   

         ENDIF
      
        (cAlias)->(dbSkip() )

    EndDo
    
   (calias)->(DbCloseArea()) 

Return

/*/{Protheus.doc} PM070DEL
description Rotina para deletar as linhas do aBrowse quando for necessario 
@type function
@version 1.0
@author Paulo Lenzi
@since 08/11/2024
@return variant, return_description
/*/
Static Function PM070DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrowse:nAt
     Local lSit        := oBrowse:LDELETE

     if lSit 
         if MsgYesNo("Deseja excluir a linha desse produto","Atenção")
            aBrowse[nLinha][nPosDel] := .T.
            aDel(aBrowse, nLinha)
            aSize(aBrowse, Len(adespes) - 1)
         endif   
     Endif    

     oBrowse:Reset()
     oBrowse:setArray(aBrowse)	// Forço o Browse a ler os novos valores informados.
     oBrowse:GoTop()

     oBrowse:Refresh(.T.)	
     FWRestArea(cArea)
RETURN

/*/{Protheus.doc} PM070VLD
description Rotina que valida no caso de digitação na coluna de Status
@type function
@version 1.0
@author Paulo Lenzi
@since 08/11/2024
@return variant, return_description
/*/
static function PM070VLD()
   Local nPos:= oBrowse:ColPos()
   // Informações do Produto
   IF nPos = nPossta  // Posiciona na coluna Local ( Armazem ) dispara os calculos 
      adespes[oBrowse:nAt][nPossta] := ' '
   ENDIF
Return(.T.)

/*/{Protheus.doc} PM070FIL
description Rotina que permite escolher atraves de combo as opções que será gravadas na coluna de Status
@type function
@version 1.0
@author Paulo Lenzi
@since 08/11/2024
@return variant, return_description
/*/
Static Function PM070FIL(cCodProd)
  Local aArea := FwgetArea()
  Local aRet  	  :=	{}
  Local aPergs    := {}
  Local cProduto  := cCodProd
  Local cObserv   := ' '
  Local cQuery    := ""

  aAdd(aPergs, {1, "Produto De" ,  cProduto,  "", ".T.", "SB1", ".T.", 80,  .F.})
  aAdd( aPergs ,{1,"Digite:   " , Upper(Space(100))    ,"","","","",110,.T.})

  If ParamBox(aPergs, "Informe os parâmetros",aRet)  
      cProduto := aRet[1]
      cObserv  := aRet[2]
  Else
		MsgAlert("Encerrado")
      oBrowse:Refresh(.T.)	
      FWRestArea(aArea)
		Return
  EndIf

   cQuery := "UPDATE  "+RetSqlName("SZB")+" SET ZB_STATUS = '"+ALLTRIM(cObserv)+"'  "+cEof
   cQuery += "from  "+RetSqlName("SZB")+" SZB  "+cEof
   cQuery += "WHERE SZB.D_E_L_E_T_ = ' '  "+cEof
   cQuery += "AND ZB_FILIAL = '"+xFilial("SZB")+"'  "+cEof
   cQuery += "AND ZB_PERIODO = '"+AnoMes(dDataBase)+"'  "+cEof
   cQuery += "AND ZB_COD = '"+cProduto+"'  "+cEof

   If TCSqlExec(cQuery) < 0
         FWAlertInfo("Falha: " + TCSQLError(), "Teste 1 TCSQLExec e TCSQLError")
   Else
         MsgRun("Carregando dados. Aguarde.....", "Processando", {|| CallBase() })
   EndIf
  
  oBrowse:Refresh(.T.)	
  FWRestArea(aArea)

Return

/*/{Protheus.doc} RemoveChar
description Funcao para remover caracteres especiais
@type function
@version 1.0
@author Paulo Lenzi
@since 11/12/2024
@param cCampo, character, param_description
@return variant, return_description
/*/
Static Function RemoveChar(cCampo)
   Local lRet := ""
   lRet := Strtran(cCampo,"&","",1)
   lRet := Strtran(lRet,"$","",1)
   lRet := Strtran(lRet,"#","",1)
   lRet := Strtran(lRet,">","",1)
   lRet := Strtran(lRet,"<","",1)
   lRet := Strtran(lRet,"Ç","",1)
   lRet := Strtran(lRet,"ç","",1)
   lRet := Strtran(lRet,"!","",1)
   lRet := Strtran(lRet,"=","",1)
   lRet := Strtran(lRet,"Ç","",1)
Return(lRet)


Static Function CallBase()
   Local aArea   := FwgetArea()
   Local cQuery  as character 
   Local cAlias  := getNextAlias()

   nPosicao := 2

   cQuery:= "Select * "+cEof
   cQuery+= "from "+RetSqlName("SZB")+" SZB "+cEof
   cQuery+= "Where SZB.D_E_L_E_T_ = ' ' "+cEof
   cQuery+= "AND ZB_FILIAL = '0803' "+cEof
   cQuery+= "AND RTRIM(ZB_PERIODO) = '"+AnoMes(dDataBase)+"'  "+cEof

  DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .T.)
 
   IF (cAlias)->(Eof())
      (cAlias)->(DbCloseArea())   
       FwRestArea(aArea)
      Return
   endif

   aBrowse := {}
   dbselectArea(cAlias)
   (cAlias)->( dbGoTop() )
   While (cAlias)->( !Eof())
   
        IF nPosicao = 1
            IF Alltrim((cAlias)->ZB_SITUA) = "BARRADOS"
               (cAlias)->(dbSkip() )
               Loop
            Endif

        elseif  nPosicao = 2  // Liberado
            IF Alltrim((cAlias)->ZB_SITUA) = "LIBERADO"
               (cAlias)->(dbSkip() )
               Loop
            Endif
        else
        Endif  

        aAdd( aBrowse, {        (cAlias)->ZB_NOME,;
                                (cAlias)->ZB_PEDIDO,;
                                (cAlias)->ZB_ITEM,;
                                (cAlias)->ZB_LEAD,;
                                (cAlias)->ZB_COD,;
                                (cAlias)->ZB_DESC,;
                                (cAlias)->ZB_LOCAL,;
                                (cAlias)->ZB_QTD,;
                                (cAlias)->ZB_SALDO,;
                                (cAlias)->ZB_TOTAL,;
                                (cAlias)->ZB_QTAPU,;
                                (cAlias)->ZB_STATUS,;
                                .F.})
        (cAlias)->(dbSkip() )
    EndDo
    aSort(aBrowse, , , {|x, y| x[5] < y[5]})
    (cAlias)->(DbCloseArea())   
    FwRestArea(aArea)
Return

Static Function PCP070CLEAR()

Return
//-====================================================================================================================================================//
// FIM DO PROGRAMA
//-====================================================================================================================================================//
