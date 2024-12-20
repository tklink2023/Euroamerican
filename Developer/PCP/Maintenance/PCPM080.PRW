//Bibliotecas
#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "FwBrowse.ch"
#Include "fwmbrowse.ch"
#include 'tbiconn.ch'
#include "topconn.ch"
#Include "PRCONST.ch"

User Function PCPM080()
    Local aArea := GetArea()
    Local oDlg 	as Object 
    Local oBrowse 	as Object 
    Local aBrowse 	as Array 
    Local cAlias  	:= GetNextAlias()
    Local aSize   	:= MsAdvSize()
    local aButtons := {}

    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    aAdd(aButtons,{"SAIR",{|| oDlg:End()},"Sair","Sair"})

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
    BeginSQL Alias cAlias
		SELECT      *
    	FROM %Table:PZ2% PZ2
		WHERE PZ2.%NotDel%
		and PZ2_FILIAL =  %xFilial:PZ2%
	    ORDER BY PZ2_COD
    EndSQL
    if (cAlias)->( Eof())
        MsgAlert("Nao tem nada empenhado nesse produto","Atencao")
        FwRestArea(aArea)
	    RETURN
    Endif
    aBrowse :={}
    If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aBrowse , {(cAlias)->PZ2_COD,;
							    (cAlias)->PZ2_DESCR,;
							    (cAlias)->PZ2_LOCAL,;
							    (cAlias)->PZ2_SALDO,;
							    (cAlias)->PZ2_EMP,;
							    (cAlias)->PZ2_DISPO,;
							    (cAlias)->PZ2_MEDIA,;
							    (cAlias)->PZ2_DEMAN,;
							    (cAlias)->PZ2_STOK})
                (cAlias)->(dbSkip() )
          End
   Endif
   (cAlias)->(DbCloseArea())
   
   // tratamento em tela dos dados

   oDlg := MSDialog():New(aSize[7],0, nHeight,nWidth,"Movimentacoes ",,,.F.,,,,,,.T.,,,.T. )
   oDlg:bInit := {||EnchoiceBar(oDlg,{||oDlg:End()},{|| oDlg:End()},,aButtons)}

   oBrowse := TCBrowse():New( aSize[7]+35,5,nWidth, nHeight,,;
    {'Produto', 'Descrição', 'Local' , 'Saldo','Empenho','Disponivel','Media','Demanda','Estoque'},;
	{   010,       050,        005,      050,    050,        050,    050,      050,   020 },;
    oDlg,,,,,{||},,,,,,,.F.,,.T.,,.T.,,.T.,.T. )
    oBrowse:SetArray(aBrowse)
    oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;   							// Produto
                      aBrowse[oBrowse:nAt,02],;		        					// Descricao
                      aBrowse[oBrowse:nAt,03],;     							// Local
					  Transform(aBrowse[oBrowse:nAt,04],"@E 999999,99999"),;	// Saldo
					  Transform(aBrowse[oBrowse:nAt,05],"@E 999999,99999"),;	// Empenho
					  Transform(aBrowse[oBrowse:nAt,06],"@E 999999,99999"),;	// Disponivel
					  Transform(aBrowse[oBrowse:nAt,07],"@E 999999,99999"),;    // Media
					  Transform(aBrowse[oBrowse:nAt,08],"@E 999999,99999"),;    // Demanda
					  Transform(aBrowse[oBrowse:nAt,09],"@E 999999,99999")} }	// Estoque   

    oBrowse:bLDblClick := { || PCP80EMP(aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,06],aBrowse[oBrowse:nAt,07]) }

    oDlg:Activate(,,,.T.)
    RestArea(aArea)
Return

