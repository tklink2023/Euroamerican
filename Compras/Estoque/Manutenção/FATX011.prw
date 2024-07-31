#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "xmlxfun.ch"
#include "shell.ch"
#include "tryexception.ch"

#DEFINE ENTER chr(13) + chr(10)

Static __nACREFRT := 0
Static __nDESCFRT := 0

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011  �Autor  �Alexandre Marson   � Data �  30/08/12   ���
�������������������������������������������������������������������������͹��
���Descricao � GERENCIAMENTO DE CARGAS                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������͹��
���02/01/18  �Emerson Paiva     �Adequa��o para ambiente Protheus 12      ���
���          �                  �                                         ���
���          �                  �                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011
//������������������������������������������������������������Ŀ
//� Declaracao de variaveis                                    �
//��������������������������������������������������������������
Local cExprFilTop	:= "ZF_FILIAL = '" + IIf( AllTrim(cFilAnt) $ "0106#0107#0108", AllTrim(cFilAnt), "" ) + "'"

Private cAlias		:= "SZF"
Private cCadastro	:= "Montagem de Carga e Descarga"
Private aRotina		:= MenuDef()
Private aCores		:= CorDef()

Private ESPARFAT1   := ""
Private ESPARFAT2   := ""
Private ESPARFAT4   := ""
Private ESPARFAT5   := ""
Private ESPARFAT6   := ""
Private cConteudo 	:= ""
Private _cPORTASUP	:= GETMV("MV_XPORTSP",, ",antonio.cabral,Administrador" )
Private lUsrOpc		:= .F.
Private lUsrOpc09	:= .F.
Private lUsrOpc10	:= .F.
Private lUsrOpc11	:= .F.

Private __cExpedicao := ''
Private __cUser      := ''

FAccess()

lUsrOpc			:= Upper(AllTrim(cUserName)) $ Upper(ESPARFAT1)
lUsrOpc09		:= Upper(AllTrim(cUserName)) $ Upper(ESPARFAT2)
lUsrOpc10		:= Upper(AllTrim(cUserName)) $ Upper(ESPARFAT4)
lUsrOpc11		:= Upper(AllTrim(cUserName)) $ Upper(ESPARFAT5)


//������������������������������������������������������������Ŀ
//� Monta mBrowse                                              �
//��������������������������������������������������������������
dbSelectArea("SZF")
dbSetOrder(1)
dbGoTop()

MBrowse(,,,,"SZF",,,,,,aCores,,,,,,,,cExprFilTop)

Return( Nil )

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alexandre Marson      � Data �24/04/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aMenuDef		:= {}
Local aRotina2		:= {}

Private cUsrOpc 	:= ""

cUsrOpc := FSeachOpc()
//-----------------------------------------------------------------------------------

aAdd( aMenuDef, {"Pesquisar"			,"AxPesqui"		, 0, 01, 0})
aAdd( aMenuDef, {"Carga"				,aRotina2		, 0, 03, 0})
aAdd( aMenuDef, {"Aprovacao Frete"		,"U_FATX011F"	, 0, 00, 0})
aAdd( aMenuDef, {"Legenda"				,"U_FATX011L"	, 0, 00, 0})
aAdd( aMenuDef, {"Conhecimento"	,"MsDocument" ,0,4})

//-----------------------------------------------------------------------------------

If Upper(alltrim(cUserName)) $ Upper(AllTrim(cUsrOpc))
	aAdd(aMenuDef, {"Desconto Admin"	,"U_FATX011Q", 0, 00, 0})
EndIf

//-----------------------------------------------------------------------------------

aAdd(aRotina2, {"Visualizar"			,"U_FATX011M"	, 0, 02, 0})
aAdd(aRotina2, {"Incluir"				,"U_FATX011M"	, 0, 03, 0})
aAdd(aRotina2, {"Alterar"				,"U_FATX011M"	, 0, 04, 0})
aAdd(aRotina2, {"Cancelar"		 		,"U_FATX011M"	, 0, 06, 0})

aAdd(aRotina2, {"Impr Romaneio"			,"U_FATX011R"	, 0, 08, 0})
aAdd(aRotina2, {"Espelho Conf."			,"U_RFAT005"	, 0, 08, 0})

aAdd(aRotina2, {"Entrega/Retorno"		,"U_FATX011M"	, 0, 09, 0})
aAdd(aRotina2, {"Validar Entr/Reto"		,"U_FATX011M"	, 0, 10, 0})


Return (aMenuDef)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CORDEF   �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao das cores para identificar status do registro    ���
���          � conforme exibido no botao Legenda                          ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CorDef()
Local aCor := {}

aAdd(aCor,{"!Empty(SZF->ZF_PAGTO)" ,"BR_VERMELHO"	})

aAdd(aCor,{"SZF->ZF_STATUS == '5' .AND. AT('IT11', SZF->ZF_LOG) == 0" ,"BR_PINK"	})
aAdd(aCor,{"SZF->ZF_STATUS == '5' .AND. AT('IT11', SZF->ZF_LOG) >  0" ,"BR_CINZA"	})

aAdd(aCor,{"SZF->ZF_STATUS == '1'" ,"BR_VERDE"		})
aAdd(aCor,{"SZF->ZF_STATUS == '2'" ,"BR_AMARELO"	})
aAdd(aCor,{"SZF->ZF_STATUS == '3'" ,"BR_AZUL"		})
aAdd(aCor,{"SZF->ZF_STATUS == '4'" ,"BR_LARANJA"	})
aAdd(aCor,{"SZF->ZF_STATUS == '6'" ,"BR_PRETO"		})
aAdd(aCor,{"SZF->ZF_STATUS == '7'" ,"BR_CANCEL"		})
aAdd(aCor,{"SZF->ZF_STATUS == '8'" ,"BR_MARRON"		})

Return aCor


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011L �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �GERA LEGENDA                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011L
Local aCor := {}

AADD(ACOR,{"BR_VERDE"			, "ABERTA"								}) //-> AO INCLUIR UM NOVO REGISTRO
AADD(ACOR,{"BR_AMARELO"			, "MATERIAL EM SEPARACAO"				}) //-> AO EMITIR DOCUMENTO DE SEPARACAO E EMBARQUE
AADD(ACOR,{"BR_AZUL"			, "VEICULO CARREGADO"					}) //-> AO EMITIR DOCUMENTO DETALHADO DA CARGA ( ROMANEIO )
AADD(ACOR,{"BR_LARANJA"			, "VEICULO EM TRANSITO"	 				}) //-> AO ASSOCIAR A CARGA A UM TICKET DA PORTARIA
AADD(ACOR,{"BR_PINK"			, "ENTREGA NAO VALIDADA"				}) //-> ENTREGA ( PORTARIA )
AADD(ACOR,{"BR_CINZA"			, "ENTREGA COM RETORNO ( VALIDADO )"	}) //-> ENTREGA ( EXPEDICAO ) COM RETORNO DE NOTA FISCAL
AADD(ACOR,{"BR_PRETO"			, "ENTREGA SEM RETORNO ( VALIDADO )"	}) //-> ENTREGA ( EXPEDICAO ) SEM RETORNO DE NOTA FISCAL
AADD(ACOR,{"BR_CANCEL"	 		, "CANCELADA"							}) //-> CARGA CANCELADA
AADD(ACOR,{"BR_VERMELHO" 		, "ORDEM DE PAGAMENTO EMITIDA"			}) //-> CARGA COM ORDEM DE PAGAMENTO EMITIDA
AADD(ACOR,{"BR_MARRON"	 		, "ROTEIRIZADO"							}) //-> CARGA ROTEIRIZADA

BrwLegenda(cCadastro, "Legenda", aCor)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011M(cAlias,nReg,nOpc)

//���������������������������������������������������������������������Ŀ
//� Define variaveis                                                    �
//�����������������������������������������������������������������������
Local aArea      		:= GetArea()

Local lOk       	 	:= .F.
Local bOk        		:= {|| If( fTudOK(nOpcUsr), ( lOk:=.T., oDlg:End() ), ( lOK:=.F. ) )}
Local bCancel   	 	:= {|| oDlg:End() }
Local aButtons   		:= {}

Local aSize		 		:= MsAdvSize()
Local aInfo  	 	  	:= {}
Local aObjects	 		:= {}
Local aPos      	 	:= {}


Local cQry				:= ""
Local cMsg				:= ""

Private lPORTASUP			:= AllTrim(cUserName)        $ _cPORTASUP
Private aPosHeader 		:= {}
Private aPosDetail	 	:= {}
Private aRegistro		:= {}

Private nHeader			:= 0

Private oMsmGet	 	  	:= Nil
Private oGetDados		:= Nil
Private oDlg     		:= Nil

Private nOpcObj    		:= 0
Private nOpcUsr    		:= 0

Private aLotes			:= {}

//��������������������������������������������������������Ŀ
//� Ajusta conteudo da variavel nOpc                       �
//����������������������������������������������������������
nOpcUsr := aRotina[nOpc][4]

Do Case

	Case nOpcUsr == 6 //-> Cancelamento
		nOpcObj := 2

	Case nOpcUsr == 9 .Or. nOpcUsr == 10 //-> Entrega/Retorno NF
		nOpcObj := 4

	Otherwise
		nOpcObj := nOpcUsr

EndCase

//��������������������������������������������������������Ŀ
//� Valida operacao do usuario no registro x acesso        �
//����������������������������������������������������������
Do Case
		Case ( nOpcUsr >= 3 .And. nOpcUsr <= 8 ) .And. .Not. lUsrOpc  .and. !( lPORTASUP .and. nOpcUsr == 4 )
			Help( ,, "FATX011 Gerenciam.Carga",, OemToAnsi("Opcao nao disponivel para o seu usuario. Pe�a para verificar a suas permiss�es ")  , 1, 0 )
			Restarea( aArea )
			Return

		Case nOpcUsr == 9 .And. .Not. lUsrOpc09
			Help( ,, "FATX011 Gerenciam.Carga",, OemToAnsi("Opcao nao disponivel para o seu usuario. Pe�a para verificar a suas permiss�es ")  , 1, 0 )

			Restarea( aArea )
			Return

		Case nOpcUsr == 10 .And. .Not. lUsrOpc10
  			Help( ,, "FATX011 Gerenciam.Carga",,OemToAnsi("Opcao nao disponivel para o seu usuario. Pe�a para verificar a suas permiss�es ")  , 1, 0 )
			Restarea( aArea )
			Return
EndCase


//��������������������������������������������������������Ŀ
//� Valida operacao do usuario no registro x status carga  �
//����������������������������������������������������������
Do Case

	Case nOpcUsr == 4
		If .Not. SZF->ZF_STATUS $ "1#2#8" .and. !lPORTASUP
			MsgStop("N�o � poss�vel alterar a carga selecionada.")
			Restarea( aArea )
			Return
		EndIf

	Case nOpcUsr == 5
		If .Not. SZF->ZF_STATUS $ "1"
			MsgStop("N�o � poss�vel excluir a carga selecionada.")
			Restarea( aArea )
			Return
		EndIf

	Case nOpcUsr == 6
		If .Not. (SZF->ZF_STATUS $ "1#2" .Or. Upper(AllTrim(cUserName)) $ Alltrim(cConteudo) )
			MsgStop("N�o � poss�vel cancelar a carga selecionada.")
			Restarea( aArea )
			Return
		EndIf

	Case nOpcUsr == 9
		If .Not. SZF->ZF_STATUS $ "4"
			MsgStop("N�o � poss�vel classificar entrega/retorno da carga selecionada.")
			Restarea( aArea )
			Return
		EndIf

	Case nOpcUsr == 10
		If .Not. SZF->ZF_STATUS $ "5" .Or. At("IT10", SZF->ZF_LOG) == 0 .Or. At("IT11", SZF->ZF_LOG) > 0
			MsgStop("N�o � poss�vel validar entrega/retorno da carga selecionada.")
			Restarea( aArea )
			Return
		EndIf

EndCase

//��������������������������������������������������������Ŀ
//� Bloqueia inclusao de novas cargas caso exista carga    �
//� nao finalizada a mais de 10 dias                       |
//����������������������������������������������������������
If nOpcUsr == 3

	cQry := "SELECT	ZF_NUM [CARGA] " + ENTER
	cQry += "FROM	" + RetSqlName("SZF") + ENTER
	cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
	cQry += "AND	ZF_FILIAL = '" + xFilial("SZF") + "' " + ENTER
	cQry += "AND 	ZF_EMISSAO < CONVERT(VARCHAR, GETDATE()-10, 112) "
	cQry += "AND 	( ZF_STATUS IN ('1','2','3','4') OR ( ZF_STATUS = '5' AND CHARINDEX('IT11', ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZF_LOG))), '') ) = 0 ) ) " + ENTER

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY

	If QRY->( !BoF() ) .And. QRY->( !EoF() )

		QRY->( dbGoTop() )
		QRY->( dbEval( { || cMsg += QRY->CARGA + ENTER },,{ || QRY->( !Eof() ) } ) )

		If  Upper (AllTrim(cUserName)) $ Upper (AllTrim(lUsrOpc11))
			Return
		EndIf

	EndIf	

EndIf

//��������������������������������������������������������Ŀ
//� Alerta na inclusao de novas cargas caso exista carga   �
//� finalizada porem nao digitalizada                      |
//����������������������������������������������������������
If nOpcUsr == 3

	cQry := "SELECT	ZF_NUM [CARGA] " + ENTER
	cQry += "FROM	" + RetSqlName("SZF") + ENTER
	cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
	cQry += "AND	ZF_FILIAL = '" + xFilial("SZF") + "' " + ENTER
	cQry += "AND 	ZF_EMISSAO < CONVERT(VARCHAR, GETDATE()-10, 112) " + ENTER
	cQry += "AND	CHARINDEX('IT15', ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZF_LOG))), '') ) = 0 " + ENTER
	cQry += "AND 	( ZF_STATUS = '6' OR ( ZF_STATUS = '5' AND CHARINDEX('IT11', ISNULL(UPPER(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),ZF_LOG))), '') ) > 0 ) ) " + ENTER

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY

	If QRY->( !BoF() ) .And. QRY->( !EoF() )

		QRY->( dbGoTop() )
		QRY->( dbEval( { || cMsg += QRY->CARGA + ENTER },,{ || QRY->( !Eof() ) } ) )

	EndIf

EndIf

//��������������������������������������������������������Ŀ
//� Variavel de memoria                                    �
//����������������������������������������������������������
RegToMemory( "SZF", (nOpcUsr==3) )

//���������������������������������������������������������������������Ŀ
//� Adiciona botoes na EnchoiceBar                                      �
//�����������������������������������������������������������������������
aAdd(aButtons, {"S4WB011N", {|| fMarkBrwSF2(nOpcUsr) }, "Selecionar NF", "Selecionar NF"})

//���������������������������������������������������������������������Ŀ
//� Define as areas para criacao de objetos visuais                     �
//�����������������������������������������������������������������������
aObjects := {}
aAdd( aObjects, { 100, 180, .T., .F. } ) //Dimensao para objetos do cabecalho
aAdd( aObjects, { 100, 100, .T., .T. } ) //Dimensao para objetos do detalhe

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3, 3, 3}
aPos  := MsObjSize(aInfo, aObjects)

aPosHeader := aClone( aPos[1] ) //Area Cabecalho
aPosDetail := aClone( aPos[2] ) //Area Detalhe

//��������������������������������������������������������Ŀ
//� Cria objetos										   �
//����������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oDlg:lCentered 		:= .T.
oDlg:bInit     		:= {|| EnchoiceBar(oDlg,bOk,bCancel,,aButtons) }

fMontaMSMGet("SZF",nReg,nOpcObj,nOpcUsr)

fMontaGetDados(nOpcObj,nOpcUsr)

oDlg:ACTIVATE()

//��������������������������������������������������������Ŀ
//� Grava informacoes no banco de dados                    �
//����������������������������������������������������������
If lOk
	fConfirma(nOpcUsr)
	If	__lSX8
		ConfirmSX8()
	EndIf
	EvalTrigger()
Else
	If ( __lSX8)
		RollBackSX8()
	EndIf
EndIf

	If altera
		VALIDAMAIL()//fabio batista 17/10/2020
	EndIf
//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������
Restarea( aArea )

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fMontaMSMGet(cAlias,nReg,nOpcObj,nOpcUsr)
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->( GetArea() )
Local aCpoMsGET := {"NOUSER"}
Local aAltMsGET := {}

//Local aAltMsGET := {"ZF_VEICULO","ZF_FRETEP","ZF_OBSERV"}


//��������������������������������������������������������Ŀ
//� Monta campos visuais e editaveis do MSMGET             �
//����������������������������������������������������������
DbSelectArea("SX3")
DbSetOrder(1)
DbGoTop()
DbSeek("SZF")

While ( !Eof() .And. SX3->X3_ARQUIVO == "SZF" )
	If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
		aAdd(aCpoMsGET, SX3->X3_CAMPO) //Campos Visuais

		//� Campos Editaveis
		If ( nOpcUsr == 3 .Or. nOpcUsr == 4 ) .And. SX3->X3_VISUAL == "A"
			If RetCodUsr() $__cExpedicao //fabio batista
				aAltMsGET := {"ZF_TIPO","ZF_VEICULO","ZF_FRETEP","ZF_OBSERV","ZF_ACREFRT","ZF_DESCFRT"}//fabio batista
				__nACREFRT := SZF->ZF_ACREFRT//fabio batista
				__nDESCFRT := SZF->ZF_DESCFRT//fabio batista
			Else
				aAltMsGET := {"ZF_TIPO","ZF_VEICULO","ZF_FRETEP","ZF_OBSERV"}//fabio batista
			EndIf
		EndIf	
    EndIf
    SX3->( dbSkip() )
EndDo

//��������������������������������������������������������Ŀ
//� Criacao do objeto MSMGET                               �
//����������������������������������������������������������
oMsmGet := MsmGet():New(cAlias,nReg,nOpcObj,,,,aCpoMsGET,aPosHeader,aAltMsGET,,,,,oDlg,,.T.,,,.T.,.T.)

//��������������������������������������������������������Ŀ
//� Restaura area anterior                                 �
//����������������������������������������������������������
Restarea( aArea )
Restarea( aAreaSX3 )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fMontaGetDados(nOpcObj,nOpcUsr)
Local aArea			:= GetArea()

Local aHeader       := {}
Local aCols         := {}

Local nX			:= 0
Local nOpcGd		:= 0

Local bGdLinOk		:= {||AllwaysTrue()}
Local bGdTudOk		:= {||AllwaysTrue()}
Local bGdDelOk		:= {||fGdDelOk()}

Local aCposAlter    := {}
Local aCposEntRet   := {"ZG_DTENTR","ZG_RETORNO","ZG_MOTRETO","ZG_OBSRETO"}



If lPORTASUP			// O Supervisor da Portaria tem acesso a alterar tamb�m todos 
	aCposEntRet   := {}	// os campos relacionados ao retorno da NF. Criado esta regra em 19/03/2024 por Geronimo a pedido de Antonio Pe�anha Cabral
Endif

//��������������������������������������������������������Ŀ
//� Ajusta modo de abertura do registro                    �
//����������������������������������������������������������
Do Case

	//+--------------------------------------------------
	//| INCLUSAO OU ALTERACAO
	//+--------------------------------------------------
	Case nOpcUsr == 3 .Or. nOpcUsr == 4
		nOpcGd := GD_UPDATE+GD_DELETE

	//+--------------------------------------------------
	//| ENTREGA/RETORNO NF OU VALIDACAO RETORNO
	//+--------------------------------------------------
	Case nOpcUsr == 9 .Or. nOpcUsr == 10
		nOpcGd := GD_UPDATE

	//+--------------------------------------------------
	//| DEMAIS OPERACOES
	//+--------------------------------------------------
	Otherwise
		nOpcGd := 0

EndCase

//��������������������������������������������������������Ŀ
//� Monta AHeader                                          �
//����������������������������������������������������������
DbSelectArea("SX3")
DbSetOrder(1)
DbGoTop()
DbSeek("SZG")

