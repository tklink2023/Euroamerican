#Include "Totvs.ch"
#Include "FWMVCDef.ch"

User Function PCPM163()
  Local cArea         := FwGetArea()
  Local cNumLote      := PARAMIXB[1]
  Local cItemLote     := PARAMIXB[2]
  Local cSeqLote      := PARAMIXB[3]
  Local cProduto      := PARAMIXB[4]
  Local cAlias  	    := GetNextAlias()
  Local cOp           := cNumLote + cItemLote + cSeqLote
  Local cPara         := getmv("JK_EMAIL")
  Local cCorpo        := ""
  Local cCodUsr       := RetCodUsr()
  Local cNomUsr       := UsrRetName(cCodUsr)
  Local cAssunto      := "Notificacao Tintometrico"  
  Local cProdEnv      := ""
  Local lExibeHelp    := .F.

 
 BeginSQL Alias cAlias
		SELECT   D4_FILIAL,D4_COD,B1_DESC,D4_LOCAL,D4_QUANT,ISNULL(BF_LOCALIZ,' ') BF_LOCALIZ, ISNULL(BF_LOTECTL,' ') BF_LOTECTL,  B8_DTVALID
		FROM %Table:SD4% SD4
		INNER JOIN %Table:SB1%  SB1 ON B1_COD = D4_COD AND SB1.D_E_L_E_T_ = ' '
      LEFT JOIN %Table:SBF% SBF ON BF_FILIAL = D4_FILIAL AND BF_PRODUTO = D4_COD AND BF_LOCAL = D4_LOCAL AND SBF.D_E_L_E_T_ = ' '
      LEFT JOIN %Table:SB8% SB8 ON B8_FILIAL = D4_FILIAL AND B8_PRODUTO = D4_COD AND B8_LOCAL = D4_LOCAL AND B8_LOTECTL = BF_LOTECTL AND SB8.D_E_L_E_T_ = ' '

		WHERE SD4.%NotDel%
		and D4_FILIAL =  %xFilial:SD4%
		AND D4_PRODUTO =  %Exp:cProduto%
      AND D4_OP = %Exp:cOp%
      AND D4_TRT = '001'
 EndSQL

  TCSetField(cAlias, "B8_DTVALID", "D")

 if (cAlias)->( Eof())
    FwRestArea(cArea)
	RETURN
 Endif

 DbSelectArea(cAlias)
 DbGotop()
 While (cAlias)->(!EOF())
    
        IF ! SZ5->(MsSeek(FWxFilial("SZ5")+(cAlias)->D4_COD+(cAlias)->D4_LOCAL+Dtos(dDatabase)+Time()))
  
               if RecLock("SZ5",.T.)
                  SZ5->Z5_FILIAL := (cAlias)->D4_FILIAL
                  SZ5->Z5_COD    := (cAlias)->D4_COD
                  SZ5->Z5_DESCR  := (cAlias)->B1_DESC
                  SZ5->Z5_LOCAL  := (cAlias)->D4_LOCAL
                  SZ5->Z5_QUANT  := (cAlias)->D4_QUANT
                  SZ5->Z5_LOCALIZ := (cAlias)->BF_LOCALIZ
                  SZ5->Z5_LOTECTL := (cAlias)->BF_LOTECTL
                  SZ5->Z5_DTVALID := (cAlias)->B8_DTVALID
                  SZ5->Z5_ARMAZ   := "TT"
                  SZ5->Z5_DATA   := MsDate()
                  SZ5->Z5_HORA   := Time()
                  SZ5->Z5_STATUS := "OP"
                  SZ5->( MsUnlock() )

                  cProdEnv := (cAlias)->D4_COD
                  cDescEnv := (cAlias)->B1_DESC
                  cOpEnv   := cOp
               ENDIF
  
         endif
  
         (cAlias)->(dbSkip() )

  ENDDO

  (cAlias)->(DbCloseArea())


  //Monta o corpo do e-Mail que será enviado
    cCorpo := ''
    cCorpo += ' <html>' + CRLF
    cCorpo += ' <head>' + CRLF
    cCorpo += '     <title>' + cAssunto + '</title>' + CRLF
    cCorpo += ' </head>' + CRLF
    cCorpo += ' <body>' + CRLF
    cCorpo += '     <center><h1>' + cAssunto + '</h1></center>' + CRLF
    cCorpo += '     Hoje, o usuário <b>' + Alltrim(cNomUsr) + '</b> incluiu um produto para transferir no almoxarifado TT:<br>' + CRLF
    cCorpo += '     <br>' + CRLF
    cCorpo += '     <b>Código do Produto:</b>  '   + cProdEnv      + '<br>' + CRLF
    cCorpo += '     <b>Descrição:</b> '            + cDescEnv     + '<br>' + CRLF
    cCorpo += '     <b>Data:</b> '                 + dToC(MsDate())      + '<br>' + CRLF
    cCorpo += '     <b>Hora:</b> '                 + Time()     + '<br>' + CRLF
    cCorpo += '     <b>Ordem Producao:</b> '       + cOpEnv   + '<br>' + CRLF
    cCorpo += '     <br>' + CRLF
    cCorpo += '     <br>' + CRLF
    cCorpo += '     --<br>' + CRLF
    cCorpo += '     <font size="1">e-Mail gerado automaticamente pelo Protheus - ' + dToC(Date()) + ' - ' + Time() + '</font><br>' + CRLF
    cCorpo += ' </body>' + CRLF
    cCorpo += ' </html>' + CRLF
    aAnexos  :={}

    lEnvio   := u_TManagerEmail(cPara, cAssunto, cCorpo, aAnexos, lExibeHelp, .T.)

  FwRestArea(cArea)
Return
