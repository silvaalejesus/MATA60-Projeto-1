# Documentação do Banco de Dados da Rede Social

## Requisitos funcionais

### RF1. Gerenciamento de Usuários

- Registro de usuários com validação de email único.
- Criptografia de senhas ao armazenar.

### RF2. Conexões entre Usuários

- Possibilidade de "seguir" e "deixar de seguir" outros usuários.
- Histórico das conexões.

### RF3. Publicações

- Publicação de textos, imagens, vídeos e links.
- Registro de autoria e colaboração por meio da tabela `tb_faz_uma`.

### RF4. Organização de Conteúdo

- Classificação e agrupamento de conteúdos por tipo.

### RF5. Interface de Pesquisa

- Busca por usuários, conteúdos ou conexões com filtros por data e tipo.

## Delimitação do minimundo para o banco de dados

### 1. Tabela: `tb_usuario`

**Descrição:** Armazena informações dos usuários registrados na plataforma.

- **id_usuario** (SERIAL): Identificador único do usuário.
- **nome** (VARCHAR(100)): Nome do usuário. _Obrigatório._
- **email** (VARCHAR(150)): Email do usuário. _Obrigatório._
- **senha** (TEXT): Senha criptografada do usuário. _Obrigatório._
- **data_criacao** (TIMESTAMP): Data de criação do registro. _Padrão: CURRENT_TIMESTAMP._

### 2. Tabela: `tb_conexao`

**Descrição:** Representa conexões entre usuários (seguidores e seguidos).

- **id_conexao** (SERIAL): Identificador único da conexão.
- **id_seguidor** (INT): Identificador do usuário que segue. _Obrigatório._
- **id_seguido** (INT): Identificador do usuário seguido. _Obrigatório._
- **data_conexao** (TIMESTAMP): Data de criação da conexão. _Padrão: CURRENT_TIMESTAMP._

### 3. Tabela: `tb_publicacao`

**Descrição:** Armazena informações básicas sobre publicações realizadas pelos usuários.

- **id_publicacao** (SERIAL): Identificador único da publicação.
- **id_conteudo** (INT): Identificador do conteúdo relacionado. _Obrigatório._
- **data_publicacao** (TIMESTAMP): Data de publicação. _Padrão: CURRENT_TIMESTAMP._

### 4. Tabela: `tb_conteudo`

**Descrição:** Armazena diferentes tipos de conteúdo (texto, imagem, vídeo, link).

- **id_conteudo** (SERIAL): Identificador único do conteúdo.
- **titulo** (VARCHAR(50)): Título do conteúdo.
- **data_criacao** (TIMESTAMP): Data de criação do conteúdo. _Padrão: CURRENT_TIMESTAMP._
- **id_texto** (INT): Identificador do conteúdo de texto.
- **id_img** (INT): Identificador do conteúdo de imagem.
- **id_video** (INT): Identificador do conteúdo de vídeo.
- **id_link** (INT): Identificador do conteúdo de link.

### 5. Tabela: `tb_texto`

**Descrição:** Armazena conteúdos em formato de texto.

- **id_texto** (SERIAL): Identificador único do texto.
- **conteudo_texto** (TEXT): Texto do conteúdo. _Obrigatório._

### 6. Tabela: `tb_img`

**Descrição:** Armazena informações de imagens.

- **id_img** (SERIAL): Identificador único da imagem.
- **url_img** (TEXT): URL da imagem. _Obrigatório._

### 7. Tabela: `tb_video`

**Descrição:** Armazena informações de vídeos.

- **id_video** (SERIAL): Identificador único do vídeo.
- **url_video** (TEXT): URL do vídeo. _Obrigatório._

### 8. Tabela: `tb_link`

**Descrição:** Armazena informações de links externos.

- **id_link** (SERIAL): Identificador único do link.
- **url_link** (TEXT): URL do link. _Obrigatório._

# Modelo Conceitual:

## ![mer](rede_social_MER.png)

# Modelo Lógico:

## ![der](rede_social_DER.png)

# Criando a estrutura relacional do SGBD

## CRIAR BANCO E TABELAS

