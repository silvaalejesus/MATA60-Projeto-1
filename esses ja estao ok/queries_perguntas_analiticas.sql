-- total de publicacoes e conexoes de cada usuario
CREATE MATERIALIZED VIEW mv_crescimento_usuarios AS
SELECT 
    DATE_TRUNC('month', data_criacao) AS mes,
    COUNT(id_usuario) AS novos_usuarios
FROM 
    tb_usuario
GROUP BY 
    DATE_TRUNC('month', data_criacao)
ORDER BY 
    mes;

CREATE MATERIALIZED VIEW mv_tipo_conteudo AS
SELECT 
    COUNT(CASE WHEN id_texto IS NOT NULL THEN 1 END) AS total_textos,
    COUNT(CASE WHEN id_img IS NOT NULL THEN 1 END) AS total_imagens,
    COUNT(CASE WHEN id_video IS NOT NULL THEN 1 END) AS total_videos,
    COUNT(CASE WHEN id_link IS NOT NULL THEN 1 END) AS total_links
FROM 
    tb_conteudo;

CREATE OR REPLACE PROCEDURE sp_usuarios_mais_ativos()
LANGUAGE plpgsql
AS $$
DECLARE
  id_usuario integer;
  nome varchar(255);
  total_publicacoes integer;
  total_conexoes integer;
  pontuacao integer;
BEGIN
    SELECT 
        u.id_usuario, 
        u.nome, 
        COUNT(DISTINCT p.id_publicacao), 
        COUNT(DISTINCT c.id_conexao),
        (COUNT(DISTINCT p.id_publicacao) + COUNT(DISTINCT c.id_conexao)) 
        INTO id_usuario, nome, total_publicacoes, total_conexoes, pontuacao
    FROM 
        tb_usuario u
    LEFT JOIN 
        tb_faz_uma f ON u.id_usuario = f.id_usuario
    LEFT JOIN 
        tb_publicacao p ON f.id_publicacao = p.id_publicacao
    LEFT JOIN 
        tb_conexao c ON u.id_usuario = c.id_seguidor
    GROUP BY 
        u.id_usuario, u.nome
    ORDER BY 
        pontuacao DESC
    LIMIT 1; -- Seleciona apenas a primeira linha

    -- Fazer algo com as variáveis 
    RAISE NOTICE 'ID Usuário: %, Nome: %, Total de Publicações: %, Total de Conexões: %, Pontuação: %', id_usuario, nome, total_publicacoes, total_conexoes, pontuacao;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_conexoes_mutuas()
LANGUAGE plpgsql
AS $$
DECLARE
  usuario1 integer;
  usuario2 integer;
  total_mutuas integer;
BEGIN
    SELECT 
        c1.id_seguidor, 
        c1.id_seguido, 
        COUNT(*) INTO usuario1, usuario2, total_mutuas
    FROM 
        tb_conexao c1
    JOIN 
        tb_conexao c2
    ON 
        c1.id_seguidor = c2.id_seguido AND c1.id_seguido = c2.id_seguidor
    GROUP BY 
        c1.id_seguidor, c1.id_seguido
    ORDER BY 
        total_mutuas DESC
    LIMIT 1; -- Seleciona apenas a primeira linha

    -- Fazer algo com as variáveis usuario1, usuario2 e total_mutuas
    RAISE NOTICE 'Usuário 1: %, Usuário 2: %, Total de conexões mútuas: %', usuario1, usuario2, total_mutuas;
END;
$$;

CREATE OR REPLACE VIEW vw_distribuicao_conexoes AS
SELECT 
    u.id_usuario, 
    u.nome, 
    COUNT(DISTINCT c.id_seguidor) AS total_seguidores,
    COUNT(DISTINCT c.id_seguido) AS total_seguidos
FROM 
    tb_usuario u
LEFT JOIN 
    tb_conexao c ON u.id_usuario = c.id_seguido OR u.id_usuario = c.id_seguidor
GROUP BY 
    u.id_usuario, u.nome;

CREATE OR REPLACE VIEW vw_publicacoes_populares AS
SELECT 
    p.id_publicacao,
    c.titulo,
    COUNT(f.id_usuario) AS total_coautores
FROM 
    tb_publicacao p
JOIN 
    tb_conteudo c ON p.id_conteudo = c.id_conteudo
LEFT JOIN 
    tb_faz_uma f ON p.id_publicacao = f.id_publicacao
GROUP BY 
    p.id_publicacao, c.titulo
ORDER BY 
    total_coautores DESC;

CREATE OR REPLACE VIEW vw_atividade_usuarios AS
SELECT 
    u.id_usuario, 
    u.nome, 
    COUNT(DISTINCT f.id_publicacao) AS total_publicacoes,
    COUNT(DISTINCT c.id_conexao) AS total_conexoes
FROM 
    tb_usuario u
LEFT JOIN 
    tb_faz_uma f ON u.id_usuario = f.id_usuario
LEFT JOIN 
    tb_conexao c ON u.id_usuario = c.id_seguidor
GROUP BY 
    u.id_usuario, u.nome
ORDER BY 
    total_publicacoes DESC, total_conexoes DESC;

-- 9. Quais são as palavras mais comuns nos conteudos?
-- Divide conteúdo em palavras e faz contagem
CREATE VIEW vw_palavras_mais_comuns AS
SELECT 
    palavra,
    COUNT(*) AS ocorrencias
FROM (
    SELECT 
        REGEXP_SPLIT_TO_TABLE(titulo, '\s') AS palavra
    FROM tb_conteudo
) palavras
GROUP BY palavra
ORDER BY ocorrencias DESC;

CALL sp_usuarios_mais_ativos();
CALL sp_conexoes_mutuas();