#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include 'topconn.ch'
#include 'tbiconn.ch'

#Define TAB    Chr(9)

/*/{Protheus.doc} DATADOR
description
@type function
@version 1.0
@author Paulo Lenzi
@since 07/02/2024
@return variant, return_description
/*/
User Function DATADOR()
    Local cArea     := FwGetArea()
    Local aRet  	:= 	{}
	Local aPergs	:= 	{}
    Local cOpIni    := Space(TamSX3("C2_NUM")[01])
	Local cLocal    := Space(TamSX3("C2_LOCAL")[01])
	Local cProduto  := Space(TamSX3("C2_PRODUTO")[01])
	
	
	Local cTitulo   := 	"Etiquetas para Datador"   
	Local nOpcao			:=	0
	Local aSays				:=	{}
	Local aButtons			:= 	{}    

    Private cMvPar01
	Private cMvPar02
	Private cMvPar03
	Private cMvPar04
	Private cLocDir
	Private cArquivo := "ETQ_DATADO.TXT" //	+ 	dtos(date()) + strtran(time(),':','-') 	+	".CSV" 
	Private cPasta   := "C:\DADOS\" //GetTempPath()
	
	If !lIsDir(cPasta)
		MakeDir(cPasta)
	EndIf         

	aAdd( aPergs ,{1,"Numero do Lote da OP"		, cOpIni   		, PesqPict("SC2", "C2_NUM"),'.T.',"SC2"   	,'.T.'	,50, .T.})
	aAdd( aPergs ,{1,"Produto"					, cProduto     	, PesqPict("SC2", "C2_PRODUTO"),'.T.',"SB1"   	,'.T.'	,50, .T.})
	aAdd( aPergs ,{1,"Armazem"					, cLocal     	, PesqPict("SC2", "C2_LOCAL"),'.T.',""   	,'.T.'	,10, .T.})

	If ParamBox(aPergs ,"Parametros do Relatorio",aRet)     
		cMvPar01 := aRet[1]
		cMvPar02 := aRet[2]
		cMvPar03 := aRet[3]
	Else
		MsgAlert("Encerrado")
		Return
	EndIf

	AAdd(aSays,"Gera Arquivo")
	AAdd(aSays,"Selecione o local para gravação [Abrir] ")
	AAdd(aSays,"Apos abrir o local será gravado o arquivo para ser utilizado   ")
	AAdd(aSays,"no Datador :  ")

	AAdd(aButtons,{ 14,.T.,{|| Arqloc()    					, FechaBatch()} } )
	AAdd(aButtons,{ 2 ,.T.,{|| nOpcao := 2 					, FechaBatch() } } )
	AAdd(aButtons,{ 1 ,.T.,{|| nOpcao := 3 					, FechaBatch() } } )	

     While .t.
	
		FormBatch(cTitulo,aSays,aButtons)
	
		If nOpcao == 3 .And. !Empty(cLocDir)
			Exit
		EndIf
		
		If nOpcao == 2
			Return
		Endif	
		
		If !Empty(cLocDir)
			aSays[02] := cArquivo
			aSays[03] := "Local : "+Upper(cLocDir)
			aSays[04] := "Inicio > "+Time()
		EndIf

		If Empty(cLocDir)
			MsgAlert("Pasta não Localizada!")
		EndIf
		
		If !Empty(cLocDir)
			If File(cLocDir+cArquivo) //arquivo ja existe
			    FERASE(cLocDir+cArquivo)
				cArqLog := 	cLocDir+cArquivo
			else
			   cArqLog := 	cLocDir+cArquivo
			EndIf
		EndIf			
	 End	     

     Processa( {|| RunProc() } , "Processamento, Aguarde....","Gerando Planilha",.T.)

    FwRestArea(cArea)
Return

/*/{Protheus.doc} Arqloc
description
@type function
@version 1.0
@author Paulo Lenzi
@since 07/02/2024
@return variant, return_description
/*/
Static Function Arqloc()
	cLocDir := cGetFile( , OemToAnsi("Selecione Diretorio de Gravação"),,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)
Return

/*/{Protheus.doc} FlushFile
description
@type function
@version 1.0
@author Paulo Lenzi
@since 07/02/2024
@param _nFile, variant, param_description
@param cMsg, character, param_description
@param nMaxSize, numeric, param_description
@return variant, return_description
/*/
Static Function FlushFile(_nFile, cMsg, nMaxSize)
Default nMaxSize := 50 * 1024 //50KB
If Len(cMsg) > nMaxSize
	FWrite(_nFile, cMsg)
	cMsg := ""
Endif
Return Nil   

Static Function RunProc()  
	Local cAlias    	:= 	GetNextAlias()  
	Local cEof   		:= 	CHAR(13)+CHAR(10) 
	Local cMsg 			:= 	""
	Local oFWriter 
     
    oFWriter := FWFileWriter():New(cPasta + cArquivo, .T.)

   If ! oFWriter:Create()
        MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oFWriter:Error():Message, "Atenção")
   Else
	   BeginSql Alias cAlias 
		Select  C2_FILIAL,C2_NUM,C2_LOCAL,C2_PRODUTO,C2_EMISSAO,C2_DATPRF, C2_XDTVALI,B1_DESC,B1_CODBAR,B1_U_UMETQ,ISNULL(B8_DFABRIC,' ') B8_DFABRIC, ISNULL(B8_DTVALID,'') B8_DTVALID
		FROM %TABLE:SC2% SC2
		INNER JOIN %TABLE:SB1% SB1  ON B1_COD = C2_PRODUTO AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' '
        LEFT JOIN %TABLE:SB8% SB8 ON B8_FILIAL = C2_FILIAL AND B8_PRODUTO = C2_PRODUTO AND B8_LOCAL = C2_LOCAL AND B8_LOTECTL = C2_NUM AND SC2.D_E_L_E_T_ = ' '
		WHERE SC2.%NotDel%
		AND   C2_FILIAL   = %xFilial:SC2%
		AND   C2_NUM = %EXP:cMvPar01% 
		AND   C2_PRODUTO  = %EXP:cMvPar02%
		AND   C2_LOCAL    = %EXP:cMvPar03%
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
          
			cMsg +=	Alltrim(FWNoAccent((cAlias)->B1_DESC)) 	+	TAB //";"			FWNoAccent(cFrase)
			cMsg +=	Alltrim((cAlias)->C2_PRODUTO) 			+   TAB	
			cMsg += Alltrim((cAlias)->C2_NUM)   			+	TAB	
			cMsg += cFabrica      							+	TAB		
			cMsg += cValida	 								+ 	TAB		
			cMsg += Alltrim((cAlias)->B1_CODBAR) 			+ 	TAB		
			cMsg += (cAlias)->B1_U_UMETQ 					+	TAB
			cMsg +=	alltrim((cAlias)->C2_PRODUTO) 			+	cEof	
			oFWriter:Write(cMsg)
		Endif	
		(cAlias)->(dbskip())
	  End
	  (cAlias)->( DbCloseArea() )
      oFWriter:Close()
	  MsgAlert("Arquivo Gerado na pasta ...")
	/*  
	  lSucess := CpyS2T(cPasta+cArquivo,cLocDir,.T.)

      If MsgYesNo("Arquivo gerado com sucesso (" + cPasta + cArquivo + ")!" + CRLF + "Deseja abrir?", "Atenção")
            ShellExecute("OPEN", cArquivo, "", cPasta, 1 )
      EndIf
    */
  endif	

Return NIL   
