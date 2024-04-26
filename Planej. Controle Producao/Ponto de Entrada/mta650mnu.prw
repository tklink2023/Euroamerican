#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mta650mnu
//PE usado para inserir informacoes no browse da Ordem de Producao
@author mjlozzardo
@since 19/01/2018
@version 1.0
@type function
/*/
User Function mta650mnu()
    Local cArea := FwGetArea()
	Local cPosMn:= GetMv("ES_POSMENU")

	aAdd(aRotina, {"Impressão de Etiqueta"	, "U_REST002" , 0, 2, Nil})
	aAdd(aRotina, {"Revalidação de Etiqueta", "U_QEETQREV" , 0, 2, Nil})
	aAdd(aRotina, {"Etiqueta p/Pallet"    	, "U_REST004" , 0, 2, Nil})
	aAdd(aRotina, {"Etiq.Caixa Coletiva" 	, "U_REST005" , 0, 2, Nil})
	aAdd(aRotina, {"Etiq. Kits"           	, "U_QETIQ002", 0, 2, Nil})
	aAdd(aRotina, {"Etiqueta HENKEL"      	, "U_EQEtHenk", 0, 2, Nil})
	aAdd(aRotina, {"Mod Ant. Ordem Prd"   	, "U_EQNewOP2( SC2->C2_NUM )", 0, 2, Nil})

    if cPosMn = '1'
	   aAdd(aRotina, {"Mod Novo Ordem Prd"   	, "U_EQNewOP3( SC2->C2_NUM )", 0, 2, Nil})
	elseif cPosMn = '2'   
       aAdd(aRotina, {"Novo Layout OP"      	, "U_PCPR280( SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN )", 0, 2, Nil})
	else
       aAdd(aRotina, {"Mod Novo Ordem Prd"   	, "U_EQNewOP3( SC2->C2_NUM )", 0, 2, Nil})
	   aAdd(aRotina, {"Novo Layout OP"      	, "U_PCPR280( SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN )", 0, 2, Nil})
	endif	   

    aAdd(aRotina, {"Arquivo Datador"   		, "U_MT650DATA( SC2->C2_NUM,SC2->C2_ITEM,SC2->C2_SEQUEN,SC2->C2_PRODUTO,SC2->C2_LOCAL)", 0, 2, Nil})

	FwRestArea(cArea)
Return
