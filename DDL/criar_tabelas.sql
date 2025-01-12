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