Aqui estão 10 perguntas analíticas que podem ser usadas para compor dashboards ou relatórios periódicos para o banco de dados de uma rede social:

Essas perguntas são úteis para extrair insights sobre o comportamento dos usuários, o desempenho da plataforma e as tendências na criação e consumo de conteúdo, possibilitando a tomada de decisões estratégicas.

# Esse tópico cumpre os seguites pré requisitos:

- quadro 5 - Domínio de BI
- P1. Perguntas analíticas
- Relatorios ou dashboards
- Quadro 3 - Domínio da aplição - P2. Sub-rotinas de suporte
- ***

### 1. Crescimento de Usuários

- **Pergunta:** Quantos novos usuários se registraram a cada mês no último ano?
- **Objetivo:** Acompanhar o crescimento da base de usuários.

```sql
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
```

---

### 2. Tipo de Conteúdo Mais Utilizado

- **Pergunta:** Qual é a proporção de publicações que utilizam textos, imagens, vídeos ou links nos últimos 6 meses?
- **Objetivo:** Compreender as preferências dos usuários em relação ao tipo de conteúdo.

```sql
CREATE MATERIALIZED VIEW mv_tipo_conteudo AS
SELECT
    COUNT(CASE WHEN c.id_texto IS NOT NULL THEN 1 END) AS total_textos,
    COUNT(CASE WHEN c.id_img IS NOT NULL THEN 1 END) AS total_imagens,
    COUNT(CASE WHEN c.id_video IS NOT NULL THEN 1 END) AS total_videos,
    COUNT(CASE WHEN c.id_link IS NOT NULL THEN 1 END) AS total_links
FROM
    tb_conteudo c
JOIN
    tb_publicacao p ON c.id_conteudo = p.id_conteudo
WHERE
    p.data_publicacao >= now() - interval '6 months';
```

---

### 3. Conexões Estabelecidas

- **Pergunta:** Qual é o número total de conexões criadas por mês no último ano?
- **Objetivo:** Monitorar o engajamento entre os usuários.

```sql
CREATE OR REPLACE VIEW vw_conexoes_estabelecidas AS
SELECT
    DATE_TRUNC('month', c.data_conexao) AS mes,
    COUNT(c.id_conexao) AS total_conexoes
FROM
    tb_conexao c
WHERE
    c.data_conexao >= NOW() - INTERVAL '1 year'
GROUP BY
    DATE_TRUNC('month', c.data_conexao)
ORDER BY
    mes;

```

---

### 4. Usuários com Mais Seguidores

- **Pergunta:** Quem são os 10 usuários com mais seguidores atualmente?
- **Objetivo:** Identificar influenciadores ou usuários populares.

```sql
CREATE OR REPLACE VIEW vw_usuarios_mais_seguidores AS
SELECT
    u.id_usuario,
    u.nome,
    COUNT(c.id_seguidor) AS total_seguidores
FROM
    tb_usuario u
LEFT JOIN
    tb_conexao c ON u.id_usuario = c.id_seguido
GROUP BY
    u.id_usuario, u.nome
ORDER BY
    total_seguidores DESC
LIMIT 10;

```

---

### 5. Publicações Populares

- **Pergunta:** Quais são as 10 publicações com mais coautores?
- **Objetivo:** Avaliar o conteúdo de maior impacto na plataforma.

```sql
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
    total_coautores DESC
LIMIT 10;
```

---

### 6. Atividade dos Usuários

- **Pergunta:** Quem são os 10 usuários mais ativos (em termos de publicações e conexões criadas) no último mês?
- **Objetivo:** Identificar os usuários mais engajados na rede.

```sql
CREATE OR REPLACE PROCEDURE sp_usuarios_mais_ativos()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        u.id_usuario,
        u.nome,
        COUNT(DISTINCT p.id_publicacao) AS total_publicacoes,
        COUNT(DISTINCT c.id_conexao) AS total_conexoes,
        (COUNT(DISTINCT p.id_publicacao) + COUNT(DISTINCT c.id_conexao)) AS pontuacao
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
    LIMIT 10;
END;
$$;
```

---

### 7. Conexões Mútuas

- **Pergunta:** Qual é a porcentagem de conexões que são mútuas (seguidores que também são seguidos)?
- **Objetivo:** Identificar a reciprocidade nas interações da rede.

```sql
CREATE OR REPLACE PROCEDURE sp_conexoes_mutuas()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        c1.id_seguidor AS usuario1,
        c1.id_seguido AS usuario2,
        COUNT(*) AS total_mutuas
    FROM
        tb_conexao c1
    JOIN
        tb_conexao c2
    ON
        c1.id_seguidor = c2.id_seguido AND c1.id_seguido = c2.id_seguidor
    GROUP BY
        c1.id_seguidor, c1.id_seguido
    ORDER BY
        total_mutuas DESC;
END;
$$;
```

---

### 8. Distribuição de Conexões