```sql
CREATE TABLE IF NOT EXISTS tb_usuario (
    id_usuario SERIAL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    senha TEXT NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_conexao (
    id_conexao SERIAL,
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    data_conexao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_publicacao (
    id_publicacao SERIAL,
    id_conteudo INT NOT NULL,
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_faz_uma (
    id_usuario INT NOT NULL,
    id_publicacao INT NOT NULL,
    papel VARCHAR(50),
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tb_conteudo (
    id_conteudo SERIAL,
    titulo VARCHAR(50),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_texto INT,
    id_img INT,
    id_video INT,
    id_link INT
);

CREATE TABLE IF NOT EXISTS tb_texto (
    id_texto SERIAL,
    conteudo_texto TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_img (
    id_img SERIAL,
    url_img TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_video (
    id_video SERIAL,
    url_video TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_link (
    id_link SERIAL,
    url_link TEXT NOT NULL
);
```

## CRIAR CONSTRAINTS

```sql
-- Constraints para tb_usuario
ALTER TABLE tb_usuario
ADD CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
ADD CONSTRAINT uk_usuario_email UNIQUE (email);

-- Constraints para tb_conexao
ALTER TABLE tb_conexao
ADD CONSTRAINT pk_conexao PRIMARY KEY (id_conexao),
ADD CONSTRAINT fk_conexao_seguidor FOREIGN KEY (id_seguidor) REFERENCES tb_usuario (id_usuario) ON DELETE CASCADE,
ADD CONSTRAINT fk_conexao_seguido FOREIGN KEY (id_seguido) REFERENCES tb_usuario (id_usuario) ON DELETE CASCADE,
ADD CONSTRAINT uk_conexao_seguidor_seguido UNIQUE (id_seguidor, id_seguido);

-- Constraints para tb_texto
ALTER TABLE tb_texto
ADD CONSTRAINT pk_texto PRIMARY KEY (id_texto);

-- Constraints para tb_img
ALTER TABLE tb_img
ADD CONSTRAINT pk_img PRIMARY KEY (id_img);

-- Constraints para tb_video
ALTER TABLE tb_video
ADD CONSTRAINT pk_video PRIMARY KEY (id_video);

-- Constraints para tb_link
ALTER TABLE tb_link
ADD CONSTRAINT pk_link PRIMARY KEY (id_link);

-- Constraints para tb_conteudo
ALTER TABLE tb_conteudo
ADD CONSTRAINT pk_conteudo PRIMARY KEY (id_conteudo),
ADD CONSTRAINT fk_tb_texto_id_texto FOREIGN KEY (id_texto) REFERENCES tb_texto (id_texto) ON DELETE SET NULL,
ADD CONSTRAINT fk_tb_video_id_video FOREIGN KEY (id_video) REFERENCES tb_video (id_video) ON DELETE SET NULL,
ADD CONSTRAINT fk_tb_img_id_img FOREIGN KEY (id_img) REFERENCES tb_img (id_img) ON DELETE SET NULL,
ADD CONSTRAINT fk_tb_link_id_link FOREIGN KEY (id_link) REFERENCES tb_link (id_link) ON DELETE SET NULL,
ADD CONSTRAINT uk_tb_conteudo_texto UNIQUE (id_conteudo, id_texto);

-- Constraints para tb_publicacao
ALTER TABLE tb_publicacao
ADD CONSTRAINT pk_publicacao PRIMARY KEY (id_publicacao),
ADD CONSTRAINT fk_publicacao_conteudo FOREIGN KEY (id_conteudo) REFERENCES tb_conteudo (id_conteudo) ON DELETE CASCADE;

-- Constraints para tb_usuario_publicacao
ALTER TABLE tb_faz_uma
ADD CONSTRAINT pk_usuario_publicacao PRIMARY KEY (id_usuario, id_publicacao),
ADD CONSTRAINT fk_tb_usuario_id_usuario FOREIGN KEY (id_usuario) REFERENCES tb_usuario (id_usuario) ON DELETE CASCADE,
ADD CONSTRAINT fk_tb_publicacao_id_publicacao FOREIGN KEY (id_publicacao) REFERENCES tb_publicacao (id_publicacao) ON DELETE CASCADE;

```

## POPULAR TABELAS

## PERGUNTAS ANALITICAS

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
