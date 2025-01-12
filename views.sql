-- 1 Taxa de crescimento de novos usuários:
CREATE VIEW vw_crescimento_usuarios AS
SELECT
    DATE(data_criacao) AS data_registro,
    COUNT(id_usuario) AS novos_usuarios
FROM
    tb_usuario
GROUP BY
    data_registro;


-- Top 10 usuários com mais conexões:
CREATE VIEW vw_top_usuarios_conexoes AS
SELECT
    u.nome AS usuario,
    COUNT(c.id_conexao) AS numero_conexoes
FROM
    tb_usuario u
JOIN
    tb_conexao c ON u.id_usuario = c.id_seguidor
GROUP BY
    u.nome
ORDER BY
    numero_conexoes DESC
LIMIT 10;

-- 2 Número médio de publicações por usuário:
CREATE PROCEDURE sp_media_publicacoes_usuario (IN periodo VARCHAR(10))
AS $$
BEGIN
    IF periodo = 'dia' THEN
        SELECT
            DATE(p.data_publicacao) AS data,
            COUNT(DISTINCT up.id_publicacao) / COUNT(DISTINCT up.id_usuario) AS media_publicacoes
        FROM
            tb_faz_uma up
        JOIN
            tb_publicacao p ON up.id_publicacao = p.id_publicacao
        GROUP BY
            data;
    ELSIF periodo = 'semana' THEN
        -- Calcula a média por semana
    ELSIF periodo = 'mes' THEN
        -- Calcula a média por mês
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3 Tipos de conteúdo mais populares:
CREATE VIEW vw_tipos_conteudo_popular AS
SELECT
    'Texto' AS tipo_conteudo,
    COUNT(t.id_texto) AS quantidade
FROM
    tb_texto t
UNION ALL
SELECT
    'Imagem' AS tipo_conteudo,
    COUNT(i.id_img) AS quantidade
FROM
    tb_img i
UNION ALL
SELECT
    'Vídeo' AS tipo_conteudo,
    COUNT(v.id_video) AS quantidade
FROM
    tb_video v
UNION ALL
SELECT
    'Link' AS tipo_conteudo,
    COUNT(l.id_link) AS quantidade
FROM
    tb_link l;

-- 4 Horários de maior atividade:
CREATE VIEW vw_horarios_atividade AS
SELECT
    EXTRACT(HOUR FROM data_publicacao) AS hora,
    COUNT(id_publicacao) AS numero_publicacoes
FROM
    tb_publicacao
GROUP BY
    hora
ORDER BY
    hora;

--  5 Usuários que mais colaboram:
CREATE VIEW vw_usuarios_colaboram AS
SELECT
    u1.nome AS usuario1,
    u2.nome AS usuario2,
    COUNT(up.id_publicacao) AS numero_colaboracoes
FROM
    tb_faz_uma up
JOIN
    tb_usuario u1 ON up.id_usuario = u1.id_usuario
JOIN
    tb_faz_uma up2 ON up.id_publicacao = up2.id_publicacao AND up.id_usuario <> up2.id_usuario
JOIN
    tb_usuario u2 ON up2.id_usuario = u2.id_usuario
GROUP BY
    u1.nome, u2.nome
HAVING
    COUNT(up.id_publicacao) > 1
ORDER BY
    numero_colaboracoes DESC;


-- 6 listar os Tipos de conteúdo mais populares de um usuario
CREATE VIEW vw_top_tipos_conteudo_por_usuario AS
WITH ConteudoClassificado AS (
    SELECT
        c.id_conteudo,
        CASE
            WHEN t.id_texto IS NOT NULL THEN 'Texto'
            WHEN i.id_img IS NOT NULL THEN 'Imagem'
            WHEN v.id_video IS NOT NULL THEN 'Vídeo'
            WHEN l.id_link IS NOT NULL THEN 'Link'
            ELSE 'Outro'
        END AS tipo_conteudo
    FROM
        tb_conteudo c
    LEFT JOIN
        tb_texto t ON c.id_conteudo = t.id_conteudo
    LEFT JOIN
        tb_img i ON c.id_conteudo = i.id_conteudo
    LEFT JOIN
        tb_video v ON c.id_conteudo = v.id_conteudo
    LEFT JOIN
        tb_link l ON c.id_conteudo = l.id_conteudo
),
ContagemPorTipo AS (
    SELECT
        up.id_usuario,
        cc.tipo_conteudo,
        COUNT(*) AS total
    FROM
        tb_faz_uma up
    JOIN
        tb_publicacao p ON up.id_publicacao = p.id_publicacao
    JOIN
        ConteudoClassificado cc ON p.id_conteudo = cc.id_conteudo
    GROUP BY
        up.id_usuario, cc.tipo_conteudo
),
TopTiposPorUsuario AS (
    SELECT
        id_usuario,
        tipo_conteudo,
        total,
        ROW_NUMBER() OVER (PARTITION BY id_usuario ORDER BY total DESC) AS row_number
    FROM
        ContagemPorTipo
)
SELECT
    id_usuario,
    tipo_conteudo,
    total
FROM
    TopTiposPorUsuario
WHERE
    row_number <= 3;


-- 7 Quais usuários mais publicam em coautoria?
CREATE VIEW vw_usuarios_mais_coautores AS
SELECT
    tfu.id_usuario,
    COUNT(tfu.id_publicacao) AS total_coautorias
FROM
    tb_faz_uma tfu
WHERE
    tfu.papel = 'Coautor'
GROUP BY
    tfu.id_usuario
ORDER BY
    total_coautorias DESC;


-- 8 Qual a distribuição de publicações por dia da semana?
CREATE VIEW vw_publicacoes_dia_semana AS
SELECT
    EXTRACT(DOW FROM p.data_publicacao) AS dia_da_semana,
    COUNT(p.id_publicacao) AS total_publicacoes
FROM
    tb_publicacao p
GROUP BY
    dia_da_semana
ORDER BY
    dia_da_semana;