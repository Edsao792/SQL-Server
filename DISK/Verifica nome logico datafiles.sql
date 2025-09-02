-- 1: Verifica o diretorio atual e nome logico dos arquivos
SELECT name, physical_name AS CurrentLocation  
FROM sys.master_files  
WHERE database_id = DB_ID(N'database_name');  
GO

-- 2: Movimentacao de Datafiles
ALTER DATABASE database_name MODIFY FILE ( NAME = logical_name , FILENAME = 'new_path\os_file_name' );
