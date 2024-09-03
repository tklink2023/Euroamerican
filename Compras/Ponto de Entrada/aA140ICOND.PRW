#Include 'Protheus.ch'

User Function A140ICOND()

Local cForn     := PARAMIXB[1]
Local cLoja     := PARAMIXB[2]
Local cCongPgto := PARAMIXB[3]

cCondPgto := SC7->C7_COND

//Customizações do cliente
MSGALERT("ALTERANDO AS CONDIÇÃO DE PAGAMENTO  VEIO "+PARAMIXB[3]+" TROCANDO POR "+SC7->C7_COND)

Return cCondPgto
