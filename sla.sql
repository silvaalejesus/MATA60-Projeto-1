**Exclusão**

-- 1. **Excluir um usuário:**
DELETE FROM tb_usuario WHERE id_usuario = 1;

-- 2. **Excluir uma conexão:**
DELETE FROM tb_conexao WHERE id_seguidor = 1 AND id_seguido = 2;

-- 3. **Excluir uma publicação:**
DELETE FROM tb_publicacao WHERE id_publicacao = 1;

-- 4. **Excluir um conteúdo de texto:**
DELETE FROM tb_texto WHERE id_texto = 1;

-- 5. **Excluir uma imagem:**
DELETE FROM tb_img WHERE id_img = 1;

**Alteração**

-- 6. **Atualizar o nome de um usuário:**
UPDATE tb_usuario SET nome = 'Novo Nome' WHERE id_usuario = 1;

-- 7. **Atualizar o título de um conteúdo:**
UPDATE tb_conteudo SET titulo = 'Novo Título' WHERE id_conteudo = 1;

**Inclusão**

-- 8. **Inserir um novo usuário:**
INSERT INTO tb_usuario (nome, email, senha) VALUES ('Novo Usuário', 'novo@email.com', 'senha123');

-- 9. **Inserir uma nova conexão:**
INSERT INTO tb_conexao (id_seguidor, id_seguido) VALUES (1, 2);

-- 10. **Inserir uma nova publicação com conteúdo de texto:**
INSERT INTO tb_conteudo (id_texto) VALUES (1);
INSERT INTO tb_publicacao (id_conteudo) VALUES (lastval());
INSERT INTO tb_faz_uma (id_usuario, id_publicacao, papel) VALUES (1, lastval(), 'Autor');

**Buscas Simples**

-- 11. **Listar todos os usuários:**
SELECT * FROM tb_usuario;

-- 12. **Encontrar um usuário pelo ID:**
SELECT * FROM tb_usuario WHERE id_usuario = 1;

-- 13. **Listar todas as publicações:**
SELECT * FROM tb_publicacao;

-- 14. **Listar todos os conteúdos de texto:**
SELECT * FROM tb_texto;

**Buscas Intermediárias**

-- 15. **Listar os usuários que seguem um determinado usuário:**
SELECT u.nome 
FROM tb_usuario u
JOIN tb_conexao c ON u.id_usuario = c.id_seguidor
WHERE c.id_seguido = 1;

-- 16. **Listar as publicações de um determinado usuário:**
SELECT p.*
FROM tb_publicacao p
JOIN tb_faz_uma f ON p.id_publicacao = f.id_publicacao
WHERE f.id_usuario = 1;

-- 17. **Contar quantas publicações cada usuário fez:**
SELECT u.nome, COUNT(f.id_publicacao) AS numero_publicacoes
FROM tb_usuario u
JOIN tb_faz_uma f ON u.id_usuario = f.id_usuario
GROUP BY u.nome;

**Buscas Avançadas**

-- 18. **Listar as publicações dos usuários que um determinado usuário segue:**
SELECT p.*
FROM tb_publicacao p
JOIN tb_faz_uma f ON p.id_publicacao = f.id_publicacao
JOIN tb_conexao c ON f.id_usuario = c.id_seguido
WHERE c.id_seguidor = 1;

-- 19. **Encontrar os usuários que publicaram conteúdo com um determinado texto:**
SELECT u.nome
FROM tb_usuario u
JOIN tb_faz_uma f ON u.id_usuario = f.id_usuario
JOIN tb_publicacao p ON f.id_publicacao = p.id_publicacao
JOIN tb_conteudo co ON p.id_conteudo = co.id_conteudo
JOIN tb_texto t ON co.id_texto = t.id_texto
WHERE t.conteudo_texto LIKE '%palavra_chave%';

-- 20. **Listar os usuários que mais publicaram conteúdo, ordenados pelo número de publicações:**
SELECT u.nome, COUNT(f.id_publicacao) AS numero_publicacoes
FROM tb_usuario u
JOIN tb_faz_uma f ON u.id_usuario = f.id_usuario
GROUP BY u.nome
ORDER BY numero_publicacoes DESC;
