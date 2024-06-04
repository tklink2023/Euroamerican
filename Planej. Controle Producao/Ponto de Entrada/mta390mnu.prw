#include 'protheus.ch'
#include 'parmtype.ch'
User Function mta390mnu()
    Local cArea := FwGetArea()
    aAdd(aRotina, {"Bloquear Lote"	, "MTA390BLQ" , 0, 2, Nil})
	FwRestArea(cArea)
Return

STATIC FUNCTION MTA390BLQ()
msgalert("bloqueio de lote")
Return
