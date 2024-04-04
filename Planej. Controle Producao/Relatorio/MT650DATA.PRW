#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define TAB    Chr(9)

User Function MT650DATA(cNumOp,cItem,cSeq,cProduto,cLocal)
    Local cArea := FwGetArea()
    Local cAlias   := 	GetNextAlias()  
    Local cPesq    := cNumOp+cItem+cSeq
    Local cArquivo := "ETQ_DATADO.TXT" 
	Local cPasta   := "C:\DADOS\" 
    Local lGrava   := .F.
    Local cEof     := 	CHAR(13)+CHAR(10) 
    Local cMsg     := " "
	
	If !lIsDir(cPasta)
		MakeDir(cPasta)
	EndIf         

    If File(cPasta+cArquivo)
       FERASE(cPasta+cArquivo)
    Endif

    oFWriter := FWFileWriter():New(cPasta + cArquivo, .T.)
    If ! oFWriter:Create()
        MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oFWriter:Error():Message, "Atenção")
    Else  
        BeginSql Alias cAlias 
            Select  C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_LOCAL,C2_PRODUTO,C2_DATPRF, C2_XDTVALI,B1_DESC,B1_CODBAR,B1_U_UMETQ
            FROM %TABLE:SC2% SC2
            INNER JOIN %TABLE:SB1% SB1  ON B1_COD = C2_PRODUTO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' '
            WHERE SC2.%NotDel%
            AND   C2_FILIAL   = %xFilial:SC2%
            AND   C2_NUM+C2_ITEM+C2_SEQUEN = %EXP:cPesq% 
            AND   C2_PRODUTO  = %EXP:cProduto%
            AND   C2_LOCAL    = %EXP:cLocal%
         EndSql 
            
         if (cAlias)->( Eof())
             MsgAlert("Nao tem produto para gerar etiqueta","ATENCAO")
             Return
         endif

         DbSelectArea(cAlias)
         DbGoTop()
         While (cAlias)->( !Eof() )
            IF (cAlias)->C2_DATPRF = ' '
               MsgAlert("Esse Produto "+Alltrim((cAlias)->C2_PRODUTO) + " nao tem a Data a Data de Fabricacao","ATENCAO")
		    elseif (cAlias)->C2_XDTVALI = ' '	 
				 MsgAlert("Esse Produto "+Alltrim((cAlias)->C2_PRODUTO) + " nao tem a Data a Data de Validacao","ATENCAO")  
            ELSE

                cFabrica := Substr((cAlias)->C2_DATPRF,7,2)+"/"+Substr((cAlias)->C2_DATPRF,5,2)+"/"+Substr((cAlias)->C2_DATPRF,1,4)
                cValida := Substr((cAlias)->C2_XDTVALI,7,2)+"/"+Substr((cAlias)->C2_XDTVALI,5,2)+"/"+Substr((cAlias)->C2_XDTVALI,1,4)
            
                cMsg +=	Alltrim((cAlias)->B1_DESC)           	+	TAB 
                cMsg +=	Alltrim((cAlias)->C2_PRODUTO) 			+   TAB	
                cMsg += Alltrim((cAlias)->C2_NUM)   			+	TAB	
                cMsg += cFabrica      							+	TAB		
                cMsg += cValida	 								+ 	TAB		
                cMsg += Alltrim((cAlias)->B1_CODBAR) 			+ 	TAB		
                cMsg += (cAlias)->B1_U_UMETQ 					+	TAB
                cMsg +=	alltrim((cAlias)->C2_PRODUTO) 			+	cEof	
                oFWriter:Write(cMsg)
                lGrava := .T.

		    Endif	
		   (cAlias)->(dbskip())
	     End
	     (cAlias)->( DbCloseArea() )
    Endif
    oFWriter:Close()

    if lGrava
        FWAlertInfo("Pasta : "+ cPasta + " Arquivo: " + cArquivo, "Arquivo Gerado... " )
    Endif

    FwRestArea(cArea)
Return
