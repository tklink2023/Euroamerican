#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function PCPM063()
  Local cArea         := FwGetArea()
  Local cNumLote      := PARAMIXB[1]
  Local cItemLote     := PARAMIXB[2]
  Local cSeqLote      := PARAMIXB[3]

  Local cAlias := GetNextAlias()

   BeginSQL Alias cAlias
        Select C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_EMISSAO,C2_DATPRI,C2_DATPRF,C2_PRIOR,C2_DATRF,C2_PRODUTO,C2_QUANT,C2_QUJE, G2_OPERAC, G2_RECURSO, G2_DESCRI
        FROM %Table:SC2% SC2
        INNER JOIN %Table:SG2% SG2 ON G2_FILIAL = C2_FILIAL AND G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ = ' '
        WHERE SC2.%NotDel%
        and C2_FILIAL = %xFilial:SC2%
        AND C2_NUM    = %Exp:cNumLote%
        AND C2_ITEM   = %Exp:cItemLote%
        AND C2_SEQUEN = %Exp:cSeqLote%
    EndSQL

    if (cAlias)->( Eof())
            MsgAlert("Não tem Ordem de Producao","ATENÇÃO")
            FwRestArea(cArea)
	        RETURN
    Endif    

    TCSetField(cAlias, "C2_EMISSAO","D")
    TCSetField(cAlias, "C2_DATPRF", "D")
    TCSetField(cAlias, "C2_DATRF",  "D")
    TCSetField(cAlias, "C2_DATPRI", "D")

    While (cAlias)->(!EOF())
           dbSelectArea("SZ7")

           SZ7->( dbSetOrder(1) )
           IF SZ7->( !dbSeek( (cAlias)->C2_FILIAL+(cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN+(cAlias)->C2_PRODUTO,.T. ) ) 
                   IF RecLock("SZ7",.T.)
                      SZ7->Z7_FILIAL    :=  (cAlias)->C2_FILIAL
                      SZ7->Z7_NUM       :=  (cAlias)->C2_NUM
                      SZ7->Z7_ITEM      :=  (cAlias)->C2_ITEM
                      SZ7->Z7_SEQUEN    :=  (cAlias)->C2_SEQUEN
                      SZ7->Z7_PRODUTO   :=  (cAlias)->C2_PRODUTO
                      SZ7->Z7_QTPROD    :=  (cAlias)->C2_QUANT
                      SZ7->Z7_EMISSAO   :=  (cAlias)->C2_EMISSAO
                      SZ7->Z7_DATPRI    :=  (cAlias)->C2_DATPRI
                      SZ7->Z7_DATPRF    :=  (cAlias)->C2_DATPRF
                      SZ7->Z7_CPRIOR    :=  (cAlias)->C2_PRIOR
                      SZ7->Z7_DATRF     :=  (cAlias)->C2_DATRF
                      SZ7->Z7_STATUS    :=  "A"
                      SZ7->Z7_OP        := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->C2_SEQUEN
                      SZ7->( MsUnlock() )
                   ENDIF
           ENDIF

           dbSelectArea("SZ8")
           SZ8->( dbSetOrder(1) )
           IF SZ8->( !dbSeek( (cAlias)->C2_FILIAL+(cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN+(cAlias)->C2_PRODUTO+(cAlias)->G2_OPERAC+(cAlias)->G2_RECURSO,.T. ) ) 
                   IF RecLock("SZ8",.T.)
                      SZ8->Z8_FILIAL    :=  (cAlias)->C2_FILIAL
                      SZ8->Z8_OP        :=  (cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN
                      SZ8->Z8_PRODUTO   :=  (cAlias)->C2_PRODUTO
                      SZ8->Z8_OPERAC    :=  (cAlias)->G2_OPERAC
                      SZ8->Z8_RECUR     :=  (cAlias)->G2_RECURSO
                      SZ7->( MsUnlock() )
                   ENDIF
           ENDIF

          (cAlias)->(dbSkip() )
    End
    (cAlias)->(DbCloseArea())
    FwRestArea(cArea)
Return