- **Pergunta:** Qual é a distribuição média de conexões por usuário (quantos seguidores e seguidos, em média)?
- **Objetivo:** Analisar a conectividade da rede social.

```sql
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
```

---

### 9. Retenção de Usuários

- **Pergunta:** Quantos usuários estão ativos (realizaram ao menos uma publicação ou conexão) nos últimos 30 dias em comparação com o mês anterior?
- **Objetivo:** Avaliar a retenção e engajamento dos usuários.

```sql
CREATE OR REPLACE VIEW vw_retencao_usuarios AS
WITH usuarios_ativos_mes_atual AS (
    SELECT DISTINCT u.id_usuario
    FROM tb_usuario u
    LEFT JOIN tb_publicacao p ON u.id_usuario = p.id_publicacao
    LEFT JOIN tb_conexao c ON u.id_usuario = c.id_seguidor
    WHERE
        (p.data_publicacao >= NOW() - INTERVAL '30 days' OR
         c.data_conexao >= NOW() - INTERVAL '30 days')
),
usuarios_ativos_mes_anterior AS (
    SELECT DISTINCT u.id_usuario
    FROM tb_usuario u
    LEFT JOIN tb_publicacao p ON u.id_usuario = p.id_publicacao
    LEFT JOIN tb_conexao c ON u.id_usuario = c.id_seguidor
    WHERE
        (p.data_publicacao >= NOW() - INTERVAL '60 days' AND p.data_publicacao < NOW() - INTERVAL '30 days') OR
        (c.data_conexao >= NOW() - INTERVAL '60 days' AND c.data_conexao < NOW() - INTERVAL '30 days')
)
SELECT
    (SELECT COUNT(*) FROM usuarios_ativos_mes_atual) AS usuarios_ativos_atual,
    (SELECT COUNT(*) FROM usuarios_ativos_mes_anterior) AS usuarios_ativos_anterior;

```

---

### 10. Quais são as palavras mais comuns nos conteudos?

- **Objetivo:** Quais são as palavras mais usadas nos conteudos das publicacoes.

```sql
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
```

Segue uma tabela com as perguntas analíticas, as queries e uma breve descrição do tipo de visualização recomendada para os resultados:

| **Pergunta Analítica**                                                                                   | **Query**                     | **Visualização Recomendada**                                                                                                            |
| -------------------------------------------------------------------------------------------------------- | ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| **Quantos novos usuários se registraram a cada mês no último ano?**                                      | `mv_crescimento_usuarios`     | **Gráfico de linha ou de barras agrupadas por mês:** Mostra o crescimento de usuários ao longo do tempo.                                |
| **Qual é a proporção de publicações que utilizam textos, imagens, vídeos ou links nos últimos 6 meses?** | `mv_tipo_conteudo`            | **Gráfico de pizza ou barras empilhadas:** Exibe a distribuição percentual dos diferentes tipos de conteúdo.                            |
| **Qual é o número total de conexões criadas por mês no último ano?**                                     | `vw_conexoes_estabelecidas`   | **Gráfico de linha ou barras:** Demonstra a evolução do número de conexões estabelecidas mensalmente.                                   |
| **Quem são os 10 usuários com mais seguidores atualmente?**                                              | `vw_usuarios_mais_seguidores` | **Tabela ou gráfico de barras horizontais:** Lista ou visualiza os usuários mais influentes, ordenados pela quantidade de seguidores.   |
| **Quais são as 10 publicações com mais coautores?**                                                      | `vw_publicacoes_populares`    | **Tabela ou gráfico de barras horizontais:** Mostra as publicações com maior número de coautores, evidenciando conteúdos colaborativos. |
| **Quem são os 10 usuários mais ativos (em termos de publicações e conexões criadas) no último mês?**     | `sp_usuarios_mais_ativos`     | **Tabela ou gráfico de barras horizontais:** Destaca os usuários mais engajados com a plataforma no último mês.                         |
| **Qual é a porcentagem de conexões que são mútuas (seguidores que também são seguidos)?**                | `sp_conexoes_mutuas`          | **Indicador numérico ou gráfico de barras horizontais:** Mostra a taxa de reciprocidade entre conexões.                                 |
| **Qual é a distribuição média de conexões por usuário (quantos seguidores e seguidos, em média)?**       | `vw_distribuicao_conexoes`    | **Gráfico de dispersão ou histograma:** Analisa a distribuição de conexões por usuário, com métricas de média e mediana.                |
| **Quantos usuários estão ativos nos últimos 30 dias em comparação com o mês anterior?**                  | `vw_retencao_usuarios`        | **Gráfico de barras ou linha com dois pontos comparativos:** Mostra a evolução do número de usuários ativos mês a mês.                  |
| **Quais são as palavras mais usadas nos conteúdos das publicações?**                                     | `vw_palavras_mais_comuns`     | **Nuvem de palavras ou gráfico de barras:** Realça as palavras mais frequentes nos conteúdos.                                           |
