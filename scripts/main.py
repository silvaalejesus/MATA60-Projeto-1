import logging
import os
from dotenv import load_dotenv
import psycopg2

from db_utils import execute_queries, populate_table_from_csv, drop_all_database_objects, create_materialized_views, create_stored_procedures, create_views
from incremental_backup import incremental_backup
from full_backup import full_backup
from criar_banco import create_database

load_dotenv()

# Configuração do log
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("db_setup.log"),
        logging.StreamHandler()
    ]
)

# Configurações do banco de dados
db_host = os.environ.get('DB_HOST')
db_port = os.environ.get('DB_PORT')
db_name = os.environ.get('DB_NAME')
db_user = os.environ.get('DB_USER')
db_password = os.environ.get('DB_PASSWORD')

def main():
    """Função principal para executar as operações no banco de dados."""
    print(db_name)
    while True:
        print("\nEscolha uma opção:")
        print("1. Criar banco de dados")
        print("2. Criar tabelas")
        print("3. Popular tabelas")
        print("4. Criar acessos")
        print("5. Executar backup completo")
        print("6. Dropar objetos do banco de dados")
        print("7. Sair")
            
        choice = input("Opção: ")

        try:
            if choice == '1':
                create_database()
            elif choice == '2':
                create_tables_and_constraints()
            elif choice == '3':
                populate_tables()
            elif choice == '4':
                create_access()
            elif choice == '5':
                full_backup()
            elif choice == '6':
                drop_objects()
            elif choice == '7':
                break
            else:
                print("Opção inválida!")
        except Exception as e:
            logging.error(f"Erro ao executar a operação: {e}")

def create_tables_and_constraints():
    """Cria as tabelas no banco de dados."""
    try:
        # Leitura das queries dos arquivos fornecidos
        with open("DDL/criar_tabelas.sql", "r", encoding="utf8") as f:
            create_table_queries = f.read().split(";")
            
        with open("DDL/constraints.sql", "r", encoding="utf8") as f:
            create_constraint_queries = f.read().split(";")

        # Execução das queries
       
        logging.info("Iniciando a criação das tabelas...")
        execute_queries(create_table_queries, "Criação de Tabelas")
        
        logging.info("Iniciando a aplicação de constraints...")
        execute_queries(create_constraint_queries, "Criação de Constraints")

        logging.info("Processo concluído!")

    except Exception as e:
        logging.critical(f"Erro ao criar as tabelas: {str(e)}")
        
def populate_tables():
    """Popula as tabelas com dados dos arquivos CSV."""
    try:
        logging.info("Iniciando a inserção de dados nas tabelas...")

        populate_table_from_csv(
            table_name="tb_usuario",
            csv_file="csv/tb_usuario.csv",
            columns=["nome","email","senha","data_criacao"]
        )
        populate_table_from_csv(
            table_name="tb_conexao",
            csv_file="csv/tb_conexao.csv",
            columns=["id_seguidor","id_seguido","data_conexao"]
        )
        populate_table_from_csv(
            table_name="tb_texto",
            csv_file="csv/tb_texto.csv",
            columns=["conteudo_texto"]
        )
        populate_table_from_csv(
            table_name="tb_video",
            csv_file="csv/tb_video.csv",
            columns=["url_video"]
        )
        populate_table_from_csv(
            table_name="tb_img",
            csv_file="csv/tb_img.csv",
            columns=["url_img"]
        )
        populate_table_from_csv(
            table_name="tb_link",
            csv_file="csv/tb_link.csv",
            columns=["url_link"]
        )
        populate_table_from_csv(
            table_name="tb_conteudo",
            csv_file="csv/tb_conteudo.csv",
            columns=["titulo", "data_criacao", "id_texto", "id_video", "id_img", "id_link"]	
        )
        populate_table_from_csv(
            table_name="tb_publicacao",
            csv_file="csv/tb_publicacao.csv",
            columns=["id_conteudo","data_publicacao"]
        )
        populate_table_from_csv(
            table_name="tb_faz_uma",
            csv_file="csv/tb_faz_uma.csv",
            columns=["id_usuario","id_publicacao", "papel", "data_publicacao"]
        )


        logging.info("Processo concluído!")

    except Exception as e:
        logging.error(f"Erro ao popular as tabelas: {str(e)}")

def drop_objects():
    """Remove todos os objetos do banco de dados."""
    try:
        with psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        ) as conn:
            drop_all_database_objects(conn)
    except Exception as e:
        logging.critical(f"Erro ao conectar ao banco de dados ou executar drops: {str(e)}")

def create_access():
    """Cria os acessos no banco de dados."""
    try:
        # Leitura das queries dos arquivos fornecidos
        with open("queries/criar_acessos.sql", "r", encoding="utf8") as f:
            create_access_queries = f.read().split(";")
     
        # Execução das queries
       
        logging.info("Iniciando a criação das tabelas...")
        execute_queries(create_access_queries, "Criação de acessos")

        logging.info("Processo concluído!")

    except Exception as e:
        logging.critical(f"Erro ao criar acessos: {str(e)}")
        
if __name__ == "__main__":
    main()