
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
                FwFldPut("A1_NOME"		, aDadFor[04] )
                FwFldPut("A1_NREDUZ"	, IIF(Empty(alltrim(aDadFor[05])),aDadFor[04],aDadFor[05]) )
                FwFldPut("A1_END"		, aDadFor[08]+","+aDadFor[09] )
                FwFldPut("A1_NR_END"	, aDadFor[09] )
                FwFldPut("A1_MUN"		, aDadFor[10] )
                FwFldPut("A1_BAIRRO"	, aDadFor[18] )
                FwFldPut("A1_COD_MUN"	, aDadFor[22] )
                FwFldPut("A1_EST"		, aDadFor[11] )
                FwFldPut("A1_CEP"		, strtran( strtran(aDadFor[12],".",""),"-","") )
                FwFldPut("A1_EMAIL"		, aDadFor[13] )
                FwFldPut("A1_DDD"		, strtran(strtran(SubString(aDadFor[14],1,AT(")",aDadFor[14]) ),"(",""),")","")    )
                FwFldPut("A1_TEL"		, Alltrim(strtran(SubString(aDadFor[14],AT(")",aDadFor[14])+1,10 ),"-","")) ) 
                FwFldPut("A1_CNAE"		, aDadFor[07] )
                FwFldPut("A1_ENDCOMP"	, aDadFor[17] )
                FwFldPut("A1_COMPLEM"	, aDadFor[17] )
                FwFldPut("A1_PAIS"		,"105" )

                U_VldCampo("A1_COD_MUN"	, aDadFor[22])
                U_VldCampo("A1_MUN"		, aDadFor[10])
                U_VldCampo("A1_CEP"		, aDadFor[12])                

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

