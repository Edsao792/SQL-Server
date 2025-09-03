DECLARE @start DATETIME = DATEADD(HOUR, -24 ,GETDATE())
DECLARE @end   DATETIME = GETDATE()
EXEC master.dbo.xp_readerrorlog 0, 1, N'Password did not match that for the login provided', null, @start, @end

-- COMO IDENTIFICAR FALHAS DE LOGIN
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'


-- COMO IDENTIFICAR FALHAS DE LOGIN POR SENHA INCORRETA
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed', N'password'

-- IDENTIFICANDO USUÁRIO E MÁQUINA
IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
CREATE TABLE #Login_Failed ( 
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
    [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
    [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
)

INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'

SELECT * FROM #Login_Failed --where [Username] = 'NOME_DO_LOGIN' AND [LogDate] LIKE '%30%' ORDER BY [LogDate] DESC
