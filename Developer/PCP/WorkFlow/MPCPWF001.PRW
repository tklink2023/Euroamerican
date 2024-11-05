#Include 'Totvs.Ch'
#Include 'Protheus.Ch'
#Include 'Rwmake.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'
#DEFINE cEof  CHAR(13)+CHAR(10)
User Function MPCPWF001()
    Local cArea         := FwGetArea()
    Local cAlias        := GetNextAlias()
    Local cQuery        := ''

    Local cPara         := GetMv("ES_EMAILWF")
    Local aCabec      as Array
    Local aColunas    as Array
    Local cAssunto   := ""
    Local cCorpo     := ""
    Local aAnexos    := {}
    Local cMensagem  := ""
    
    cQuery :="Select   C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,B1_DESC,B1_TIPO,B1_MSBLQL,C2_QUANT,C2_EMISSAO,C2_DATPRF,DATEDIFF(DD,C2_EMISSAO, GETDATE()) DIAS  "+cEof 
    cQuery +="FROM "+ RetSqlName("SC2")+" SC2  "+cEof  
    cQuery +="INNER JOIN "+ RetSqlName("SB1")+" SB1 ON B1_COD = C2_PRODUTO AND SB1.D_E_L_E_T_ = ' '  "+cEof 
    cQuery +="WHERE SC2.D_E_L_E_T_ = ' '  "+cEof 
    cQuery +="and C2_FILIAL =  '0803'  "+cEof 
    cQuery +="AND C2_DATRF = ' ' "+cEof 
    cQuery +="AND DATEDIFF(DD,C2_EMISSAO, GETDATE()) > 15  "+cEof 
    cQuery +="ORDER BY C2_FILIAL,C2_NUM,C2_ITEM  "+cEof        
    cQuery := ChangeQuery(cQuery)

    If !Empty(Select(cAlias))
        DbSelectArea(cAlias)
        (cAlias)->(dbCloseArea())
    Endif
                
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	
	TCSetField(cAlias, "C2_EMISSAO" , "D")	
    TCSetField(cAlias, "C2_DATPRF"  , "D")	
    TCSetField(cAlias, "C2_QUANT"   , "N",9,3)	

    if (cAlias)->( Eof())
                FwRestArea(cArea)
                RETURN
    Endif

	aAdd( aCabec, {{'<B><Font Size=4 color=white>Log do Evento</Font></B>', '6', 100, 6, 'C'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' +"Relacao das Ordem Producao Paradas"+'</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Tipo NF</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + "Emissao: " + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})

    aColunas := {}
	aAdd( aColunas, {'Ordem'	    			, 12	, 'C'})
	aAdd( aColunas, {'Produto'					, 15	, 'C'})
    aAdd( aColunas, {'Descricao'		    	, 30	, 'C'})
	aAdd( aColunas, {'Tipo'						, 05	, 'C'})
    aAdd( aColunas, {'Situacao'					, 10	, 'C'})
	aAdd( aColunas, {'Quantidade'	    		, 15	, 'C'})
	aAdd( aColunas, {'Emissao'					, 08	, 'C'})
	aAdd( aColunas, {'Entrega'					, 08	, 'C'})
    aAdd( aColunas, {'Atraso'					, 08	, 'C'})
	cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

    While (cAlias)->(!EOF())

            aColunas := {}
            aAdd( aColunas, {AllTrim((cAlias)->C2_NUM+(cAlias)->C2_ITEM+(cAlias)->C2_SEQUEN), 12	, 'C'})
            aAdd( aColunas, {AllTrim((cAlias)->C2_PRODUTO)	  		                        , 15	, 'C'})
            aAdd( aColunas, {AllTrim((cAlias)->B1_DESC)	    	                            , 30	, 'C'})
            aAdd( aColunas, {AllTrim((cAlias)->B1_TIPO)		  	                            , 05	, 'C'})
            aAdd( aColunas, {AllTrim((IIF((cAlias)->B1_MSBLQL<>'2',"Bloqueado","Ativo")))   , 10	, 'C'})
            aAdd( aColunas, {AllTrim(Transform((cAlias)->C2_QUANT,"@E 999,999.999"))	    , 08	, 'C'})
            aAdd( aColunas, {Dtoc((cAlias)->C2_EMISSAO)			  	                        , 08	, 'C'})
            aAdd( aColunas, {Dtoc((cAlias)->C2_DATPRF)			  	                        , 08	, 'C'})
            aAdd( aColunas, {Transform((cAlias)->DIAS,"@R 9999")                            , 08	, 'C'})
            cMensagem += U_BeHtmDet( aColunas, .F. , .F. )
            (cAlias)->(dbSkip() )

    EndDo
    cMensagem += U_BeHtmRod(.T.)
    (cAlias)->(DbCloseArea())		

    cAssunto := "Relacao das Ordens de Produção Paradas"
    cCorpo   := cMensagem
    aAnexos  :={}

    lEnvio   := u_TManagerEmail(cPara, cAssunto, cCorpo, aAnexos, lExibeHelp, .T.)
   
    If lEnvio
        FWAlertSuccess("Sucesso no disparo do e-Mail", "Sucesso")
    Else
        FWAlertError("Falha no disparo do e-Mail", "Atenção (Erro)")
    EndIf


    FwRestArea(cArea)
Return  
