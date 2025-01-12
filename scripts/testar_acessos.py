import psycopg2
import os
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

# Configurações do banco de dados
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

# Constantes para os usuários e senhas
USERS = {
    "admin": {"username": "user_admin", "password": "12345"},
    "developer": {"username": "developer", "password": "12345"},
    "operational": {"username": "usuario_operacional", "password": "12345"},
    "client_app": {"username": "user_comum", "password": "12345"},
}

# Função para testar um comando SQL
def testar_acesso(usuario, senha, comando, descricao, esperado="sucesso"):
    try:
        # Conexão com o banco de dados
        conn = psycopg2.connect(
            dbname=DB_NAME, user=usuario, password=senha, host=DB_HOST, port=DB_PORT
        )
        cur = conn.cursor()

        # Executar o comando SQL
        cur.execute(comando)
        conn.commit()

        # Verificar o resultado esperado
        if esperado == "sucesso":
            print(f"[SUCESSO] {descricao}")
        else:
            print(f"[FALHA] {descricao} - Esperado erro, mas executado com sucesso!")

        # Fechar a conexão
        cur.close()
        conn.close()
    except psycopg2.Error as e:
        if esperado == "falha":
            print(f"[SUCESSO] {descricao} - Erro esperado: {e}")
        else:
            print(f"[FALHA] {descricao} - {e}")

# Testes de permissões para cada usuário
def executar_testes():
    # Testes para admin
    testar_acesso(
        USERS["admin"]["username"],
        USERS["admin"]["password"],
        "CREATE TABLE teste_admin (id SERIAL PRIMARY KEY);",
        "Criar tabela (admin)",
    )
    testar_acesso(
        USERS["admin"]["username"],
        USERS["admin"]["password"],
        "DELETE FROM tb_publicacao WHERE id_publicacao = 1;",
        "Excluir dados em tb_publicacao (admin)",
    )

    # Testes para developer
    testar_acesso(
        USERS["developer"]["username"],
        USERS["developer"]["password"],
        "INSERT INTO tb_publicacao (id_conteudo) VALUES (1);",
        "Inserir dados em tb_publicacao (developer)",
        esperado="falha",
    )
    testar_acesso(
        USERS["developer"]["username"],
        USERS["developer"]["password"],
        "SELECT * FROM tb_publicacao;",
        "Ler dados em tb_publicacao (developer)",
    )

    # Testes para usuário operacional
    testar_acesso(
        USERS["operational"]["username"],
        USERS["operational"]["password"],
        "SELECT * FROM tb_publicacao;",
        "Ler dados em tb_publicacao (operational_user)",
    )
    testar_acesso(
        USERS["operational"]["username"],
        USERS["operational"]["password"],
        "DELETE FROM tb_publicacao WHERE id_publicacao = 1;",
        "Excluir dados em tb_publicacao (operational_user)",
        esperado="falha",
    )

    # Testes para aplicação cliente
    testar_acesso(
        USERS["client_app"]["username"],
        USERS["client_app"]["password"],
        "INSERT INTO tb_publicacao (id_conteudo) VALUES (1);",
        "Inserir dados em tb_publicacao (client_app)",
    )
    testar_acesso(
        USERS["client_app"]["username"],
        USERS["client_app"]["password"],
        "SELECT * FROM tb_publicacao;",
        "Ler dados em tb_publicacao (client_app)",
    )
    testar_acesso(
        USERS["client_app"]["username"],
        USERS["client_app"]["password"],
        "UPDATE tb_conteudo SET titulo = 'Novo Título' WHERE id_conteudo = 1;",
        "Atualizar dados em tb_conteudo (client_app)",
        esperado="falha",
    )

# Executar os testes
if __name__ == "__main__":
    executar_testes()
