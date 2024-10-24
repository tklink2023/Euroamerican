
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
User Function GTCOM002()
    Local cArea := FwGetArea()
    Local cCodigo:= Space(06)
    Local cLoja  := Space(02)
    Local lRet   := .T.
    Local aDadFor:= {}

    IF INCLUI .AND. !ALTERA

       cCodigo := IIF(FWFldGet("A2_TIPO") = 'J', Substr(FWFldGet("A2_CGC"),1,6), IIF(FWFldGet("A2_TIPO") = 'X',GetSX8Num("SA2","A2_COD"),Substr(FWFldGet("A2_CGC"),1,6)))
       cLoja   := IIF(FWFldGet("A2_TIPO") = 'J', Substr(FWFldGet("A2_CGC"),13,2),IIF(FWFldGet("A2_TIPO") = 'X',"99",Substr(FWFldGet("A2_CGC"),10,2) ))

       cCodigo := SearchCodigo(cCodigo)

       FwFldPut("A2_COD"		, cCodigo)
       FwFldPut("A2_LOJA"		, cLoja )

       IF FWFldGet("A2_TIPO") = 'J'
            // Busca informações da Receita Federal
            aDadFor:=U_SearchCnpj(FWFldGet("A2_CGC"))
       ENDIF

       if len(aDadFor) > 0
            IF aDadFor[1] 
                FwFldPut("A2_NOME"		, aDadFor[04] )
                FwFldPut("A2_NREDUZ"	, IIF(Empty(alltrim(aDadFor[05])),aDadFor[04],aDadFor[05]) )
                FwFldPut("A2_END"		, aDadFor[08]+","+aDadFor[09] )
                FwFldPut("A2_NR_END"	, aDadFor[09] )
                FwFldPut("A2_MUN"		, aDadFor[10] )
                FwFldPut("A2_BAIRRO"	, aDadFor[18] )
                FwFldPut("A2_COD_MUN"	, aDadFor[22] )
                FwFldPut("A2_EST"		, aDadFor[11] )
                FwFldPut("A2_CEP"		, strtran( strtran(aDadFor[12],".",""),"-","") )
                FwFldPut("A2_EMAIL"		, aDadFor[13] )
                FwFldPut("A2_DDD"		, strtran(strtran(SubString(aDadFor[14],1,AT(")",aDadFor[14]) ),"(",""),")","")    )
                FwFldPut("A2_TEL"		, Alltrim(strtran(SubString(aDadFor[14],AT(")",aDadFor[14])+1,10 ),"-","")) ) 
                FwFldPut("A2_CNAE"		, aDadFor[07] )
                FwFldPut("A2_ENDCOMP"	, aDadFor[17] )
                FwFldPut("A2_COMPLEM"	, aDadFor[17] )
                FwFldPut("A2_PAIS"		,"105" )

                U_VldCampo("A2_COD_MUN"	, aDadFor[22])
                U_VldCampo("A2_MUN"		, aDadFor[10])
                U_VldCampo("A2_CEP"		, aDadFor[12])                

            Endif 
        ENDIF
    ENDIF    
    FwRestArea(cArea)
Return(lRet)

