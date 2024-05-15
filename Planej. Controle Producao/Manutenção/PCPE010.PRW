#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"


User Function PCPE010()
    Local cArea         := FwGetArea()
    Local aFields       :={}
    Local cAlias 	    := GetNextAlias()
    Local oDlgMark    as Object 
    Local aSize         := MsAdvSize()
    local bSair   as block
    Local bGrava  as block

    local oArea   as object
    local oBtn1   as object
    local oBtn2   as object
    local oCenterPanel as object
    local oLayout as object
    local oPanel  as object
    local oOption as object
    local oSide   as object

    Private ctmp        := GetNextAlias()
    Private oTable      := FWTemporaryTable():New( ctmp ) 
    Private aBrowse     := {}
    Private oBrowse    := FwBrowse():New()
    Private nPosPro:= 01, nPosDesc:= 02, nPosRev:= 03, nPosRST:= 04, nPosRFim:= 05, nPosDel := 06

    bSair   := {|| Iif(MsgYesNo('Deseja realmente sair do gerenciamento?','Gerenciamento'),(oDlgMark:End()),NIL)}
    bGrava  := {|| Iif(MsgYesNo('Grava Revisões?','Atualizar'),(PCPEGRV(),oDlgMark:End()),NIL)} 

    aAdd(aFields,{"TMP_FILIAL"		, GetSx3Cache("G5_FILIAL","X3_TIPO")		,tamSx3("G5_FILIAL")[1]	    ,tamSx3(" G5_FILIAL")[2]})
    aAdd(aFields,{"TMP_PROD"		, GetSx3Cache("G5_PRODUTO","X3_TIPO")		,tamSx3("G5_PRODUTO")[1]	,tamSx3(" G5_PRODUTO")[2]})
    aAdd(aFields,{"TMP_DESC"		, GetSx3Cache("B1_DESC","X3_TIPO")		    ,tamSx3("B1_DESC")[1]	    ,tamSx3(" B1_DESC")[2]})
    aAdd(aFields,{"TMP_REV"	    	, GetSx3Cache("G5_REVISAO","X3_TIPO")		,tamSx3("G5_REVISAO")[1]	,tamSx3(" G5_REVISAO")[2]})
    aAdd(aFields,{"TMP_REVSTR"	   	, GetSx3Cache("G5_REVISAO","X3_TIPO")		,tamSx3("G5_REVISAO")[1]	,tamSx3(" G5_REVISAO")[2]})
    aAdd(aFields,{"TMP_FINAL"		, GetSx3Cache("G5_REVISAO","X3_TIPO")		,tamSx3("G5_REVISAO")[1]	,tamSx3(" G5_REVISAO")[2]})

	oTable:SetFields( aFields )
	oTable:AddIndex("ind1",{"TMP_FILIAL","TMP_PROD"} )

 	oTable:Create()

    cQuery :=" select	DISTINCT "
    cQuery +="   		B1_COD,  "
    cQuery +="		    B1_DESC, "
    cQuery +="		    B1_TIPO, "
    cQuery +="		    B1_REVATU,"
    cQuery +="		    ISNULL(( SELECT MAX(G1_REVFIM) FROM SG1100 SG1A WHERE SG1A.D_E_L_E_T_ = ' ' AND SG1A.G1_FILIAL = '0803' AND SG1A.G1_COD = SB1.B1_COD ),'')  G1_REVFIM "
    cQuery +="From "+ RetSqlName("SB1")+" SB1 "
    cQuery +="LEFT JOIN "+ RetSqlName("SB5")+" SB5 ON B5_FILIAL = '0803' AND B5_COD = B1_COD AND SB5.D_E_L_E_T_ = ' ' "
    cQuery +="LEFT JOIN "+ RetSqlName("SG1")+" SG1 ON G1_FILIAL = B5_FILIAL AND G1_COD = B1_COD AND SG1.D_E_L_E_T_ = ' ' "
    cQuery +="WHERE SB1.D_E_L_E_T_ = ' ' "
    cQuery +="AND B1_MSBLQL <> '1' "
    cQuery +="AND B1_TIPO = 'PI' "
    cQuery +="ORDER BY 1 "

   cQuery := ChangeQuery(cQuery)

    If !Empty(Select(cAlias))
        DbSelectArea(cAlias)
            (cAlias)->(dbCloseArea())
    Endif
            
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

    DbSelectArea(cAlias)
    (cAlias)->( dbGotop() )

    ProcRegua(Reccount())

    While (cAlias)->( !Eof() )
          IF RecLock(ctmp,.T.)
            TMP_FILIAL  := '0803'	
            TMP_PROD    := (cAlias)->B1_COD	
            TMP_DESC    := (cAlias)->B1_DESC	
            TMP_REV     := (cAlias)->B1_REVATU	
            TMP_REVSTR  := (cAlias)->G1_REVFIM	
            TMP_FINAL   :=  space( tamSx3( "G5_REVISAO" )[1]        )
            MsUnlock()
          ENDIF
       IncProc("Gerando arquivo...")
      (cAlias)->(dbSkip() )           
    ENDDO
    (cAlias)->(dbCloseArea())   

    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 

    dbSelectArea(ctmp)
    (ctmp)->( dbgotop() )
    While (ctmp)->( !Eof() )
        aAdd( aBrowse, {      (ctmp)->TMP_PROD,;
                                (ctmp)->TMP_DESC,;
                                (ctmp)->TMP_REV,;
                                (ctmp)->TMP_REVSTR,;
                                (ctmp)->TMP_FINAL,;
                                .F.})
        (ctmp)->(dbSkip() )
    EndDo

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

    oBtn1 := TButton():New( 1,202,'Gravar Revisões' ,oOption, bGrava,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn1:Align := CONTROL_ALIGN_TOP

    oBtn2 := TButton():New( 1,202,'Sair'    ,oOption, bSair,35 ,15 ,,,.F. ,.T. ,.F. ,,.F. ,,,.F. )
    oBtn2:Align := CONTROL_ALIGN_BOTTOM

    oArea:AddLayout ( "Default" )
    oLayout := oArea:GetLayout ( "Default" )

    oArea:AddWindow ( 100, 100, "cId2","Estruturas", 3 , 3,oLayout, CONTROL_ALIGN_TOP )
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
    //oBrowse:AddStatusColumns( { || BrwStatus() }, { || BrwLegend() } )
    oBrowse:setInsert( .T. ) 
    oBrowse:Setdelete(.T.,{ || PM050DEL() } ) 
    oBrowse:SetBlkBackColor({|| IIf(aBrowse[oBrowse:nAt,nPosDel]=.T. , CLR_LIGHTGRAY , Nil )})

    oBrowse:addColumn({"Produto", {||aBrowse[oBrowse:nAt,nPosPro]}, GetSx3Cache("G5_PRODUTO","X3_TIPO"), pesqPict("SG5","G5_PRODUTO") , 1, tamSx3("G5_PRODUTO")[1] ,, .T. ,, .F.,, "XG5_PRODUTO",, .F., .T.,, "XG5_PRODUTO"})

    oBrowse:addColumn({"Descricao", {||aBrowse[oBrowse:nAt,nPosDesc]}, GetSx3Cache("B1_DESC","X3_TIPO"), pesqPict("SB1","B1_DESC") , 1, tamSx3("B1_DESC")[1] ,, .T. ,, .F.,, "XB1_DESC",, .F., .T.,, "XB1_DESC"})

    oBrowse:addColumn({"Revisao", {||aBrowse[oBrowse:nAt,nPosRev]}, GetSx3Cache("G5_REVISAO","X3_TIPO"), pesqPict("SG5","G5_REVISAO") , 1, tamSx3("G5_REVISAO")[1] ,, .T. ,, .F.,, "XG5_REVISAO",, .F., .T.,, "XG5_REVISAO"})

    oBrowse:addColumn({"Rev.Estru", {||aBrowse[oBrowse:nAt,nPosRST]}, GetSx3Cache("G5_REVISAO","X3_TIPO"), pesqPict("SG5","G5_REVISAO") , 1, tamSx3("G5_REVISAO")[1] ,, .T. ,, .F.,, "XG5_REVSTRU",, .F., .T.,, "XG5_REVSTRU"})

   oBrowse:addColumn({"Rev.Final", {||aBrowse[oBrowse:nAt,nPosRFim]}, GetSx3Cache("G5_REVISAO","X3_TIPO"), pesqPict("SG5","G5_REVISAO") , 1, tamSx3("G5_REVISAO")[1] ,, .T. ,, .F.,, "XG5_REVFIM",, .F., .T.,, "XG5_REVFIM"})    

   oBrowse:acolumns[nPosRFim]:ledit     := .T.
   oBrowse:acolumns[nPosRFim]:cReadVar:= 'aBrowse[oBrowse:nAt,nPosRFim]'

   oBrowse:setAfterAddLine( { || posIncLine()} )
   oBrowse:setEditCell( .T.,{ || PM050VLD() } )

  oBrowse:Activate()

  ACTIVATE MSDIALOG oDlgMark CENTERED

  FwRestArea(cArea)

RETURN

Static function posIncLine()
    aBrowse[ oBrowse:nAt , oBrowse:GetColByID("XG5_PRODUTO"):nOrder ]   := space( tamSx3( "XG5_PRODUTO" )[1]  )
    aBrowse[ oBrowse:nAt , oBrowse:GetColByID("XB1_DESC"):nOrder ]      := space( tamSx3( "XB1_DESC" )[1] )
    aBrowse[ oBrowse:nAt , oBrowse:GetColByID("XG5_REVISAO"):nOrder ]   := space( tamSx3( "XG5_REVISAO" )[1] )
    aBrowse[ oBrowse:nAt , oBrowse:GetColByID("XG5_REVSTRU"):nOrder ]   := space( tamSx3( "XG5_REVISAO" )[1] )
    aBrowse[ oBrowse:nAt , oBrowse:GetColByID("XG5_REVFIM"):nOrder ]    := space( tamSx3( "XG5_REVISAO" )[1] )
    aBrowse[ oBrowse:nAt , nPosDel]                                     := .F.
return

static function PM050VLD()
   Local nPos:= oBrowse:ColPos()

   IF nPos = nPosRFim  // Posiciona na coluna Local ( Armazem ) dispara os calculos 
      IF aBrowse[oBrowse:nAt][nPosRFim] < aBrowse[oBrowse:nAt][nPosRST] 
         msgAlert("Nao pode ser menor que da estrutura")
      Endif
   ENDIF

Return(.T.)

Static Function PM050DEL()
     Local cArea       := FWGetArea()
     Local nLinha      := oBrowse:nAt
     Local lSit        := oBrowse:LDELETE
     if lSit 
         aBrowse[nLinha][nPosDel] := .T.
     Endif    
     oBrowse:setArray(aBrowse)	// Forço o Browse a ler os novos valores informados.
     oBrowse:GoTop()
     oBrowse:Refresh()	
     FWRestArea(cArea)
RETURN


Static Function PCPEGRV()
    Local cArea := FwGetArea()
    Local nReg  := Len(aBrowse)
    Local I
     ProcRegua(nReg)
    if Len(aBrowse) > 0
        FOR I:=1 TO Len(aBrowse)
             IF !Empty(aBrowse[I][nPosRFim])
                    GrvSG5( aBrowse[I][nPosPro],aBrowse[I][nPosRev],aBrowse[I][nPosRFim])
             Endif
           IncProc("Gerando arquivo...")  
        NEXT
    Endif
    FwRestArea(cArea)
Return

Static Function GrvSG5(cCodigo,cRevisao,cRevFinal)
    Local cArea := FwGetArea()
    Local AB

    FOR AB:= 1 TO VAL(cRevFinal)
        dbSelectArea("SG5")
        SG5->( dbSetOrder(1))
        IF SG5->( !dbSeek(xFilial("SG5")+cCodigo+STRZERO(AB,3) ,.T.))
            IF RECLOCK("SG5",.T.)
                SG5->G5_FILIAL  := xFilial("SG5")
                SG5->G5_PRODUTO := cCodigo
                SG5->G5_REVISAO := STRZERO(AB,3)
                SG5->G5_USER    := RETCODUSR()
                SG5->G5_MSBLQL  := IIF(STRZERO(AB,3) = cRevisao,"2","1" )
                SG5->G5_STATUS  := IIF(STRZERO(AB,3) = cRevisao,"2","1" )
                SG5->G5_DATAREV := dDataBase
                SG5->G5_OBS     := "GERADO PCPE010"
               SG5->( MsUnlock() )
            ENDIF  
        ENDIF
    NEXT

    FwRestArea(cArea)
Return