While ( !Eof() .And. SX3->X3_ARQUIVO == "SZG" )

	If X3Uso(SX3->X3_USADO) ;
			.And. cNivel >= SX3->X3_NIVEL

		aAdd(aHeader, {;
							X3Titulo()				,;
	                        SX3->X3_CAMPO			,;
	                 		SX3->X3_PICTURE			,;
	                		SX3->X3_TAMANHO			,;
	                		SX3->X3_DECIMAL			,;
	                 		SX3->X3_VALID			,;
	                		SX3->X3_USADO			,;
	                		SX3->X3_TIPO			,;
	                		SX3->X3_F3				,;
	                		SX3->X3_CONTEXT			,;
	                		SX3->X3_CBOX			,;
	                		SX3->X3_RELACAO			;
                	 })

		//��������������������������������������������������������Ŀ
		//� Habilita ou Desabilita campo para edicao conforme      �
		//� opcao selecionada pelo usuario no aRotina              �
		//����������������������������������������������������������
		Do Case

			//+----------------------------------------------------------------------------
			//| INCLUSAO OU ALTERACAO  -> TODOS os campos relacionados ao processo de retorno
			//|                          de NF estar�o DESABILITADOS para edicao
			//+----------------------------------------------------------------------------
			Case nOpcUsr == 3 .Or. nOpcUsr == 4

				If aScan( aCposEntRet, {|cCampo| cCampo == AllTrim(SX3->X3_CAMPO) }) == 0
					aAdd(aCposAlter, AllTrim(SX3->X3_CAMPO))
				EndIf

			//+----------------------------------------------------------------------------
			//| RETORNO DE NOTA FISCAL -> APENAS os campos relacionado ao processo de retorno
			//|                          de NF estar�o HABILITADOS para edicao
			//+----------------------------------------------------------------------------
			Case nOpcUsr == 9 .Or. nOpcUsr == 10
				IF RetCodUsr() $__cUser //alterado por fabio batista
					aCposEntRet   := {"ZG_PESO","ZG_VOLUME","ZG_DTENTR","ZG_RETORNO","ZG_MOTRETO","ZG_OBSRETO"}//alterado por fabio batista
				ENDIF//alterado por fabio batista
				If aScan( aCposEntRet, {|cCampo| cCampo == AllTrim(SX3->X3_CAMPO) }) > 0
					aAdd(aCposAlter, AllTrim(SX3->X3_CAMPO))
				EndIf

		EndCase

	EndIf

	DbSkip()
Enddo

//��������������������������������������������������������Ŀ
//� Monta aCols                                            �
//����������������������������������������������������������
nHeader := Len(aHeader)

If nOpcUsr == 3

	aAdd(aCols,Array(nHeader+1))

	For nX := 1 to nHeader
		aCols[1,nX] := CriaVar(aHeader[nX,2])

		If ( AllTrim(aHeader[nX][2]) == "ZG_ITEM" )
			aCols[1][nX] := "01"
		EndIf

	Next nX

	aCols[1,(nHeader+1)] := .F.

Else

	dbSelectArea("SZG")
	dbSetOrder(1)
	dbSeek(xFilial("SZG")+M->ZF_NUM)

	While SZG->(!EoF()) .And. xFilial("SZG")+SZG->ZG_NUM == xFilial("SZF")+M->ZF_NUM

		//+----------------------------------------------------------------------------
		//| Adiciona registro na aCols
		//+----------------------------------------------------------------------------
		aAdd(aCols,Array(nHeader+1))

		For nX := 1 to nHeader
			If aHeader[nX][10] != "V"
				aCols[Len(aCols),nX] := FieldGet(FieldPos(aHeader[nX,2]))
			Else
				aCols[Len(aCols),nX] := CriaVar(aHeader[nX,2])
			EndIf
		Next nX

		aCols[Len(aCols),(nHeader+1)] := .F.

		//+----------------------------------------------------------------------------
		//| Adiciona registro na matriz de controle de edicao
		//+----------------------------------------------------------------------------
		aAdd(aRegistro,RecNo())

		//+----------------------------------------------------------------------------
		//| Avanca para o proximo registro
		//+----------------------------------------------------------------------------
		dbSkip()

	Enddo

EndIf

//��������������������������������������������������������Ŀ
//� Monta objeto GetDados                                  �
//����������������������������������������������������������
oGetDados := Nil
oGetDados := MsNewGetDados():New(aPosDetail[1], aPosDetail[2],aPosDetail[3],aPosDetail[4],nOpcGd,bGdLinOk,bGdTudOk,"+ZG_ITEM",aCposAlter,0,999999,Nil,Nil,bGdDelOk,oDlg,aHeader,aCols)
oGetDados:ForceRefresh()

//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������
RestArea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Confirma  �Autor  �Alexandre Marson    � Data �  24/04/12   ���
�������������������������������������������������������������������������͹��
���Descricao �Efetua o tratamento da Troca de Clientes.	                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fConfirma(nOpcUsr)

Local nX, nZ  		:= 0

Local bCampo   		:= {|nField| FieldName(nField) }

Local cLog      	:= ""
Local cLogCancel	:= ""

Local cQry	  		:= ""
Local cTransp		:= ""
Local cVeiculo		:= ""

Local aHeader  		:= oGetDados:aHeader
Local aCols   		:= oGetDados:aCols
Local aSoma	  		:= {}
Local aIndApv 		:= {}

Local nPEmpFil  	:= 0
Local nPNota   		:= 0
Local nPSerie  		:= 0
Local nPRetorno		:= 0

Local lNFRet 		:= .F.

dbSelectArea("DA3")
dbSetOrder(3)
If dbSeek(xFilial("DA3")+M->ZF_VEICULO)
	cVeiculo := DA3->DA3_COD
EndIf

