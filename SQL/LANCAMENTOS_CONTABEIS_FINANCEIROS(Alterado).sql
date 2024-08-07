--Lancamentos Contabeis e Financeiros
--LANCAMENTOS_CONTABEIS_FINANCEIROS

DECLARE @DATA_1         DATE = :DATA_1
DECLARE @DATA_2         DATE = :DATA_2
DECLARE @TIPO           VARCHAR(1) = :TIPO
DECLARE @OPERACAO       VARCHAR(1) = :OPERACAO
DECLARE @CONTA_CONTABIL NUMERIC(15) = :CONTA_CONTABIL

-- DECLARE @DATA_1         DATE         = '01.10.2023'
-- DECLARE @DATA_2         DATE         = '31.10.2023'
-- DECLARE @TIPO           VARCHAR(1)   = 'F'                   
-- DECLARE @OPERACAO       VARCHAR(1)   = 'D'
-- DECLARE @CONTA_CONTABIL NUMERIC(15)  = 694
--
-- IF OBJECT_ID('TEMPDB..#BASE') IS NOT NULL      
--     DROP TABLE #BASE

SELECT A.ENTIDADE                   
     , A.NOME
     , A.FORMULARIO
     , A.REGISTRO
     , A.VALOR
     , A.DATA
     , A.OPERACAO
     , A.TIPO           
     , A.CONTA
     , A.TIPO_FINANCEIRO
     , A.TELEVENDA
     , A.VALOR_TELEVENDA
     , A.BLOCO
     , A.NF_NUMERO