/*/{Protheus.doc} SearchCnpj
description
@type function
@version 1.0
@author Paulo Lenzi
@since 11/10/2024
@param cCNPJ, character, param_description
@return variant, return_description
/*/
User Function SearchCnpj(cCNPJ)
    Local aArea         := FWGetArea()
    Local aDados        := Array(22)
    Local aHeader       := {}    
    Local oRestClient   := FWRest():New("https://www.receitaws.com.br/v1")
    Local cResultado    := ""
    Local jResultado    := Nil
    Local cError        := ""
    Local cMensagem     := ""
    Default cCNPJ       := ""
 
    //Define a primeira posição como .F. default
    aDados[01] := .F.
 
    //Retira caracteres especiais
    cCNPJ := StrTran(cCNPJ, ".", "")
    cCNPJ := StrTran(cCNPJ, "/", "")
    cCNPJ := StrTran(cCNPJ, "-", "")
 
    //Se veio CNPJ e tem 14 caracteres
    If ! Empty(cCNPJ) .And. Len(cCNPJ) == 14
 
        //Adiciona os headers que serão enviados via WS
        aAdd(aHeader,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
        aAdd(aHeader,'Content-Type: application/json; charset=utf-8')
     
        //Define a url e aciona o método GET
        oRestClient:setPath("/cnpj/" + cCNPJ)
        If oRestClient:Get(aHeader)
 
            //Pega o resultado
            cResultado := DecodeUTF8(oRestClient:cResult, "cp1252")
            jResultado := JsonObject():New()
            cError     := jResultado:FromJson(cResultado)
 
            //Se não houve erros
            If Empty(cError) .And. jResultado:GetJsonObject('status') != "ERROR"
                aDados[01] := .T.
                aDados[02] := jResultado:GetJsonObject('abertura')
                aDados[03] := jResultado:GetJsonObject('situacao')
                aDados[04] := jResultado:GetJsonObject('nome')
                aDados[05] := jResultado:GetJsonObject('fantasia')
                aDados[06] := jResultado:GetJsonObject('porte')
                aDados[07] := jResultado:GetJsonObject('natureza_juridica')
                aDados[08] := jResultado:GetJsonObject('logradouro')
                aDados[09] := jResultado:GetJsonObject('numero')
                aDados[10] := jResultado:GetJsonObject('municipio')
                aDados[11] := jResultado:GetJsonObject('uf')
                aDados[12] := jResultado:GetJsonObject('cep')
                aDados[13] := jResultado:GetJsonObject('email')
                aDados[14] := jResultado:GetJsonObject('telefone')
                aDados[15] := jResultado:GetJsonObject('cnpj')
                aDados[16] := jResultado:GetJsonObject('ultima_atualizacao')
                aDados[17] := jResultado:GetJsonObject('complemento')
                aDados[18] := jResultado:GetJsonObject('bairro')
                aDados[19] := jResultado:GetJsonObject('tipo')
                aDados[20] := jResultado:GetJsonObject('status')
                aDados[21] := jResultado:GetJsonObject('capital')

            EndIf
        EndIf
    EndIf
    if aDados[01]
        cCodMun := U_SeacherCep(StrTran(StrTran(aDados[12], ".", ""),"-",""))
        aDados[22] := cCodMun
    endif
    If aDados[1]

        cMensagem += "Razão Social: "       + aDados[04] + " " + CRLF
        cMensagem += "Nome Fantasia: "      + aDados[05] + " " + CRLF
        cMensagem += "Lougradouro: "        + aDados[08] + " " + CRLF
        cMensagem += "Numero: "             + aDados[09] + " " + CRLF
        cMensagem += "Complemento: "        + aDados[17] + " " + CRLF
        cMensagem += "Bairro: "             + aDados[18] + " " + CRLF
        cMensagem += "Municipio: "          + aDados[10] + " " + CRLF
        cMensagem += "Estado: "             + aDados[11] + " " + CRLF
        cMensagem += "Cep: "                + aDados[12] + " " + CRLF
        cMensagem += "Cod Municipio "       + aDados[22] + " " + CRLF
        cMensagem += "E-Mail: "             + aDados[13] + " " + CRLF
        cMensagem += "Telefone: "           + aDados[14] + " " + CRLF
        cMensagem += "Tipo: "               + aDados[19] + " " + CRLF
        cMensagem += "Data de Abertura: "   + aDados[02] + " " + CRLF
        cMensagem += "Situação: "           + aDados[03] + " " + CRLF
        cMensagem += "Porte: "              + aDados[06] + " " + CRLF
        cMensagem += "Natureza Juridica: "  + aDados[07] + " " + CRLF
        cMensagem += "Última Atualização: " + aDados[16] + " " + CRLF
 
        FWAlertInfo(cMensagem, "Dados do CNPJ")
    else
        FWAlertInfo("CNPJ não encontrado na Receita","Dados do CNPJ")    
    EndIf
    FWRestArea(aArea)
Return aDados

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

     dbSelectArea("SA2")
     ("SA2")->( dbSetOrder(1) )
     IF ("SA2")->( dbSeek( xFilial("SA2")+cCodigo,.T.))
          cCodigo := GetSX8Num("SA2","A2_COD")
     ENDIF

     FWRestArea(aArea)
Return(cCodigo)

/*/{Protheus.doc} SeacherCep
description Rotina que busca o codigo do Municipio
@type function
@version 1.0
@author Paulo Lenzi
@since 14/10/2024
@param cCep, character, param_description
@return variant, return_description
/*/
User Function SeacherCep(cCep)
    Local aArea         := GetArea()
    Local aHeader       := {}
    //Local cCep          := '03062010'
    Local cCodMun       := ''
    Local oRestClient   := FWRest():New("https://viacep.com.br/ws")
    Local oJsObj
     
    aadd(aHeader,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    aAdd(aHeader,'Content-Type: application/json; charset=utf-8')
           
    ////////////////////////////////////////////////////////////////
    //[GET] Consulta Dados na Api
    oRestClient:setPath("/"+cCep+"/json/")
    If oRestClient:Get(aHeader)
        //Deserealiza o Json
        FWJsonDeserialize(oRestClient:CRESULT,@oJsObj)
     
        //Recebe Dados do Json
        cCodMun := SubStr(oJsObj:IBGE,3,5)
     
        /*oJsObj:BAIRRO
        oJsObj:CEP
        oJsObj:COMPLEMENTO
        oJsObj:GIA
        oJsObj:IBGE
        oJsObj:LOCALIDADE
        oJsObj:LOGRADOURO
        oJsObj:UF
        oJsObj:UNIDADE*/
     
        FreeObj(oJsObj)
    Else
        ConOut("Erro Api ViaCep: "+oRestClient:GetLastError())
    Endif
     
    RestArea(aArea)
Return(cCodMun)


User Function VldCampo(cCampo,cConteud)
    Local cArea := FwGetArea()
    Local cVldSis   := ""
    Local cVldUsr   := ""
 
    cVldSis := Alltrim(GetSX3Cache(cCampo, "X3_VALID"))
    cVldUsr := Alltrim(GetSX3Cache(cCampo, "X3_VLDUSER"))

    if !Empty(cVldSis) 
        FWFldPut(cCampo, cConteud)
        If ExistTrigger(cCampo)
                    RunTrigger( ;
                        1,;           //nTipo (1=Enchoice; 2=GetDados; 3=F3)
                        Nil,;         //Linha atual da Grid quando for tipo 2
                        Nil,;         //Não utilizado
                        ,;            //Objeto quando for tipo 1
                        cCampo;       //Campo que dispara o gatilho
                    )
        EndIf       
    endif

    if !Empty(cVldUsr) 
        FWFldPut(cCampo, cConteud)
        If ExistTrigger(cCampo)
                    RunTrigger( ;
                        1,;           //nTipo (1=Enchoice; 2=GetDados; 3=F3)
                        Nil,;         //Linha atual da Grid quando for tipo 2
                        Nil,;         //Não utilizado
                        ,;            //Objeto quando for tipo 1
                        cCampo;       //Campo que dispara o gatilho
                    )
        EndIf       
    endif

    FwRestArea(cArea)
Return
