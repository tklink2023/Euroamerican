#include "protheus.ch"
#include "topconn.ch"

User Function EQEtqSep() // Etiqueta de ordem de separa��o...

Local cPorta 	:= "LPT1"
Local cModelo   := "LPT1"

Private cPerg   := "BEETQORDEM"

ValidPerg()

If Pergunte(cPerg, .T.)
	cQuery := "SELECT CB8_FILIAL, D4_OP, D4_COD, D4_LOCAL, D4_QUANT,D4_QTDORI, CB8_QTDORI, CB8_ORDSEP, D4_LOTECTL, CB8_LOTECT, CB8_NUMLOT, CB8_LOCAL, CB8_PROD, CB8_ITEM, CB8_SEQUEN, CB8_LCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SC2") + " AS SC2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD4") + " AS SD4 WITH (NOLOCK) ON D4_FILIAL = C2_FILIAL " + CRLF
	cQuery += "  AND D4_OP = C2_NUM + C2_ITEM + C2_SEQUEN " + CRLF
	cQuery += "  AND SD4.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("CB8") + " AS CB8 WITH (NOLOCK) ON CB8_FILIAL = D4_FILIAL " + CRLF
	cQuery += "  AND CB8_OP = D4_OP " + CRLF
	cQuery += "  AND CB8_PROD = D4_COD " + CRLF
	cQuery += "  AND CB8_LOCAL = D4_LOCAL " + CRLF
	cQuery += "  AND CB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE C2_FILIAL = '" + xFilial("SC2") + "' " + CRLF
	cQuery += "AND C2_NUM BETWEEN '" + AllTrim( mv_par01 ) + "' AND '" + AllTrim( mv_par02 ) + "' " + CRLF // 010307
	cQuery += "AND C2_ITEM = '01' AND C2_SEQUEN = '001' " + CRLF // 010307
	cQuery += "AND SC2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY CB8_FILIAL, CB8_ORDSEP, D4_LOCAL, CB8_LCALIZ, CB8_ITEM, CB8_LOCAL, CB8_PROD, D4_COD, CB8_LOTECT, CB8_NUMLOT, D4_OP, D4_LOTECTL, D4_QUANT,D4_QTDORI, CB8_QTDORI, CB8_SEQUEN " + CRLF
	cQuery += "ORDER BY CB8_FILIAL, CB8_ORDSEP, CB8_LOCAL, CB8_LCALIZ, CB8_PROD, CB8_LOTECT, CB8_NUMLOT, CB8_ITEM, CB8_SEQUEN " + CRLF  
Else
	Return
EndIf

TCQuery cQuery New Alias "TMLBAR"
dbSelectArea("TMLBAR")
dbGoTop()

nConta := 0

Do While !TMLBAR->( Eof() )
		MSCBPRINTER(cModelo,cPorta,,40,.f.)
		MSCBCHKSTATUS(.F.)
		MSCBBEGIN(1,6)
		MSCBWrite("^FO400,070^BXN ,05,200,20^FD"+BeAscHex(TMLBAR->D4_COD + TMLBAR->D4_LOTECTL)+"^FS") 				// C�digo de Barras 2d - Data Matrix
				MSCBSAY(014,004,"ORDEM DE PRODUCAO  :. " + Alltrim( TMLBAR->D4_OP ),"N","0","020,020")
				MSCBSAY(014,008,"ORDEM DE SEPARACAO :. " + Alltrim( TMLBAR->CB8_ORDSEP ),"N","0","020,020")
				MSCBSAY(014,012,"PRODUTO: " + Alltrim( TMLBAR->D4_COD ),"N","0","020,020")
				MSCBSAY(014,016,"LOCAL: " + Alltrim( TMLBAR->D4_LOCAL ),"N","0","020,020")
				MSCBSAY(014,020,"LOTE :. " + Alltrim( TMLBAR->D4_LOTECTL ),"N","0","020,020")
				//MSCBSAY(014,024,"QUANTIDADE: " + TRANSFORM( TMLBAR->CB8_QTDORI, "@E 999,999,999.9999"),"N","0","020,020") <- Alterado 10/07/2024 - Paulo Lenzi
				MSCBSAY(014,024,"QUANTIDADE: " + TRANSFORM( TMLBAR->D4_QTDORI, "@E 999,999,999.9999"),"N","0","020,020")
		MSCBEND()
		MSCBCLOSEPRINTER()
		Sleep(1000)
		TMLBAR->( dbSkip() )
