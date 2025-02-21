#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#DEFINE cEof  CHAR(13)+CHAR(10)
//============================================================================================================
//
// Funções de Biblioteca
//
//============================================================================================================

/*/{Protheus.doc} Ambiente
description
@type function
@version 1.0
@author Paulo Lenzi
@since 19/02/2025
@return variant, return_description
/*/
User Function XEnvironment()
    Local cAutoEmp := PARAMIXB[1]
    Local cAutoFil := PARAMIXB[2]
    RpcClearEnv()  //Limpa o Ambiente
	RpcSetType(3)
    If Select("SX2") <= 0
	    RpcSetEnv( cAutoEmp, cAutoFil )
    Endif    
Return

/*/{Protheus.doc} RegLog
description
@type function
@version 1.0
@author Paulo Lenzi
@since 19/02/2025
@return variant, return_description
/*/
User Function XRegistroLog()
    Local cArea := FwGetArea()
    Local cMensagem :=  PARAMIXB[1]
    Local cProcesso :=  PARAMIXB[2]
    Local xcUser    :=  PARAMIXB[3]    
    Local cDetalhe  :=  PARAMIXB[4]
    Local cSubProc  :=  PARAMIXB[5]
    Local cIdMov    :=  PARAMIXB[6]

    dbSelectArea("CV8")
    If RecLock("CV8",.T.)
                CV8->CV8_FILIAL:= xFilial("CV8")
                CV8->CV8_DATA 	:= MsDate()
                CV8->CV8_HORA 	:= SubStr(Time(),1,TamSx3("CV8_HORA")[1])
                CV8->CV8_PROC	:= cProcesso
                CV8->CV8_USER	:= xcUser
                CV8->CV8_INFO   := '2'
                CV8->CV8_MSG 	:= cMensagem
                CV8->CV8_DET    := cDetalhe
                CV8->CV8_SBPROC := cSubProc
                CV8->CV8_IDMOV  := cIdMov
                CV8->(MsUnlock())
    EndIf
     FwRestArea(cArea)
Return

//------------------------------------------------------------------------------------------------------------
// Programas de Gatilho
//------------------------------------------------------------------------------------------------------------


//============================================================================================================
//  
// FIM DO ARQUIVO
//
//============================================================================================================  
