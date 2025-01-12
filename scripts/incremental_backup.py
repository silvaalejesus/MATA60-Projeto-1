import psycopg2
import os
import subprocess
from datetime import datetime
import time
from dotenv import load_dotenv
load_dotenv()

# Dados de conexão com o banco de dados
# Configurações do banco de dados
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

def incremental_backup():
  """Realiza o incremental backup do banco de dados."""
  print(DIR_LOCAL)
  try:
    # Data e hora do backup
    # data_hora = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    arquivo_backup = os.path.join(DIR_LOCAL, f"incremental_backup.tar")

    # Comando pg_basebackup
    comando = [
        "pg_basebackup",
        "-h", conn_params['host'],
        "-p", str(conn_params['port']),
        "-U", conn_params['user'],
        "-D", arquivo_backup,
        "-X", "fetch",
    ]
    subprocess.run(comando, check=True)

    print(f"Incremental backup realizado com sucesso em {arquivo_backup}")

    # Limpeza (opcional): remover backups antigos do disco local
    for arquivo in os.listdir(DIR_LOCAL):
      if arquivo.startswith("incremental_backup") and arquivo.endswith(".tar"):
        caminho_arquivo = os.path.join(DIR_LOCAL, arquivo)
        if os.path.getmtime(caminho_arquivo) < time.time() - (14 * 24 * 60 * 60):  # 14 dias em segundos
          os.remove(caminho_arquivo)
          print(f"Backup antigo removido: {caminho_arquivo}")

  except Exception as e:
    print(f"Erro ao realizar o incremental backup: {e}")

if __name__ == "__main__":
  incremental_backup()