//���������������������������������������������������������������������Ŀ
//� INCLUSAO                                                            �
//�����������������������������������������������������������������������
If nOpcUsr == 3

	// Itens - SZG
	dbSelectArea("SZG")
	dbSetOrder(1)

	For nX := 1 To Len(aCols)

		If !( aCols[nX][nHeader+1] ) //Registro Deletado

			//+----------------------------------------------
			//| Grava registro de carga
			//+----------------------------------------------
			RecLock("SZG",.T.)
				For nZ := 1 To nHeader
					If ( aHeader[nZ][10] != "V" )
						FieldPut(FieldPos(aHeader[nZ][2]),aCols[nX][nZ])
					EndIf
				Next nZ
				SZG->ZG_FILIAL	:= xFilial("SZG")
				SZG->ZG_NUM		:= M->ZF_NUM
			SZG->( MsUnlock() )

			//+----------------------------------------------
			//| Atualiza registro da nota fiscal
			//+----------------------------------------------
			nPEmpFil	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPFIL"})
			nPNota  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOTA"})
			nPSerie  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_SERIE"})

			cQry := "UPDATE " + RetSqlName("SF2") + ENTER
			cQry += " SET		F2_CARGA = '" +  M->ZF_NUM + "' " + ENTER
			If !Empty(cVeiculo)
				cQry += " 			,F2_VEICUL1 = '" +  cVeiculo + "' " + ENTER
			EndIf
			cQry += "WHERE		D_E_L_E_T_ = '' " + ENTER
			cQry += "AND 		F2_FILIAL = '" + aCols[nX][nPEmpFil] + "' " + ENTER
			cQry += "AND 		F2_DOC = '" + aCols[nX][nPNota] + "' " + ENTER
			cQry += "AND 		F2_SERIE = '" + aCols[nX][nPSerie] + "' " + ENTER

			If (TcSQLExec(cQry) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			If (TcSQLExec(cQry) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

  		EndIf

	Next nX

	// Cabecalho - SZF
	aIndApv	:= fIndAprov()
	aSoma	:= fSomaItens()
	cLog	:= U_FATX011H(1)
	cTransp := Posicione("DA3",3,xFilial("DA3")+M->ZF_VEICULO,"DA3_TRANSP")

	dbSelectArea("SZF")
	RecLock("SZF", .T.)

		For nX := 1 To FCount()
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		Next nX

		SZF->ZF_FILIAL	:= xFilial("SZF")
		SZF->ZF_PESO	:= aSoma[1]
		SZF->ZF_VALOR	:= aSoma[2]
		SZF->ZF_VOLUME	:= aSoma[3]
		SZF->ZF_LOG		:= cLog
		SZF->ZF_APVPESO := aIndApv[1]
		SZF->ZF_APVFRET := aIndApv[2]
		SZF->ZF_FRETEP  := M->ZF_FRETEP

	SZF->( MsUnlock() )

//���������������������������������������������������������������������Ŀ
//� ALTERACAO                                                           �
//�����������������������������������������������������������������������
ElseIf nOpcUsr == 4

	//Itens - SZG
	dbSelectArea("SZG")
	dbSetOrder(1)

	For nX := 1 To Len(aCols)

		If nX <= Len(aRegistro)

			dbGoto(aRegistro[nX])

			RecLock("SZG",.F.)
			If ( aCols[nX][nHeader+1] )
				dbDelete()
			EndIf

	    Else

		  	If !( aCols[nX][nHeader+1] )
		    	RecLock("SZG",.T.)
		   	EndIf

	    EndIf

		If !( aCols[nX][nHeader+1] )

			For nZ := 1 To nHeader
				If (aHeader[nZ][10] != "V")
					FieldPut(FieldPos(aHeader[nZ][2]), aCols[nX][nZ])
				EndIf
			Next nZ

			SZG->ZG_FILIAL	:= xFilial("SZG")
			SZG->ZG_NUM	:= M->ZF_NUM

		EndIf

		SZG->( MsUnlock() )

		//+----------------------------------------------
		//| Atualiza registro da nota fiscal
		//+----------------------------------------------
		If !( aCols[nX][nHeader+1] )

			nPEmpFil	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPFIL"})
			nPNota  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOTA"})
			nPSerie  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_SERIE"})

			cQry := "UPDATE " + RetSqlName("SF2") + ENTER
			cQry += " SET		F2_CARGA = '" +  M->ZF_NUM + "' " + ENTER
			If !Empty(cVeiculo)
				cQry += " 			,F2_VEICUL1 = '" +  cVeiculo + "' " + ENTER
			EndIf			
			cQry += "WHERE		D_E_L_E_T_ = '' " + ENTER
			cQry += "AND 		F2_FILIAL = '" + aCols[nX][nPEmpFil] + "' " + ENTER
			cQry += "AND 		F2_DOC = '" + aCols[nX][nPNota] + "' " + ENTER
			cQry += "AND 		F2_SERIE = '" + aCols[nX][nPSerie] + "' " + ENTER

			If (TcSQLExec(cQry) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			If (TcSQLExec(cQry) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

		EndIf

	Next nX

	// Cabecalho - SZF
	aIndApv	:= fIndAprov()
	aSoma	:= fSomaItens()
	cLog	:= U_FATX011H(2)
	cTransp := Posicione("DA3",3,xFilial("DA3")+M->ZF_VEICULO,"DA3_TRANSP")

	dbSelectArea("SZF")
	RecLock("SZF", .F.)

		For nX := 1 To FCount()
			FieldPut(nX,M->&(EVAL(bCampo,nX)))
		Next nX

		If !( AllTrim(cUserName) $ GETMV("MV_XPORTSP",, ",antonio.cabral,Administrador" ) .and. SZF->ZF_STATUS == "5")	// Alterado em 11/03/2024 por Geronimo a pedido do Pessanha para permitir ao Supervisor da portaria alterar os campos em entrega n�o validada (legenda roxa) e n�o alterar os campos n�o alterados
			SZF->ZF_PESO	:= aSoma[1]
			SZF->ZF_VALOR	:= aSoma[2]
			SZF->ZF_VOLUME	:= aSoma[3] 
			SZF->ZF_STATUS	:= "1"
			SZF->ZF_LOG		:= cLog
			SZF->ZF_APVPESO	:= aIndApv[1]
			SZF->ZF_APVFRET	:= aIndApv[2]
			SZF->ZF_FRETEP  := M->ZF_FRETEP
		Endif

	SZF->( MsUnlock() )

//���������������������������������������������������������������������Ŀ
//� EXCLUSAO                                                            �
//�����������������������������������������������������������������������
ElseIf nOpcUsr == 5

	//+----------------------------------------------------------------------------
	//| Valida qual o status da carga antes de realizar a exclusao
	//| Regra: Apenas podera ser excluido carga com status 1-ABERTA
	//+----------------------------------------------------------------------------
	If SZF->ZF_STATUS != '1'
		MsgStop("N�o � poss�vel excluir a carga selecionada.")
		Return
	EndIf

	//Itens - SZG
	dbSelectArea("SZG")
	dbSetOrder(1)
	dbSeek(xFilial("SZG") + M->ZF_NUM)

	While SZG->(!EoF()) .And. xFilial("SZG")+SZG->ZG_NUM == xFilial("SZF")+M->ZF_NUM

		RecLock("SZG")
			dbDelete()
		SZG->( MsUnlock() )

		//+----------------------------------------------
		//| Atualiza registro da nota fiscal
		//+----------------------------------------------
		nPEmpFil	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPFIL"})
		nPNota		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOTA"})
		nPSerie		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_SERIE"})


		cQry := "UPDATE " + RetSqlName("SF2") + ENTER
		cQry += " SET		F2_CARGA = '', F2_VEICUL1 = '' " + ENTER
		cQry += "WHERE		D_E_L_E_T_ = '' " + ENTER
		cQry += "AND 		F2_FILIAL = '" + aCols[nX][nPEmpFil] + "' " + ENTER
		cQry += "AND 		F2_DOC = '" + aCols[nX][nPNota] + "' " + ENTER
		cQry += "AND 		F2_SERIE = '" + aCols[nX][nPSerie] + "' " + ENTER

		If (TcSQLExec(cQry) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

		If (TcSQLExec(cQry) < 0)
			Return MsgStop("TCSQLError() " + TCSQLError())
		EndIf

		//+----------------------------------------------
		//| Avanca para o proximo registro
		//+----------------------------------------------
		dbSelectArea("SZG")
		dbSkip()

	EndDo

	//Cabecalho - SZF
	cLog  := U_FATX011H(3)

	dbSelectArea("SZF")

	RecLock("SZF")
		SZF->ZF_LOG	:= cLog
	SZF->( MsUnlock() )

	RecLock("SZF")
		dbDelete()
	SZF->( MsUnlock() )

//���������������������������������������������������������������������Ŀ
//� CANCELAMENTO                                                        �
//�����������������������������������������������������������������������
ElseIf nOpcUsr == 6

	If fCancelOk( @cLogCancel )

		//Itens - SZG
		dbSelectArea("SZG")
		dbSetOrder(1)
		dbSeek(xFilial("SZG") + M->ZF_NUM)

		While SZG->(!EoF()) .And. xFilial("SZG")+SZG->ZG_NUM == xFilial("SZF")+SZF->ZF_NUM

			//+----------------------------------------------
			//| Atualiza registro da nota fiscal
			//+----------------------------------------------

			cQry := "UPDATE " + RetSqlName("SF2") + ENTER
			cQry += " SET		F2_CARGA = '', F2_VEICUL1 = '' " + ENTER
			cQry += "WHERE		D_E_L_E_T_ = '' " + ENTER
			cQry += "AND 		F2_FILIAL = '" + SZG->ZG_EMPFIL + "' " + ENTER
			cQry += "AND 		F2_DOC = '" + SZG->ZG_NOTA + "' " + ENTER
			cQry += "AND 		F2_SERIE = '" + SZG->ZG_SERIE + "' " + ENTER

			If (TcSQLExec(cQry) < 0)
				Return MsgStop("TCSQLError() " + TCSQLError())
			EndIf

			dbSelectArea("SZG")
			dbSkip()

		EndDo

		//Cabecalho - SZF
		cLog  := U_FATX011H(4)

		dbSelectArea("SZF")
		RecLock("SZF")
			SZF->ZF_STATUS	:= "7"
			SZF->ZF_LOG		:= cLog + cLogCancel
		SZF->( MsUnlock() )

	EndIf

//���������������������������������������������������������������������Ŀ
//� ENTREGA/RETORNO NF ou VALIDACAO RETORNO                             �
//�����������������������������������������������������������������������
ElseIf nOpcUsr == 9 .Or. nOpcUsr == 10

	//Itens - SZG
	dbSelectArea("SZG")
	dbSetOrder(1)

	lNFRet 		:= .F.
	nPRetorno  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_RETORNO"})

	For nX := 1 To Len(aCols)

		If nX <= Len(aRegistro)

			dbGoto(aRegistro[nX])

			RecLock("SZG",.F.)

			If ( aCols[nX][nHeader+1] )
				dbDelete()
			EndIf

	    Else

		  	If !( aCols[nX][nHeader+1] )
		    	RecLock("SZG",.T.)
		   	EndIf

    	EndIf

		If !( aCols[nX][nHeader+1] )

			If ( aCols[nX][nPRetorno] == "1" .And. !lNFRet )
				lNFRet := .T.
			EndIf

			For nZ := 1 To nHeader
				If (aHeader[nZ][10] != "V")
					FieldPut(FieldPos(aHeader[nZ][2]), aCols[nX][nZ])
				EndIf
			Next nZ

			SZG->ZG_FILIAL	:= xFilial("SZG")
			SZG->ZG_NUM	:= M->ZF_NUM

		EndIf

		SZG->( MsUnlock() )

	Next nX

	// Cabecalho - SZF
	cLog  := IIf( nOpcUsr == 9, U_FATX011H(10), U_FATX011H(11) )

	dbSelectArea("SZF")
	RecLock("SZF", .F.)

		SZF->ZF_LOG	:= cLog

    	If nOpcUsr == 9 /* PORTARIA */
    		SZF->ZF_STATUS := "5"

    	ElseIf nOpcUsr == 10 /* EXPEDICAO */

    		If lNFRet
				SZF->ZF_STATUS := "5"
			Else
				SZF->ZF_STATUS := "6"
			EndIf

		EndIf

	SZF->( MsUnlock() )

EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MARKBRWSF2�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Selecao de notas fiscais para composicao da carga          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fMarkBrwSF2(nOpcUsr)

//���������������������������������������������������������������������Ŀ
//� Define variaveis                                                    �
//�����������������������������������������������������������������������
Local aArea      	:= GetArea()

Local aHeader  		:= oGetDados:aHeader
Local aCols   		:= oGetDados:aCols

Local lOk        	:= .F.

Local bOk        	:= {|| lOk:=.T., oDlgMark:End() }
Local bCancel    	:= {|| oDlgMark:End() }
Local aButtons   	:= {}

Local cQry			:= ""

Local aStruMark     := {}
Local aCposMark     := {}

Local cArqMark      := ""
Local cIndMark      := ""
//Local cIndMarC      := ""

Local cWhereSQL     := ""

Local nX            := 0

Local nPItem    	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_ITEM"})
Local nPEmpFil  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPFIL"})
Local nPEmpresa 	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPRESA"})
Local nPNota    	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOTA"})
Local nPSerie   	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_SERIE"})
Local nPCliente 	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_CLIENTE"})
Local nPLoja    	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_LOJA"})
Local nPRzSocial	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOMECLI"})
Local nPPeso    	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_PESO"})
Local nPValor   	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_VALOR"})
Local nPVolume  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_VOLUME"})
Local nPDtEntr  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_DTENTR"})
Local nPRetorno  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_RETORNO"})
Local nPMotReto  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_MOTRETO"})
Local nPObsReto  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_OBSRETO"})
Local nPKM0	  		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_KM0"})
Local nPTM0  		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_TM0"})
Local nPKMX  		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_KMX"})
Local nPTMX  		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_TMX"})
Local nPPorcent  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_PORCENT"})
Local nPMun		  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_MUN"})
Local nPEst  		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EST"})
Local nPCodMun 		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_CODMUN"})

Local aIndApv		:= {}

Local cTmpAlias		:= U_NewAlias()

Local aCores		:= {}

Private oDlgMark    := Nil

Private oMark       := Nil
Private lInverte	:= .F.
Private cMarca		:= GetMark()

Private aCbxPesq	:={"Nota Fiscal + Serie"}// fabio batista
Private cCbxPesq    := ""

Private cGetPesq	:= Space(12)
Private oGetPesq    := ""

//��������������������������������������������������������Ŀ
//� Verifica se foi informado campos chaves ( TIPO/TRANSP) �
//����������������������������������������������������������
If Empty(M->ZF_TIPO)
	MsgStop("Informe o TIPO da carga que esta sendo montada.")
	Return
EndIf

//��������������������������������������������������������Ŀ
//� Verifica se foi informado campos chaves ( TIPO/TRANSP) �
//����������������������������������������������������������
If Empty(M->ZF_VEICULO)
	MsgStop("Informe o VEICULO que ser� utilizado na carga.")
	Return
EndIf

//��������������������������������������������������������Ŀ
//� Verifica modo de abertura do registro                  �
//����������������������������������������������������������
If ( nOpcUsr != 3 .And. nOpcUsr != 4 )
	Return
EndIf

//��������������������������������������������������������Ŀ
//� Ajusta ponteiro do mouse ( Aguarde )                   �
//����������������������������������������������������������
CursorWait()

//��������������������������������������������������������Ŀ
//� Apaga tabela temporaria do banco  P_FATX011            �
//����������������������������������������������������������
If TcCanOpen("P_" + cTmpAlias)
	TcDelFile("P_" + cTmpAlias)
EndIf

//��������������������������������������������������������Ŀ
//� Define script SQL da tabela temporaria P_FATX011       �
//����������������������������������������������������������
cQry := "SELECT * " + ENTER
cQry += "INTO P_" + cTmpAlias + ENTER
cQry += "FROM ( " + ENTER

//+-------------------------------------------
//| Nota Fiscal - MATRIZ
//+-------------------------------------------
If Left(cFilAnt,2) $ "02#03#08#09#10"

	cQry += "		SELECT " + ENTER
	cQry += "			F2_FILIAL+F2_DOC+F2_SERIE [CHAVE], " + ENTER
	cQry += "			F2_FILIAL [EMPFIL],  " + ENTER
	cQry += "			F2_DOC [NOTA],  " + ENTER
	cQry += "			F2_SERIE [SERIE],  " + ENTER
	cQry += "			F2_EMISSAO [EMISSAO],  " + ENTER
	cQry += "			F2_PBRUTO [PESO],  " + ENTER
	cQry += "			F2_VALMERC [VALOR],  " + ENTER
	cQry += "			F2_CLIENTE [CLIENTE],  " + ENTER
	cQry += "			F2_LOJA [LOJA],  " + ENTER
	cQry += "			CASE  " + ENTER
	cQry += "				WHEN F2_TIPO = 'N' THEN A1_NOME " + ENTER
	cQry += "				WHEN F2_TIPO IN ('B','D') THEN A2_NOME " + ENTER
	cQry += "			END [RZSOCIAL], " + ENTER
	cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN A1_MUNE " + ENTER    //Trocado C5_MUNREC
	cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN A2_MUN " + ENTER
	cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
	cQry += "		 		 ELSE A4_MUN " + ENTER
	cQry += "			END [MUN], " + ENTER
	cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN A1_ESTE " + ENTER //Trocado C5_ESTREC
	cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN A2_EST " + ENTER
	cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
	cQry += "		 		 ELSE A4_EST " + ENTER
	cQry += "			END [EST], " + ENTER
	cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN A1_CODMUNE " + ENTER  //Trocado C5_CMUNREC E A1_CODMENT
	cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN A2_COD_MUN " + ENTER
	cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
	cQry += "		 		 ELSE A4_COD_MUN " + ENTER
	cQry += "			END [CODMUN], " + ENTER
	cQry += "			CASE WHEN F2_VOLUME1 != 0 THEN CONVERT(VARCHAR,F2_VOLUME1) + '-' + RTRIM(F2_ESPECI1) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME2 != 0 THEN CONVERT(VARCHAR,F2_VOLUME2) + '-' + RTRIM(F2_ESPECI2) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME3 != 0 THEN CONVERT(VARCHAR,F2_VOLUME3) + '-' + RTRIM(F2_ESPECI3) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME4 != 0 THEN CONVERT(VARCHAR,F2_VOLUME4) + '-' + RTRIM(F2_ESPECI4) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME5 != 0 THEN CONVERT(VARCHAR,F2_VOLUME5) + '-' + RTRIM(F2_ESPECI5) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME6 != 0 THEN CONVERT(VARCHAR,F2_VOLUME6) + '-' + RTRIM(F2_ESPECI6) + ' | ' ELSE '' END +  " + ENTER
	cQry += "			CASE WHEN F2_VOLUME7 != 0 THEN CONVERT(VARCHAR,F2_VOLUME7) + '-' + RTRIM(F2_ESPECI7) + ' | ' ELSE '' END [VOLUME], " + ENTER

	cQry += "			( " + ENTER
	cQry += "				SELECT  " + ENTER
	cQry += "						MIN(SITUACAO) [SITUACAO] " + ENTER
	cQry += "				FROM  " + ENTER
	cQry += "					( " + ENTER
	cQry += "						SELECT  " + ENTER
	cQry += "							'0' SITUACAO " + ENTER
	cQry += "						FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK)" + ENTER
	cQry += "						INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) " + ENTER
	cQry += "							ON	SB1.D_E_L_E_T_ = '' " + ENTER
	cQry += "							AND	B1_FILIAL = '' " + ENTER
	cQry += "							AND	B1_COD = D2_COD " + ENTER
	cQry += "							AND B1_RASTRO <> 'L' " + ENTER
	cQry += "							AND B1_TIPO != 'PA' " + ENTER
	cQry += "						WHERE  " + ENTER
	cQry += "							SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "							AND D2_FILIAL = F2_FILIAL  " + ENTER
	cQry += "							AND	D2_DOC = F2_DOC " + ENTER
	cQry += "							AND	D2_SERIE = F2_SERIE " + ENTER
	cQry += "							AND D2_CLIENTE = F2_CLIENTE " + ENTER
	cQry += "							AND	D2_LOJA = F2_LOJA " + ENTER
	cQry += "							AND	D2_EMISSAO = F2_EMISSAO  " + ENTER

	cQry += "						UNION ALL " + ENTER
	cQry += "						SELECT " + ENTER
	cQry += "							'1' SITUACAO " + ENTER
	cQry += "						FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + ENTER
	cQry += "							INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) " + ENTER
	cQry += "										ON	SB1.D_E_L_E_T_ = ''  " + ENTER
	cQry += "										AND	B1_FILIAL = ''  " + ENTER
	cQry += "										AND	B1_COD = D2_COD  " + ENTER
	cQry += "										AND B1_RASTRO = 'L'  " + ENTER
	cQry += "										AND B1_TIPO = 'PA'  " + ENTER
	cQry += "						WHERE " + ENTER
	cQry += "							SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "							AND D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "							AND	D2_DOC = F2_DOC " + ENTER
	cQry += "							AND	D2_SERIE = F2_SERIE " + ENTER
	cQry += "							AND D2_CLIENTE = F2_CLIENTE " + ENTER
	cQry += "							AND	D2_LOJA = F2_LOJA " + ENTER
	cQry += "							AND	D2_EMISSAO = F2_EMISSAO " + ENTER

	cQry += "						UNION ALL " + ENTER
	cQry += "						SELECT " + ENTER
	cQry += "							'2' SITUACAO " + ENTER
	cQry += "						FROM " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) " + ENTER
	cQry += "							INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) " + ENTER
	cQry += "										ON	SB1.D_E_L_E_T_ = ''  " + ENTER
	cQry += "										AND	B1_FILIAL = ''  " + ENTER
	cQry += "										AND	B1_COD = D2_COD  " + ENTER
	cQry += "										AND B1_RASTRO = 'L'  " + ENTER
	cQry += "										AND B1_TIPO = 'ME'  " + ENTER
	cQry += "						WHERE " + ENTER
	cQry += "							SD2.D_E_L_E_T_ = '' " + ENTER
	cQry += "							AND D2_FILIAL = F2_FILIAL " + ENTER
	cQry += "							AND	D2_DOC = F2_DOC " + ENTER
	cQry += "							AND	D2_SERIE = F2_SERIE " + ENTER
	cQry += "							AND D2_CLIENTE = F2_CLIENTE " + ENTER
	cQry += "							AND	D2_LOJA = F2_LOJA " + ENTER
	cQry += "							AND	D2_EMISSAO = F2_EMISSAO " + ENTER


	cQry += "					) QRY " + ENTER
	cQry += "			) [SITUACAO] " + ENTER
	cQry += "		FROM " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) " + ENTER
	cQry += "		LEFT JOIN " + RetSqlName("SA4") + " AS SA4 WITH (NOLOCK) " + ENTER
	cQry += "				ON	SA4.D_E_L_E_T_ = '' " + ENTER
	cQry += "				AND	A4_FILIAL = '' " + ENTER
	cQry += "				AND	A4_COD = F2_TRANSP " + ENTER
	cQry += "		LEFT JOIN " + RetSqlName("SA1") + " AS SA1 WITH (NOLOCK) " + ENTER
	cQry += "				ON	SA1.D_E_L_E_T_ = ''  " + ENTER
	cQry += "				AND	A1_FILIAL = F2_FILIAL " + ENTER
	cQry += "				AND	A1_COD = F2_CLIENTE " + ENTER
	cQry += "				AND	A1_LOJA = F2_LOJA " + ENTER
	cQry += "		LEFT JOIN " + RetSqlName("SA2") + " AS SA2 WITH (NOLOCK) " + ENTER
	cQry += "				ON	SA2.D_E_L_E_T_ = ''  " + ENTER
	cQry += "				AND	A2_FILIAL = '' " + ENTER
	cQry += "				AND	A2_COD = F2_CLIENTE " + ENTER
	cQry += "				AND	A2_LOJA = F2_LOJA " + ENTER
	cQry += "		WHERE  " + ENTER
	cQry += "			SF2.D_E_L_E_T_ = ''  " + ENTER
	cQry += "			-- APENAS NF EMITIDA NOS ULTIMOS 90 DIAS " + ENTER
	cQry += "			AND F2_EMISSAO >= CONVERT(VARCHAR, GETDATE() - 150, 112)  " + ENTER       //Alterado de -120 para -150 dias

	cQry += "			-- APENAS NF NAO UTILIZADA EM CARGAS ANTERIORES " + ENTER
	cQry += "			AND ( SELECT COUNT(1) FROM " + RetSqlName("SZG") + " AS SZG WITH (NOLOCK) INNER JOIN " + RetSqlName("SZF") + " AS SZF WITH (NOLOCK) ON SZF.D_E_L_E_T_ = '' AND ZG_FILIAL = ZF_FILIAL AND ZG_NUM = ZF_NUM AND ZF_STATUS != '7' WHERE SZG.D_E_L_E_T_ = '' AND ZG_EMPFIL = F2_FILIAL AND ZG_NOTA = F2_DOC AND ZG_SERIE = F2_SERIE AND (ZF_STATUS+ZG_RETORNO) <> '51') = 0 " + ENTER
	cQry += "			-- APENAS NF QUE NAO FOI DEVOLVIDA ( ** DEVOLUCAO TOTAL ** )" + ENTER
	cQry += "			AND ( SELECT COUNT(1) FROM " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) WHERE SD1.D_E_L_E_T_ = '' AND D1_FILIAL = F2_FILIAL AND D1_NFORI = F2_DOC AND D1_SERIORI = F2_SERIE ) = 0  " + ENTER // ( SELECT COUNT(1) FROM SD2020 SD2 WHERE SD2.D_E_L_E_T_ = '' AND D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND	D2_EMISSAO = F2_EMISSAO ) " + ENTER
	//
    If M->ZF_TIPO == "1"
		cQry += "			-- APENAS NF QUE NAO UTILIZE TRANSPORTADORA = RETIRA " + ENTER
		cQry += "			AND F2_TRANSP != '000002'" + ENTER
	ElseIf M->ZF_TIPO == "4" .And. .Not. ( AllTrim(cFilAnt) $ "0106#0107#0108" )
		cQry += "			-- APENAS NF QUE UTILIZE TRANSPORTADORA = RETIRA " + ENTER
		cQry += "			AND F2_TRANSP = '000002'" + ENTER
	EndIf
	cQry += "			AND F2_FILIAL IN ('0200','0803','0901','1001','0902') " + ENTER

EndIf

cQry += "	) SUBQRY " + ENTER

Memowrite("FATX011.SQL", cQry)

TcSQLExec(cQry)

//��������������������������������������������������������Ŀ
//� Monta condicao SQL para nao trazer NF's ja selecionadas�
//����������������������������������������������������������
For nX := 1 To Len(aCols)

	If  !Empty( aCols[nX, nPEmpFil] ) /* .And. !( aCols[nX][nHeader+1] ) */
		cWhereSQL += IIf( Empty(cWhereSQL), "", ", ") +  "'" + aCols[nX, nPEmpFil] + aCols[nX, nPNota] + aCols[nX, nPSerie] + "'" + ENTER
	EndIf

Next nX

If !Empty( cWhereSQL)
	cWhereSQL := "WHERE NOT CHAVE IN (" + cWhereSQL + ")"
EndIf

//��������������������������������������������������������Ŀ
//� Define script SQL                                      �
//����������������������������������������������������������
cQry := " SELECT * FROM P_" + cTmpAlias + Space(1) + cWhereSQL

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

//��������������������������������������������������������Ŀ
//� Define campos do arquivo temporario TRB                �
//����������������������������������������������������������
aStruMark := {}
aadd(aStruMark,{"TR_OK"	   		,"C",02,00})
aadd(aStruMark,{"TR_EMPFIL"		,"C",04,00})
aadd(aStruMark,{"TR_EMPRESA"	,"C",20,00})
aadd(aStruMark,{"TR_NOTA"		,"C",09,00})
aadd(aStruMark,{"TR_SERIE"		,"C",03,00})
aadd(aStruMark,{"TR_CLIENTE"	,"C",06,00})
aadd(aStruMark,{"TR_LOJA"		,"C",02,00})
aadd(aStruMark,{"TR_RZSOCI"		,"C",70,00})
aadd(aStruMark,{"TR_EMISSAO"	,"D",08,00})
aadd(aStruMark,{"TR_PESO"		,"N",12,03})
aadd(aStruMark,{"TR_VALOR"		,"N",14,02})
aadd(aStruMark,{"TR_VOLUME"		,"C",70,00})
//aadd(aStruMark,{"TR_PORCENT"	,"N",12,02})
aadd(aStruMark,{"TR_MUN"		,"C",25,00})
aadd(aStruMark,{"TR_EST"		,"C",02,00})
aadd(aStruMark,{"TR_CODMUN"		,"C",05,00})
aadd(aStruMark,{"TR_STATUS"		,"C",01,00})
aadd(aStruMark,{"TR_SEPUS"		,"C",50,00})

//��������������������������������������������������������Ŀ
//� Define campos do MsSelect                              �
//����������������������������������������������������������
aCposMark := {}
aadd(aCposMark,{"TR_OK"			,,""			,"@!"})
aadd(aCposMark,{"TR_EMPFIL"		,,"Empresa/Fil"	,"@!"})
aadd(aCposMark,{"TR_EMPRESA"	,,"N Fantasia"	,"@!"})
aadd(aCposMark,{"TR_NOTA"		,,"Nota Fiscal"	,"@!"})
aadd(aCposMark,{"TR_SERIE"		,,"Serie"		,"@!"})
aadd(aCposMark,{"TR_CLIENTE"	,,"Cliente"		,"@!"})
aadd(aCposMark,{"TR_LOJA"	   	,,"Loja"		,"@!"})
aadd(aCposMark,{"TR_RZSOCI" 	,,"Rz Social"	,"@!"})
aadd(aCposMark,{"TR_EMISSAO"	,,"Dt Emissao"	,"D"})
aadd(aCposMark,{"TR_PESO"		,,"Peso Bruto"	,"@E 99,999,999.99"})
aadd(aCposMark,{"TR_VALOR"		,,"Valor"		,"@E 99,999,999,999.99"})
aadd(aCposMark,{"TR_VOLUME"		,,"Volume"		,"@!"})
aadd(aCposMark,{"TR_MUN"		,,"Municipio"	,"@!"})
aadd(aCposMark,{"TR_EST"		,,"Estado"		,"@!"})
aadd(aCposMark,{"TR_CODMUN"		,,"Codigo IBGE"	,"@!"})
aadd(aCposMark,{"TR_STATUS"		,,"Situacao"	,"@!"})
//aadd(aCposMark,{"TR_SEPUS"		,,"Separador"	,"@!"})

//��������������������������������������������������������Ŀ
//� Cria arquivo de trabalho temporario (DBF)              �
//����������������������������������������������������������
If Select("TRBMARK") > 0
	TRBMARK->(dbCloseArea())
EndIf

cArqMark := CriaTrab(aStruMark, .T.)
dbUseArea( .T., "DBFCDX", cArqMark, "TRBMARK",.F.,.F.)

//��������������������������������������������������������Ŀ
//� Cria arquivo de indice temporario (IDX)                �
//����������������������������������������������������������
cIndMark := CriaTrab(NIL, .F.)
IndRegua("TRBMARK",cIndMark,"TR_NOTA+TR_SERIE",,,"")
TRBMARK->(dbSetOrder(1))
//cIndMarC := CriaTrab(NIL, .F.)
//IndRegua("TRBMARK",cIndMarC,"TR_CLIENTE+TR_LOJA",,,"")
//TRBMARK->(dbSetOrder(1))


//��������������������������������������������������������Ŀ
//� Popula arquivo temporario                              �
//����������������������������������������������������������
dbSelectArea("QRY")
dbGoTop()
While QRY->(!EoF())

	dbSelectArea("TRBMARK")
	RecLock("TRBMARK", .T.)
		TRBMARK->TR_OK		:= Space(2)
		TRBMARK->TR_EMPFIL	:= QRY->EMPFIL
		TRBMARK->TR_EMPRESA	:= fIDEmpresa(QRY->EMPFIL)
		TRBMARK->TR_NOTA	:= QRY->NOTA
		TRBMARK->TR_SERIE	:= QRY->SERIE
		TRBMARK->TR_CLIENTE	:= QRY->CLIENTE
		TRBMARK->TR_LOJA	:= QRY->LOJA
		TRBMARK->TR_RZSOCI  := QRY->RZSOCIAL
		TRBMARK->TR_EMISSAO	:= StoD(QRY->EMISSAO)
		TRBMARK->TR_PESO	:= QRY->PESO
		TRBMARK->TR_VALOR	:= QRY->VALOR
		TRBMARK->TR_VOLUME	:= QRY->VOLUME
		TRBMARK->TR_MUN		:= QRY->MUN
		TRBMARK->TR_EST		:= QRY->EST
		TRBMARK->TR_CODMUN	:= QRY->CODMUN
		TRBMARK->TR_STATUS	:= QRY->SITUACAO
		
	TRBMARK->( MsUnlock() )

	QRY->(dbSelectArea("QRY"))
	QRY->(dbSkip())

EndDo

dbSelectArea("TRBMARK")
dbGoTop()

//��������������������������������������������������������Ŀ
//� Adiciona coluna de cores ao objeto MsSelect            �
//����������������������������������������������������������
aCores := {}
aAdd(aCores,{"TRBMARK->TR_STATUS == '1'","BR_VERMELHO"})
aAdd(aCores,{"TRBMARK->TR_STATUS == '2'","BR_AMARELO"})
aAdd(aCores,{"TRBMARK->TR_STATUS == '3'","BR_VERDE"	})

//��������������������������������������������������������Ŀ
//� Adiciona botoes na enchoicebar                         �
//����������������������������������������������������������
Aadd( aButtons, {"S4WB011N", {|| fSeparacao()}, "Separa��o...", "Separa��o" , {|| .T.}} )

//��������������������������������������������������������Ŀ
//� Ajusta ponteiro do mouse ( Default )                   �
//����������������������������������������������������������
CursorArrow()

//��������������������������������������������������������Ŀ
//� Cria objetos										   �
//����������������������������������������������������������
DEFINE MSDIALOG oDlgMark TITLE cCadastro + " - Sele��o de Nota Fiscal"  FROM 065, 000 TO 552,786 OF oMainWnd PIXEL

oDlgMark:lCentered	:= .T.
oDlgMark:bInit		:= {|| EnchoiceBar(oDlgMark,bOk,bCancel,,aButtons) }

@ 034, 005 COMBOBOX cCbxPesq ITEMS aCbxPesq SIZE 080,010 PIXEL OF oDlgMark // fabio batista
@ 034, 090 MSGET oGetPesq VAR cGetPesq SIZE 080,010 PIXEL OF oDlgMark  // fabio batista
@ 034, 190 BUTTON "&Pesquisar" SIZE 040, 011  PIXEL ACTION ( fPesqMark( cGetPesq ) ) // fabio batista

oMark 				:= MSSELECT():New("TRBMARK","TR_OK","",@aCposMark,@lInverte,@cMarca,{060,005,242,391},,,oDlgMark,,aCores)
oMark:bMark 		:= {|| fLinOkMark() }
oMark:oBrowse:lCanAllmark := .F.

oDlgMark:ACTIVATE()

If lOk

	//���������������������������������������������������������������������Ŀ
	//|Popula aCols com registros selecionados                              |
	//�����������������������������������������������������������������������
	dbSelectArea("TRBMARK")
	dbGoTop()

	While !EoF()

		If !Empty(TRBMARK->TR_OK)

			//��������������������������������������������������������Ŀ
			//� Verifica se ja nao existe a nota fiscal na carga	   �
			//����������������������������������������������������������
			If aScan(aCols, {|n| n[nPEmpFil]+n[nPNota]+n[nPSerie] == TRBMARK->(TR_EMPFIL+TR_NOTA+TR_SERIE) }) == 0

				//��������������������������������������������������������Ŀ
				//� Adiciona registro no aCols                             �
				//����������������������������������������������������������
				If !Empty( aCols[Len(aCols),nPEmpFil] )
					aAdd(aCols,Array(Len(aHeader)+1))
				EndIf

				aCols[Len(aCols),nPItem]   		:= StrZero(Len(aCols),2)
				aCols[Len(aCols),nPEmpFil]   	:= TRBMARK->TR_EMPFIL
				aCols[Len(aCols),nPEmpresa]  	:= TRBMARK->TR_EMPRESA
				aCols[Len(aCols),nPNota]  		:= TRBMARK->TR_NOTA
				aCols[Len(aCols),nPSerie]     	:= TRBMARK->TR_SERIE
				aCols[Len(aCols),nPCliente] 	:= TRBMARK->TR_CLIENTE
				aCols[Len(aCols),nPLoja]  		:= TRBMARK->TR_LOJA
				aCols[Len(aCols),nPRzSocial]   	:= TRBMARK->TR_RZSOCI
				aCols[Len(aCols),nPPeso]   		:= TRBMARK->TR_PESO
				aCols[Len(aCols),nPValor]  		:= TRBMARK->TR_VALOR
				aCols[Len(aCols),nPVolume]    	:= TRBMARK->TR_VOLUME
				aCols[Len(aCols),nPRetorno]		:= ""
				aCols[Len(aCols),nPMotReto]    	:= ""
				aCols[Len(aCols),nPObsReto]    	:= ""
				aCols[Len(aCols),nPDtEntr]    	:= CtoD("//")
				aCols[Len(aCols),nPKM0]    		:= 0
				aCols[Len(aCols),nPTM0]   	 	:= 0
				aCols[Len(aCols),nPKMX]   	 	:= 0
				aCols[Len(aCols),nPTMX]    		:= 0
				aCols[Len(aCols),nPPorcent]    	:= 100	//TRBMARK->TR_PORCENT
				aCols[Len(aCols),nPMun] 	   	:= TRBMARK->TR_MUN
				aCols[Len(aCols),nPEst]    		:= TRBMARK->TR_EST
				aCols[Len(aCols),nPCodMun] 		:= TRBMARK->TR_CODMUN
				aCols[Len(aCols),(nHeader+1)]	:= .F. //Delete

			EndIf

		EndIf

		dbSkip()

	EndDo

	//��������������������������������������������������������Ŀ
	//� Atualiza objeto GetDados                               �
	//����������������������������������������������������������
	oGetDados:SetArray(aCols, .T.)
	oGetDados:ForceRefresh()

	//���������������������������������������������������������������������Ŀ
	//|Atualiza informacoes de totais ( carga, peso, volume )               |
	//�����������������������������������������������������������������������
	aSoma			:= fSomaItens()
	M->ZF_PESO		:= aSoma[1]
	M->ZF_VALOR		:= aSoma[2]
	M->ZF_VOLUME	:= aSoma[3]

	//���������������������������������������������������������������������Ŀ
	//|Calcula frete previsto                                               |
	//�����������������������������������������������������������������������
	M->ZF_FRETEP	:= U_FATX011W()

	//���������������������������������������������������������������������Ŀ
	//|Atualiza informacoes de aproveitamento                               |
	//�����������������������������������������������������������������������
	aIndApv			:= fIndAprov()
	M->ZF_APVPESO	:= aIndApv[1]
	M->ZF_APVFRET	:= aIndApv[2]

	//��������������������������������������������������������Ŀ
	//� Atualiza objeto MsMGet                                 �
	//����������������������������������������������������������
	//oMsmGet:Refresh()

EndIf

//���������������������������������������������������������������������Ŀ
//|Fecha e elimina arquivos temporarios 								|
//�����������������������������������������������������������������������
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

If Select("TRBMARK") > 0
	TRBMARK->(dbCloseArea())
EndIf

TcSqlExec("DROP TABLE P_"+ cTmpAlias)

If File(cArqMark+GetDBExtension())
	FErase(cArqMark+GetDBExtension())
EndIf

If File(cIndMark+OrdBagExt())
	FErase(cIndMark+OrdBagExt())
EndIf

Ferase(Alltrim(cArqMark) + ".DBF")
Ferase(Alltrim(cArqMark) + ".DTC")
Ferase(Alltrim(cIndMark) + ".CDX")
Ferase(Alltrim(cIndMark))
Ferase(Alltrim(cArqMark))

//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fMarkLinOK�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Validacao e Avisos                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fLinOkMark()

Local aArea		:= GetArea()
Local aAreaTRB	:= TRBMARK->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())

