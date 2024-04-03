#include "rwmake.ch"

/*/{Protheus.doc} A020EOK - Validação, Inclusão ou Alteração do Fornecedor
description Function FCanAvalSA2 - Função de Validação da digitação, na inclusão, alteração ou exclusão do Fornecedor.
EM QUE PONTO: Na validação para cada uma das filiais, após a confirmação da exclusão, antes de excluir o fornecedor, deve ser utilizado para validações adicionais para a EXCLUSÃO do fornecedor, podendo considerar a filial (variável cFilAnt) para verificar algum arquivo/campo criado pelo usuário, para validar se o movimento será efetuado ou não.
Eventos

@type function User
@version 1.0
@author Paulo Lenzi
@since 29/02/2024
@return variant, return_description
/*/
User Function A020EOK()

If M->A1_EST = "EX" 
	If ! EMPTY(M->A2_CGC)
			Alert("Fornecedor estrangeiro não deve ter CNPJ cadastrado.")
		Return(.f.)
	Endif
Endif

If m->a2_est # "EX"
	If m->a2_tipo == "X"
		Alert("Para clientes com tipo igual a Exportação o Estado deve ser igual a EX, verifique!")
		Return(.f.)
	Endif
Endif

If  M->A2_EST <> "EX" .AND. EMPTY(M->A2_CGC)  
			ALERT("Por favor, cadastrar o CNPJ do cliente.")
			Return(.f.)
EndIf

If M->A2_EST # "EX"
	If empty(M->A2_COD_MUN)
		Alert("Por favor, preencher o Código do município")
		Return(.f.)
	Endif
Endif

If M->A2_EST # "EX"
	If empty(M->A2_INSCR)
		Alert("Por favor, preencher Inscrição estadual")
		Return(.f.)
	Endif
Endif

	If empty(M->A2_PAIS)
		Alert("Por favor, preencher o código do pais")
		Return(.f.)
	Endif

if ExistBlock("FINCCTD")
    aParam2:= {"F",M->A2_COD,M->A2_LOJA,M->A2_NOME }
    ExecBlock("FINCCTD",.f.,.f.,aParam2)
endif

RETURN(.T.)

/*/{Protheus.doc} MA030TOK
description Função chamada na validação do cadastro de clientes
@type function
@version 1.0
@author Paulo Lenzi
@since 29/02/2024
@return variant, return_description
/*/
User Function MA030TOK()

If M->A1_EST = "EX" 
	If ! EMPTY(M->A1_CGC)
			Alert("Cliente estrangeiro não deve ter CNPJ cadastrado.")
		Return(.f.)
	Endif
Endif

If m->a1_est # "EX"
	If m->a1_tipo == "X"
		Alert("Para clientes com tipo igual a Exportação o Estado deve ser igual a EX, verifique!")
		Return(.f.)
	Endif
Endif

If  M->A1_EST <> "EX" .AND. EMPTY(M->A1_CGC)  
			ALERT("Por favor, cadastrar o CNPJ do cliente.")
			Return(.f.)
EndIf

If M->A1_EST # "EX"
	If empty(M->A1_COD_MUN)
		Alert("Por favor, preencher o Código do município")
		Return(.f.)
	Endif
Endif

If M->A1_EST # "EX"
	If empty(M->A1_INSCR)
		Alert("Por favor, preencher Inscrição estadual")
		Return(.f.)
	Endif
Endif

If empty(M->A1_PAIS)
		Alert("Por favor, preencher o código do pais")
		Return(.f.)
Endif

if ExistBlock("FINCCTD")
    aParam2:= {"C",M->A1_COD,M->A1_LOJA,M->A1_NOME }
    ExecBlock("FINCCTD",.f.,.f.,aParam2)
endif

RETURN(.T.)


user Function FINCCTD()
    Local cArea := FwGetArea()
	Local cPrefixo := PARAMIXB[1]
	Local cCodigo  := PARAMIXB[2]
	Local cLoja    := PARAMIXB[3]
	Local cNome    := PARAMIXB[4]
	
    dbSelectArea("CTD")
	CTD->( dbSetOrder(1) )
	IF CTD->( !dbSeek(xFilial("CTD")+cPrefixo+cCodigo+cLoja,.T.))
			Reclock("CTD",.T.)
			CTD->CTD_FILIAL :=XFILIAL("CTD")
			CTD->CTD_ITEM   :=cPrefixo+cCodigo+cLoja
			CTD->CTD_CLASSE :="2"
			CTD->CTD_DESC01 :=cNome
			CTD->CTD_BLOQ   :="2"
			CTD->CTD_DTEXIS :=CTOD("01/01/07")
			CTD->CTD_CLOBRG :="2"
			CTD->CTD_ACCLVL :="1"
			CTD->CTD_ITLP   :=cPrefixo+cCodigo+cLoja
			CTD->CTD_ITSUP  :="C"
	        CTD->(MsUnlock() )
    ENDIF

    FwRestArea(cArea)
Return

User Function MCTBA001()
    Local cArea     := FwGetArea()
    Local cAlias    := GetNextAlias()

    BeginSQL Alias cAlias
		SELECT  A1_FILIAL , A1_COD, A1_LOJA, A1_NOME 	
		FROM %Table:SA1% SA1
		WHERE SA1.%NotDel%
		and A1_FILIAL =  %xFilial:SA1%
        and A1_MSBLQL <> '1'
    EndSQL  

    ProcRegua( (cAlias)->(RecCount()) )

    While (cAlias)->(!EOF())
          IncProc()
          if ExistBlock("FINCCTD")
             aParam2:= {"C",(cAlias)->A1_COD,(cAlias)->A1_LOJA,(cAlias)->A1_NOME }
             ExecBlock("FINCCTD",.f.,.f.,aParam2)
          endif

          (cAlias)->(dbSkip() )
    ENDDO
    (cAlias)->(DbCloseArea())
    FwRestArea(cArea)
Return

/*/{Protheus.doc} MCTBA002
description
@type function
@version 1.0
@author Paulo Lenzi
@since 01/03/2024
@return variant, return_description
/*/
User Function MCTBA002()
    Local cArea     := FwGetArea()
    Local cAlias    := GetNextAlias()

    BeginSQL Alias cAlias
		SELECT  A2_FILIAL , A2_COD, A2_LOJA, A2_NOME 	
		FROM %Table:SA2% SA2
		WHERE SA2.%NotDel%
		and A2_FILIAL =  %xFilial:SA2%
        and A2_MSBLQL <> '1'
    EndSQL  

    ProcRegua( (cAlias)->(RecCount()) )

    While (cAlias)->(!EOF())
          IncProc()
          if ExistBlock("FINCCTD")
             aParam2:= {"F",(cAlias)->A2_COD,(cAlias)->A2_LOJA,(cAlias)->A2_NOME }
             ExecBlock("FINCCTD",.f.,.f.,aParam2)
          endif

          (cAlias)->(dbSkip() )
    ENDDO
    (cAlias)->(DbCloseArea())
    FwRestArea(cArea)
Return

