-- Inclusão de usuários
INSERT INTO tb_usuario (nome, email, senha) VALUES ('João Silva', 'joao.silva@email.com', 'senha123');
INSERT INTO tb_usuario (nome, email, senha) VALUES ('Maria Oliveira', 'maria.oliveira@email.com', 'senha123');

-- Inclusão de conexões
INSERT INTO tb_conexao (id_seguidor, id_seguido) VALUES (1, 2);
INSERT INTO tb_conexao (id_seguidor, id_seguido) VALUES (2, 1);

-- Inclusão de conteúdos
INSERT INTO tb_conteudo (titulo, id_texto) VALUES ('Primeiro conteúdo', 102);
INSERT INTO tb_conteudo (titulo, id_texto) VALUES ('abrobinha', 105);
INSERT INTO tb_conteudo (titulo, id_texto) VALUES ('abrobinha', 107);

-- Inclusão de publicações
INSERT INTO tb_publicacao (id_conteudo) VALUES (1);
INSERT INTO tb_publicacao (id_conteudo) VALUES (2);

-- Inclusão de coautores
INSERT INTO tb_faz_uma (id_usuario, id_publicacao, papel) VALUES (1, 1, 'Autor Principal');
INSERT INTO tb_faz_uma (id_usuario, id_publicacao, papel) VALUES (2, 1, 'Coautor');

-- Comandos de Alteração
-- Atualizar o nome de um usuário
UPDATE tb_usuario SET nome = 'João Pedro Silva' WHERE id_usuario = 1;

-- Alterar o título de um conteúdo
UPDATE tb_conteudo SET titulo = 'Primeiro conteúdo atualizado' WHERE id_conteudo = 1;

-- Alterar o papel de um coautor
UPDATE tb_faz_uma SET papel = 'Revisor' WHERE id_usuario = 2 AND id_publicacao = 1;

-- EXCLUSAO
-- Excluir uma conexão entre dois usuários
DELETE FROM tb_conexao WHERE id_seguidor = 2 AND id_seguido = 1;

-- Excluir uma publicação
DELETE FROM tb_publicacao WHERE id_publicacao = 2;

-- Excluir um conteúdo e suas dependências
DELETE FROM tb_conteudo WHERE id_conteudo = 2;

-- BUSCAS SIMPLES
-- Buscar todos os usuários
SELECT * FROM tb_usuario;

-- Buscar todas as conexões
SELECT * FROM tb_conexao;

-- Buscar todas as publicações
SELECT * FROM tb_publicacao;

-- Buscar os conteúdos criados
SELECT * FROM tb_conteudo;


-- INTERMEDIARIAS
-- Buscar os usuários e suas conexões
SELECT u1.nome AS Seguidor, u2.nome AS Seguido 
FROM tb_conexao c
JOIN tb_usuario u1 ON c.id_seguidor = u1.id_usuario
JOIN tb_usuario u2 ON c.id_seguido = u2.id_usuario;

-- Buscar publicações com o nome dos autores
SELECT p.id_publicacao, p.data_publicacao, u.nome AS Autor 
FROM tb_publicacao p
JOIN tb_faz_uma up ON p.id_publicacao = up.id_publicacao
JOIN tb_usuario u ON up.id_usuario = u.id_usuario;

-- Buscar conteúdos com o número de publicações relacionadas
SELECT c.id_conteudo, c.titulo, COUNT(p.id_publicacao) AS Total_Publicacoes 
FROM tb_conteudo c
LEFT JOIN tb_publicacao p ON c.id_conteudo = p.id_conteudo
GROUP BY c.id_conteudo, c.titulo;


--AVANCADAS
-- Buscar os coautores de cada publicação
SELECT p.id_publicacao, p.data_publicacao, 
       STRING_AGG(u.nome, ', ') AS Coautores 
FROM tb_publicacao p
JOIN tb_faz_uma up ON p.id_publicacao = up.id_publicacao
JOIN tb_usuario u ON up.id_usuario = u.id_usuario
GROUP BY p.id_publicacao, p.data_publicacao;

-- Buscar usuários que são autores e também seguidores de outros usuários
SELECT DISTINCT u.nome AS Usuario 
FROM tb_usuario u
JOIN tb_faz_uma up ON u.id_usuario = up.id_usuario
JOIN tb_conexao c ON u.id_usuario = c.id_seguidor;

-- Buscar publicações com título, coautores e número de conexões dos autores
SELECT p.id_publicacao, c.titulo AS Titulo, 
       STRING_AGG(u.nome, ', ') AS Coautores, 
       COUNT(DISTINCT cn.id_conexao) AS Total_Conexoes
FROM tb_publicacao p
JOIN tb_conteudo c ON p.id_conteudo = c.id_conteudo
JOIN tb_faz_uma up ON p.id_publicacao = up.id_publicacao
JOIN tb_usuario u ON up.id_usuario = u.id_usuario
LEFT JOIN tb_conexao cn ON u.id_usuario = cn.id_seguidor
GROUP BY p.id_publicacao, c.titulo;
