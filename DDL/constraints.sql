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


