import psycopg2
from psycopg2 import sql
import logging
import csv
import os
from dotenv import load_dotenv

load_dotenv()

# Configurações do banco de dados
db_host = os.environ.get('DB_HOST')
db_port = os.environ.get('DB_PORT')
db_name = os.environ.get('DB_NAME')
db_user = os.environ.get('DB_USER')
db_password = os.environ.get('DB_PASSWORD')

def execute_queries(queries, description):
    """Executa uma lista de queries no banco de dados."""
    try:
        with psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        ) as conn:
            with conn.cursor() as cursor:
                for query in queries:
                    try:
                        # Remove espaços em branco extras e quebras de linha
                        query = query.strip() 
                        if query:  # Ignora queries vazias
                            if "DO $$" in query:
                                print(query)
                                cursor.execute(sql.SQL(query))
                            else:
                                print(query)
                                cursor.execute(query)
                            logging.info(f"{description}: Executado com sucesso - {query[:50]}...")
                    except Exception as e:
                        logging.error(f"Erro ao executar {description}: {query[:50]}... - {str(e)}")
                        # Levanta uma exceção para interromper a execução
                        raise RuntimeError(f"Falha em {description}: {query[:50]}...")
                    conn.commit()
    except Exception as e:
        logging.critical(f"Erro na conexão com o banco de dados ou execução: {str(e)}")
        exit(1)  # Interrompe o programa completamente

# Define a função para popular tabela
def populate_table_from_csv(table_name, csv_file, columns):
    """Popula uma tabela do banco de dados usando um arquivo CSV."""
    try:
        with psycopg2.connect(
            database=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        ) as conn:
            with conn.cursor() as cursor:
                with open(csv_file, 'r', encoding='utf8') as file:
                    reader = csv.DictReader(file)
                    for row in reader:
                        # Apenas pega os valores para as colunas especificadas
                        raw_values = [row[col] for col in columns]
                        values = tratar_valores(raw_values)  # Tratar valores vazios
                        placeholders = ', '.join(['%s'] * len(columns))
                        query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
                        cursor.execute(query, values)
                        logging.info(f"Registro inserido na tabela {table_name}: {values}")
                conn.commit()
    except Exception as e:
        logging.error(f"Erro ao popular a tabela {table_name}: {str(e)}")

# Função para tratar valores vazios
def tratar_valores(row):
    return [None if v == '' else v for v in row]

def drop_all_database_objects(conn):
    """
    Remove todas as tabelas, índices, constraints e enums do banco de dados.

    Args:
      conn: Uma conexão com o banco de dados PostgreSQL.
    """
    cur = conn.cursor()

    # Desabilita triggers para evitar problemas com dependências
    cur.execute("SET session_replication_role = replica;")

    # Obtem todas as tabelas do schema public
    cur.execute("""
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    """)
    tables = [table[0] for table in cur.fetchall()]

    # Obtem todos os enums
    cur.execute("""
        SELECT typname 
        FROM pg_type 
        WHERE typcategory = 'E'
    """)
    enums = [enum[0] for enum in cur.fetchall()]

    # Queries de DROP
    drop_enums_queries = [f"DROP TYPE IF EXISTS {enum} CASCADE;" for enum in enums]
    drop_constraints_queries = [f"ALTER TABLE {table} DROP CONSTRAINT IF EXISTS {table}_pkey CASCADE;" for table in tables]
    drop_index_queries = [f"DROP INDEX IF EXISTS idx_{table};" for table in tables]
    drop_tables_queries = [f"DROP TABLE IF EXISTS {table} CASCADE;" for table in tables]

    # Executa as queries na ordem correta
    execute_queries(drop_enums_queries, "DROP Enums")
    execute_queries(drop_constraints_queries, "DROP Constraints")
    execute_queries(drop_index_queries, "DROP Índices")
    execute_queries(drop_tables_queries, "DROP Tabelas")

    # Obter todas as sequências
    cur.execute("""
        SELECT sequence_name
        FROM information_schema.sequences
        WHERE sequence_schema = 'public'; 
    """)
    sequences = [seq[0] for seq in cur.fetchall()]

    # Gerar comandos para reiniciar as sequências
    reset_sequences_queries = [
        f"ALTER SEQUENCE {sequence} RESTART WITH 1;" for sequence in sequences
    ]

    # Executar os comandos
    execute_queries(reset_sequences_queries, "Reiniciar Sequências")
    # Reativa triggers
    cur.execute("SET session_replication_role = DEFAULT;")

def create_stored_procedures():
    """Cria as stored procedures no banco de dados."""
    try:
        with open("queries/stored_procedures/sp.sql", "r", encoding="utf8") as f:
            create_sp_queries = f.read().split(";")
        execute_queries(create_sp_queries, "Criação de Stored Procedures")
        logging.info("Stored procedures criadas com sucesso!")
    except Exception as e:
        logging.error(f"Erro ao criar stored procedures: {str(e)}")

def create_materialized_views():
    """Cria as materialized views no banco de dados."""
    try:
        with open("queries/mviews/mviews.sql", "r", encoding="utf8") as f:
            create_mv_queries = f.read().split(";")
        execute_queries(create_mv_queries, "Criação de Materialized Views")
        logging.info("Materialized views criadas com sucesso!")
    except Exception as e:
        logging.error(f"Erro ao criar materialized views: {str(e)}")

def create_views():
    """Cria as views no banco de dados."""
    try:
        with open("queries/views/views.sql", "r", encoding="utf8") as f:
            create_views_queries = f.read().split(";")
        execute_queries(create_views_queries, "Criação de Views")
        logging.info("Views criadas com sucesso!")
    except Exception as e:
        logging.error(f"Erro ao criar views: {str(e)}")