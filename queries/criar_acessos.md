| Recurso/Tabela     | admin_role     | developer_role                 | operational_user_role | client_app_role        |
| ------------------ | -------------- | ------------------------------ | --------------------- | ---------------------- |
| Todas as Tabelas   | ALL PRIVILEGES | SELECT, INSERT, UPDATE, DELETE | SELECT                | SELECT                 |
| -tb_publicacao     | ALL PRIVILEGES | SELECT                         | SELECT                | SELECT, INSERT         |
| tb_usuario         | ALL PRIVILEGES | SELECT                         | SELECT                | SELECT, INSERT         |
| tb_conexao         | ALL PRIVILEGES | SELECT                         | SELECT                | SELECT, INSERT, DELETE |
| tb_conteudo        | ALL PRIVILEGES | SELECT, INSERT, UPDATE         | SELECT                | SELECT                 |
| tb_texto           | ALL PRIVILEGES | SELECT, INSERT, UPDATE         | SELECT                | SELECT                 |
| tb_img             | ALL PRIVILEGES | SELECT, INSERT, UPDATE         | SELECT                | SELECT                 |
| tb_video           | ALL PRIVILEGES | SELECT, INSERT, UPDATE         | SELECT                | SELECT                 |
| tb_link            | ALL PRIVILEGES | SELECT, INSERT, UPDATE         | SELECT                | SELECT                 |
| Todas as Views     | SELECT         | -                              | -                     | -                      |
| Materialized Views | SELECT         | -                              | -                     | -                      |
| Funções/Procedures | EXECUTE        | EXECUTE                        | -                     | -                      |
| Sequências         | USAGE, SELECT  | USAGE, SELECT                  | USAGE, SELECT         | -                      |
