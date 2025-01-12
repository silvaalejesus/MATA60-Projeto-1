-- Buscar coautores de uma publicação
SELECT u.nome
FROM tb_usuario u
JOIN tb_autoria a ON u.id_usuario = a.id_usuario
WHERE a.id_publicacao = 1;

-- Buscar publicações de um usuário
SELECT p.titulo
FROM tb_publicacao p
JOIN tb_autoria a ON p.id_publicacao = a.id_publicacao
WHERE a.id_usuario = 2;

-- INSERTS
INSERT INTO tb_autoria (id_usuario, id_publicacao) VALUES (1, 1), (2, 1);
INSERT INTO tb_autoria (id_usuario, id_publicacao) VALUES (2, 2);

-- Consulta para Recuperar Dados do Conteúdo
-- Para buscar o conteúdo com todos os detalhes:
SELECT c.id_conteudo, c.titulo, t.conteudo_texto, i.url_img, v.url_video, l.url_link
FROM conteudo c
LEFT JOIN texto t ON c.id_conteudo = t.id_conteudo
LEFT JOIN img i ON c.id_conteudo = i.id_conteudo
LEFT JOIN video v ON c.id_conteudo = v.id_conteudo
LEFT JOIN link l ON c.id_conteudo = l.id_conteudo
WHERE c.id_conteudo = 1;

-- Inserir o conteúdo base:
INSERT INTO conteudo (titulo) VALUES ('Meu primeiro conteúdo');

-- Inserir um texto associado:
INSERT INTO texto (id_conteudo, conteudo_texto) VALUES (1, 'Este é um texto explicativo.');

-- Inserir imagens associadas:
INSERT INTO img (id_conteudo, url_img, descricao) VALUES (1, 'https://example.com/imagem1.jpg', 'Imagem de exemplo 1');
INSERT INTO img (id_conteudo, url_img, descricao) VALUES (1, 'https://example.com/imagem2.jpg', 'Imagem de exemplo 2');



--  Inserir conteúdos na tabela conteudo
-- Inserir conteúdo da Publicação A
INSERT INTO conteudo (titulo) VALUES ('Conteúdo Descritivo A');
INSERT INTO texto (id_conteudo, conteudo_texto) VALUES (1, 'Texto para Publicação A.');

INSERT INTO conteudo (titulo) VALUES ('Imagem para Publicação A');
INSERT INTO img (id_conteudo, url_img, descricao) VALUES (2, 'https://example.com/imagem_a.jpg', 'Imagem ilustrativa A.');

INSERT INTO conteudo (titulo) VALUES ('Vídeo para Publicação A');
INSERT INTO video (id_conteudo, url_video, descricao) VALUES (3, 'https://example.com/video_a.mp4', 'Vídeo explicativo A.');

-- Inserir conteúdo da Publicação B
INSERT INTO conteudo (titulo) VALUES ('Texto para Publicação B');
INSERT INTO texto (id_conteudo, conteudo_texto) VALUES (4, 'Texto exclusivo para Publicação B.');

INSERT INTO conteudo (titulo) VALUES ('Link para Publicação B');
INSERT INTO link (id_conteudo, url_link, descricao) VALUES (5, 'https://example.com/link_b', 'Link externo para referência.');

-- Criar publicações e associar conteúdos
-- Inserir Publicação A e associar conteúdos
INSERT INTO tb_publicacao (id_conteudo, data_publicacao) VALUES (1, '2025-01-01');
INSERT INTO publicacao_conteudo (id_publicacao, id_conteudo) VALUES (1, 2); -- Imagem
INSERT INTO publicacao_conteudo (id_publicacao, id_conteudo) VALUES (1, 3); -- Vídeo

-- Inserir Publicação B e associar conteúdos
INSERT INTO tb_publicacao (id_conteudo, data_publicacao) VALUES (4, '2025-01-02');
INSERT INTO publicacao_conteudo (id_publicacao, id_conteudo) VALUES (2, 2); -- Reutilizando a mesma imagem de Publicação A
INSERT INTO publicacao_conteudo (id_publicacao, id_conteudo) VALUES (2, 5); -- Link exclusivo