Local cEmpVld	:= SuperGetMV("ES_EMPVLOS",.f.,"") // Empresas que n�o permitem Embarque sem OS Finalizada

Local cEmpMrk	:= SUBSTR(TRBMARK->TR_EMPFIL,1,2)
Local cFilMrk	:= SUBSTR(TRBMARK->TR_EMPFIL,3,2)

//��������������������������������������������������������Ŀ
//� Inicia valida��o Nota Fiscal x Lote x Validade         �
//����������������������������������������������������������
BEGIN SEQUENCE

	If Marked("TR_OK") .And. cEmpMrk+cFilMrk $ cEmpVld

		dbSelectArea("SD2")
		dbSetOrder(3)
		If dbSeek(cFilMrk+TRBMARK->(TR_NOTA+TR_SERIE+TR_CLIENTE+TR_LOJA))
		
			While !SD2->(Eof()) .And. SD2->D2_FILIAL == cFilMrk .and. SD2->D2_DOC == TRBMARK->TR_NOTA .And.;
			  		SD2->D2_SERIE == TRBMARK->TR_SERIE .And. SD2->D2_CLIENTE == TRBMARK->TR_CLIENTE .And. SD2->D2_LOJA == TRBMARK->TR_LOJA
			  		
			  		If !Empty(SD2->D2_ORDSEP)
			  		
			  			dbSelectArea("CB7")
			  			dbSetOrder(1)
			  			If dbSeek(cFilMrk+SD2->D2_ORDSEP) .And. CB7->CB7_STATUS <> '9'
			  				MsgAlert("A Ordem de Separa��o desta nota n�o est� encerrada ." + ENTER +;
			  						 "N�o sera poss�vel emitir o romaneio at� que todas as separa��es sejam conclu�das!")

							dbSelectArea("TRBMARK")
							RecLock("TRBMARK", .F.)
								TRBMARK->TR_OK := Space(2)
							TRBMARK->( MsUnlock() )

			  				Exit		 	
			  			EndIf
			  		
			  		EndIf
			
			  	SD2->(dbSkip())
			End  		 

		EndIf
	EndIf

END SEQUENCE

RestArea( aAreaTRB )
RestArea( aArea )
RestArea( aAreaSD2 )

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IDEMPRESA �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Devolve nome da empresa referente a nota fiscal             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fIDEmpresa( cID )
Local cRet := ""

Do Case

	Case AllTrim(cID) == "0106"
		cRet := "DNT DISTRIBUIDORA"

	Case AllTrim(cID) == "0107"
		cRet := "JAYS TINTAS"

	Case AllTrim(cID) == "0108"
		cRet := "QUALYCOR"

	Case AllTrim(cID) == "0111"
		cRet := "MACRO CORES"

	Case AllTrim(cID) $ "0200#0205"
		cRet := "EURO/MATRIZ"

	Case AllTrim(cID) == "0201"
		cRet := "EURO/REVENDA"

	Case AllTrim(cID) == "0203"
		cRet := "QUALY/COMERCIAL"

	Case AllTrim(cID) == "0204"
		cRet := "EURO/COMERCIAL"

	Case AllTrim(cID) == "0301"
		cRet := "QUALY/MATRIZ"

	Case AllTrim(cID) == "0303"
		cRet := "QUALY/FILIAL-03"

	Case AllTrim(cID) == "0304"
		cRet := "QUALY/FILIAL-04"

	Case AllTrim(cID) == "0801"
		cRet := "QUALYCRIL/MATRIZ"

	Case AllTrim(cID) == "0803"
		cRet := "QUALYCRIL/FILIAL-03"

	Case AllTrim(cID) == "0901"
		cRet := "PHOENIX QUIMICA/FILIAL-01"

	Case AllTrim(cID) == "0902"
		cRet := "PHOENIX QUIMICA/FILIAL-02"

	Case AllTrim(cID) == "1001"
		cRet := "DECOR/FILIAL-01"		
	Otherwise
		cRet := "### DESCONHECIDO ###"

EndCase

Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PESQMARK  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Pesquisa de registro no MarkBrowse de notas fiscais         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fPesqMark( cChave )

dbSelectArea("TRBMARK")
//Private aCbxPesq	:={"Nota Fiscal + Serie","Cliente + Loja"}// fabio batista
//Private cCbxPesq    := ""
If AllTrim(cCbxPesq) == "Nota Fiscal + Serie"
	dbSetOrder(1)
	dbSeek( AllTrim(cChave) )
Else
	//dbSetOrder(2)
	dbSeek( AllTrim(cChave) )
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SOMAITENS �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Soma campos dos itens ( Peso, Valor, Volumes ) e retorna   ���
���          � em formato de array e os valores estao nas posicoes:       ���
���          � Array[1] := Peso Bruto                                     ���
���          � Array[2] := Valor Mercadoria                               ���
���          � Array[3] := Volumes/Especies                               ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fSomaItens()

Local aRet			:= {0,0,""}

Local aHeader  		:= aClone( oGetDados:aHeader )
Local aCols   		:= aClone( oGetDados:aCols )

Local nPVolume		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_VOLUME"})
Local nPPeso		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_PESO"})
Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_VALOR"})

Local nX, nY, nZ	:= 0
Local aAux1, aAux2	:= {}
Local aVolumes		:= {}

//��������������������������������������������������������Ŀ
//� Processa Volumes e Especies                            �
//����������������������������������������������������������
For nX := 1 To Len(aCols)

	If !( aCols[nX][nHeader+1] )

		// Soma Peso Bruto
		aRet[1] +=  aCols[nX, nPPeso]

		// Soma Valor Mercadoria
		aRet[2] +=  aCols[nX, nPValor]

		// Soma Especie/Volume
		aAux1 := StrTokArr( aCols[nX, nPVolume], "|" )

		For nY := 1 To Len(aAux1)

			If !Empty(aAux1[nY])

				aAux2 := StrTokArr( aAux1[nY], "-" )

				nVol  := Val( aAux2[1] )
				cEsp  := AllTrim( aAux2[2] )

				nPos  := Ascan(aVolumes, {|x| cEsp == AllTrim(x[2])})

				If nPos <> 0
				 	aVolumes[nPos, 1] += nVol
				Else
					aAdd(aVolumes, {nVol,cEsp})
				EndIf
			EndIf

		Next nY

	EndIf

Next nX

// Preenche retorno para o item Especie/Volume
For nZ := 1 To Len(aVolumes)
	aRet[3] += cValToChar( aVolumes[nZ,1] ) + "-" + aVolumes[nZ,2] + " | "
Next nZ

Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GAT/INIPAD�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Gatilhos e Inicializadores                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011G(nOpc)

//������������������������������������������������������������������������������������������Ŀ
//| Define variaveis                                                                         |
//��������������������������������������������������������������������������������������������
Local aArea    := GetArea()
Local aAreaSA4 := SA4->(GetArea())

Local xRet     := Nil

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZF_VEICULO                                                                     |
//| Objetivo: Preenche campo ZF_CAPACID conforme cadastro de veiculo ( DA3 )                 |
//��������������������������������������������������������������������������������������������
If nOpc == 1
	xRet := Posicione("DA3",3,xFilial("DA3")+M->ZF_VEICULO,"DA3_CAPACM")
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZF_VEICULO                                                                     |
//| Objetivo: Preenche campo ZF_TRANSP ou ZF_XTRANSP conforme cadastro Transportadora ( SA4 )|
//��������������������������������������������������������������������������������������������
If nOpc == 2 .Or. nOpc == 12

	xRet    := ""

	cPlaca  := IIf( Type("M->ZF_VEICULO") != "U", M->ZF_VEICULO, SZF->ZF_VEICULO )

   	cTransp := Posicione("DA3",3,xFilial("DA3")+cPlaca,"DA3_TRANSP")

	dbSelectArea("SA4")
	dbSetOrder(1)

	If dbSeek(xFilial("SA4")+cTransp)
		xRet := IIf( nOpc == 2, SA4->A4_NOME, SA4->A4_COD )
	EndIf

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_EMPRESA                                                                     |
//| Objetivo: Preencher campo ZG_EMPRESA conforme retorno da funcao IDEmpresa()              |
//��������������������������������������������������������������������������������������������
If nOpc == 3

	xRet := ""

	If !INCLUI

		xRet := fIDEmpresa( SZG->ZG_EMPFIL )

	EndIf

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_NOMECLI                                                                     |
//| Objetivo: Preencher campo ZG_NOMECLI conforme cadastro de cliente ( SA1 )                |
//��������������������������������������������������������������������������������������������
If nOpc == 4

    xRet      := Space(10)

    If !INCLUI

		cIDEmp    := SZG->ZG_EMPFIL
	    cCliFor   := SZG->ZG_CLIENTE
	    cLoja     := SZG->ZG_LOJA
	    cNFDoc    := SZG->ZG_NOTA
	    cNFSerie  := SZG->ZG_SERIE
	    cNFTipo   := ""

	    If !Empty( cCliFor ) .And. !Empty( cLoja )


			cQry := "SELECT F2_TIPO	" + ENTER
			cQry +=	"  FROM	" + RetSqlName("SF2") + ENTER
			cQry +=	" WHERE D_E_L_E_T_ = '' " + ENTER
			cQry +=	"   AND F2_FILIAL = '" + cIDEmp + "' " + ENTER
			cQry +=	"   AND F2_DOC = '" + cNFDoc + "' " + ENTER
			cQry +=	"   AND F2_SERIE = '" + cNFSerie + "' " + ENTER

			If Select("QRY") > 0
				QRY->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY

			If QRY->( !BoF() .And. !EoF() )
				cNFTipo := AllTrim(QRY->F2_TIPO)
			EndIf

			QRY->(dbCloseArea())

			If !Empty( cNFTipo )

				If cNFTipo == "N"

					cQry := "SELECT A1_NOME	CLIFOR " + ENTER
					cQry +=	"  FROM	" + RetSqlName("SA1") + ENTER
					cQry +=	" WHERE D_E_L_E_T_ = '' " + ENTER
					cQry +=	"   AND A1_FILIAL = '" + cIDEmp + "' " + ENTER
					cQry +=	"   AND A1_COD = '" + cCliFor + "' " + ENTER
					cQry +=	"   AND A1_LOJA = '" + cLoja + "' " + ENTER

				ElseIf cNFTipo $ "B#D"

					cQry := "SELECT A2_NOME CLIFOR " + ENTER
					cQry +=	"  FROM	" + RetSqlName("SA2") + " " + ENTER
					cQry +=	" WHERE D_E_L_E_T_ = '' " + ENTER
					cQry +=	"   AND A2_FILIAL = '' " + ENTER
					cQry +=	"   AND A2_COD = '" + cCliFor + "' " + ENTER
					cQry +=	"   AND A2_LOJA = '" + cLoja + "' " + ENTER

				EndIf

				If Select("QRY") > 0
					QRY->(dbCloseArea())
				EndIf

				TCQUERY cQry NEW ALIAS QRY

				If QRY->( !BoF() .And. !EoF() )
					xRet := AllTrim(QRY->CLIFOR)
				EndIf

				QRY->(dbCloseArea())

			EndIf

		EndIf

	EndIf

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZF_FRETEP                                                                      |
//| Objetivo: Preencher campo ZF_APVPESO conforme retorno da funcao INDAPROV()               |
//��������������������������������������������������������������������������������������������
If nOpc == 5

	aIndApv	:= fIndAprov()
	xRet	:= aIndApv[1]

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZF_FRETEP                                                                      |
//| Objetivo: Preencher campo ZF_APVFRET conforme retorno da funcao INDAPROV()               |
//��������������������������������������������������������������������������������������������
If nOpc == 6

	aIndApv := fIndAprov()
	xRet	:= aIndApv[2]

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_DTENTR                                                                      |
//| Objetivo: Preencher campo ZG_RETORNO com "2-NAO" quando informado data de entrega da NF  |
//��������������������������������������������������������������������������������������������
If nOpc == 7
	xRet := "2"
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_DTENTR                                                                      |
//| Objetivo: Preencher campo ZG_MOTRETO com "" quando informado data de entrega da NF       |
//��������������������������������������������������������������������������������������������
If nOpc == 8
	xRet := Space(TamSX3("ZG_MOTRETO")[1])
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_DTENTR                                                                      |
//| Objetivo: Preencher campo ZG_OBSRETO com "" quando informado data de entrega da NF       |
//��������������������������������������������������������������������������������������������
If nOpc == 9
	xRet := Space(TamSX3("ZG_OBSRETO")[1])
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_MUN / ZG_EST / ZG_CODMUN                                                    |
//| Objetivo: Preencher campo ZG_MUN / ZG_EST / ZG_CODMUN conforme endereco de entrega       |
//��������������������������������������������������������������������������������������������
If nOpc == 10 .Or. nOpc == 11 .Or. nOpc == 13

    xRet      := ""

    If !INCLUI

		cIDEmp    := SZG->ZG_EMPFIL
	    cCliFor   := SZG->ZG_CLIENTE
	    cLoja     := SZG->ZG_LOJA
	    cNFDoc    := SZG->ZG_NOTA
	    cNFSerie  := SZG->ZG_SERIE

	    If !Empty( cCliFor ) .And. !Empty( cLoja )

			cQry := "		SELECT " + ENTER
			cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
			cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_MUN FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
			cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
			cQry += "		 		 ELSE A4_MUN " + ENTER
			cQry += "			END [MUN], " + ENTER
			cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
			cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_EST FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
			cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
			cQry += "		 		 ELSE A4_EST " + ENTER
			cQry += "			END [EST], " + ENTER
			cQry += "			CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_CODMUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_CMUNREC " + ENTER
			cQry += "		 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_COD_MUN FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
			cQry += "		 		 WHEN A4_COD = '000002' THEN '' " + ENTER
			cQry += "		 		 ELSE A4_COD_MUN " + ENTER
			cQry += "			END [CODMUN] " + ENTER
			//cQry += "		FROM  SF2" + Subs(cIDEmp,1,2) + "0 SF2  " + ENTER
			cQry += "		FROM  "+RetSqlName("SF2")+" SF2  " + ENTER			
			cQry += "		INNER JOIN " + ENTER
			cQry += "			" + RetSqlName("SA4") + " SA4 " + ENTER
			cQry += "				ON	SA4.D_E_L_E_T_ = '' " + ENTER
			cQry += "				AND	A4_FILIAL = '' " + ENTER
			cQry += "				AND	A4_COD = F2_TRANSP " + ENTER
			cQry += "		WHERE  " + ENTER
			cQry += "			SF2.D_E_L_E_T_ = ''  " + ENTER
			cQry += "			AND	F2_DOC = '" + cNFDoc + "'" + ENTER
			cQry += "			AND	F2_SERIE = '" + cNFSerie + "'" + ENTER
			cQry += "			AND	F2_CLIENTE = '" + cCliFor + "'" + ENTER
			cQry += "			AND	F2_LOJA = '" + cLoja + "'" + ENTER

			If Select("QRY") > 0
				QRY->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY

			If QRY->( !BoF() .And. !EoF() )

				Do Case

					Case nOpc == 10
						xRet := AllTrim(QRY->MUN)

					Case nOpc == 11
						xRet := AllTrim(QRY->EST)

					Case nOpc == 13
						xRet := AllTrim(QRY->CODMUN)

				EndCase

			EndIf

			QRY->(dbCloseArea())

	    EndIf

	 EndIf

EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZF_TIPO / ZF_VEICULO                                                           |
//| Objetivo: Limpa getdados ao alterar o valor do campo ZF_TIPO ou ZF_VEICULO               |
//��������������������������������������������������������������������������������������������
If nOpc == 14
	fMontaGetDados(nOpcObj,3)
	xRet := &(ReadVar())
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ZG_RETORNO                                                                     |
//| Objetivo: Impede de classificar uma nota como entregue qdo existir devolucao             |
//��������������������������������������������������������������������������������������������
If nOpc == 15
	xRet := &(ReadVar())

	If ( nOpcUsr == 9 .Or. nOpcUsr == 10 ) .And. M->ZF_TIPO == "1"

		nPEmpFil	:= aScan(aHeader, {|x| "ZG_EMPFIL" $ x[2]})
		nPNota		:= aScan(aHeader, {|x| "ZG_NOTA" $ x[2]})
		nPSerie		:= aScan(aHeader, {|x| "ZG_SERIE" $ x[2]})
		nPRetorno	:= aScan(aHeader, {|x| "ZG_RETORNO" $ x[2]})

		aHeader  	:= oGetDados:aHeader
		aCols   	:= oGetDados:aCols
		nAT			:= oGetDados:nAT

		cQry := "SELECT	COUNT(1) REGS " + ENTER
		cQry += "FROM	"+RetSqlName("SD1") + ENTER //cQry += "FROM	SD1" + Left( aCols[nAT][nPEmpFil], 2 ) + "0 " + ENTER
		cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
		cQry += "AND	D1_FILIAL = '" + Right( aCols[nAT][nPEmpFil], 2 ) + "' "  + ENTER
		cQry += "AND	D1_NFORI = '" + aCols[nAT][nPNota] + "' " + ENTER
		cQry += "AND	D1_SERIORI = '" + aCols[nAT][nPSerie] + "' " + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		If QRY->REGS > 0

			xRet := "1"

		EndIf

	EndIf


EndIf


//������������������������������������������������������������������������������������������Ŀ
//| Campo   : ?                                                                              |
//| Objetivo: ?                                                                              |
//��������������������������������������������������������������������������������������������
If nOpc == 16
	//Utilizar este codigo para criar o proximo gatilho
EndIf

//������������������������������������������������������������������������������������������Ŀ
//| Restaura area ( Alias, Indice, Registro )                                                |
//��������������������������������������������������������������������������������������������
Restarea( aAreaSA4 )
Restarea( aArea )

Return xRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fTudOK    �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Validacao e Avisos                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fTudOK(nOpcUsr)

//���������������������������������������������������������������������Ŀ
//� Variaveis                                                           �
//�����������������������������������������������������������������������
Local aArea		:= GetArea()

Local lRet		:= .T.

