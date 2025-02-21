//Bibliotecas
#include "TOTVS.ch"
#include "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

/*/{Protheus.doc} A010TOK
description
@type function
@version 1.0
@author Paulo Lenzi
@since 20/02/2025
@return variant, return_description
/*/
User Function A010TOK()
    Local lRet := .T.// Validações do usuário para exclusão do produto
    Private cCampos := ""
    Private cUsr := UsrFullName( )

    If  M->B1_TIPO  == "PA" .Or. ( M->B1_TIPO == "EM" .And. '.DE' $ M->B1_COD ) // Se o produto for "PA", ou for "ME" na DECOR, efetuo a validação abaixo
        lRet:=VecpoAnt()
    ENDIF    
    If  M->B1_TIPO  == "PA" .Or.  M->B1_TIPO == "EM" // Alteracoes Paulo Lenzi 19/02/2025
        lRet:= VecpoPCP()
    ENDIF   
    IF lRet
        if Altera
          lRet:=VeStru()
        Endif
    Endif
    IF !Empty(cCampos)
        MSGSTOP("Campos obrigatorios nao preenchidos: " + cCampos)
        if ExistBlock("XRegistroLog")
                   aDados:= {"Alterando Cad. Produto",FunName(),UsrFullName( ),cCampos,"A010TOK","PCP"}
                   ExecBlock("XRegistroLog",.F.,.F.,aDados)   
        Endif           
    Endif  
            
Return(lRet)

/*/{Protheus.doc} VecpoAnt
description
@type function
@version 1.0
@author Paulo Lenzi
@since 20/02/2025
@return variant, return_description
/*/
Static Function VecpoAnt()
   
    Local cCampoFix := GETMV("ES_VLDCPO")
    Local aCampos   := {}
    Local Ny        := 0
    Local nPos      := 0
    Local lRet      := .T.
     
   aCampos := TableFields("SB1", 0, , {|cField| "_X" $ cField})

   IF LEN(aCampos) > 0
        FOR Ny := 1 TO LEN(aCampos)
          IF aCampos[Ny] $ cCampoFix 
             nPos := FieldPos(aCampos[Ny])
             IF nPos > 0
                IF Empty(FieldGet(nPos))
                   cCampos += ", " + Alltrim(FieldName(nPos))
                ENDIF              
             ENDIF
          ENDIF

        NEXT    
    Endif    

Return(lRet)

/*/{Protheus.doc} VecpoPCP
description
@type function
@version 1.0
@author Paulo Lenzi
@since 20/02/2025
@return variant, return_description
/*/
Static Function VecpoPCP()
   
    Local cCampoPA  := GETMV("ES_CPOPA")
    Local cCampoEM  := GETMV("ES_CPOEM")
    Local aCampos   := {}
    Local Ny        := 0
    Local nPos      := 0
    Local lRet      := .T.
    Local cTipo     := M->B1_TIPO
    Local cCodFil   := FWCodFil()

    IF cCodFil <> '0803'
        Return(lRet)
    endif
     
    aCampos := TableFields("SB1", 0, , {|cField| "_X" $ cField})

    IF cTipo =  "PA"
        IF LEN(aCampos) > 0
                FOR Ny := 1 TO LEN(aCampos)
                    IF aCampos[Ny] $ cCampoPA 
                        nPos := FieldPos(aCampos[Ny])
                        IF nPos > 0
                            IF Empty(FieldGet(nPos))
                                cCampos += ", " + FieldName(nPos)
                                lRet := .F.
                            ENDIF              
                        ENDIF
                    ENDIF
                NEXT    
        Endif 

        IF M->B1_LE == 0
            cCampos += ", LOTE ECONOMICO"
            lRet := .F.
        ENDIF    

    ENDIF

   IF cTipo =  "EM"
        IF LEN(aCampos) > 0
                FOR Ny := 1 TO LEN(aCampos)
                    IF aCampos[Ny] $ cCampoEM 
                        nPos := FieldPos(aCampos[Ny])
                        IF nPos > 0
                            IF Empty(FieldGet(nPos))
                                cCampos += ", " + FieldName(nPos)
                                lRet := .F.
                            ENDIF              
                        ENDIF
                    ENDIF
                NEXT    
        Endif    
    ENDIF

Return(lRet)

/*/{Protheus.doc} VeStru
description
@type function
@version 1.0
@author Paulo Lenzi
@since 20/02/2025
@return variant, return_description
/*/
Static Function VeStru()
    Local cAlias := GetNextAlias()
    Local cQuery := "" 
    Local lRet   := .T.
    Local cMensagem := ""
    Local cEof := Chr(13) + Chr(10)


	cQuery := " SELECT G1_FILIAL, G1_COD, G1_NIV, G1_QUANT, G1_REVINI, G1_REVFIM, " +cEof
	cQuery += " SUBSTRING(G1_INI,7,2) + '/' + 	SUBSTRING(G1_INI,5,2) + '/' + SUBSTRING(G1_INI,1,4) Data_inicial_Validade , " +cEof
	cQuery += " SUBSTRING(G1_FIM,7,2) + '/' + 	SUBSTRING(G1_FIM,5,2) + '/' + SUBSTRING(G1_FIM,1,4) Data_final_Validade  " +cEof
	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "  +cEof
	cQuery += " INNER JOIN " + RetSqlName("SG1") + " SG1 " +cEof
	cQuery += " 	   ON G1_COMP   = B1_COD AND " +cEof
	cQuery += " 		SG1.D_E_L_E_T_ = ' ' " +cEof
	cQuery += " WHERE B1_COD = '" +M->B1_COD+ "' AND B1_MSBLQL <> '1' AND SB1.D_E_L_E_T_ = ' ' " +cEof
	cQuery += " ORDER BY B1_COD, G1_COD, G1_FILIAL, G1_NIV " +cEof 
    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While .Not. (cAlias)->(Eof())
        lRet := .F.
        cMensagem := "Não é possivel bloquea o produto, pois o mesmo possui estrutura de produto ativa!" +cEof
        cMensagem += "Produto: " + M->B1_COD +cEof
        cMensagem += "Filial: " + (cAlias)->G1_FILIAL +cEof
        cMensagem += "Nivel: " + (cAlias)->G1_NIV +cEof
        (cAlias)->(DbSkip())
    Enddo     

    (cAlias)->(DbCloseArea())

    if cMensagem <> ""
        MSGSTOP(cMensagem)
    endif    

Return(lRet)

//---------------------------------------------------------
//		FIM DO PONTO DE ENTRADA
//
