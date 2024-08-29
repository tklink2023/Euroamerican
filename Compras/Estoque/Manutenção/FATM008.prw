#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

#define ENTER chr(13) + chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATM008  � Autor �Tiago O Beraldi     � Data � 14/10/08    ���
�������������������������������������������������������������������������͹��
���Descricao �AJUSTA CUSTO STANDARD E PRECO DE VENDAS                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATM008()
      
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aArea       := GetArea()
                                            
Private cPerg     := "FATM08"
Private cTimeCur  := "00:00"
Private cTimeIni  := Time()
Private oDlg1        

 
SetPrvt("oGrp1","oGrp2","oGrp3","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSBtn1","oSBtn2","oSBtn3")

//���������������������������������������������������������������������Ŀ
//� Dicionario de Perguntas                                             �
//�����������������������������������������������������������������������
Pergunte(cPerg, .F.)

//���������������������������������������������������������������������Ŀ
//| Definicao do Dialog e todos os seus componentes.                    |
//�����������������������������������������������������������������������
oDlg1      := MSDialog():New( 000,000,120,400,"Ajusta Custo Standard e Pre�os de Venda",,,.F.,,,,,,.T.,,,.T. )   
oGrp1      := TGroup():New( 002,002,040,200,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGrp2      := TGroup():New( 042,002,060,110,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGrp3      := TGroup():New( 042,112,060,200,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 006,007,{||"Este programa tem o objetivo de ajustar o Custo Standard e Pre�os de Venda"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay2      := TSay():New( 014,007,{||"conforme cadastro de estrutura.                                           "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay3      := TSay():New( 022,007,{||"Obs.: Somente ira atualizar o Custo dos Produtos com Estrutura cadastrada."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay4      := TSay():New( 030,007,{||"Espec�fico Empresa Euroamerican.                                          "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay5      := TSay():New( 048,007,{||"Tempo Decorrido: " },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,008)
oSay6      := TSay():New( 048,050,{|| cTimeCur           },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSBtn1     := SButton():New( 046,115,5,{|| Pergunte(cPerg, .T.)},oDlg1,,"", )
oSBtn2     := SButton():New( 046,143,1,{|| CursorWait(), U_FATM08E(), CursorArrow()},oDlg1,,"", )
oSBtn3     := SButton():New( 046,171,2,{|| oDlg1:End()         },oDlg1,,"", )
	
oDlg1:Activate(,,,.T.)
                   
RestArea(aArea) 

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOADCUSTD � Autor �Tiago O Beraldi     � Data � 14/10/08    ���
�������������������������������������������������������������������������͹��
���Descricao �PROCESSA ATUALIZACAO                                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATM08E(lBlind) 

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cSProc0200  := ""     

Default lBlind    := .F.
                                            
//���������������������������������������������������������������������Ŀ
//� 1 = Atualiza Custo Standard 2 = Atualiza Custo Teste                �
//�����������������������������������������������������������������������
If !lBlind
	If mv_par03 == 1
		cMsg := "Deseja continuar a atualiza��o? (CUSTO STANDARD)"
	Else
		cMsg := "Deseja continuar a atualiza��o? (CUSTO TESTES)"
	EndIf
	
	If !ApMsgYesNo(cMsg, "Atualiza��o de Custos")                             
		Return                                                                
	EndIf
Else   
	Pergunte("FATM08", .F.)
EndIf	
		
// Executa procedure
cSProc0200 := "SP_CUSTOST4'" + mv_par01 + "','" + mv_par02 + "','B1_CUST" + Subs(DtoC(dDataBase),4,2) + "', '" + StrZero(mv_par03, 1) + "'"
//TcSQLExec(cSProc0200)

If TCSqlExec(cSProc0200) < 0 // -> Paulo Lenzi 29/08/2024
        FWAlertInfo("Falha: " + TCSQLError(), " Processo Store Procedure interrompido...")
		return
EndIf


// Atualiza Historico de Custos                                                                            
If mv_par03 == 1    

	cUpdate := "  UPDATE " + RetSqlName("SB1") + ENTER
	cUpdate += "  SET B1_XCUSTD = B1_VAL1, " + ENTER                                    
	cUpdate += "      B1_VALOR4 = B1_VAL1, " + ENTER                                    		
	cUpdate += "      B1_CUST" + StrZero(Month(dDataBase), 2) + " = B1_VAL1, " + ENTER 
	cUpdate += "      B1_XPRV1 = B1_CUSTNET / ( (1 - 0.04 -  "
	cUpdate += "      				CASE WHEN B1_COD LIKE '8%' AND SUBSTRING(B1_COD,4,1) = '.' THEN 0.03 "  + ENTER //"Produtos Revenda
	cUpdate += "      					ELSE 0.155 END ) - ( 40 * 0.000421 ) - ( 0.0925 + 0.18 ) - 0.025 ) " + ENTER 
   	cUpdate += "  WHERE	D_E_L_E_T_ <> '*' " + ENTER                                   
   	cUpdate += "  		AND B1_TIPO = 'PA' " + ENTER                           
   	cUpdate += "  		AND NOT EXISTS (SELECT G1_COD FROM  " + RetSqlName("SG1") + "  WHERE D_E_L_E_T_ = '' AND G1_COD = B1_COD) " + ENTER
   	cUpdate += "  		AND B1_MSBLQL <> '1' "   
   	
	//MemoWrite("fatm008.sql", cUpdate)                             
	//TcSQLExec(cUpdate)                             

	If TCSqlExec(cUpdate) < 0 // -> Paulo Lenzi 29/08/2024
			FWAlertInfo("Falha: " + TCSQLError(), " Update dos PAs interrompido...")
			return
	EndIf



Endif
        
                                      
If !lBlind
	cTimeCur := CalcProg(cTimeIni, Time())
	GetdRefresh()
	ApMsgInfo("Fim do Processamento!", "Atualiza��o de Custos")
EndIf	

Return                   

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATM008  � Autor �Tiago O Beraldi     � Data � 14/10/08    ���
�������������������������������������������������������������������������͹��
���Descricao � CALCULO DE PROGRESSO                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CalcProg(cTimeI, cTimeF)

Local nSegIni := Val(Subs(cTimeI,1,2)) * 3600 + Val(Subs(cTimeI,4,2)) * 60 + Val(Subs(cTimeI,7,2))
Local nSegFim := Val(Subs(cTimeF,1,2)) * 3600 + Val(Subs(cTimeF,4,2)) * 60 + Val(Subs(cTimeF,7,2))
Local nSeg    := nSegFim - nSegIni
Local nMin    := (nSeg - (nSeg % 60)) / 60

nSeg := nSeg % 60
                    
Return StrZero(nMin,2) + ":" + StrZero(nSeg,2)