Local aHeader  	:= oGetDados:aHeader
Local aCols   	:= oGetDados:aCols

Local cMsg  	:= ""
Local cQry  	:= ""
Local nx

//���������������������������������������������������������������������Ŀ
//� Validacoes - INCLUSAO / ALTERACAO                                   �
//�����������������������������������������������������������������������
If ( nOpcUsr == 3 .Or. nOpcUsr == 4 )

	//+----------------------------------------------------------------------------
	//|Verifica se os campos obrigatorios foram preenchidos
	//+----------------------------------------------------------------------------
	If lRet
		lRet := Obrigatorio(oMsmGet:aGets,oMsmGet:aTela)
	EndIf

	//+----------------------------------------------------------------------------
	//� Verifica se foi informado o frete previsto para operacao de 1-CARGA
	//+----------------------------------------------------------------------------
	If lRet

		If M->ZF_TIPO == "1" .And. M->ZF_FRETEP <= 0
			lRet := .F.
			MsgStop("A carga selecionada nao possui frete previsto v�lido.")
		EndIF

	EndIf

	//+----------------------------------------------------------------------------
	//� Verifica se existe um veiculo associado a carga            �
	//+----------------------------------------------------------------------------
	If lRet

		cTransp := Posicione("DA3",3,xFilial("DA3")+M->ZF_VEICULO,"DA3_TRANSP")

		If Empty(M->ZF_VEICULO) .Or.;
				!ExistCpo("DA3",M->ZF_VEICULO,3) .Or.;
					 ( M->ZF_TIPO == "1" .And. cTransp == "000002" )

			lRet := .F.
			MsgStop("A carga selecionada nao possui um veiculo de transporte v�lido.")

		EndIf

	EndIf

	//+----------------------------------------------------------------------------
	//|Verifica o tipo da Carga x Transportadora
	//+----------------------------------------------------------------------------
	If lRet

		cTransp := Posicione("DA3",3,xFilial("DA3")+M->ZF_VEICULO,"DA3_TRANSP")

		If AllTrim(cTransp) == "000001" .And. M->ZF_TIPO == "4"
			lRet := .F.
			MsgStop("O tipo de carga n�o pode ser 4-RETIRA para veiculo da propria empresa ( NOSSO CARRO ).")
		EndIf

	EndIf

	//+----------------------------------------------------------------------------
	//|Verifica se ja existe uma carga em processo para o veiculo
	//| ** APENAS REGISTRO DO TIPO 1-CARGA **
	//+----------------------------------------------------------------------------
	If lRet

		If M->ZF_TIPO == "1"

			cQry := "SELECT	ZF_NUM [CARGA]" + ENTER
			cQry += "FROM	" + RetSqlName("SZF") + ENTER
			cQry += "WHERE	D_E_L_E_T_ = ''" + ENTER
			cQry += "AND	ZF_FILIAL = '" + xFilial("SZF") + "'" + ENTER
			cQry += "AND	ZF_VEICULO = '" + M->ZF_VEICULO + "'" + ENTER
			cQry += "AND	ZF_NUM <> '" + M->ZF_NUM + "'" + ENTER
			cQry += "AND	ZF_STATUS IN ('1','2','3')" + ENTER

			If Select("QRY") > 0
				QRY->(dbCloseArea())
			EndIf

			TCQUERY cQry NEW ALIAS QRY

			If QRY->( !EoF() )
				MsgStop("O veiculo j� esta associado a uma carga ( "  + QRY->CARGA + " ) sem romaneio emitido.")
			EndIF

			QRY->(dbCloseArea())

		EndIf

	EndIf

	//+----------------------------------------------------------------------------
	//|Verifica se existe nota fiscal selecionada
	//+----------------------------------------------------------------------------
	If lRet

		lRet        := .F.
		nPDelete	:= (nHeader+1)
		nPEmpFil	:= aScan(aHeader, {|x| "ZG_EMPFIL" $ x[2]})

		For nX := 1 to Len( aCols )
			If !aCols[nX][nPDelete] .And. !Empty( aCols[nX][nPEmpFil] )
				lRet := .T.
				Exit
			EndIf
		Next nX

		If !lRet
			MsgStop("Para  montar uma carga � necess�rio selecionar uma ou mais notas fiscais.")
		EndIf

	EndIf

	//+----------------------------------------------------------------------------
	//| Emite aviso quanto a existencia de containers para retira no cliente
	//+----------------------------------------------------------------------------
	If lRet

		lRet        := .T.
		nPDelete	:= (nHeader+1)
		nPEmpFil	:= aScan(aHeader, {|x| "ZG_EMPFIL" $ x[2]})
		nPCliente	:= aScan(aHeader, {|x| "ZG_CLIENTE" $ x[2]})
		nPLoja		:= aScan(aHeader, {|x| "ZG_LOJA" $ x[2]})
        cWhere01	:= "''"
		cWhere02    := ""
		cWhere03    := ""
		cQry        := ""

		For nX := 1 to Len( aCols )

			If !aCols[nX][nPDelete] .And. !Empty( aCols[nX][nPEmpFil] )

				cWhere01 += ",'" + aCols[nX, nPEmpFil] + aCols[nX, nPCliente] + aCols[nX, nPLoja] + "'"
		EndIf

		Next nX

		If !Empty(cWhere01)
			cWhere01 := "	OR B6_FILIAL+B6_CLIFOR+B6_LOJA IN (" +  cWhere01 + ") " + ENTER
		EndIf

		cQry := " SELECT    CONVERT(VARCHAR, CONVERT(DATETIME, B6_EMISSAO), 103) EMISSAO, " + ENTER
		cQry += " 			B6_PRODUTO PRODUTO, " + ENTER
		cQry += " 			(SELECT B1_DESC FROM " + RetSqlName("SB1") + " WHERE B1_FILIAL = '' AND B1_COD = B6_PRODUTO AND D_E_L_E_T_ = ' ') DESCRICAO, " + ENTER
		cQry += " 			B6_SERIE + '-' + B6_DOC NOTA, " + ENTER
		cQry += " 	     	B6_SALDO SALDO, " + ENTER
		cQry += " 	     	( SELECT A1_COD + '-' + A1_LOJA + ' ' + A1_NOME FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ <> '*' AND A1_FILIAL = B6_FILIAL AND A1_COD = B6_CLIFOR AND A1_LOJA = B6_LOJA ) CLIENTE "
		cQry += " FROM " + RetSqlName("SB6") + " " + ENTER
		cQry += " WHERE	D_E_L_E_T_ <> '*' " + ENTER
		cQry += " 		AND B6_PRODUTO = 'ME.0044' " + ENTER
		cQry += " 		AND B6_SALDO <> 0 " + ENTER
		cQry += " 		AND B6_TIPO = 'E' " + ENTER
		cQry += " 		AND B6_TPCF = 'C' " + ENTER
		cQry += " 		AND B6_EMISSAO < '" + DtoS(dDataBase) + "' " + ENTER
		cQry += "	AND	( 1=2 " + cWhere01 + " )" + ENTER
		cQry += " ORDER BY EMISSAO "

		TCQUERY cQry NEW ALIAS QRY

		dbSelectArea("QRY")
		dbGoTop()

		cMsg := ""

		While !QRY->(EOF())
			cMsg += QRY->EMISSAO + " " + QRY->NOTA + " " + Transform(QRY->SALDO, "@E 9,999.99") + " " + QRY->CLIENTE + ENTER
			QRY->(dbSkip())
		EndDo

		If !Empty(cMsg)
			Aviso("Retira de Containeres", "H� containeres a serem retirados nesse cliente. Segue rela��o abaixo " + ENTER + cMsg, {"Ok"}, 3)
		EndIf

		QRY->(dbCloseArea())

	EndIf


//���������������������������������������������������������������������Ŀ
//� Validacoes - ENTREGA/RETORNO                                        �
//�����������������������������������������������������������������������
ElseIf ( nOpcUsr == 9 .Or. nOpcUsr == 10 ) .And. M->ZF_TIPO == "1" // 1 - CARGA

	lRet      := .T.
	nPDelete	:= (nHeader+1)
	nPNota		:= aScan(aHeader, {|x| "ZG_NOTA" $ x[2]})
	nPSerie		:= aScan(aHeader, {|x| "ZG_SERIE" $ x[2]})
	nPDtEntr	:= aScan(aHeader, {|x| "ZG_DTENTR" $ x[2]})
	nPRetorno	:= aScan(aHeader, {|x| "ZG_RETORNO" $ x[2]})
	nPMotReto	:= aScan(aHeader, {|x| "ZG_MOTRETO" $ x[2]})
	nPObsReto	:= aScan(aHeader, {|x| "ZG_OBSRETO" $ x[2]})

	For nX := 1 to Len( aCols )

		If !aCols[nX][nPDelete]

			If aCols[nX][nPRetorno] == "1"

				If !Empty( aCols[nX][nPDtEntr] )

					MsgStop("A nota fiscal " + AllTrim(aCols[nX][nPSerie]) + "-" + aCols[nX][nPNota] + " esta marcada como retornada e esta com a data de entrega preenchida." + ENTER + ENTER +;
										"Informe o campo 'DT ENTREGA' quando a nota fiscal foi entregue ou preencha o campo 'NF RETORNADA' quando a nota fiscal retornou para empresa."+ ENTER + ENTER +;
										"Nunca preencha os 2 campos numa mesma nota fiscal.")
					lRet := .F.
					Exit

				ElseIf Empty( aCols[nX][nPMotReto] )

					MsgStop("A nota fiscal " + AllTrim(aCols[nX][nPSerie]) + "-" + aCols[nX][nPNota] + " esta marcada como retornada mas nao tem um motivo informado.")
					lRet := .F.
					Exit

				ElseIf /* aCols[nX][nPMotReto] == "4" .And. */ Empty( aCols[nX][nPObsReto] )

					MsgStop("Informe no campo 'OBS RETORNO' a justificativa deste retorno.")
					lRet := .F.
					Exit

				EndIf

			ElseIf aCols[nX][nPRetorno] == "2"


			ElseIf Empty( aCols[nX][nPDtEntr] ) .and. !lPORTASUP

				MsgStop("A nota fiscal " + AllTrim(aCols[nX][nPSerie]) + "-" + aCols[nX][nPNota] + " nao foi classificada como entregue ou retornada.")
				lRet := .F.
				Exit

			EndIf

		EndIf

	Next nX

EndIf


//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������
Restarea( aArea )

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX011H  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Registra acao ( LOG )do usuario no registro de carga        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011H(nOpc,cObs,cUsuario)
Local aArea := GetArea()
Local cLog  := IIf( Type("M->ZF_LOG") != "U", AllTrim(M->ZF_LOG), AllTrim(SZF->ZF_LOG) )
Local cAux  := ""

Default nOpc	 := 0
Default cObs 	 := ""
Default cUsuario := cUsername

Do Case
	Case nOpc == 1
		cAux := "IT01 - INCLUIDO"

	Case nOpc == 2
		cAux  := "IT02 - ALTERADO"

		//������������������������������������������������������������Ŀ
		//� Retira aprovacao do registro                               �
		//��������������������������������������������������������������
		cLog  := StrTran( cLog, "IT05", "ITXX" )
		cLog  := StrTran( cLog, "IT06", "ITXX" )
		cLog  := StrTran( cLog, "IT07", "ITXX" )
		cLog  := StrTran( cLog, "IT08", "ITXX" )
		cLog  := StrTran( cLog, "IT16", "ITXX" )

	Case nOpc == 3
		cAux := "IT03 - EXCLUIDO"

	Case nOpc == 4
		cAux := "IT04 - CANCELADO"

	Case nOpc == 5
		cAux := "IT05 - APROVACAO PESO"

	Case nOpc == 6
		cAux := "IT06 - APROVACAO FRETE"

	Case nOpc == 7
		cAux := "IT07 - IMP SEPARACAO/EMBARQUE"

	Case nOpc == 8
		cAux := "IT08 - IMP ROMANEIO"

	Case nOpc == 9
		cAux := "IT09 - LIBERACAO PORTARIA"

	Case nOpc == 10
		cAux := "IT10 - ENTREGA/RETORNO"

	Case nOpc == 11
		cAux := "IT11 - VALIDACAO ENTR/RETO"

	Case nOpc == 12
		cAux := "IT12 - IMP CANHOTO"

	Case nOpc == 13
		cAux := "IT13 - EMISSAO PAGAMENTO"

	Case nOpc == 14
		cAux := "IT14 - EXCLUSAO PAGAMENTO"

		//������������������������������������������������������������Ŀ
		//� Retira ordem de pagamento do registro                      �
		//��������������������������������������������������������������
		cLog  := StrTran( cLog, "IT13", "ITXX" )

	Case nOpc == 15
		cAux := "IT15 - DIGITALIZADO"

		//������������������������������������������������������������Ŀ
		//� Retira status de digitalizacao anterior                    �
		//��������������������������������������������������������������
		cLog  := StrTran( cLog, "IT15", "ITXX" )

	Case nOpc == 16
		cAux := "IT16 - ROTEIRIZADO"

End Case

cAux := cAux + IIf(!Empty(cObs), + " (" + AllTrim(cObs) + ") ", "")  + " por " + Upper(AllTrim(cUsuario)) + " em " + DtoC(dDataBase) + " " + Time() + ENTER
cLog := cLog + cAux

RestArea(aArea)

Return cLog


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011S �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Relatorio Separacao e Embarque                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011S()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local lReImp	:= .F.
Local cQry		:= ""

If SZF->ZF_TIPO $ "1#4" //1-CARGA; 4-RETIRA

	//���������������������������������������������������������������������Ŀ
	//� Verifica status da carga                                            �
	//�����������������������������������������������������������������������
	If lRet

		If .Not. SZF->ZF_STATUS $ "1#2"
			MsgStop("A carga selecionada n�o esta na etapa para emissao de separacao e embarque.")
			lRet := .F.
		EndIf

	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica se existem NFs vinculada a carga                  �
	//��������������������������������������������������������������
	If lRet

		cQry := "SELECT " + ENTER
		cQry += "	COUNT(1) REGS " + ENTER
		cQry += "FROM " + RetSqlName("SZG") + ENTER
		cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
		cQry += "AND	ZG_FILIAL = '" + xFilial("SZG") + "' " + ENTER
		cQry += "AND	ZG_NUM = '" + SZF->ZF_NUM + "' " + ENTER
		cQry += "AND	ZG_NOTA <> '' " + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		If QRY->REGS == 0
			MsgStop("A carga selecionada n�o tem nenhuma nota fiscal vinculada para emissao da ordem de separacao e embarque.")
			lRet := .F.
		EndIf

		QRY->(dbCloseArea())

	EndIf

	If lRet

		//������������������������������������������������������������Ŀ
		//� Verifica se ordem de separacao ja foi impresso             �
		//��������������������������������������������������������������
		If AT("IT07", SZF->ZF_LOG) > 0
			lReImp := MsgYesNo("A ordem de separacao e embarque ja foi impressa anteriormente para a carga selecionada." + ENTER + ENTER +;
								"Confirma a reimpressao do documento?", "A T E N C A O")
		EndIf

		//������������������������������������������������������������Ŀ
		//� Processa relatorio                                         �
		//��������������������������������������������������������������
		If AT("IT07", SZF->ZF_LOG) == 0 .Or. lReImp
			U_FATR065( SZF->ZF_NUM )
		EndIf

		//������������������������������������������������������������Ŀ
		//� Atualiza Status / Log  do registro                         �
		//��������������������������������������������������������������
		cLog  := U_FATX011H(7, IIf( lReImp, "( REIMPRESSAO )", "" ))

		dbSelectArea("SZF")
		RecLock("SZF", .F.)
			SZF->ZF_STATUS	:= "2" // -> CARREGANDO
			SZF->ZF_LOG	:= cLog
		SZF->( MsUnlock() )

	EndIf

EndIf

//������������������������������������������������������������Ŀ
//� Restaura area anterior									   �
//��������������������������������������������������������������
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IndAprov  �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Retorna o indice de aproveitamento da carga e frete         ���
���          �                                                            ���
���          �Array[1] = Carga                                            ���
���          �Array[2] = Frete                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fIndAprov()

Local aRet			:= {}
Local aSoma         :={}

Local nApvPeso		:= 0
Local nApvFrete		:= 0

Local nPeso         := 0
Local nValor        := 0

Local lMemoria		:= ( Type("M->ZF_NUM") <> "U" )

If .Not. lMemoria

	//���������������������������������������������������������������������Ŀ
	//� Calcula aproveitamento de Peso/Frete baseado nos dados do arquivo   �
	//�����������������������������������������������������������������������
	If SZF->ZF_TIPO == "1" //1-CARGA
		nApvPeso := Round( ( ( SZF->ZF_PESO / SZF->ZF_CAPACID ) * 100 ), 2 )
		nApvFrete := Round( ( ( ( SZF->ZF_FRETEP - SZF->ZF_DESCFRT + SZF->ZF_ACREFRT  ) / SZF->ZF_VALOR ) * 100 ), 2 )
	EndIf

Else

	//���������������������������������������������������������������������Ŀ
	//� Calcula aproveitamento de Peso/Frete baseado nos dados de memoria   �
	//�����������������������������������������������������������������������
	If M->ZF_TIPO == "1" //1-CARGA

		aSoma  := fSomaItens()

		nPeso  := aSoma[1]
		nValor := aSoma[2]

		If nPeso != 0
			nApvPeso := Round( ( ( nPeso / M->ZF_CAPACID ) * 100 ), 2 )
		EndIf

		If nValor != 0
			nApvFrete := Round( ( ( ( M->ZF_FRETEP - M->ZF_DESCFRT + M->ZF_ACREFRT ) / nValor ) * 100 ), 2 )
		EndIf

	EndIf

EndIf

//���������������������������������������������������������������������Ŀ
//� Retorno da Funcao                                                   �
//�����������������������������������������������������������������������
aAdd( aRet, nApvPeso )
aAdd( aRet, nApvFrete )

Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011R �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Relatorio - Romaneio de Expedicao                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011R()
Local aArea		:= GetArea()
Local aAreaSZF	:= SZF->( GetArea() )
Local cQry		:= ""
Local cMsg		:= ""
Local aIndApv	:= fIndAprov()
Local nFrete	:= aIndApv[2]
Local lFrete	:= ( aIndApv[2] > 05 .And. At( "IT06", SZF->ZF_LOG ) == 0 ) // Regra - Aproveitamento de frete maior que 5%