EndDo


TMLBAR->( dbCloseArea() )
	
Return

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}
Local i      := 0

cPerg := Padr( cPerg, 10)

aAdd(_aPerg, {cPerg, "01", "Da Ordem Produ��o  ?", "MV_CH1" , "C", 11	, 0	, "G", "MV_PAR01", "SC2",""           ,""               ,""               ,""     ,""})
aAdd(_aPerg, {cPerg, "02", "At� Ordem Produ��o ?", "MV_CH2" , "C", 11	, 0	, "G", "MV_PAR02", "SC2",""           ,""               ,""               ,""     ,""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(_aPerg)
	IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with _aPerg[i,01]
	Replace X1_ORDEM   with _aPerg[i,02]
	Replace X1_PERGUNT with _aPerg[i,03]
	Replace X1_VARIAVL with _aPerg[i,04]
	Replace X1_TIPO	   with _aPerg[i,05]
	Replace X1_TAMANHO with _aPerg[i,06]
	Replace X1_PRESEL  with _aPerg[i,07]
	Replace X1_GSC	   with _aPerg[i,08]
	Replace X1_VAR01   with _aPerg[i,09]
	Replace X1_F3	   with _aPerg[i,10]
	Replace X1_DEF01   with _aPerg[i,11]
	Replace X1_DEF02   with _aPerg[i,12]
	Replace X1_DEF03   with _aPerg[i,13]
	Replace X1_DEF04   with _aPerg[i,14]
	Replace X1_DEF05   with _aPerg[i,15]
	MsUnlock()
Next i

RestArea(_aArea)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BeAscHex	� Autor � Fabio F Sousa         � Data � 16/12/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Converte Asc para Hexadecimal.							  ���
���          � 					  			  							  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function BeAscHex(cString)

Local cRet 		:= "^FH_^FD"
Local aAcento	:= {}
Local nPos		:= 0
Local nX

//���������������������������������������������������������������������Ŀ
//� Define caracteres a serem tratados.									�
//�����������������������������������������������������������������������
aAcento := {{"�","_85"},{"�","_a0"},{"�","_83"},{"�","_c6"},;
			{"�","_b7"},{"�","_b5"},{"�","_b6"},{"�","_c7"},;
			{"�","_8a"},{"�","_82"},{"�","_88"},;
			{"�","_d4"},{"�","_90"},{"�","_d2"},;
			{"�","_8d"},{"�","_a1"},{"�","_8c"},;
			{"�","_de"},{"�","_d6"},{"�","_d7"},;
			{"�","_95"},{"�","_a2"},{"�","_93"},{"�","_e4"},;
			{"�","_e3"},{"�","_e0"},{"�","_e2"},{"�","_e5"},;
			{"�","_97"},{"�","_a3"},{"�","_96"},;
			{"�","_eb"},{"�","_e9"},{"�","_ea"},;
			{"�","_87"},{"�","_80"},;
			{"�","_a7"},{'"',"_22"},{"@","_40"},{"/","_2f"},;
			{"�","_27"},{"�","_2d"},{"�","_ae"},{"%","_25"},{"�","_2d"}}


For nX := 1 to Len(cString)
	cAux := Substr(cString,nX,1)
	nPos := aScan(aAcento,{|x| x[1] == cAux })
	If nPos > 0
		cRet += aAcento[nPos][2]
	Else
		cRet += cAux
	EndIf
Next nX
cRet := cRet+"^FS"
Return cRet

/*
Local nXLocal cPorta := "COM1:9600,N,8,1"  
MSCBPRINTER("S500-8",cPorta,          , 40   ,.f.)

For nx:=1 to 3   
	MSCBBEGIN(1,6)             
	MSCBSAY(10,06,"CODIGO","N","A","015,008")   
	MSCBSAY(33,09, Strzero(nX,10), "N", "0", "032,035")    
	MSCBSAY(05,17,"IMPRESSORA ZEBRA S500-8","N", "0", "020,030")   
	MSCBEND()
Next	
MSCBCLOSEPRINTER()
*/