Static Function PCP80EMP(cProduto,nDisponivel,nMedia)
    Local aSubArea  := GetArea()
    Local oDlgSub  	as Object 
    Local oBrw  	as Object 
    Local aCols 	as Array 
    Local cAlias  	:= "A_"+GetNextAlias()
    Local cTmp  	:= "B_"+GetNextAlias()
    Local aSize   	:= MsAdvSize()
    local aButtons  := {}
    Local AB
 
    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    aAdd(aButtons,{"SAIR",{|| oDlg:End()},"Sair","Sair"})

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
    BeginSQL Alias cAlias
		SELECT      *
    	FROM %Table:PZ3% PZ3
		WHERE PZ3.%NotDel%
		and PZ3_FILIAL =  %xFilial:PZ3%
        AND PZ3_PROD = %EXP:cProduto%
	    ORDER BY PZ3_PROD
    EndSQL

    if (cAlias)->( Eof())
        MsgAlert("Nao tem nada empenhado nesse produto","Atencao")
        (cAlias)->(DbCloseArea())
        FwRestArea(aSubArea)
	    RETURN
    Endif

    aCols :={}
    nSaldo := nDisponivel
    If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aCols ,   {STRZERO(VAL((cAlias)->PZ3_DIA),2),;
							    (cAlias)->PZ3_QTD,;
                                0,;
                                0,;
                                0,;
                                0})
                (cAlias)->(dbSkip() )
          End
   Endif
   // Pedidos de Compra
    BeginSQL Alias cTmp
		SELECT C7_PRODUTO,DAY(C7_DATPRF) DIA, C7_QUANT
    	FROM %Table:SC7% SC7
		WHERE SC7.%NotDel%
		and C7_FILIAL =  %xFilial:SC7%
        AND C7_PRODUTO = %EXP:cProduto%
        AND YEAR(C7_DATPRF) =  %Exp:Year(dDataBase)%
        AND MONTH(C7_DATPRF) =  %Exp:Month(dDataBase)% 
    EndSQL

    if (cTmp)->( Eof())
        MsgAlert("Nao tem nada empenhado nesse produto","Atencao")
        (cTmp)->(DbCloseArea())
        FwRestArea(aSubArea)
	    RETURN
    Endif
    nSaldo := nDisponivel
    If (cTmp)->(!EOF())
          While (cTmp)->(!EOF())
           
           nPos :=  aScan(aCols,{|x| Alltrim(x[1]) == StrZero((cTmp)->DIA,2) } )
           
           if nPos == 0
              aAdd(aCols ,{StrZero((cTmp)->DIA,2),0,0,(cTmp)->C7_QUANT,0,0})
           else
		      aCols[nPos][4] := aCols[nPos][4] + (cTmp)->C7_QUANT
            Endif
            
            (cTmp)->(dbSkip() )
          End
   Endif

   (cTmp)->(DbCloseArea())

   if len(aCols) > 0
      nSaldo := nDisponivel
      aSort(aCols, , , {|x, y| x[1] < y[1]})
      FOR AB:=1 TO LEN(aCols)
          if AB == 1
             aCols[AB][3] := nDisponivel
          else
             aCols[AB][3] := nSaldo
          ENDIF
          nSaldo := nSaldo - aCols[AB][2] + aCols[AB][4]
          aCols[AB][5] := nSaldo
          aCols[AB][6] := nSaldo / nMedia
      Next
   Endif

   oDlgSub := MSDialog():New(aSize[7],0, nHeight,nWidth,"Empenhos ",,,.F.,,,,,,.T.,,,.T. )
   oDlgSub:bInit := {||EnchoiceBar(oDlgSub,{||oDlgSub:End()},{|| oDlgSub:End()},,aButtons)}

   oBrw := TCBrowse():New( aSize[7]+35,5,nWidth, nHeight,,;
            {'Dia', 'Quantidade','Saidas','Entregas','Final','Projecao'},{010, 050 , 050 ,050,050,050},;
            oDlgSub,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

    oBrw:SetArray(aCols)

    oBrw:bLine := {||{ aCols[oBrw:nAt,01],;   							// Dia
					  Transform(aCols[oBrw:nAt,02],"@E 999999,99999"),;    // Quantidade
                      Transform(aCols[oBrw:nAt,03],"@E 999999,99999"),;    // Saidas
                      Transform(aCols[oBrw:nAt,04],"@E 999999,99999"),;    // entregas
                      Transform(aCols[oBrw:nAt,05],"@E 999999,99999") ,;   // Saldo Final
                      Transform(aCols[oBrw:nAt,06],"@E 999999,99999")} }	// Projecao

    oBrw:bLDblClick := { || PCP80DAY(cProduto,aCols[oBrw:nAt,01]) }

    oDlgSub:Activate(,,,.T.)   
    RestArea(aSubArea)
Return

Static Function PCP80DAY(cProduto,cDia)
    Local aSubA2    := GetArea()
    Local oDlgSub  	as Object 
    Local oBrw  	as Object 
    Local aCols 	as Array 
    Local cAlias  	:= GetNextAlias()
    Local aSize   	:= MsAdvSize()
    local aButtons  := {}
 
    oMainWnd:ReadClientCoors()
    nHeight := oMainWnd:nHeight-50
    nWidth  := oMainWnd:nWidth-15

    aAdd(aButtons,{"SAIR",{|| oDlg:End()},"Sair","Sair"})

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 } 
 
    BeginSQL Alias cAlias
		SELECT  DAY(D4_DATA) DIA,SUBSTRING(D4_OP,1,6) LOTE,D4_PRODUTO,D4_QUANT
    	FROM %Table:SD4% SD4
		WHERE SD4.%NotDel%
		and D4_FILIAL =  %xFilial:PZ3%
        AND D4_COD = %EXP:cProduto%
        AND YEAR(D4_DATA) = %Exp:Year(dDataBase)%
        AND MONTH(D4_DATA) = %Exp:Month(dDataBase)%
        AND DAY(D4_DATA) = %Exp:cDia%     
    EndSQL

    if (cAlias)->( Eof())
        MsgAlert("Nao tem nada OPs nesse produto","Atencao")
        (cAlias)->(DbCloseArea())
        FwRestArea(aSubA2)
	    RETURN
    Endif

    aCols :={}
    If (cAlias)->(!EOF())
          While (cAlias)->(!EOF())
		        aAdd(aCols ,   {(cAlias)->DIA,;
							    (cAlias)->LOTE,;
                                (cAlias)->D4_PRODUTO ,;
                                (cAlias)->D4_QUANT})
                (cAlias)->(dbSkip() )
          End
   Endif

   (cAlias)->(DbCloseArea())

   oDlgSub := MSDialog():New(aSize[7],0, nHeight,nWidth,"Ordens de Producao",,,.F.,,,,,,.T.,,,.T. )
   oDlgSub:bInit := {||EnchoiceBar(oDlgSub,{||oDlgSub:End()},{|| oDlgSub:End()},,aButtons)}

   oBrw := TCBrowse():New( aSize[7]+35,5,nWidth, nHeight,,;
            {'Dia', 'Lote','Produto','Quantidade'},{010, 050 , 050 ,050},;
            oDlgSub,,,,,{||},,,,,,,.F.,,.T.,,.T.,,, )

    oBrw:SetArray(aCols)

    oBrw:bLine := {||{ aCols[oBrw:nAt,01],;   							// Dia
 					   aCols[oBrw:nAt,02],;                              // Lote
                       aCols[oBrw:nAt,03],;                              // Produto
                       Transform(aCols[oBrw:nAt,04],"@E 999999,99999") } }	// Saldo Final

    oDlgSub:Activate(,,,.T.)   
    RestArea(aSubA2)
Return 