BEGIN SEQUENCE

	//������������������������������������������������������������Ŀ
	//� Verifica qual o tipo da carga                              �
	//��������������������������������������������������������������
	If .Not. SZF->ZF_TIPO $ "1#4" //1-CARGA; 4-RETIRA

		MsgStop("O tipo da carga selecionada nao emite romaneio")
		Break

	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica qual status atual da carga                        �
	//��������������������������������������������������������������
	If ( SZF->ZF_TIPO == "1" .AND. .NOT. SZF->ZF_STATUS $ "1#2") .OR.;
			( SZF->ZF_TIPO == "4" .AND. .NOT. SZF->ZF_STATUS $ "1#2" )

		MsgStop("A carga selecionada nao esta na etapa para emissao do romaneio.")

		If SZF->ZF_STATUS $ "3" .And. Upper(AllTrim(cUserName)) $ Alltrim(cConteudo)

			If !MsgYesNo("Romaneio ja emitido para a carga selecionada selecionada. Deseja reimprimir?", "Impress�o Romaneio")
				Break
			EndIf

		Else

			Break

		EndIf

	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica se o romaneio ja foi impresso anteriormente       �
	//��������������������������������������������������������������
	If AT("IT08", SZF->ZF_LOG) > 0 .And. !Upper(AllTrim(cUserName)) $ Alltrim(cConteudo) //!U_IsGroup("Administradores")

		MsgStop("Romaneio ja emitido para a carga selecionada selecionada." + ENTER +;
							"Reimpress�o nao autorizada para este documento.")
		Break

	EndIf

	//������������������������������������������������������������Ŀ
	//� Verifica se o veiculo associado a carga ja esta em transito�
	//��������������������������������������������������������������
	If SZF->ZF_TIPO == "1"

		cQry := "SELECT	ZF_NUM [CARGA]" + ENTER
		cQry += "FROM	" + RetSqlName("SZF") + ENTER
		cQry += "WHERE	D_E_L_E_T_ = ''" + ENTER
		cQry += "AND	ZF_FILIAL = '" + xFilial("SZF") + "'" + ENTER
		cQry += "AND	ZF_VEICULO = '" + SZF->ZF_VEICULO + "'" + ENTER
		cQry += "AND	ZF_STATUS IN ('4')" + ENTER

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY

		If QRY->( !EoF() )

			MsgStop("O romaneio nao pode ser impresso porque o veiculo associado encontra-se em transito com a carga " + QRY->CARGA + ".")
			//Break

		EndIF

		QRY->(dbCloseArea())

	EndIf

	//+--------------------------------------------------
	//| REGRA PARA REGISTROS DE TIPO CARGA
	//+--------------------------------------------------
	If SZF->ZF_TIPO == "1"

		//������������������������������������������������������������Ŀ
		//� Verifica se a transportadora � diferente de 'NOSSO CARRO'  �
		//��������������������������������������������������������������


			//������������������������������������������������������������Ŀ
			//� Verifica se o frete/peso esta dentro da regra              �
			//��������������������������������������������������������������
			If lFrete /* .Or. lPeso */

				//������������������������������������������������������������Ŀ
				//� Ajusta mensagem de exibicao com motivo da restricao        �
				//��������������������������������������������������������������
				cMsg += IIf( lFrete, "- Aproveitamento de frete maior que 5% (" + cValToChar(nFrete) + ")do valor total da mercadoria" + ENTER, "" )


				If !Empty(cMsg)
					cMsg := "Motivo:" + ENTER + cMsg
				EndIf

				//������������������������������������������������������������Ŀ
				//� Exibe mensagem ao usuario                                  �
				//��������������������������������������������������������������
				MsgStop("A carga selecionada nao esta autorizada a emitir o romaneio." + ENTER + ENTER + cMsg)

				//������������������������������������������������������������Ŀ
				//� Encerra execucao da funcao                                 �
				//��������������������������������������������������������������
				Break

			EndIf
	EndIf

	
	//������������������������������������������������������������Ŀ
	//� Atualiza Status / Log do registro                          �
	//��������������������������������������������������������������
	cLog	:= U_FATX011H(8)

	If SZF->ZF_TIPO == "1"

		//+--------------------------------------------------
		//| CARGA
		//+--------------------------------------------------

		dbSelectArea("SZF")
		RecLock("SZF", .F.)
			SZF->ZF_LOG		:= cLog
			SZF->ZF_STATUS	:= IIf( AllTrim(cFilAnt) $ "0106#0107#0108", "4", "3" )
		SZF->( MsUnlock() )
		
	ElseIf SZF->ZF_TIPO == "4"

		//+--------------------------------------------------
		//| RETIRA
		//+--------------------------------------------------

		If ( AllTrim(cFilAnt) $ "0106#0107#0108" ) .Or. ( SZF->ZF_PESO <= 50 )

			dbSelectArea("SZF")
			RecLock("SZF", .F.)
				SZF->ZF_LOG		:= cLog
				SZF->ZF_STATUS	:= "6"
			SZF->( MsUnlock() )

			dbSelectArea("SZG")
			dbSetOrder(1)
			dbSeek(xFilial("SZG")+SZF->ZF_NUM)
			While SZG->( !EoF() ) .And. SZG->( ZG_FILIAL+ZG_NUM ) == xFilial("SZG")+SZF->ZF_NUM

				RecLock("SZG", .F.)
					SZG->ZG_DTENTR	:= dDatabase
					SZG->ZG_RETORNO	:= "2"
					SZG->ZG_OBSRETO := ""
				SZG->( MsUnlock() )

				SZG->( dbSkip() )

			EndDo

		Else

			dbSelectArea("SZF")
			RecLock("SZF", .F.)
				SZF->ZF_LOG		:= cLog
				SZF->ZF_STATUS	:= "3"
			SZF->( MsUnlock() )

		EndIf

	EndIf

	//������������������������������������������������������������Ŀ
	//� Processa relatorio                                         �
	//��������������������������������������������������������������
	U_FATR068( SZF->ZF_NUM )

END SEQUENCE

//������������������������������������������������������������Ŀ
//� Fecha workarea temporario                                  �
//��������������������������������������������������������������
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

//������������������������������������������������������������Ŀ
//� Restaura area anterior ao processamento                    �
//��������������������������������������������������������������
Restarea( aAreaSZF )
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011P �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Aprova��o da carga ( PESO MINIMO 80% )                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011P()
//���������������������������������������������������������������������Ŀ
//� Variaveis                                                           �
//�����������������������������������������������������������������������
Local aArea      := GetArea()
Local aAreaSZF   := SZF->( GetArea() )

Local aIndApv    := {}
Local nPeso      := 0

Local lUserDIR   := Upper(AllTrim(cUserName)) $ "ADMINISTRADOR#CAROLINE.MONEA#THIAGO.MONEA" //U_IsGroup("Administradores#DIR-X00")

Local cMsg		 := ""

//���������������������������������������������������������������������Ŀ
//� Verifica status da carga                                            �
//�����������������������������������������������������������������������
If .Not. SZF->ZF_STATUS $ "2"
	MsgStop("A carga selecionada n�o esta na etapa de aprova��o.")
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� Calcula Aproveitamento da Carga                                     �
//�����������������������������������������������������������������������
aIndApv := fIndAprov()
nPeso   := aIndApv[1]

//���������������������������������������������������������������������Ŀ
//� Verifica se a carga esta fora da regra de peso ou frete             �
//�����������������������������������������������������������������������
If nPeso < 80

	If At("IT05", SZF->ZF_LOG) == 0

		If lUserDIR

			//���������������������������������������������������������������������Ŀ
			//� Atualiza log do registro                                            �
			//�����������������������������������������������������������������������
			cLog  := U_FATX011H(5, cValToChar(nPeso) + "%")

			dbSelectArea("SZF")
			RecLock("SZF", .F.)
				SZF->ZF_LOG := cLog
			SZF->( MsUnlock() )

			//���������������������������������������������������������������������Ŀ
			//� Dispara alerta via gerenciador para usuarios do grupo EXP-X00       �
			//�����������������������������������������������������������������������
		 	cMsg := '"(Autoriza��o - Montagem de Carga)' + ENTER
		 	cMsg += 'De: ' + cUserName + ENTER
			cMsg += 'AVISO: A autorizacao para utilizacao da capacidade do veiculo abaixo de 80% ( ' + cValToChar(SZF->ZF_APVPESO) + '% ) foi concedida para a carga ' + SZF->ZF_NUM + '. Favor verificar!"' + ENTER
			//WinExec(cPath + Space(1) + U_GetUserGp("EXP-X00") + Space(1) + cMsg, 0)

		Else

			//���������������������������������������������������������������������Ŀ
			//� Chama rotina padrao do programa LIBSMS                              �
			//�����������������������������������������������������������������������
			U_SMSMarkBrw( "001", 5 )

		EndIf

	Else

		MsgStop("A carga selecionada j� recebeu a aprova��o de peso.")
		Return

	EndIf

Else

	MsgStop("A carga selecionada n�o necessita de aprova��o de peso.")
	Return

EndIf

//���������������������������������������������������������������������Ŀ
//� Restaura area anterior                                              �
//�����������������������������������������������������������������������
RestArea( aAreaSZF )
RestArea( aArea )

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011F �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Aprova��o da carga ( FRETE MAIOR QUE 5% )                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011F()
//���������������������������������������������������������������������Ŀ
//� Variaveis                                                           �
//�����������������������������������������������������������������������
Local aArea      := GetArea()
Local aAreaSZF   := SZF->( GetArea() )

Local aIndApv    := {}
Local nFrete     := 0

Local cUserDIR1  := "ADMINISTRADOR,CAROLINE.MONEA,THIAGO.MONEA,ROBSON.MORAES,ANTONIO.BARBOSA,CARLOS.ARAUJO"		//Retirado Alexandre.Martins em 23/03/18 U_IsGroup("Administradores#DIR-X00")
Local cUserDIR2  := "JEAN.BLASQUES,LUIS.HENRIQUE,AURIEL.FANCHINI,JORGE.RAIMUNDO,SAMUEL.OLIVEIRA,IGOR.SILVA,LEONARDO.JESUS" 	// Geronimo em 24/07/23 de acordo com o chamado 000674 e solicita��o de Samuel.Oliveira e carlos.araujo, concedi a estes usu�rios, tamb�m o direito aprova��o de frete acima de 5%.

Local lUserDIR   := Upper(AllTrim(cUserName)) $ cUserDIR1
Local lUserCON   := Upper(AllTrim(cUsername)) $ "ADMINISTRADOR,CAROLINE.MONEA,THIAGO.MONEA,LUIZ.SILVA"

Local cMsg		 := ""

If ! lUserDIR		// Caso o usuario n�o esteja na lista anterior dos que podem aprovar carga acima do limite, verifico tambem se ele est� na lista abaixo,
	lUserDIR   := Upper(AllTrim(cUserName)) $ cUserDIR2		// Geronimo em 24/07/23 de acordo com o chamado 000674 e solicita��o de Samuel.Oliveira e carlos.araujo, concedi a estes usu�rios, tamb�m o direito aprova��o de frete acima de 5%.
Endif

//���������������������������������������������������������������������Ŀ
//� Verifica tipo da carga                                            �
//�����������������������������������������������������������������������
If SZF->ZF_TIPO != "1"
	MsgStop("O tipo de carga do registro selecionado n�o necessita de aprova��o de frete.")
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� Verifica status da carga                                            �
//�����������������������������������������������������������������������
If .Not. SZF->ZF_STATUS $ "1#2#8"
	MsgStop("A carga selecionada n�o esta na etapa de aprova��o.")
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� Calcula Aproveitamento da Carga                                     �
//�����������������������������������������������������������������������
aIndApv := fIndAprov()
nFrete  := aIndApv[2]

//���������������������������������������������������������������������Ŀ
//� Verifica se a carga esta fora da regra de peso ou frete             �
//�����������������������������������������������������������������������
If nFrete > 5

	If At("IT06", SZF->ZF_LOG) == 0

		If ( nFrete <= 7 .And. lUserCON ) .Or. lUserDIR

			//���������������������������������������������������������������������Ŀ
			//� Atualiza log do registro                                            �
			//�����������������������������������������������������������������������
			cLog  := U_FATX011H(6, cValToChar(nFrete) + "%")

			dbSelectArea("SZF")
			RecLock("SZF", .F.)
				SZF->ZF_LOG := cLog
			SZF->( MsUnlock() )

			//���������������������������������������������������������������������Ŀ
			//� Dispara alerta via gerenciador para usuarios do grupo EXP-X00       �
			//�����������������������������������������������������������������������
		 	cMsg := '"(Autoriza��o - Montagem de Carga)' + ENTER
		 	cMsg += 'De: ' + cUserName + ENTER
			cMsg += 'AVISO: A autorizacao para frete acima de 5% ( ' + cValToChar(SZF->ZF_APVFRET) + '% ) foi concedida para a carga ' + SZF->ZF_NUM + '. Favor verificar!"' + ENTER
			//WinExec(cPath + Space(1) + cUserCIC + Space(1) + cMsg, 0)

			//���������������������������������������������������������������������Ŀ
			//� Avisa usuario aprovador                                             �
			//�����������������������������������������������������������������������
			ApMsgInfo("Aprova��o feita com sucesso para a carga " + SZF->ZF_NUM + ".")

		Else
			//U_SMSMarkBrw( "002", IIf( nFrete > 7, 5, 1 ) )		// Chama rotina padrao do programa LIBSMS que envia SMS para aprova��o da carga
			Help(NIL, NIL, "FATX011-FATX011F", NIL, OemToAnsi("O seu usu�rio do Protheus n�o tem permiss�o para efetuar esta aprova��o de carga. ")  , 1, 1, NIL, NIL, NIL, NIL, .F., { "Os usu�rios com este acesso s�o os listados abaixo: " +ENTER+ cUserDIR1 +ENTER+ cUserDIR2 }) 
		EndIf

	Else

		MsgStop("A carga selecionada j� recebeu a aprova��o de frete.")
		Return

	EndIf

Else

	MsgStop("A carga selecionada n�o necessita de aprova��o de frete.")
	Return

EndIf

//���������������������������������������������������������������������Ŀ
//� Restaura area anterior                                              �
//�����������������������������������������������������������������������
RestArea( aAreaSZF )
RestArea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011D �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Digitalizacao do Comprovante de Entrega                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011D()

Local aArea		:= GetArea()
Local lUsrDoc	//:= Upper(AllTrim(cUserName)) $ "ADMINISTRADOR#CAROLINE.MONEA#THIAGO.MONEA#CARLOS.ARAUJO#REGIANE.TAQUETTE#JOSE.FERNANDES#ELIAS.NOVAIS#JESSICA.FREITAS#HELLEN.VALADAO#ANTONIO.MARCOS"	//U_IsGroup("Administradores#EXP-X00#VEN-D06#VEN-D07#VEN-D08")

lUsrDoc	:= Upper(AllTrim(cUserName)) $ Alltrim(cConteudo)	//U_IsGroup("Administradores#EXP-X00#VEN-D06#VEN-D07#VEN-D08")


Begin Sequence

	If !lUsrDoc
		MsgStop("Opcao nao disponivel para seu usuario.")
		Break
	EndIf

	cLog := U_FATX011H(15)

	If !U_GENA006( SZF->(RECNO()), "SZF" )
		cLog := StrTran( cLog, "IT15", "ITXX" )
	EndIf

	dbSelectArea("SZF")
	RecLock("SZF", .F.)
		SZF->ZF_LOG := cLog
	SZF->( MsUnlock() )

End Sequence

Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fAviso   �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Exibe mensagem para o usuario                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fAviso( cTit, cMsg, cUrl )
Local oDlga
Local oFontLoc
Local oGet

Default cTit := "Informa��o"
Default cMsg := ""
Default cUrl := ""

oFontLoc := TFont():New("Courier New",,-12)

DEFINE MSDIALOG oDlga TITLE cTit FROM 065,000 TO 432,486 PIXEL

	oGet := TMultiGet():New(003,004,bSetGet(cMsg),oDlgA,237,165,oFontLoc,,,,,.T.,,,,,,.T.)
	oGet:EnableHScroll(.T.)
	oGet:lWordWrap := .F.

	If !Empty( cUrl )
		@ 171,144 Button "Mapa" Size 037,012 PIXEL OF oDlga ACTION ( ShellExecute("open", cUrl,"","", 1 ) )
	EndIf

	@ 171,197 Button "Fechar" Size 037,012 PIXEL OF oDlga ACTION ( oDlga:End()	)

ACTIVATE MSDIALOG oDlga Centered

oFontLoc:End()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011K �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �Converte metros em quilometros                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011K( cIdCarga )

Local aArea			:= GetArea()

Default cIdCarga	:= ""

dbSelectArea("SZF")
dbSetOrder(1)
dbGoTop()

If !Empty( cIdCarga )

	dbSeek( xFilial("SZF")+cIdCarga )

	If SZF->( Found() ) .And. SZF->ZF_TIPO == "1"
		MsgRun("Processando carga " + SZF->ZF_NUM, "FATX011K", {|| U_FATX011Z() })
	EndIf

Else

	While !EoF()

		If SZF->ZF_TIPO != "1"
			dbSkip()
			Loop
		EndIf

		MsgRun("Processando carga " + SZF->ZF_NUM, "FATX011K", {|| U_FATX011Z() })

		dbSelectArea("SZF")
		dbSkip()

	EndDo

EndIf

Restarea( aArea )

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011W �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � ROTERIZACAO E CALCULO DE FRETE PREVISTO                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011W()

//��������������������������������������������������������Ŀ
//� Variaveis                                              �
//����������������������������������������������������������
Local aArea		:= GetArea()
Local aAreaZZ8	:= ZZ8->(GetArea())

Local aHeader  	:= oGetDados:aHeader
Local aCols   	:= oGetDados:aCols

Local nPEmpFil	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_EMPFIL"})
Local nPNota  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_NOTA"})
Local nPSerie  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_SERIE"})
Local nPKm0		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_KM0"})
Local nPTm0  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_TM0"})
Local nPKmX		:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_KMX"})
Local nPTmX  	:= aScan(aHeader,{|x| AllTrim(x[2])=="ZG_TMX"})

Local aEmpNF	:= {}

Local cQry		:= ""

Local oError	:= Nil

Local nRet		:= 0

Local cEndAnt	:= ""

Local nQtdeEnt	:= 0

Local nKm		:= 0
Local nTm		:= 0

Local cUrl		:= ""
Local cXml		:= ""

Local cMailBody	:= ""

Local nGMaps	:= 0
Local lGMaps	:= .F.
Local nX, nZ

