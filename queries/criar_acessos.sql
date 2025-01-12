-- Criar roles
CREATE ROLE admin_role;
CREATE ROLE developer_role;
CREATE ROLE operational_user_role;
CREATE ROLE client_app_role;

-- Criar usuários
CREATE USER user_admin WITH PASSWORD '12345';
CREATE USER user_comum WITH PASSWORD '12345';
CREATE USER usuario_operacional WITH PASSWORD '12345';
CREATE USER developer WITH PASSWORD '12345';

-- Atribuir roles a usuários
GRANT admin_role TO user_admin;
GRANT developer_role TO developer;
GRANT operational_user_role TO usuario_operacional;
GRANT client_app_role TO user_comum;

-- Permissões para admin_role (total controle)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON DATABASE postgres TO admin_role;
GRANT CREATE ON SCHEMA public TO admin_role;

-- Permissões para developer_role (leitura e escrita em tabelas)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO developer_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO developer_role;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO developer_role;

-- Permissões para operational_user_role (somente leitura)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO operational_user_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO operational_user_role;

-- Permissões para client_app_role (acesso restrito)
GRANT SELECT, INSERT, UPDATE, DELETE ON tb_usuario TO client_app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON tb_publicacao TO client_app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON tb_conexao TO client_app_role;
GRANT SELECT ON tb_conteudo TO client_app_role;
GRANT SELECT ON tb_texto TO client_app_role;
GRANT SELECT ON tb_img TO client_app_role;
GRANT SELECT ON tb_video TO client_app_role;
GRANT SELECT ON tb_link TO client_app_role;

-- Restrições adicionais conforme os testes

-- operational_user_role não deve ter permissão de escrita ou exclusão em tabelas
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM operational_user_role;

-- developer_role não deve ter permissão de escrita em tb_publicacao
REVOKE INSERT, UPDATE, DELETE ON tb_publicacao FROM developer_role;

-- client_app_role deve ter permissão apenas para leitura e escrita em tabelas específicas
GRANT SELECT, INSERT ON tb_publicacao TO client_app_role;
REVOKE UPDATE, DELETE ON tb_conteudo FROM client_app_role;

-- Permitir exclusão de dados sensíveis apenas ao admin_role
GRANT DELETE ON tb_publicacao TO admin_role;
GRANT DELETE ON tb_conexao TO admin_role;

-- VIEWS, PROCEDURES E MATERIALIZED VIEWS
-- Conceder permissões de leitura para views (admin_role)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'VIEW') LOOP
        EXECUTE 'GRANT SELECT ON ' || quote_ident(r.table_name) || ' TO admin_role';
    END LOOP;
END $$;

-- Conceder permissões de leitura para materialized views (admin_role)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT matviewname FROM pg_catalog.pg_matviews WHERE schemaname = 'public') LOOP
        EXECUTE 'GRANT SELECT ON ' || quote_ident(r.matviewname) || ' TO admin_role';
    END LOOP;
END $$;

-- Conceder permissões de execução para funções (admin_role)
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public') LOOP
        EXECUTE 'GRANT EXECUTE ON FUNCTION public.' || quote_ident(r.routine_name) || ' TO admin_role';
    END LOOP;
END $$;

-- Garantir acesso a todas as sequências para admin_role
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public') LOOP
        EXECUTE 'GRANT USAGE ON SEQUENCE ' || quote_ident(r.sequence_name) || ' TO admin_role';
    END LOOP;
END $$;

REVOKE DELETE ON tb_publicacao FROM operational_user_role;
GRANT USAGE, SELECT ON SEQUENCE tb_publicacao_id_publicacao_seq TO client_app_role;
REVOKE UPDATE ON tb_conteudo FROM client_app_role;