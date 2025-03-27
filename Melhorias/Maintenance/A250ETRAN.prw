#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} A250ETRAN
Ponto de Entrada após a gravação dos dados da rotina MATA250 (Produção) 
Utilizado para envio de email quando produto for do grupo especial
Utilizado também para na tabela SDA-Saldos a distribuir gravar o campo DA_HORA com time()
@type function Ponto de entrada
@version 1.00
@author mario.antonaccio
@since 21/09/2021
@return character, sem retorno
/*/
User Function A250ETRAN()
    Local aArea:=GetArea()

    // Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
    //Posiciona Pedido
    SC6->(dbSetOrder(2))
    If SC6->(dbSeek(xFilial("SC6")+SD3->D3_COD+SC2->C2_XPEDIDO))

        If SC6->C6_XGRPESP $ GETMV("QE_GRPPRES") // grupo de produtos

           cEmail:=SuperGetMv("QE_MLEPSOP",.F.,"mario.antonaccio@euroamerican.com.br;eulalia.ramos@qualyvinil.com.br;alexandre.gomes@qualyvinil.com.br;ellen.ataide@qualyvinil.com.br")

            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
            
            // Considera Saldo do produto para Tolerancia = Alex - 2021-09-27
            SB2->(dbSetOrder(1))
            SB2->(dbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))

            If (SC6->C6_QTDVEN/(SD3->D3_QUANT+SB2->B2_QATU)*100) > SuperGetMv("QE_ESPTLR",.F.,10)
               RecLock("SC2",.F.)
                SC2->C2_XBLQESP:="2"
                SC2->C2_XDTESP :=dDataBase    
                MsUnLock()          
                ALERT("Tolerancia Ultrapassada em "+Str((SC6->C6_QTDVEN/(SD3->D3_QUANT+SB2->B2_QATU)*100)-10,6,2)+"% Verificar !")

            Else

                //Atualiza Quantidade Produzida no pedido
                RecLock("SC6",.F.)
                SC6->C6_XQTDPRD:=SD3->D3_QUANT
                SC6->C6_QTDLIB:=0
                MsUnlock()

                //Atualiza Dados da OP
                RecLock("SC2",.F.)
                SC2->C2_XBLQESP:="1"
                SC2->C2_XDTESP :=CTOD(" ")
                If SC2->(FieldPos("C2_MSBLQL")) > 0
                    SC2->C2_MSBLQL :="2"
                End
                MsUnLock()

                cMensagem:="<h2>Prezados</h2>"
                cMensagem+="<p>A ORDEM DE PRODUCAO (OP) <u> <strong>"+SC2->C2_NUM+"</strong> que possue produto(s) especial(ais):</u></p>"
                cMensagem+="<p>foi <strong> PRODUZIDA  </strong> <strong>em "+DTOC(dDataBase)+"</strong> </p>"
                cMensagem+="<p>"+" "+"</p>"
                cMensagem+='<table border="1" cellpadding="1" cellspacing="1" style="width:500px">'
                cMensagem+="<tbody>"
                cMensagem+="<tr>"
                cMensagem+="	<td>Pedido</td>"
                cMensagem+="	<td>Produto</td>"
                cMensagem+="	<td>Descricao</td>"
                cMensagem+="	<td>Unid Medida</td>"
                cMensagem+="	<td>Qtd Produzida</td>"
                cMensagem+="	<td>Data Prevista</td>"
                cMensagem+="	<td>Produzida em</td>"
                cMensagem+="</tr>"
                cMensagem+="<tr>"
                cMensagem+='	<td style="text-align:center">'+SC2->C2_XPEDIDO+"</td>"
                cMensagem+="    <td>"+SB1->B1_COD+"</td>"
                cMensagem+="	<td>"+RTRIM(SB1->B1_DESC)+"</td>"
                cMensagem+='	<td style="text-align: center;">'+SB1->B1_UM+"</td>"
                cMensagem+='	<td style="text-align: center;">'+Transform(SD3->D3_QUANT,"@E 999,999.9999")+"</td>"
                cMensagem+='	<td style="text-align:center">'+DTOC(SC2->C2_DATPRF)+"</td>"
                cMensagem+='	<td style="text-align:center">'+DTOC(dDataBase)+"</td>"
                cMensagem+="</tr>"
                cMensagem+="</tbody>"
                cMensagem+="</table>"
                cMensagem+="<p>"+" "+"</p>"
                cMensagem+="<p>Atenciosamente</p>"

                //Limpando os registros da SC9  - Se houver
                SC9->(dbSetOrder(3))
                SC9->(dbSeek(xFilial("SC9")+SC2->C2_XPEDIDO+SB1->B1_GRUPO+SB1->B1_COD))
                While SC9->(!EOF()) .and. 	SC9->C9_FILIAL 	==  	xFilial("SC9") .and. ;
                        SC9->C9_PEDIDO 	==  	SC2->C2_XPEDIDO .and.;
                        SC9->C9_GRUPO 	== 		SB1->B1_GRUPO .and. ;
                        SC9->C9_PRODUTO ==  	SB1->B1_COD
                    RecLock("SC9",.F.)
                    SC9->(dbDelete())
                    MsUnLock()
                    SC9->(dbSkip())
                End

                U_CPEmail(cEmail," ","Ordem de Producao com Produto Especial - Apontamento OP",cMensagem,"",.F.)

            End
        End
    End

    //If Posicione("SB1",1, xFilial("SB1")+SC2->C2_PRODUTO,"B1_LOCALIZ") == "S"     //Para produtos que controlam localização
        U_DA_HORAG()                                                                // ,(alimentam a tabela SDA), preencho o campo DA_HORA com time() nos registros incluidos hoje que ainda estão com o campo DA_HORA vazio.
    //Endif

    RestArea(aArea)
Return NIL


/*/{Protheus.doc} DA_HORAG
AE250TRAN é o ponto de entrada após a gravação dos dados da rotina MATA250 (Produção). Preencho o campo DA_HORA com time() nos registros incluidos na data atual que ainda estão com o campo DA_HORA vazio, assim garanto que todos os registros são atualizados 
@type function
@author geronimo.alves
@since 09/01/2024
/*/
User Function DA_HORAG(aParam)
  local cQry := ""
  // Geronimo 09/01/2024 P.E. A250ETRAN, MA680INC, MT681INC e MT680VAL
  If ValType(aParam) <> "U"              // Rotina chamada pelo Schedule
	WFPrepEnv(aParam[1],aParam[2])
  Endif

    cQry := " UPDATE SDA100 " 
    cQry += " SET DA_HORA = '" + TIME() + "'  "
    cQry += " WHERE  "
    cQry += " DA_DATA  = '" + DTOS( dDataBase ) + "'  "
    cQry += " AND DA_HORA  = ' ' "
    Conout(" ***** U_DA_HORAG() " + cQry )
    TcSQLExec(cQry)
    
Return