Begin Sequence

	//�����������������������������������������������������������������������Ŀ
	//� Ajusta ponteiro do mouse ( HourGlass )                                �
	//�������������������������������������������������������������������������
	CursorWait()

	//�����������������������������������������������������������������������Ŀ
	//� Valida qual o tipo da carga                                           �
	//�������������������������������������������������������������������������
	If M->ZF_TIPO != "1"
		nRet := M->ZF_FRETEP
		Break
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//� Monta script SQL                                                      �
	//�������������������������������������������������������������������������
	For nX := 1 To Len(aCols)

		// Considera apenas registro NAO marcado como deletado
		If .Not. aCols[nX, (Len(aHeader)+1)] .And. .Not. Empty( aCols[nX, nPEmpFil] )

			nPosEmp := aScan(aEmpNF, {|x| AllTrim(x[1]) == aCols[nX, nPEmpFil]})

			If nPosEmp == 0
				aAdd(aEmpNF, {aCols[nX, nPEmpFil], "'" + aCols[nX, nPEmpFil] + AllTrim(aCols[nX, nPNota]) + AllTrim(aCols[nX, nPSerie]) + "'"})
			Else
				aEmpNF[nPosEmp,2] := aEmpNF[nPosEmp,2] + ", '" + aCols[nX, nPEmpFil] + AllTrim(aCols[nX, nPNota]) + AllTrim(aCols[nX, nPSerie]) + "'"
			EndIf
		EndIf

	Next nX

	If Len(aEmpNF) == 0
		Break
	EndIf

	aSort( aEmpNF,,,{|x,y| x[1] < y[1]} )

	For nX := 1 To Len(aEmpNF)

		If !Empty(cQry)
			cQry += "------------------------------" + ENTER
			cQry += "UNION ALL                     " + ENTER
			cQry += "------------------------------" + ENTER
		EndIf

		cQry += "SELECT " + ENTER
		cQry += "	F2_FILIAL+F2_DOC+F2_SERIE [CHAVE], " + ENTER
		cQry += "	F2_SERIE + F2_DOC [NFISCAL], " + ENTER
		cQry += "	F2_TRANSP [TRANSP], " + ENTER
		cQry += "	CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_CEPE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_CEPREC
		cQry += " 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_CEP FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
		cQry += "		 WHEN A4_COD = '000002' THEN '' " + ENTER
		cQry += "		 ELSE A4_CEP " + ENTER
		cQry += "	END [CEP], " + ENTER
		cQry += "	CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_ENDENT FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER	//RTRIM(C5_ENDREC) " + ENTER
		cQry += " 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_END FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
		cQry += "		 WHEN A4_COD = '000002' THEN '' " + ENTER
		cQry += "		 ELSE A4_END " + ENTER
		cQry += "	END [ENDER], " + ENTER
		cQry += "	CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_MUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA )) " + ENTER		//C5_MUNREC
		cQry += " 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_MUN FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
		cQry += "		 WHEN A4_COD = '000002' THEN '' " + ENTER
		cQry += "		 ELSE A4_MUN " + ENTER
		cQry += "	END [MUN], " + ENTER
		cQry += "	CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_ESTE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_ESTREC
		cQry += " 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_EST FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
		cQry += "		 WHEN A4_COD = '000002' THEN '' " + ENTER
		cQry += "		 ELSE A4_EST " + ENTER
		cQry += "	END [EST], " + ENTER
		cQry += "	CASE WHEN A4_COD = '000001' AND F2_TIPO = 'N' THEN RTRIM(( SELECT A1_CODMUNE FROM " + RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' AND A1_FILIAL = F2_FILIAL AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA ))  " + ENTER	//C5_CMUNREC
		cQry += " 		 WHEN A4_COD = '000001' AND F2_TIPO IN ('B','D') THEN ( SELECT A2_COD_MUN FROM " + RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' AND A2_FILIAL = '' AND A2_COD = F2_CLIENTE AND A2_LOJA = F2_LOJA ) " + ENTER
		cQry += "		 WHEN A4_COD = '000002' THEN '' " + ENTER
		cQry += "		 ELSE A4_COD_MUN " + ENTER
		cQry += "	END [CODMUN]	 " + ENTER
		cQry += "FROM " + ENTER
		cQry += "	" + RetSqlName("SF2") + " SF2 " + ENTER
		cQry += "INNER JOIN " + ENTER
		cQry += "	" + RetSqlName("SA4") + " SA4 " + ENTER
		cQry += "		ON	SA4.D_E_L_E_T_ = '' " + ENTER
		cQry += "		AND	A4_FILIAL = '' " + ENTER
		cQry += "		AND	A4_COD = F2_TRANSP " + ENTER
		cQry += "WHERE " + ENTER
		cQry += "	F2_FILIAL = '" + aEmpNF[nX, 1] + "' AND " + ENTER
		cQry += "	SF2.D_E_L_E_T_ = '' " + ENTER
		cQry += "	AND	F2_FILIAL+F2_DOC+F2_SERIE IN (" + aEmpNF[nX, 2] + ")" + ENTER

	Next nX

	cQry += "ORDER BY " + ENTER
	cQry += "	CEP " + ENTER

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQUERY cQry NEW ALIAS QRY

	dbSelectArea("QRY")
	dbGoTop()

	If QRY->( EoF() )
		Break
	EndIf

	//�����������������������������������������������������������������������Ŀ
	//� Inicializa matriz aRota                                               �
	//�������������������������������������������������������������������������
	aRota := {}

	//�����������������������������������������������������������������������Ŀ
	//� Popula matriz aRota com os enderecos de entrega                       �
	//�������������������������������������������������������������������������
	aAdd(aRota, {	0,;
					AllTrim(SM0->M0_CEPENT)+AllTrim(SM0->M0_ESTENT),;
					0,;
					0,;
					0,;
					0,;
					"",;
					AllTrim(SM0->M0_CIDCOB),;
					AllTrim(SM0->M0_ESTENT),;
					AllTrim(SM0->M0_ENDCOB)+"#"+AllTrim(SM0->M0_CIDCOB)+"#"+AllTrim(SM0->M0_ESTENT)+"#"+AllTrim(SM0->M0_CEPENT),;
					Substr(SM0->M0_CODMUN,3,Len(SM0->M0_CODMUN)),;
					""})

	While .Not. QRY->( EoF() )

		If M->ZF_TIPO == "1" .And. QRY->TRANSP == "000002"
			MsgStop("A nota fiscal " + QRY->NFISCAL + " � uma retira e n�o pode estar associada a carga " + M->ZF_NUM + ".")
			Break
		EndIf

		If M->ZF_TIPO == "1" .And. ( Empty(QRY->ENDER) .OR. Empty(QRY->MUN) .OR. Empty(QRY->EST) .OR. Empty(QRY->CEP) )
			MsgStop("A nota fiscal " + QRY->NFISCAL + " est� com endere�o para entrega incompleto.")
			Break
		EndIf

		aAdd(aRota, {	QRY->CHAVE,;
						AllTrim(QRY->CEP)+AllTrim(QRY->EST),;
						0,;
						0,;
						0,;
						0,;
						AllTrim(QRY->NFISCAL),;
						AllTrim(QRY->MUN),;
						AllTrim(QRY->EST),;
						AllTrim(QRY->ENDER)+"#"+AllTrim(QRY->MUN)+"#"+AllTrim(QRY->EST)+"#"+AllTrim(QRY->CEP),;
						QRY->CODMUN,;
						AllTrim(QRY->CEP)+AllTrim(QRY->ENDER)	})

	    QRY->( dbSkip() )

	EndDo

	//�����������������������������������������������������������������������Ŀ
	//� Roteiro entre ponto zero ( EURO ) e todos os outros pontos ( NF's )   �
	//�������������������������������������������������������������������������
	For nZ := 2 To Len(aRota) //Primeiro elemento ignorado por ser o proprio ponto zero ( EURO )

		cParOri := aRota[01,2]
		cParDes := aRota[nZ,2]

		//+--------------------------------------------------
		//| Procura rota pelo banco de dados
		//+--------------------------------------------------
		dbSelectArea("ZZ8")
		dbSetOrder(1)
		dbSeek( xFilial("ZZ8")+cParOri+cParDes )

		If ZZ8->( Found() ) .And. ( ( ZZ8->ZZ8_ORIG == ZZ8->ZZ8_DEST .And. ZZ8->ZZ8_KM == 0 ) .Or. (  ZZ8->ZZ8_ORIG != ZZ8->ZZ8_DEST .And. ZZ8->ZZ8_KM != 0 ) )

			nKM := ZZ8->ZZ8_KM
			nTM := ZZ8->ZZ8_TM

			aRota[nZ, 3] := nKM
			aRota[nZ, 4] := nTM

		Else

			//+--------------------------------------------------
			//| Forca criacao de um novo registro com KM correto
			//+--------------------------------------------------
			If ZZ8->( Found() ) .And. ZZ8->ZZ8_KM == 0
				RecLock("ZZ8", .F.)
					dbDelete()
				ZZ8->( MsUnlock() )
			EndIf

			//+--------------------------------------------------
			//| Procura rota pelo google maps ( 2 tentavias )
			//+--------------------------------------------------
			nGMaps := 1
			lGMaps := .F.

			While nGMaps <= 2 .And. lGMaps == .F.

				TRYEXCEPTION             //TRY EXCEPTION

					cParOri := StrGMAPS(aRota[01,10], nGMaps)
					cParDes := StrGMAPS(aRota[nZ,10], nGMaps)

					cUrl	:= "http://maps.googleapis.com/maps/api/distancematrix/xml?origins=" + cParOri + "&destinations=" + cParDes + "&mode=driving&language=pt-BR&sensor=false"

					cXml	:= HttpGet( cUrl )

					Sleep(5000)

					If cXml != Nil .And. .Not. Empty(cXml)

						CREATE oXml XMLSTRING cXml

							If Upper(AllTrim(oXml:_DISTANCEMATRIXRESPONSE:_STATUS:TEXT)) == "OK"

								//+--------------------------------------------------
								//| Atualiza matriz de rotas ( AROTA )
								//+--------------------------------------------------
								nKM := 0
								nTM := 0

								If !Empty( oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_STATUS:TEXT ) .And. oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_STATUS:TEXT == "OK"

									If oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DISTANCE != Nil
										nKM := Round( (Val(oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DISTANCE:_VALUE:TEXT)/1000), 2 ) //Converte o retorno em metros para quilometros
									EndIf

									If oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DURATION != Nil
										nTM := (Val(oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DURATION:_VALUE:TEXT)/60) //Converte o retorno em segundos para minutos
									EndIf

									aRota[nZ, 3] := nKM
									aRota[nZ, 4] := nTM

									//+--------------------------------------------------
									//| Atualiza arquivo de rotas ( ZZ8 )
									//+--------------------------------------------------
									dbSelectArea("ZZ8")
									RecLock("ZZ8", .T.)
										ZZ8->ZZ8_FILIAL	:= xFilial("ZZ8")
										ZZ8->ZZ8_ORIG	:= aRota[01,2]
										ZZ8->ZZ8_DEST	:= aRota[nZ,2]
										ZZ8->ZZ8_KM		:= aRota[nZ,3]
										ZZ8->ZZ8_TM		:= aRota[nZ,4]
										ZZ8->ZZ8_DATA	:= dDatabase
									ZZ8->( MsUnlock() )

									//+--------------------------------------------------
									//| Atualiza flag de controle do loop
									//+--------------------------------------------------
									lGMaps := .T.

								EndIf

							EndIf

						//+--------------------------------------------------
						//| Destroi objeto
						//+--------------------------------------------------
						FreeObj(oXml)
						oXml := Nil
						cXml := ""
						cUrl := ""

					EndIf

				CATCHEXCEPTION USING oError		//CATCH EXCEPTION USING oError

					//+--------------------------------------------------
					//| Envia e-mail para auditoria em caso de erro
					//+--------------------------------------------------
					cMailBody := "Carga.....: " + M->ZF_NUM + ENTER
					cMailBody += "Data/Hora.: " + DtoC( dDatabase ) + " - " + Time() + ENTER
					cMailBody += "Usuario...: " + cUserName + ENTER
					cMailBody += "Origem....: " + aRota[01,2] + ENTER
					cMailBody += "Destino...: " + aRota[nZ,2] + ENTER
					cMailBody += "KM0.......: " + cValToChar(nKM) + ENTER
					cMailBody += "TM0.......: " + cValToChar(nTM) + ENTER
					cMailBody += "Erro......: " + oError:Description + ENTER
					cMailBody += "GMaps URL.: " + cUrl + ENTER
					cMailBody += "GMaps XML.: " + cXml + ENTER
					fSendEmail( cMailBody )

					//+--------------------------------------------------
					//| Destroi objeto
					//+--------------------------------------------------
					FreeObj(oXml)
					oXml := Nil
					cXml := ""
					cUrl := ""

					//+--------------------------------------------------
					//| Atualiza flag de controle do loop
					//+--------------------------------------------------
					lGMaps := .F.

				ENDEXCEPTION //END TRY

				//+--------------------------------------------------
				//| Atualiza flag de controle do loop
				//+--------------------------------------------------
				nGMaps++

			EndDo

			If !lGmaps

				
			EndIf

		EndIf

	Next nZ

	//�����������������������������������������������������������������������Ŀ
	//� Roteiro entre ponto mais proximo do ponto zero ate proximo ponto      �
	//�������������������������������������������������������������������������
	aSort( aRota, , , { |x,y| x[3] < y[3] }) //Ordena as rotas pela quilometragem mais proxima do ponto zero ( EURO )

	For nZ := 2 To Len(aRota) //Primeiro elemento ignorado por ser o proprio ponto zero ( EURO )

		cParOri := aRota[(nZ-1),2]
		cParDes := aRota[nZ,2]

		//+--------------------------------------------------
		//| Procura rota pelo banco de dados
		//+--------------------------------------------------
		dbSelectArea("ZZ8")
		dbSetOrder(1)
		dbSeek( xFilial("ZZ8")+cParOri+cParDes )

		If ZZ8->( Found() ) .And. ( ( ZZ8->ZZ8_ORIG == ZZ8->ZZ8_DEST .And. ZZ8->ZZ8_KM == 0 ) .Or. ( ZZ8->ZZ8_ORIG != ZZ8->ZZ8_DEST .And. ZZ8->ZZ8_KM != 0 ) )

			nKM := ZZ8->ZZ8_KM
			nTM := ZZ8->ZZ8_TM

			aRota[nZ, 5] := nKM
			aRota[nZ, 6] := nTM

		Else
			//+--------------------------------------------------
			//| Procura rota pelo google maps
			//+--------------------------------------------------
			nGMaps := 1
			lGMaps := .F.

			While nGMaps <= 2 .And. lGMaps == .F.

				TRYEXCEPTION     //TRY EXCEPTION

					cParOri := StrGMAPS(aRota[(nZ-1),10], nGMaps)
					cParDes := StrGMAPS(aRota[nZ,10], nGMaps)

					cUrl	:= "http://maps.googleapis.com/maps/api/distancematrix/xml?origins=" + cParOri + "&destinations=" + cParDes + "&mode=driving&language=pt-BR&sensor=false"

					cXml	:= HttpGet( cUrl )

					Sleep(5000)

					If cXml != Nil .And. .Not. Empty(cXml)

						CREATE oXml XMLSTRING cXml

							If Upper(AllTrim(oXml:_DISTANCEMATRIXRESPONSE:_STATUS:TEXT)) == "OK"

								nKM := 0
								nTM := 0

								If !Empty( oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_STATUS:TEXT ) .And. oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_STATUS:TEXT == "OK"

									If oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DISTANCE != Nil
										nKM := Round( (Val(oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DISTANCE:_VALUE:TEXT)/1000), 2 ) //Converte o retorno em metros para quilometros
									EndIf

									If oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DURATION != Nil
										nTM := (Val(oXml:_DISTANCEMATRIXRESPONSE:_ROW:_ELEMENT:_DURATION:_VALUE:TEXT)/60) //Converte o retorno em segundos para minutos
									EndIf

									aRota[nZ, 5] := nKM
									aRota[nZ, 6] := nTM

									//+--------------------------------------------------
									//| Atualiza tabela ZZ8 - Rotas ( GMAPS )
									//+--------------------------------------------------
									dbSelectArea("ZZ8")
									RecLock("ZZ8", .T.)
										ZZ8->ZZ8_FILIAL	:= xFilial("ZZ8")
										ZZ8->ZZ8_ORIG	:= aRota[(nZ-1),2]
										ZZ8->ZZ8_DEST	:= aRota[nZ,2]
										ZZ8->ZZ8_KM		:= aRota[nZ,5]
										ZZ8->ZZ8_TM		:= aRota[nZ,6]
										ZZ8->ZZ8_DATA	:= dDatabase
									ZZ8->( MsUnlock() )

									//+--------------------------------------------------
									//| Atualiza flag de controle do loop
									//+--------------------------------------------------
									lGMaps := .T.

								EndIf

							EndIf

						//+--------------------------------------------------
						//| Destroi objeto
						//+--------------------------------------------------
						FreeObj(oXml)
						oXml := Nil
						cXml := ""
						cUrl := ""

					EndIf

				CATCHEXCEPTION USING oError //TRY EXCEPTION

					//+--------------------------------------------------
					//| Envia e-mail para auditoria em caso de erro
					//+--------------------------------------------------
					cMailBody := "Carga.....: " + M->ZF_NUM + ENTER
					cMailBody += "Data/Hora.: " + DtoC( dDatabase ) + " - " + Time() + ENTER
					cMailBody += "Usuario...: " + cUserName + ENTER
					cMailBody += "Origem....: " + aRota[01,2] + ENTER
					cMailBody += "Destino...: " + aRota[nZ,2] + ENTER
					cMailBody += "KM0.......: " + cValToChar(nKM) + ENTER
					cMailBody += "TM0.......: " + cValToChar(nTM) + ENTER
					cMailBody += "Erro......: " + oError:Description + ENTER
					cMailBody += "GMaps URL.: " + cUrl + ENTER
					cMailBody += "GMaps XML.: " + cXml + ENTER
					fSendEmail( cMailBody )

					//+--------------------------------------------------
					//| Destroi objeto
					//+--------------------------------------------------
					FreeObj(oXml)
					oXml := Nil
					cXml := ""
					cUrl := ""

					//+--------------------------------------------------
					//| Atualiza flag de controle do loop
					//+--------------------------------------------------
					lGMaps := .F.

				ENDEXCEPTION //END TRY

				//+--------------------------------------------------
				//| Atualiza flag de controle do loop
				//+--------------------------------------------------
				nGMaps++

			EndDo

			If !lGmaps

			EndIf

		EndIf

		//+--------------------------------------------------
		//| Atualiza campos KM0 e KMX do GetDados
		//+--------------------------------------------------
		nPACols := aScan( aCols, {|n| AllTrim(n[nPEmpFil]+n[nPNota]+n[nPSerie]) == AllTrim(aRota[nZ, 1]) })

		If nPACols > 0

			aCols[nPACols, nPKm0] := aRota[nZ,3]
			aCols[nPACols, nPTm0] := aRota[nZ,4]
			aCols[nPACols, nPKmX] := aRota[nZ,5]
			aCols[nPACols, nPTmX] := aRota[nZ,6]

			//+--------------------------------------------------
			//| Identifica entrega extra ( Bonus R$ 10 )
			//+--------------------------------------------------
			If aRota[nZ,12] != cEndAnt
				cEndAnt		:= aRota[nZ,12]
				nQtdeEnt	:= ( nQtdeEnt+1 )
			EndIf

		Else

			//+--------------------------------------------------
			//| Envia e-mail para auditoria em caso de erro
			//+--------------------------------------------------
			cMailBody := "Carga.....: " + M->ZF_NUM + ENTER
			cMailBody += "Data/Hora.: " + DtoC( dDatabase ) + " - " + Time() + ENTER
			cMailBody += "Usuario...: " + cUserName + ENTER
			cMailBody += "Origem....: " + aRota[01,2] + ENTER
			cMailBody += "Destino...: " + aRota[nZ,2] + ENTER
			cMailBody += "KM0.......: " + cValToChar(aRota[nZ,3]) + ENTER
			cMailBody += "TM0.......: " + cValToChar(aRota[nZ,4]) + ENTER
			cMailBody += "Erro......: " + "NAO ENCONTROU NOTA FISCAL ( " +  AllTrim(aRota[nZ, 1]) + " ) NO ACOLS" + ENTER
			cMailBody += "GMaps URL.: " + cUrl + ENTER
			cMailBody += "GMaps XML.: " + cXml + ENTER
			fSendEmail( cMailBody )

		EndIf

	Next nZ

	//�����������������������������������������������������������������������Ŀ
	//� Atualiza objeto GetDados                                              �
	//�������������������������������������������������������������������������
	oGetDados:SetArray(aCols, .T.)
	oGetDados:ForceRefresh()

	//�����������������������������������������������������������������������Ŀ
	//� Aplica regra de frete conforme cadastro de frete ( ZZ9 )              �
	//�������������������������������������������������������������������������
	If Len(aRota)>0
		nUltRota	:= Len(aRota)
		aSoma		:= fSomaItens()
		nRet		:= U_FATX014F(M->ZF_TRANSP, M->ZF_VEICULO, aRota[nUltRota,11], aRota[nUltRota, 9], aSoma[2], aSoma[1], nQtdeEnt)
	EndIf

End Sequence

//�����������������������������������������������������������������������Ŀ
//� Fecha arquivo temporario                                              �
//�������������������������������������������������������������������������
If Select("QRY") > 0
	QRY->( dbCloseArea())
EndIf

//�����������������������������������������������������������������������Ŀ
//� Ajusta ponteiro do mouse ( Default )                                  �
//�������������������������������������������������������������������������
CursorArrow()

//�����������������������������������������������������������������������Ŀ
//� Restaura area anterior                                                �
//�������������������������������������������������������������������������
Restarea( aAreaZZ8 )
Restarea( aArea )

Return( nRet )

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX011W �Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao �CALCULA FRETE PREVISTO                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fGdDelOK()
Local aArea := GetArea()

M->ZF_FRETEP := U_FATX011W()

Restarea( aArea )

Return( .T. )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �STRGMAPS  � Autor �Tiago O. Beraldi    � Data �  17/07/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Monta string utilizada como parametro na funcao DISTANCE    ���
���          �MATRIX da API do Google Maps                                ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function StrGMAPS(cString, nTipo)
Local cChar  	:= ""
Local nX     	:= 0
Local nY     	:= 0
Local cSepar 	:= "#"
Local cEspec 	:= ",.- "
Local aString	:= {}
Local cStrAux	:= ""

//�����������������������������������������������������������������������Ŀ
//� Monta string : nTipo 1 -> ENDERECO+CIDADE+ESTADO+CEP                  �
//�                nTipo 2 -> CIDADE+ESTADO+CEP                           �
//�������������������������������������������������������������������������
aString := StrTokArr(cString, "#")

For nX := nTipo To Len(aString)
	cStrAux += AllTrim(aString[nX]) + "+"
Next nX

cString := Substr(cStrAux,1,Len(cStrAux)-1)

//�����������������������������������������������������������������������Ŀ
//� Substitui caracteres invalidos                                        �
//�������������������������������������������������������������������������
cString := NoAcento(cString)

For nX := 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)

	If cChar$cSepar
		nY:= At(cChar,cSepar)
		If nY > 0
			cString := StrTran(cString,cChar,"+")
		EndIf
	EndIf

	If cChar$cEspec
		nY:= At(cChar,cEspec)
		If nY > 0
			cString := StrTran(cString,cChar,"%20")
		EndIf
	EndIf

Next nX

cString := cString+"+BRASIL"

Return cString

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOACENTO  � Autor �Tiago O. Beraldi    � Data �  17/07/08   ���
�������������������������������������������������������������������������͹��
���Descricao �RETIRA ACENTOS                                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "�����"+"�����"
Local cCircu := "�����"+"�����"
Local cTrema := "�����"+"�����"
Local cCrase := "�����"+"�����"
Local cTio   := "��"
Local cCecid := "��"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVEMAIL  �Autor  �Tiago O. Beraldi    � Data �23/06/2006   ���
�������������������������������������������������������������������������͹��
���Descricao � ENVIO DO EMAIL                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fSendEmail( cMsg )

Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT"))
Local cPassAut  := AllTrim(GetMV("MV_RELPSW"))
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH"))
Local cTo       := "workflow@euroamerican.com.br"
Local cFrom     := "workflow@euroamerican.com.br"
Local cCco		:= ""
LocaL cCc		:= ""
Local lOk		:= .F.

CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)

	If cAuthent == ".T."
		MAILAUTH(cUserAut, cPassAut)
	EndIf

	SEND MAIL FROM cTo TO cFrom ;
	BCC cCco ;
	CC cCc ;
	SUBJECT "Auditoria - Fun��o: FATX011 - CONTROLE DE CARGA";
	BODY cMsg;
	RESULT lOK
	DISCONNECT SMTP SERVER

Endif

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVEMAIL  �Autor  �Tiago O. Beraldi    � Data �23/06/2006   ���
�������������������������������������������������������������������������͹��
���Descricao � ENVIO DO EMAIL                                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fSeparacao()

Local oDlg			:= Nil

Local aObjects	  	:= {}
Local aSizeAut 		:= MsAdvSize(.T., .T., 600)
Local aInfo			:= {}
Local aPosObj		:= {}

Local bOk        	:= {|| oDlg:End() }
Local bCancel    	:= {|| oDlg:End() }
Local aButtons   	:= {}

Local oGetD			:= Nil
Local aHeader		:= {}
Local aCols			:= {}

Local cQry			:= ""

Local cTrbFil		:= TRBMARK->TR_EMPFIL
Local cTrbDoc		:= TRBMARK->TR_NOTA
Local cTrbSerie		:= TRBMARK->TR_SERIE

//��������������������������������������������������������Ŀ
//� Ajusta ponteiro do mouse ( Aguarde )                   �
//����������������������������������������������������������
CursorWait()

