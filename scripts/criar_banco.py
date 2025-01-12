import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# Dados de conexão com o banco de dados
db_host = os.environ.get('DB_HOST')
db_port = os.environ.get('DB_PORT')
db_name = os.environ.get('DB_NAME')
db_user = os.environ.get('DB_USER')
db_password = os.environ.get('DB_PASSWORD')

conn_params = {
    "host": db_host,
    "port": db_port,
    "database": 'postgres', # Conecte-se ao banco de dados 'postgres' inicialmente
    "user": db_user,
    "password": db_password
}

def create_database():
  try:
    # Conecte-se ao banco de dados PostgreSQL
    conn = psycopg2.connect(**conn_params)
    conn.autocommit = True

    # Crie um cursor
    cur = conn.cursor()

    # Nome do novo banco de dados
    # nome_banco_dados = 'meu_novo_banco'

    # Execute o comando SQL para criar o banco de dados
    cur.execute(f"CREATE DATABASE {db_name}")

    print(f"Banco de dados '{db_name}' criado com sucesso!")

    # Feche a conexão com o banco de dados 'postgres'
    cur.close()
    conn.close()

    # Atualize as informações de conexão para o novo banco de dados
    conn_params['database'] = db_name

    # print(f"Banco de dados '{nome_banco_dados}' criado com sucesso!")

  except (Exception, psycopg2.Error) as error:
    print(f"Erro ao criar ou conectar ao banco de dados: {error}")

  finally:
    # Feche a conexão com o banco de dados
    if conn:
        cur.close()
        conn.close()


if __name__ == "__main__":
  create_database()

