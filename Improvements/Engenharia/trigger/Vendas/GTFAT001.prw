
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} GTCOM002
description
@type function
@version 1.0
@author Paulo Lenzi
@since 11/10/2024
@return variant, return_description
/*/
User Function GTFAT001()
    Local cArea := FwGetArea()
    Local cCodigo:= Space(06)
    Local cLoja  := Space(02)
    Local lRet   := .T.
    Local aDadFor:= {}
    Local nCnpj := FWFldGet("A1_CGC")
    Local cTipo := ""
    Local cCodigoCnae := ""

    nCnpj := StrTran(nCnpj, ".", "")
    nCnpj := StrTran(nCnpj, "/", "")
    nCnpj := StrTran(nCnpj, "-", "")

    cTipo :=  IIF((LEN(nCnpj)==14),"J", IIF((LEN(nCnpj)==11),"F","X"))

    IF INCLUI .AND. !ALTERA
       cCodigo := IIF(cTipo = 'J', Substr(FWFldGet("A1_CGC"),1,6),IIF(cTipo = 'X',GetSX8Num("SA1","A1_COD"),Substr(FWFldGet("A1_CGC"),1,6)))  
       cLoja   := IIF(cTipo = 'J', Substr(FWFldGet("A1_CGC"),13,2),IIF(cTipo = 'X',"99",Substr(FWFldGet("A1_CGC"),10,2) ))
       cCodigo := SearchCodigo(cCodigo)

       FwFldPut("A1_COD"		, cCodigo)
       FwFldPut("A1_LOJA"		, cLoja )
       FwFldPut("A1_PESSOA"       , cTipo  )

       IF cTipo = 'J'
            // Busca informações da Receita Federal
            aDadFor:=U_SearchCnpj(FWFldGet("A1_CGC"))
       ENDIF

       if len(aDadFor) > 0
            IF aDadFor[1] 
                cCodigoCnae := SearchCC3(STRTRAN(STRTRAN(Substring(aDadFor[07],1,6),"-",""),".","")) 
                cCodigoCnae := STRTRAN(STRTRAN(cCodigoCnae,"-",""),".","")

                FwFldPut("A1_NOME"		, aDadFor[04] )
                FwFldPut("A1_NREDUZ"	, IIF(Empty(alltrim(aDadFor[05])),aDadFor[04],aDadFor[05]) )
                FwFldPut("A1_END"		, aDadFor[08]+","+aDadFor[09] )
                FwFldPut("A1_NR_END"	, aDadFor[09] )
                FwFldPut("A1_MUN"		, aDadFor[10] )
                FwFldPut("A1_BAIRRO"	, aDadFor[18] )
                FwFldPut("A1_COD_MUN"	, aDadFor[22] )
                FwFldPut("A1_EST"		, aDadFor[11] )
                FwFldPut("A1_CEP"		, strtran( strtran(aDadFor[12],".",""),"-","") )
                FwFldPut("A1_EMAIL"	, aDadFor[13] )
                FwFldPut("A1_DDD"		, strtran(strtran(SubString(aDadFor[14],1,AT(")",aDadFor[14]) ),"(",""),")","")    )
                FwFldPut("A1_TEL"		, Alltrim(strtran(SubString(aDadFor[14],AT(")",aDadFor[14])+1,10 ),"-","")) ) 
                FwFldPut("A1_CNAE"		, cCodigoCnae )
                FwFldPut("A1_ENDCOMP"	, aDadFor[17] )
                FwFldPut("A1_COMPLEM"	, aDadFor[17] )
                FwFldPut("A1_PAIS"		,"105" )

               FwFldPut("A1_ENDREC" , aDadFor[08]+","+aDadFor[09] )
               FwFldPut("A1_ENDCOB" , aDadFor[08]+","+aDadFor[09] )
               FwFldPut("A1_BAIRROC", aDadFor[08]+","+aDadFor[09] )
               FwFldPut("A1_CEPC", strtran( strtran(aDadFor[12],".",""),"-","") )
               FwFldPut("A1_MUNC" , aDadFor[10] )

               FwFldPut("A1_ENDENT" , aDadFor[08]+","+aDadFor[09] )
               FwFldPut("A1_BAIRROC"	, aDadFor[18] )
               FwFldPut("A1_CEPEC", strtran( strtran(aDadFor[12],".",""),"-","") )
               FwFldPut("A1_MUNE" , aDadFor[10] )
               FwFldPut("A1_ESTE", aDadFor[11] )
               FwFldPut("A1_CODMUNE", aDadFor[22] )

                U_VldCampo("A1_COD_MUN"	     , aDadFor[22])
                U_VldCampo("A1_MUN"		, aDadFor[10])
                U_VldCampo("A1_CEP"		, aDadFor[12]) 
                U_VldCampo("A1_CNAE"		, STRTRAN(STRTRAN(STRTRAN(aDadFor[07],"-",""),".",""),"/","") )             

            Endif 
        ENDIF
    ENDIF    
    FwRestArea(cArea)
Return(lRet)


/*/{Protheus.doc} SearchCodigo
description Rotina que valida se já existe o codigo gerado
@type function
@version 1.0
@author Paulo Lenzi
@since 14/10/2024
@param cCodigo, character, param_description
@return variant, return_description
/*/
Static Function SearchCodigo(cCodigo)
     Local aArea         := FWGetArea()

     dbSelectArea("SA1")
     ("SA1")->( dbSetOrder(1) )
     IF ("SA1")->( dbSeek( xFilial("SA1")+cCodigo,.T.))
          cCodigo := GetSX8Num("SA1","A1_COD")
     ENDIF

     FWRestArea(aArea)
Return(cCodigo)

/*/{Protheus.doc} SearchCC3
description
@type function
@version 1.0
@author Paulo Lenzi
@since 16/10/2024
@param cCnae, character, param_description
@return variant, return_description
/*/
Static Function SearchCC3(cCnae)
   Local aArea  := FWGetArea()
   Local cAlias := GetNextAlias()
   Local cQuery := ''
   Local lRetorno:= ' '

   cQuery :="SELECT * "
   cQuery +="FROM "+ RetSqlName("CC3")+" "
   cQuery +="WHERE D_E_L_E_T_ = ' ' "
   cQuery +="AND CC3_FILIAL = '"+xFilial("CC3")+"' "
   cQuery +="AND CC3_MSBLQL <> '1' "
   cQuery +="AND CC3_COD LIKE '"+Alltrim(cCnae)+"%' "

  cQuery := ChangeQuery(cQuery)

   If !Empty(Select(cAlias))
        DbSelectArea(cAlias)
        (cAlias)->(dbCloseArea())
   Endif
            
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
   DbSelectArea(cAlias)
   (cAlias)->( dbGotop() )
   While (cAlias)->( !Eof() )
    lRetorno := (cAlias)->CC3_COD
    (cAlias)->(dbSkip() )   
   EndDo
   (cAlias)->(dbCloseArea())   

   FWRestArea(aArea)
Return(lRetorno)