//��������������������������������������������������������Ŀ
//� Gera script SQL                                        �
//����������������������������������������������������������
cQry	:= "SELECT " + ENTER
cQry	+= "	D2_ITEM [ITEM], " + ENTER
cQry	+= "	RTRIM(B1_COD) + ' - ' + B1_DESC [PRODUTO], " + ENTER
cQry	+= "	D2_QUANT [QTDE_NF], " + ENTER
cQry	+= "	/*ZZE_QTDE*/ 0 [QTDE_SEP], " + ENTER
cQry	+= "	/*ZZE_LOTE*/ '' [LOTE], " + ENTER
cQry	+= "	/*ZZE_VALID*/ '' [VALIDADE] " + ENTER
cQry	+= "FROM   " + ENTER
cQry	+= "	" + RetSqlName("SD2") + " SD2  " + ENTER
cQry	+= "LEFT JOIN " + ENTER
cQry	+= "	" + RetSqlName("SB1") + " SB1 " + ENTER
cQry	+= "		ON	SB1.D_E_L_E_T_ = '' " + ENTER
cQry	+= "		AND	B1_FILIAL = '' " + ENTER
cQry	+= "		AND	B1_COD = D2_COD " + ENTER
cQry	+= "WHERE   " + ENTER
cQry	+= "	SD2.D_E_L_E_T_ = ''     " + ENTER
cQry	+= "AND	D2_FILIAL = '" + cTrbFil + "' " + ENTER
cQry	+= "AND	D2_DOC = '" + cTrbDoc + "' " + ENTER
cQry	+= "AND	D2_SERIE = '" + cTrbSerie + "' " + ENTER
cQry	+= "ORDER BY  " + ENTER
cQry	+= "	D2_ITEM " + ENTER

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

aAdd(aHeader,	{"Item"		,"TMP_ITEM"		, "@!"	  			,02		,00		,,,"C"		,,"V",,,,"V",,,})
aAdd(aHeader,	{"Produto"	,"TMP_PRODUTO"	, "@!"				,50		,00		,,,"C"		,,"V",,,,"V",,,})
aAdd(aHeader,	{"Qtde NF"	,"TMP_QTDNF"	, "@E 999,999.99"	,14		,02		,,,"N"		,,"V",,,,"V",,,})
aAdd(aHeader,	{"Qtde SEP"	,"TMP_QTDSEP"	, "@E 999,999.99"	,14		,02		,,,"N"		,,"V",,,,"V",,,})
aAdd(aHeader,	{"Lote"		,"TMP_LOTE"		, "@!"				,06		,00		,,,"C"		,,"V",,,,"V",,,})
aAdd(aHeader,	{"Validade"	,"TMP_VALID"	, "@D"				,08		,00		,,,"D"		,,"V",,,,"V",,,})

While QRY->( !EoF() )

	aAdd( aCols, Array( Len(aHeader)+1 ) )

	aCols[ Len(aCols), 01 ] := QRY->ITEM
	aCols[ Len(aCols), 02 ] := QRY->PRODUTO
	aCols[ Len(aCols), 03 ] := QRY->QTDE_NF
	aCols[ Len(aCols), 04 ] := QRY->QTDE_SEP
	aCols[ Len(aCols), 05 ] := QRY->LOTE
	aCols[ Len(aCols), 06 ] := CtoD(QRY->VALIDADE)
	aCols[ Len(aCols), 07 ] := .F.

	QRY->( dbSkip() )
EndDo

//��������������������������������������������������������Ŀ
//� Ajusta ponteiro do mouse ( Default )                   �
//����������������������������������������������������������
CursorArrow()

//��������������������������������������������������������Ŀ
//� Define area de criacao de objetos                      �
//����������������������������������������������������������
aObjects 	:= {}
aAdd(aObjects, {100, 100, .T., .T.})
aInfo		:= {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3, 3, 3}
aPosObj		:= MsObjSize(aInfo, aObjects, .T., .F.)

//��������������������������������������������������������Ŀ
//� Cria objetos										   �
//����������������������������������������������������������
DEFINE MSDIALOG oDlg TITLE cCadastro + " - Separa��o e Confer�ncia"  FROM aSizeAut[7], 00 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

oDlg:lCentered	:= .T.
oDlg:bInit		:= {|| EnchoiceBar(oDlg,bOk,bCancel,,aButtons) }

oGetD			:= MsNewGetDados():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],0,,,,,0,999999,Nil,Nil,,oDlg,aHeader,aCols,)
oGetD:oBrowse:SetArray( aCols )
oGetD:ForceRefresh()

oDlg:ACTIVATE()

Return( Nil )



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �fCancelOK � Autor �Alexandre Marson    � Data �17/09/14     ���
�������������������������������������������������������������������������͹��
���Descri��o �Solicitar justificativa do cancelamento da carga            ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fCancelOK( cLog )

Local aArea     := GetArea()
Local oMemo     := Nil
Local cMemo     := ""
Local oDlg   	:= Nil
Local cCarga	:= SZF->ZF_NUM
Local lRet      := .F.

DEFINE FONT oFont14B NAME "Tahoma" SIZE 0,20 OF oDlg BOLD

DEFINE MSDIALOG oDlg TITLE "Cancelamento de Carga" FROM 065,000 TO 432,459 PIXEL

	@ 001,004 TO 165,229 LABEL "" PIXEL OF oDlg

	@ 010,010 Say "Carga Nro:" Size 030,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 007,045 Say cCarga Size 060,008 COLOR CLR_BLUE FONT oFont14B PIXEL OF oDlg

	@ 025,010 Say "Motivo:" Size 030,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 034,010 GET oMemo Var cMemo MEMO Size 212,115 PIXEL OF oDlg

	@ 169,070 Button "Confirmar" Size 037,012 PIXEL OF oDlg Action( IIf( Empty(cMemo), ( lRet:=.F., MsgAlert("Informe o motivo do cancelamento.", "Aten��o") ), ( lRet:=.T., oDlg:End() ) ) )
	@ 169,125 Button "Cancelar" Size 037,012 PIXEL OF oDlg Action( lRet:=.F., oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

If lRet

	cLog := ""
	cLog += ENTER
	cLog += Replicate("-", 80)
	cLog += ENTER
	cLog += "C A N C E L A M E N T O"
	cLog += ENTER
	cLog += Replicate("-", 80)
	cLog += ENTER
	cLog += "Usuario..: " + Upper(AllTrim(cUserName))
	cLog += ENTER
	cLog += "Data/Hora: " + DtoC(dDataBase) + " - " + Time()
	cLog += ENTER
	cLog += "Motivo   : " + cMemo
	cLog += ENTER
	cLog += Replicate("-", 80)
	cLog += ENTER

EndIf

Restarea( aArea )

Return lRet





/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �FATX011Q  � Autor �Alexandre Marson    � Data �17/09/14     ���
�������������������������������������������������������������������������͹��
���Descri��o �Justificativa para adicao de desconto administrativo        ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX011Q(cAlias,nReg,nOpc)

Local aArea     := GetArea()
Local oValor	:= Nil
Local nValor	:= 0
Local oMemo     := Nil
Local cMemo     := ""
Local oDlg   	:= Nil
Local cCarga	:= SZF->ZF_NUM
Local lRet      := .F.

DEFINE FONT oFont14B NAME "Tahoma" SIZE 0,20 OF oDlg BOLD

DEFINE MSDIALOG oDlg TITLE "Desconto Administrativo" FROM 065,000 TO 432,459 PIXEL

	@ 001,004 TO 163,229 LABEL "" PIXEL OF oDlg

	@ 010,010 Say "Carga Nro:" Size 030,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 007,045 Say cCarga Size 060,008 COLOR CLR_BLUE FONT oFont14B PIXEL OF oDlg

	@ 025,010 Say "Valor:" Size 030,008 COLOR CLR_BLACK  PIXEL OF oDlg
	@ 024,045 GET oValor Var nValor Size 60,010 PICTURE "@E 999,999.99" PIXEL OF oDlg

	@ 040,010 Say "Motivo:" Size 030,008 COLOR CLR_BLACK PIXEL OF oDlg
	@ 039,045 GET oMemo Var cMemo MEMO Size 180,100 PIXEL OF oDlg

	@ 169,070 Button "Confirmar" Size 037,012 PIXEL OF oDlg Action( lRet:=.T., oDlg:End() )
	@ 169,125 Button "Cancelar" Size 037,012 PIXEL OF oDlg Action( lRet:=.F., oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

If lRet

	If !Empty(nValor) .And. !Empty(cMemo)

		cLog := ""
		cLog += ENTER
		cLog += Replicate("-", 80)
		cLog += ENTER
		cLog += "D E S C O N T O    A D M I N I S T R A T I V O"
		cLog += ENTER
		cLog += Replicate("-", 80)
		cLog += ENTER
		cLog += "Usuario..: " + Upper(AllTrim(cUserName))
		cLog += ENTER
		cLog += "Data/Hora: " + DtoC(dDataBase) + " - " + Time()
		cLog += ENTER
		cLog += "Motivo   : " + cMemo
		cLog += ENTER
		cLog += Replicate("-", 80)
		cLog += ENTER

		dbSelectArea("SZF")
		RecLock("SZF", .F.)
			SZF->ZF_DESCFRT := SZF->ZF_DESCFRT + nValor
			SZF->ZF_LOG		:= ZF_LOG + cLog
		MsUnlock()

		MsgInfo("Desconto aplicado com sucesso!")

	EndIf

EndIf

Restarea( aArea )

Return(lRet)

/*/{Protheus.doc} VALIDAMAIL
description
@type function
@version  
@author Fabio Batista
@since 17/10/2020
/*/
Static Function VALIDAMAIL()

	If !__nACREFRT == SZF->ZF_ACREFRT .and. !__nDESCFRT == SZF->ZF_DESCFRT
		If SZF->ZF_ACREFRT > 300
			Alert("A T E N � � O" + CRLF + CRLF +"Valor informado maior que o permitido!" + CRLF + "O valor vai ser alterado para o anterior: ("+cValtochar(__nACREFRT) +")!")
			RecLock("SZF", .F.)
			SZF->ZF_ACREFRT := __nACREFRT
			MsUnLock()
			Return
		EndIf	
		ENVTOD()
		Return
	EndIf

	If !__nACREFRT == SZF->ZF_ACREFRT
		If SZF->ZF_ACREFRT > 300
			Alert("A T E N � � O" + CRLF + CRLF +"Valor informado maior que o permitido!" + CRLF + "O valor vai ser alterado para o anterior: ("+cValtochar(__nACREFRT) +")!")
			RecLock("SZF", .F.)
			SZF->ZF_ACREFRT := __nACREFRT
			MsUnLock()
			Return
		EndIf	
		ENVACRE()
		Return
	EndIf

	If !__nDESCFRT == SZF->ZF_DESCFRT
		ENVADES()
		Return
	EndIf

Return

/*/{Protheus.doc} ENVTOD
//Rotina envio de e-mail na 
altera��o do campo acr�scimo e desconto
@author Fabio Batista
@since 17/10/2020
@version 1.0
/*/
Static Function ENVTOD()

Local _cHtml := ''
Local cAssunto := 'Altera��o acr�scimo e desconto'
Local cBody    := ''
Local cEmail   := GETMV("MV_XMAILEX",,'fabio.batista@euroamerican.com.br')
Local cAttach  := '' 

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Altera��o acr�scimo e desconto</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="9" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Carga</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de altera��o</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Acr�scimo</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Acr�scimo</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Desconto</b></font>  ' + CRLF  
_cHtml += '				</td> 	' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Desconto</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usu�rio</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZF->ZF_NUM +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">acr�scimo|Desconto</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(__nACREFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(SZF->ZF_ACREFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(__nDESCFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(SZF->ZF_DESCFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Upper(AllTrim(cUserName)) + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Time() + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		cAssunto := 'altera��o dos campos SZF'
		cBody := 'O parametro que devem existir os e-mail est� vazio (MV_XMAILEX)'
		cEmail   := 'fabio.batista@euroamerican.com.br'
	EndIf

	//cEmail   := 'fabio.batista@euroamerican.com.br'
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return

/*/{Protheus.doc} ENVACRE
//Rotina envio de e-mail na 
altera��o do campo acr�scimo
@author Fabio Batista
@since 17/10/2020
@version 1.0
/*/
Static Function ENVACRE()

Local _cHtml := ''
Local cAssunto := 'Altera��o Acr�scimo'
Local cBody    := ''
Local cEmail   := GETMV("MV_XMAILEX",,'fabio.batista@euroamerican.com.br')
Local cAttach  := '' 

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Altera��o acr�scimo</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="8" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Carga</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de altera��o</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF


_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Acr�scimo</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Acr�scimo</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usu�rio</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZF->ZF_NUM +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">acr�scimo</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(__nACREFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(SZF->ZF_ACREFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Upper(AllTrim(cUserName)) + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Time() + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		cAssunto := 'altera��o dos campos SZF'
		cBody := 'O parametro que devem existir os e-mail est� vazio (MV_XMAILEX)'
		cEmail   := 'fabio.batista@euroamerican.com.br'
	EndIf

	//cEmail   := 'fabio.batista@euroamerican.com.br'
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return

/*/{Protheus.doc} ENVADES
//Rotina envio de e-mail na 
altera��o do campo desconto
@author Fabio Batista
@since 17/10/2020
@version 1.0
/*/
Static Function ENVADES()

Local _cHtml := ''
Local cAssunto := 'Altera��o desconto'
Local cBody    := ''
Local cEmail   := GETMV("MV_XMAILEX",,'fabio.batista@euroamerican.com.br')
Local cAttach  := '' 

_cHtml := '<html>' + CRLF
_cHtml += '	<head>' + CRLF
_cHtml += '		<meta http-equiv="content-type" content="text/html;charset=utf-8">' + CRLF
_cHtml += '		<style>' + CRLF
_cHtml += '			table 	{' + CRLF
_cHtml += '					border-collapse: collapse;' + CRLF
_cHtml += '					border: 1px solid black;' + CRLF
_cHtml += '					}' + CRLF
_cHtml += '		</style>' + CRLF
_cHtml += '	</head>' + CRLF
_cHtml += '	<body>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center">' + CRLF
_cHtml += '			<tr rowspan="2">' + CRLF
_cHtml += '				<td width="100%" style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#ffffff">      ' + CRLF
_cHtml += '					<br>' + CRLF
_cHtml += '					<font face="Courier New" size="5" VALIGN="MIDDLE" color=black><strong><B>Altera��o desconto</B></strong></font>   ' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td>' + CRLF
_cHtml += '					<font>' + CRLF
_cHtml += '						<br>' + CRLF
_cHtml += '					</font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>    ' + CRLF
_cHtml += '		</table><Br>' + CRLF
_cHtml += '		<table border="0" width="100%" align="center" >' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td colspan="8" width="100%"style=mso-number-format:"\@" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color="ffffff" ><B></b></Font>' + CRLF
_cHtml += '				</td>' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Nro.Carga</b></font>    ' + CRLF
_cHtml += '				</td>    	' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Campo de altera��o</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF


_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Ant Desconto</b></font>  ' + CRLF  
_cHtml += '				</td> ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Atu Desconto</b></font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Usu�rio</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Hora Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF
_cHtml += '				<td width="11%" align="center" VALIGN="MIDDLE" bgcolor="#336699">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3" color=WHITE><b>Data Altera��o</b></font>    ' + CRLF
_cHtml += '				</td> ' + CRLF

_cHtml += '			</tr>' + CRLF
_cHtml += '			<tr>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ SZF->ZF_NUM +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">Desconto</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(__nDESCFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+cValtochar(SZF->ZF_DESCFRT)+'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF

_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Upper(AllTrim(cUserName)) + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">' + Time() + '</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '				<td  width="11%"style=mso-number-format:"\@" align="center"  VALIGN="MIDDLE">      ' + CRLF
_cHtml += '					<font face="Courier New" size="3">'+ DTOC(DDATABASE) +'</font>    ' + CRLF
_cHtml += '				</td>    ' + CRLF
_cHtml += '			</tr>' + CRLF
_cHtml += '		</table>' + CRLF
_cHtml += '		<Hr>' + CRLF
_cHtml += '		<font face="Arial" size="1"><I>Powered by TI Euroamerican</I></font>  <font face="Arial" size="1" color="#FFFFFF">%cCodUsr% %cIDWF% %cFuncao%</font><br>' + CRLF
_cHtml += '		<font face="Arial" size="3"><B>Euroamerican do Brasil Imp Ind e Com LTDA</B></font><br/>' + CRLF
_cHtml += '	</body>' + CRLF
_cHtml += '</html>' + CRLF

cBody := _cHtml

	If Empty(cEmail )
		cAssunto := 'altera��o dos campos SZF'
		cBody := 'O parametro que devem existir os e-mail est� vazio (MV_XMAILEX)'
		cEmail   := 'fabio.batista@euroamerican.com.br'
	EndIf

	//cEmail   := 'fabio.batista@euroamerican.com.br'
	u_FSENVMAIL(cAssunto, cBody, cEmail,cAttach,,,,,,,,,)
 
Return


Static Function FAccess()
	Local cArea	:= FwGetArea()
	Local cAlias        := "Y-"+GetNextAlias()
    Local cQuery        := ' '
	Local cNomeUser     := UsrRetName(RetCodUsr())

	cUsrOpc 	:= ''
	ESPARFAT1	:= ''
	ESPARFAT2	:= ''
	ESPARFAT4	:= ''
	ESPARFAT5	:= ''
	__cExpedicao:=''
	__cUser 	:= ''
	cConteudo   := ''
    
	cQuery :="select * "+ENTER
	cQuery +="from "+RetSqlName("SZ3")+" "+ENTER
	cQuery +="WHERE D_E_L_E_T_ = ' ' "+ENTER
	cQuery +="AND Z3_FILIAL =  '"+xFilial("SZ3")+"'"+ENTER
	cQuery +="AND Z3_MSBLQL <> '1' "+ENTER
	cQuery +="AND Z3_KEYUSR = '"+cNomeUser+"' "+ENTER

    If  Select(cAlias) > 0
                DbSelectArea(cAlias)
                DbCloseArea()
     Endif

     DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), cAlias , .F., .T. )

     if (cAlias)->(Eof())
        (cAlias)->( dbcloseArea() )
		Return
     ENDIF

      While !(cAlias)->(EoF())

	        // Permite Op��o de Desconto Administrativo
            IF (cAlias)->Z3_PAR_A = '1'
                 cUsrOpc:= cUsrOpc + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF
	        // Permite Manutencao dos cadastro de carga
            IF (cAlias)->Z3_PAR_B = '1'
                ESPARFAT1 :=  ESPARFAT1 + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF
			// Permite Entrega e Retorno
            IF (cAlias)->Z3_PAR_C = '1'
				 ESPARFAT2 :=  ESPARFAT2 + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF
            // Validar 
      		IF (cAlias)->Z3_PAR_D = '1'
				 ESPARFAT4 :=  ESPARFAT4 + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF			
            // Bloqueio de novas cargas acima 10 dias
      		IF (cAlias)->Z3_PAR_E = '1'
				 ESPARFAT5 :=  ESPARFAT5 + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF	
			// Expedicao
      		IF (cAlias)->Z3_PAR_F = '1'
				__cExpedicao := __cExpedicao + Alltrim((cAlias)->Z3_CODIGO) + ";"
			ENDIF
			IF (cAlias)->Z3_PAR_G = '1'
				__cUser:= __cUser + Alltrim((cAlias)->Z3_CODIGO) + ";"
			ENDIF			

			IF (cAlias)->Z3_PAR_I = '1'
				cConteudo:= cConteudo + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF			

			IF (cAlias)->Z3_PAR_J = '1'
				cConteudo:= cConteudo + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF	

			IF (cAlias)->Z3_PAR_H = '1'
				cConteudo:= cConteudo + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF	

            (cAlias)->( dbskip() )  

	  EndDo
      (cAlias)->( dbcloseArea() )
	FwRestArea(cArea)
Return


Static Function FSeachOpc()
	Local cArea	:= FwGetArea()
	Local cAlias        := "Y-"+GetNextAlias()
    Local cQuery        := ' '
	Local cNomeUser     := UsrRetName(RetCodUsr())

	cUsrOpc 	:= ''
    
	cQuery :="select * "+ENTER
	cQuery +="from "+RetSqlName("SZ3")+" "+ENTER
	cQuery +="WHERE D_E_L_E_T_ = ' ' "+ENTER
	cQuery +="AND Z3_FILIAL =  '"+xFilial("SZ3")+"'"+ENTER
	cQuery +="AND Z3_MSBLQL <> '1' "+ENTER
	cQuery +="AND Z3_KEYUSR = '"+cNomeUser+"' "+ENTER

    If  Select(cAlias) > 0
                DbSelectArea(cAlias)
                DbCloseArea()
     Endif

     DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQuery), cAlias , .F., .T. )

     if (cAlias)->(Eof())
        (cAlias)->( dbcloseArea() )
		Return
     ENDIF

      While !(cAlias)->(EoF())

	        // Permite Op��o de Desconto Administrativo
            IF (cAlias)->Z3_PAR_A = '1'
                 cUsrOpc:= cUsrOpc + Alltrim((cAlias)->Z3_KEYUSR) + ";"
			ENDIF
            (cAlias)->( dbskip() )  

	  EndDo
      (cAlias)->( dbcloseArea() )
	FwRestArea(cArea)
Return(cUsrOpc)
