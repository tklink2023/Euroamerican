
#Include "protheus.ch"

User Function GerarGrafico()

    Local nCapacidade   := 5000  // 5 toneladas
    Local nTotalTinta   := 0
    Local aOrdens       :=0

    // Consultando as ordens de produção (SC2) direcionadas ao contêiner
    aOrdens := 10000 //DbSelect("SELECT SUM(QTAPRODUCAO) AS QTATOTAL FROM SC2 WHERE CONTENEDOR = 'TINTA1'") // Exemplo, substitua pelo filtro correto

    IF Empty(aOrdens)
        MsgStop("Não há ordens de produção para o contêiner.", "Aviso")
        RETURN
    ENDIF

    nTotalTinta := aOrdens  // Soma total de tinta recebida

    // Garantir que o total de tinta não ultrapasse a capacidade do contêiner
    IF nTotalTinta > nCapacidade
        nTotalTinta := nCapacidade
    ENDIF

    // Criando o gráfico de preenchimento do contêiner
    // O gráfico será uma barra representando a quantidade de tinta no contêiner
    Graficos( "Contêiner de Tinta", "Preenchimento do Contêiner",0, 0, 500, 200,"Quantidade de Tinta (kg)", "Preenchimento",1, { {nTotalTinta, nCapacidade} }, { RGB(255, 0, 0), RGB(0, 255, 0) },.T. )  

    // Exibindo o gráfico com a quantidade de tinta
    MsgInfo("O contêiner foi preenchido com " + Str(nTotalTinta) + " kg de tinta.", "Informação")

Return

