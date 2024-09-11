#include 'protheus.ch'
#include 'parmtype.ch'
User Function PCP200FIL()
    Local cArea := FwGetArea()
    Local cFiltro := ""
    Local cIdUser := __cUserId
    Local cGrpVec := ""
    dbSelectArea("SZA")
    SZA->( dbSetOrder(1) )
    IF SZA->( dbSeek( xFilial("SZA")+cIdUser))
        cGrpVec := SZA->ZA_TIPVEC
        IF !Empty(cGrpVec)
            cFiltro := " G1_TIPVEC == '"+cGrpVec+"' "
        ENDIF
    ENDIF    
    FwRestArea(cArea)
Return cFiltro
