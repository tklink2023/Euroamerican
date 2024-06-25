//Bibliotecas
#Include "TOTVS.ch"
 
/*/{Protheus.doc} User Function zBusCNPJ
(long_description)
@type  Function
@author Atilio
@since 18/12/2022
@version version
@param cCNPJ, Caractere, Número do CNPJ a ser consultado
@return aDados, Array, Retorna um array com dados do cnpj consultado (veja as posições na observação abaixo)
@example
    aDados := u_zBusCNPJ("00.000.000/0000-00")
    If aDados[01]
        // Deu certo a consulta
    EndIf
@obs As posições do aDados são:
    [01] Se deu certo a consulta (.T.) ou (.F.)
    [02] Data de Abertura
    [03] Situação
    [04] Razão Social
    [05] Nome Fantasia
    [06] Porte
    [07] Natureza Juridica
    [08] Endereço
    [09] Número
    [10] Cidade
    [11] Estado
    [12] CEP
    [13] eMail
    [14] Telefone
    [15] CNPJ
    [16] Última Atualização
 
 
    A consulta é feita no site: https://www.receitaws.com.br/v1/cnpj/00000000000000
/*/
 
User Function zBusCNPJ(cCNPJ)
    Local aArea         := FWGetArea()
    Local aDados        := Array(16)
    Local aHeader       := {}    
    Local oRestClient   := FWRest():New("https://www.receitaws.com.br/v1")
    Local cResultado    := ""
    Local jResultado    := Nil
    Local cError        := ""
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
            EndIf
        EndIf
    EndIf
 
    FWRestArea(aArea)
Return aDados

User Function zTstCNPJ()
    Local aDados    := {}
    Local cMensagem := ""
 
    aDados := u_zBusCNPJ("28.671.016/0001-45")
 
    If aDados[1]
        cMensagem += "Data de Abertura: "   + aDados[02] + " " + CRLF
        cMensagem += "Situação: "           + aDados[03] + " " + CRLF
        cMensagem += "Nome Fantasia: "      + aDados[05] + " " + CRLF
        cMensagem += "Porte: "              + aDados[06] + " " + CRLF
        cMensagem += "Natureza Juridica: "  + aDados[07] + " " + CRLF
        cMensagem += "Cidade: "             + aDados[10] + " " + CRLF
        cMensagem += "Estado: "             + aDados[11] + " " + CRLF
        cMensagem += "Última Atualização: " + aDados[16] + " " + CRLF
 
        FWAlertInfo(cMensagem, "Dados do CNPJ")
    EndIf
Return
