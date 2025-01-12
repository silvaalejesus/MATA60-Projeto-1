-- Materialized Views
-- 1. Materialized View: Publicações e seus Autores
-- Esta materialized view combina informações das publicações com os autores e seus papéis.
CREATE MATERIALIZED VIEW mv_publicacoes_autores AS
SELECT 
    p.id_publicacao,
    c.titulo AS titulo_conteudo,
    STRING_AGG(u.nome || ' (' || up.papel || ')', ', ') AS autores,
    p.data_publicacao
FROM tb_publicacao p
JOIN tb_conteudo c ON p.id_conteudo = c.id_conteudo
JOIN tb_usuario_publicacao up ON p.id_publicacao = up.id_publicacao
JOIN tb_usuario u ON up.id_usuario = u.id_usuario
GROUP BY p.id_publicacao, c.titulo, p.data_publicacao
WITH DATA;

-- Atualizar a materialized view
REFRESH MATERIALIZED VIEW mv_publicacoes_autores;

-- 2. Materialized View: Usuários e Conexões
-- Esta materialized view traz informações sobre os usuários e o número de conexões que eles possuem (seguindo e sendo seguidos).
CREATE MATERIALIZED VIEW mv_usuarios_conexoes AS
SELECT 
    u.id_usuario,
    u.nome,
    (SELECT COUNT(*) FROM tb_conexao WHERE id_seguidor = u.id_usuario) AS total_seguindo,
    (SELECT COUNT(*) FROM tb_conexao WHERE id_seguido = u.id_usuario) AS total_seguidores,
    u.data_criacao
FROM tb_usuario u
WITH DATA;

-- Atualizar a materialized view
REFRESH MATERIALIZED VIEW mv_usuarios_conexoes;