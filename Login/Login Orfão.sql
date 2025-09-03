
-- VERIFICAR USUÁRIOS ORFÃOS
USE nome_do_banco;

GO

sp_change_users_login @Action='Report';

GO

-- ACERTA O USUARIO DO BANCO COM O USUARIO DE LOGIN
USE nome_do_banco;

GO

sp_change_users_login @Action='update_one', @UserNamePattern='edson',

   @LoginName='edson';

GO


/*1 - Executar o primeiro comando no database */
EXEC sp_change_users_login @Action='Report';

/*2- pegar o nome do login retornado no primeiro comando e informar substituindo 'NOME' */
EXEC sp_change_users_login 'auto_fix', 'NOME'