-- INTO #BASE
FROM (
		--PRIMEIRA PARTE, BUSCA NA TABELA CONTABIL_LANCAMENTOS
		--OPÇÕES CONTABIL E DEBITO
		--NÃO TRAZ O NUMERO DA NOTA FISCAL, MAS APENAS DEIXA A COLUNA NULA
		--TELEVENDA, VALOR_TELEVENDA E NF NULAS
		--NUMERO DO BLOCO DE EXECUÇÃO 1
		SELECT A.ENTIDADE 
           , DBO.FN_ESCONDETEXTO(C.NOME)                                     [NOME]
           , B.FORMULARIO
           , A.REG_MASTER_ORIGEM                                          AS REGISTRO
           , A.VALOR
           , CONVERT(VARCHAR(10), A.DATA, 103)                            AS DATA
           , 'DEBITO'                                                     AS OPERACAO
           , 'CONTABIL'                                                   AS TIPO
           , CONVERT(VARCHAR(5), D.CODIGO_REDUZIDO) + ' - ' + D.DESCRICAO AS CONTA
           , ''                                                           AS TIPO_FINANCEIRO
           , NULL                                                         AS TELEVENDA
           , NULL                                                         AS VALOR_TELEVENDA
           , 1                                                            AS BLOCO
           , T.NF_NUMERO                                                  AS NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM CONTABIL_LANCAMENTOS A (NOLOCK)
               LEFT JOIN FORMULARIOS B (NOLOCK) ON B.NUMID = A.FORMULARIO_ORIGEM
               LEFT JOIN ENTIDADES C (NOLOCK) ON C.ENTIDADE = A.ENTIDADE
               LEFT JOIN PLANO_CONTAS D (NOLOCK) ON D.CODIGO_REDUZIDO = @CONTA_CONTABIL
			   
OUTER APPLY (SELECT TOP 1 T.NF_NUMERO, T.OPERACAO_FISCAL --CODIGO ADICIONADO PELO VLAD PARA PUXAR A NOTA FISCAL DE ACORDO COM O FORMULARIO
                      FROM (SELECT TOP 1 X.NF_NUMERO, X.OPERACAO_FISCAL
                            FROM NF_FATURAMENTO X (NOLOCK)
                            WHERE X.NF_FATURAMENTO = A.REG_MASTER_ORIGEM
                              AND A.FORMULARIO_ORIGEM = 753537

                            UNION ALL

                            SELECT TOP 1 X.NF_NUMERO, Y.OPERACAO_FISCAL
                            FROM DEV_PRODUTOS_TELEVENDAS      X (NOLOCK)
                                     JOIN DEV_PRODUTOS_CAIXAS Y (NOLOCK) ON Y.DEVOLUCAO_PRODUTO = X.DEVOLUCAO_PRODUTO
                            WHERE X.DEVOLUCAO_PRODUTO = A.REG_MASTER_ORIGEM
                              AND A.FORMULARIO_ORIGEM = 437752

                            UNION ALL

                            SELECT TOP 1 Y.NF_NUMERO, Y.OPERACAO_FISCAL
                            FROM CANCELAMENTOS_NOTAS_FISCAIS X (NOLOCK)
                                     JOIN NF_FATURAMENTO     Y (NOLOCK) ON Y.NF_FATURAMENTO = X.CHAVE
                            WHERE X.NF_CANCELAMENTO = A.REG_MASTER_ORIGEM
                              AND X.FORMULARIO_ORIGEM = 561664
                              AND X.TIPO = 1) T)    T  
							  
      WHERE CONVERT(DATE, A.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL_DEBITO = @CONTA_CONTABIL
        AND @tipo = 'C'
        AND @OPERACAO = 'D'


      UNION ALL
		--PRIMEIRA PARTE, BUSCA NA TABELA CONTABIL_LANCAMENTOS
		--OPÇÕES CONTABIL E CREDITO
		--NÃO TRAZ O NUMERO DA NOTA FISCAL, MAS APENAS DEIXA A COLUNA NULA
		--TELEVENDA, VALOR_TELEVENDA E NF NULAS
		--NUMERO DO BLOCO DE EXECUÇÃO 2

      SELECT A.ENTIDADE
           , DBO.FN_ESCONDETEXTO(C.NOME)                                     [NOME]
           , B.FORMULARIO
           , A.REG_MASTER_ORIGEM                                          AS REGISTRO
           , A.VALOR
           , CONVERT(VARCHAR(10), A.DATA, 103)                            AS DATA
           , 'CREDITO'                                                    AS OPERACAO
           , 'CONTABIL'                                                   AS TIPO
           , CONVERT(VARCHAR(5), D.CODIGO_REDUZIDO) + ' - ' + D.DESCRICAO AS CONTA
           , ''                                                           AS TIPO_FINANCEIRO
           , NULL                                                         AS TELEVENDA
           , NULL                                                         AS TELEVENDA
           , 2                                                            AS BLOCO
           , T.NF_NUMERO                                                  AS NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM CONTABIL_LANCAMENTOS A (NOLOCK)
               LEFT JOIN FORMULARIOS B (NOLOCK) ON B.NUMID = A.FORMULARIO_ORIGEM
               LEFT JOIN ENTIDADES C (NOLOCK) ON C.ENTIDADE = A.ENTIDADE
               LEFT JOIN PLANO_CONTAS D (NOLOCK) ON D.CODIGO_REDUZIDO = @CONTA_CONTABIL	
			   
OUTER APPLY (SELECT TOP 1 T.NF_NUMERO, T.OPERACAO_FISCAL --CODIGO ADICIONADO PELO VLAD PARA PUXAR A NOTA FISCAL DE ACORDO COM O FORMULARIO
                      FROM (SELECT TOP 1 X.NF_NUMERO, X.OPERACAO_FISCAL
                            FROM NF_FATURAMENTO X (NOLOCK)
                            WHERE X.NF_FATURAMENTO = A.REG_MASTER_ORIGEM
                              AND A.FORMULARIO_ORIGEM = 753537

                            UNION ALL

                            SELECT TOP 1 X.NF_NUMERO, Y.OPERACAO_FISCAL
                            FROM DEV_PRODUTOS_TELEVENDAS      X (NOLOCK)
                                     JOIN DEV_PRODUTOS_CAIXAS Y (NOLOCK) ON Y.DEVOLUCAO_PRODUTO = X.DEVOLUCAO_PRODUTO
                            WHERE X.DEVOLUCAO_PRODUTO = A.REG_MASTER_ORIGEM
                              AND A.FORMULARIO_ORIGEM = 437752

                            UNION ALL

                            SELECT TOP 1 Y.NF_NUMERO, Y.OPERACAO_FISCAL
                            FROM CANCELAMENTOS_NOTAS_FISCAIS X (NOLOCK)
                                     JOIN NF_FATURAMENTO     Y (NOLOCK) ON Y.NF_FATURAMENTO = X.CHAVE
                            WHERE X.NF_CANCELAMENTO = A.REG_MASTER_ORIGEM
                              AND X.FORMULARIO_ORIGEM = 561664
                              AND X.TIPO = 1) T)    T  	
							  
      WHERE CONVERT(DATE, A.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL_CREDITO = @CONTA_CONTABIL
        AND @tipo = 'C'
        AND @OPERACAO = 'C'

      UNION ALL
			--PRIMEIRA PARTE, BUSCA NA TABELA TITULOS_PAGAR
			--TRAZ INFORMAÇÕES SOBRE TELEVENDA, VALOR_TELEVENDA E NOTA FISCAL
			--TELEVENDA A PARTIR DA TABELA DEV_PRODUTOS_TELEVENDAS E DEVOLUCOES_NEGOCIACOES_CANCELAMENTOS
			--VALOR_TELEVENDA A PARTIR DA TABELA TELEVENDAS_TOTAIS E TELEVENDAS_TOTAIS
			-- FINANCEIRO CREDITO
			--NUMERO DO BLOCO DE EXECUÇÃO 3

      SELECT A.ENTIDADE
           , DBO.FN_ESCONDETEXTO(B.NOME)                                     [NOME]
           , D.FORMULARIO
           , C.REG_MASTER_ORIGEM                                          AS REGISTRO
           , CREDITO                                                      AS VALOR
           , CONVERT(VARCHAR(10), C.DATA, 103)                            AS DATA
           , 'CREDITO'                                                    AS OPERACAO
           , 'FINANCEIRO'                                                 AS TIPO
           , CONVERT(VARCHAR(5), E.CODIGO_REDUZIDO) + ' - ' + E.DESCRICAO AS CONTA
           , 'CP'                                                         AS TIPO_FINANCEIRO
           , COALESCE(H.TELEVENDA, J.TELEVENDA)                           AS TELEVENDA
           , COALESCE(I.TOTAL_GERAL, K.TOTAL_GERAL)                       AS VALOR_TELEVENDA
           , 3                                                            AS BLOCO
           , G.NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM TITULOS_PAGAR A (NOLOCK)
               JOIN ENTIDADES B (NOLOCK) ON B.ENTIDADE = A.ENTIDADE
               JOIN TITULOS_PAGAR_TRANSACOES C (NOLOCK) ON C.TITULO_PAGAR = A.TITULO_PAGAR
               LEFT JOIN FORMULARIOS D (NOLOCK) ON D.NUMID = C.FORMULARIO_ORIGEM
               LEFT JOIN PLANO_CONTAS E (NOLOCK) ON E.CODIGO_REDUZIDO = @CONTA_CONTABIL
			   
               LEFT JOIN DEVOLUCOES_NEGOCIACOES F (NOLOCK)
                         ON F.TAB_MASTER_ORIGEM = A.TAB_MASTER_ORIGEM
                             AND F.FORMULARIO_ORIGEM = A.FORMULARIO_ORIGEM
                             AND F.DEVOLUCAO_NEGOCIACAO = A.REG_MASTER_ORIGEM
							 
               LEFT JOIN DEVOLUCOES_NEGOCIACOES_DEV_PRODUTOS G (NOLOCK)
                         ON G.FORMULARIO_ORIGEM = F.FORMULARIO_ORIGEM
                             AND G.TAB_MASTER_ORIGEM = F.TAB_MASTER_ORIGEM
                             AND G.REG_MASTER_ORIGEM = F.DEVOLUCAO_NEGOCIACAO
                             AND G.DEVOLUCAO_NEGOCIACAO = F.DEVOLUCAO_NEGOCIACAO
							 
               LEFT JOIN DEV_PRODUTOS_TELEVENDAS H (NOLOCK) ON H.DEVOLUCAO_PRODUTO = G.DEVOLUCAO_PRODUTO
               LEFT JOIN TELEVENDAS_TOTAIS I (NOLOCK) ON I.TELEVENDA = H.TELEVENDA
			   
               LEFT JOIN DEVOLUCOES_NEGOCIACOES_CANCELAMENTOS J (NOLOCK)
                         ON J.FORMULARIO_ORIGEM = F.FORMULARIO_ORIGEM
                             AND J.TAB_MASTER_ORIGEM = F.TAB_MASTER_ORIGEM
                             AND J.REG_MASTER_ORIGEM = F.DEVOLUCAO_NEGOCIACAO
                             AND J.DEVOLUCAO_NEGOCIACAO = F.DEVOLUCAO_NEGOCIACAO
							 
               LEFT JOIN TELEVENDAS_TOTAIS K (NOLOCK) ON K.TELEVENDA = J.TELEVENDA
      WHERE CREDITO > 0
        AND CONVERT(DATE, C.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL = @CONTA_CONTABIL
        AND @tipo = 'F'
        AND @OPERACAO = 'C'

      UNION ALL
			--PRIMEIRA PARTE, BUSCA NA TABELA TITULOS_PAGAR
			--TRAZ INFORMAÇÕES SOBRE TELEVENDA, VALOR_TELEVENDA E NOTA FISCAL
			--TELEVENDA A PARTIR DA TABELA DEV_PRODUTOS_TELEVENDAS E DEVOLUCOES_NEGOCIACOES_CANCELAMENTOS
			--VALOR_TELEVENDA A PARTIR DA TABELA TELEVENDAS_TOTAIS E TELEVENDAS_TOTAIS
			-- FINANCEIRO DEBITO
			--NUMERO DO BLOCO DE EXECUÇÃO 4

      SELECT A.ENTIDADE
           , DBO.FN_ESCONDETEXTO(B.NOME)                                     [NOME]
           , D.FORMULARIO
           , C.REG_MASTER_ORIGEM                                          AS REGISTRO
		   , A.TITULO_PAGAR
           , DEBITO                                                       AS VALOR
           , CONVERT(VARCHAR(10), C.DATA, 103)                            AS DATA
           , 'DEBITO'                                                     AS OPERACAO
           , 'FINANCEIRO'                                                 AS TIPO
           , CONVERT(VARCHAR(5), E.CODIGO_REDUZIDO) + ' - ' + E.DESCRICAO AS CONTA
           , 'CP'                                                         AS TIPO_FINANCEIRO
           , COALESCE(H.TELEVENDA, J.TELEVENDA)                           AS TELEVENDA
           , COALESCE(I.TOTAL_GERAL, K.TOTAL_GERAL)                       AS VALOR_TELEVENDA
           , 4                                                            AS BLOCO
           , G.NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM TITULOS_PAGAR A (NOLOCK)
               JOIN ENTIDADES B (NOLOCK) ON B.ENTIDADE = A.ENTIDADE
               JOIN TITULOS_PAGAR_TRANSACOES C (NOLOCK) ON C.TITULO_PAGAR = A.TITULO_PAGAR
               LEFT JOIN FORMULARIOS D (NOLOCK) ON D.NUMID = C.FORMULARIO_ORIGEM
               LEFT JOIN PLANO_CONTAS E (NOLOCK) ON E.CODIGO_REDUZIDO = @CONTA_CONTABIL
               LEFT JOIN DEVOLUCOES_NEGOCIACOES F (NOLOCK)
                         ON F.TAB_MASTER_ORIGEM = A.TAB_MASTER_ORIGEM
                             AND F.FORMULARIO_ORIGEM = A.FORMULARIO_ORIGEM
                             AND F.DEVOLUCAO_NEGOCIACAO = A.REG_MASTER_ORIGEM
               LEFT JOIN DEVOLUCOES_NEGOCIACOES_DEV_PRODUTOS G (NOLOCK)
                         ON G.FORMULARIO_ORIGEM = F.FORMULARIO_ORIGEM
                             AND G.TAB_MASTER_ORIGEM = F.TAB_MASTER_ORIGEM
                             AND G.REG_MASTER_ORIGEM = F.DEVOLUCAO_NEGOCIACAO
                             AND G.DEVOLUCAO_NEGOCIACAO = F.DEVOLUCAO_NEGOCIACAO
               LEFT JOIN DEV_PRODUTOS_TELEVENDAS H (NOLOCK) ON H.DEVOLUCAO_PRODUTO = G.DEVOLUCAO_PRODUTO
               LEFT JOIN TELEVENDAS_TOTAIS I (NOLOCK) ON I.TELEVENDA = H.TELEVENDA
               LEFT JOIN DEVOLUCOES_NEGOCIACOES_CANCELAMENTOS J (NOLOCK)
                         ON J.FORMULARIO_ORIGEM = F.FORMULARIO_ORIGEM
                             AND J.TAB_MASTER_ORIGEM = F.TAB_MASTER_ORIGEM
                             AND J.REG_MASTER_ORIGEM = F.DEVOLUCAO_NEGOCIACAO
                             AND J.DEVOLUCAO_NEGOCIACAO = F.DEVOLUCAO_NEGOCIACAO
               LEFT JOIN TELEVENDAS_TOTAIS K (NOLOCK) ON K.TELEVENDA = J.TELEVENDA
      WHERE DEBITO > 0
        AND CONVERT(DATE, C.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL = @CONTA_CONTABIL
        AND @tipo = 'F'
        AND @OPERACAO = 'D'

-- Titulos Receber
      union all
			--PRIMEIRA PARTE, BUSCA NA TABELA TITULOS_RECEBER
			--TRAZ INFORMAÇÕES SOBRE TELEVENDA_MASTER, VALOR_TELEVENDA E NOTA FISCAL
			--TELEVENDA A PARTIR DA TABELA TELEVENDAS
			--VALOR_TELEVENDA A PARTIR DA TABELA TELEVENDAS_MASTER_TOTAIS
			-- FINANCEIRO CREDITO
			--NUMERO DO BLOCO DE EXECUÇÃO  5
      SELECT A.ENTIDADE
           , DBO.FN_ESCONDETEXTO(B.NOME)                                     [NOME]
           , D.FORMULARIO
           , C.REG_MASTER_ORIGEM                                          AS REGISTRO
           , CREDITO                                                      AS VALOR
           , CONVERT(VARCHAR(10), C.DATA, 103)                            AS DATA
           , 'CREDITO'                                                    AS OPERACAO
           , 'FINANCEIRO'                                                 AS TIPO
           , CONVERT(VARCHAR(5), E.CODIGO_REDUZIDO) + ' - ' + E.DESCRICAO AS CONTA
           , 'CR'                                                         AS TIPO_FINANCEIRO
           , G.TELEVENDA                                                  AS TELEVENDA_MASTER
           , F.TOTAL_GERAL                                                AS VALOR_TELEVENDA
           , 5                                                            AS BLOCO
           , H.NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM TITULOS_RECEBER A (NOLOCK)

               JOIN ENTIDADES B (NOLOCK) ON B.ENTIDADE = A.ENTIDADE
               JOIN TITULOS_RECEBER_TRANSACOES C (NOLOCK) ON C.TITULO_RECEBER = A.TITULO_RECEBER
               LEFT JOIN FORMULARIOS D (NOLOCK) ON D.NUMID = C.FORMULARIO_ORIGEM
               LEFT JOIN PLANO_CONTAS E (NOLOCK) ON E.CODIGO_REDUZIDO = @CONTA_CONTABIL
               LEFT JOIN TELEVENDAS_MASTER_TOTAIS F (NOLOCK)
                         ON F.FORMULARIO_ORIGEM = A.FORMULARIO_ORIGEM
                             AND F.TAB_MASTER_ORIGEM = A.TAB_MASTER_ORIGEM
                             AND F.REG_MASTER_ORIGEM = A.REG_MASTER_ORIGEM
                             AND F.TELEVENDA_MASTER_TOTAL = A.REGISTRO_CONTROLE
                             AND F.MODALIDADE = A.REGISTRO_CONTROLE_II
               LEFT JOIN TELEVENDAS G (NOLOCK) ON G.TELEVENDA_MASTER = F.TELEVENDA_MASTER


               OUTER APPLY (SELECT TOP 1 AA.NF_NUMERO
                            FROM TITULOS_RECEBER_NF_FATURAMENTO AA (NOLOCK)
                            WHERE AA.TITULO_RECEBER = A.TITULO_RECEBER) H

      WHERE CREDITO > 0
        AND CONVERT(DATE, C.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL = @CONTA_CONTABIL
        AND @tipo = 'F'
        AND @OPERACAO = 'C'

      UNION ALL

			--PRIMEIRA PARTE, BUSCA NA TABELA TITULOS_RECEBER
			--TRAZ INFORMAÇÕES SOBRE TELEVENDA_MASTER, VALOR_TELEVENDA E NOTA FISCAL
			--TELEVENDA A PARTIR DA TABELA TELEVENDAS
			--VALOR_TELEVENDA A PARTIR DA TABELA TELEVENDAS_MASTER_TOTAIS
			-- FINANCEIRO DEBITO
			--NUMERO DO BLOCO DE EXECUÇÃO  6
      SELECT A.ENTIDADE
           , DBO.FN_ESCONDETEXTO(B.NOME)                                     [NOME]
           , D.FORMULARIO
           , C.REG_MASTER_ORIGEM                                          AS REGISTRO
           , DEBITO                                                       AS VALOR
           , CONVERT(VARCHAR(10), C.DATA, 103)                            AS DATA
           , 'DEBITO'                                                     AS OPERACAO
           , 'FINANCEIRO'                                                 AS TIPO
           , CONVERT(VARCHAR(5), E.CODIGO_REDUZIDO) + ' - ' + E.DESCRICAO AS CONTA
           , 'CR'                                                         AS TIPO_FINANCEIRO
           , G.TELEVENDA                                                  AS TELEVENDA_MASTER
           , F.TOTAL_GERAL                                                AS VALOR_TELEVENDA
           , 6                                                            AS BLOCO
           , H.NF_NUMERO -- PATRÍCIA 04.05.2022

      FROM TITULOS_RECEBER A (NOLOCK)
               JOIN ENTIDADES B (NOLOCK) ON B.ENTIDADE = A.ENTIDADE
               JOIN TITULOS_RECEBER_TRANSACOES C (NOLOCK) ON C.TITULO_RECEBER = A.TITULO_RECEBER
               LEFT JOIN FORMULARIOS D (NOLOCK) ON D.NUMID = C.FORMULARIO_ORIGEM
               LEFT JOIN PLANO_CONTAS E (NOLOCK) ON E.CODIGO_REDUZIDO = @CONTA_CONTABIL
               LEFT JOIN TELEVENDAS_MASTER_TOTAIS F (NOLOCK) ON F.FORMULARIO_ORIGEM = A.FORMULARIO_ORIGEM
          AND F.TAB_MASTER_ORIGEM = A.TAB_MASTER_ORIGEM
          AND F.REG_MASTER_ORIGEM = A.REG_MASTER_ORIGEM
          AND F.TELEVENDA_MASTER_TOTAL = A.REGISTRO_CONTROLE
          AND F.MODALIDADE = A.REGISTRO_CONTROLE_II
               LEFT JOIN TELEVENDAS G (NOLOCK) ON G.TELEVENDA_MASTER = F.TELEVENDA_MASTER

               OUTER APPLY (SELECT TOP 1 AA.NF_NUMERO
                            FROM TITULOS_RECEBER_NF_FATURAMENTO AA (NOLOCK)
                            WHERE AA.TITULO_RECEBER = A.TITULO_RECEBER) H

      WHERE DEBITO > 0
        AND CONVERT(DATE, C.DATA) BETWEEN @data_1 AND @data_2
        AND A.CCONTABIL = @CONTA_CONTABIL
        AND @tipo = 'F'
        AND @OPERACAO = 'D') A
