#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

User Function MA650EMP()
   Local cArea         := FwGetArea()

   if Substring(SC2->C2_PRODUTO,1,1) == "T" .and. SC2->C2_LOCAL = 'TT'

        if ExistBlock("PCPM163")
            aDados:= {SC2->C2_NUM,SC2->C2_ITEM, SC2->C2_SEQUEN,SC2->C2_PRODUTO, SC2->C2_LOCAL}
            ExecBlock("PCPM163",.F.,.F.,aDados)   
        Endif
   
   Endif
 
   FwRestArea(cArea)
Return
