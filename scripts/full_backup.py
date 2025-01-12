import psycopg2
import os
from datetime import datetime
import time  # Importe o módulo time
from dotenv import load_dotenv
load_dotenv()

# Dados de conexão com o banco de dados
db_host = os.environ.get('DB_HOST')
db_port = os.environ.get('DB_PORT')
db_name = os.environ.get('DB_NAME')
db_user = os.environ.get('DB_USER')
db_password = os.environ.get('DB_PASSWORD')
bk_dir_local = os.environ.get('DIR_LOCAL')

# Crie o dicionário conn_params
conn_params = {
    "host": db_host,
    "port": db_port,
    "database": db_name,
    "user": db_user,
    "password": db_password
}


# Diretório local para o backup
DIR_LOCAL = bk_dir_local

def full_backup():
  """Realiza o full backup do banco de dados."""

  try:
    # Conecta ao banco de dados
    conn = psycopg2.connect(**conn_params)
    conn.autocommit = True
    cur = conn.cursor()

    # Data e hora do backup
    # data_hora = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    arquivo_backup = os.path.join(DIR_LOCAL, f"full_backup.sql")

    # Comando pg_dump
    comando = f"pg_dump -h {conn_params['host']} -p {conn_params['port']} -U {conn_params['user']} -Fc {conn_params['database']} > {arquivo_backup}"
    os.system(comando)

    print(f"Full backup realizado com sucesso em {arquivo_backup}")

    # Limpeza: remover backups antigos do disco local
    for arquivo in os.listdir(DIR_LOCAL):
      if arquivo.startswith("full_backup_") and arquivo.endswith(".sql"):
        caminho_arquivo = os.path.join(DIR_LOCAL, arquivo)
        if os.path.getmtime(caminho_arquivo) < time.time() - (7 * 24 * 60 * 60):  # 7 dias em segundos
          os.remove(caminho_arquivo)
          print(f"Backup antigo removido: {caminho_arquivo}")

  except Exception as e:
    print(f"Erro ao realizar o full backup: {e}")
  finally:
    if conn:
      cur.close()
      conn.close()

if __name__ == "__main__":
  full_backup()

