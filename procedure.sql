CREATE OR REPLACE PROCEDURE sp_relatorio_usuarios_ativos()
LANGUAGE plpgsql
AS $$
DECLARE
  rec RECORD;
BEGIN
  -- Gera o relatório com os usuários mais ativos no último mês
  CREATE TEMP TABLE tmp_usuarios_ativos AS
  SELECT
    u.id_usuario,
    u.nome,
    COUNT(DISTINCT p.id_publicacao) AS total_publicacoes,
    COUNT(DISTINCT c.id_conexao) AS total_conexoes,
    (COUNT(DISTINCT p.id_publicacao) + COUNT(DISTINCT c.id_conexao)) AS total_atividade
  FROM tb_usuario u
  LEFT JOIN tb_faz_uma up ON u.id_usuario = up.id_usuario
  LEFT JOIN tb_publicacao p ON up.id_publicacao = p.id_publicacao AND p.data_publicacao >= NOW() - INTERVAL '1 month'
  LEFT JOIN tb_conexao c ON (c.id_seguidor = u.id_usuario OR c.id_seguido = u.id_usuario)
    AND c.data_conexao >= NOW() - INTERVAL '1 month'
  GROUP BY u.id_usuario, u.nome
  ORDER BY total_atividade DESC;

  -- Exibe os usuários mais ativos
  RAISE NOTICE 'Relatório de Usuários Mais Ativos no Último Mês:';
  FOR rec IN
    SELECT * FROM tmp_usuarios_ativos
  LOOP
    RAISE NOTICE 'Usuário: %, Publicações: %, Conexões: %, Atividade Total: %',
      rec.nome, rec.total_publicacoes, rec.total_conexoes, rec.total_atividade;
  END LOOP;

  -- Opcionalmente, retornar os dados para uma tabela persistente
  -- INSERT INTO relatorio_usuarios_ativos (id_usuario, nome, total_publicacoes, total_conexoes, total_atividade)
  -- SELECT * FROM tmp_usuarios_ativos;

  -- Remove a tabela temporária
  DROP TABLE tmp_usuarios_ativos;
END;
$$;

CALL sp_relatorio_usuarios_ativos();