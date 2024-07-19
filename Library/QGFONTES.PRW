//-------------------------------------------------------------------
/*/{Protheus.doc} getRpoCustomFunctions
Geração de CSV com as funções de usuário presentes no RPO Custom

@author Daniel Mendes
@since 24/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
user function getRpoCustomFunctions()
local aFunc1 as array
local aType1 as array
local aFile1 as array
local aLine1 as array
local aDate1 as array
local aTime1 as array
local aFunc2 as array
local aType2 as array
local aFile2 as array
local aLine2 as array
local aDate2 as array
local aTime2 as array
local nHandler as numeric
local aSrc as array
local nI as numeric
local cCRLF as character

aType1 := {}
aFile1 := {}
aLine1 := {}
aDate1 := {}
aTime1 := {}

aFunc1 := GetFuncArray('U_*', @aType1, @aFile1, @aLine1, @aDate1, @aTime1)

aFunc2 := {}
aType2 := {}
aFile2 := {}
aLine2 := {}
aDate2 := {}
aTime2 := {}

for nI := 1 to Len(aFunc1)
    aSrc := GetSrcArray(aFile1[nI], 3)

    if !Empty(aSrc)
        aSize(aSrc, 0)
        aAdd(aFunc2, aFunc1[nI])
        aAdd(aType2, aType1[nI])
        aAdd(aFile2, aFile1[nI])
        aAdd(aLine2, aLine1[nI])
        aAdd(aDate2, aDate1[nI])
        aAdd(aTime2, aTime1[nI])
    endif
next

aSize(aFunc1, 0)
aSize(aType1, 0)
aSize(aFile1, 0)
aSize(aLine1, 0)
aSize(aDate1, 0)
aSize(aTime1, 0)

nHandler := FCreate("custom-user-functions.csv")

if nHandler >= 0
    cCRLF := Chr(13) + Chr(10)
    FWrite(nHandler, "Função;Fonte;Tipo;Linha;Data;Hora" + cCRLF)

    for nI := 1 to Len(aFunc2)
        FWrite(nHandler, aFunc2[nI] + ";" + aFile2[nI] + ";" + aType2[nI] + ";" + aLine2[nI] + ";" + DtoC(aDate2[nI]) + ";" + aTime2[nI] + cCRLF)
    next

    FClose(nHandler)
else
    MsgStop("Erro na criação do arquivo:" + cValToChar(FError()))
endif

aSize(aFunc2, 0)
aSize(aType2, 0)
aSize(aFile2, 0)
aSize(aLine2, 0)
aSize(aDate2, 0)
aSize(aTime2, 0)

return
