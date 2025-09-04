-- Index compression (clustered index or non-clustered index)
SELECT [s].[name] AS [Schema],
	   [t].[name] AS [Table], 
       [i].[name] AS [Index],  
       [p].[partition_number] AS [Partition],
       [p].[data_compression_desc] AS [Compression], 
       [i].[fill_factor],
       [p].[rows],
			 'ALTER INDEX [' + [i].[name] + '] ON [' + [s].[name] + '].[' + [t].[name] + 
			 '] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE' +
			 CASE WHEN [i].[fill_factor] BETWEEN 1 AND 89 THEN ', FILLFACTOR = 90' ELSE '' END + ' )' AS Ds_Comando
FROM [sys].[partitions] AS [p]
INNER JOIN sys.tables AS [t] 
     ON [t].[object_id] = [p].[object_id]
INNER JOIN sys.indexes AS [i] 
     ON [i].[object_id] = [p].[object_id] AND i.index_id = p.index_id
INNER JOIN sys.schemas AS [s]
		 ON [t].[schema_id] = [s].[schema_id]
WHERE [p].[index_id] > 0
			AND [i].[name] IS NOT NULL
			AND [p].[rows] > 10000
			AND [p].[data_compression_desc] = 'NONE'
ORDER BY [p].[rows]									-- PARA VERIFICAR O TAMANHO DOS INDICES
--ORDER BY [s].[name], [t].[name], [i].[name]		-- ORDENA POR TABELA PARA PODER RODAR EM PARALELO
	
-- Data (table) compression (heap)
SELECT DISTINCT 
			 [t].[name] AS [Table],
       [p].[data_compression_desc] AS [Compression], 
       --[i].[fill_factor],
       'ALTER TABLE [' + [s].[name] + '].[' + [t].[name] + '] REBUILD WITH (DATA_COMPRESSION = PAGE)' AS Ds_Comando
FROM [sys].[partitions] AS [p]
INNER JOIN sys.tables AS [t] 
     ON [t].[object_id] = [p].[object_id]
INNER JOIN sys.indexes AS [i] 
     ON [i].[object_id] = [p].[object_id]
INNER JOIN sys.schemas AS [s]
		 ON [t].[schema_id] = [s].[schema_id]
WHERE [p].[index_id]  = 0
			AND [p].[rows] > 10000
			AND [p].[data_compression_desc] = 'NONE'

--aplica compress
use [database_name]
go

if exists (select 1 from tempdb.sys.tables where name like '%##tabela%')
	drop table ##tabela
go

create table ##tabela (DatabaseName sysname, SchemaName sysname, TableName sysname, IndexName sysname null, IndexType tinyint)


if DB_ID() > 4 and DATABASEPROPERTYEX(DB_NAME(), 'status') = 'ONLINE' and DATABASEPROPERTYEX(DB_NAME(), 'updateability') = 'READ_WRITE'
	insert into ##tabela (DatabaseName, SchemaName, TableName, IndexName, IndexType)
	select distinct
		DB_NAME() DBName,
		sc.name SchemaName,
		st.name TableName,
		si.name IndexName,
		si.type IndexType
	from sys.tables st
	inner join sys.schemas sc on sc.schema_id = st.schema_id
	inner join sys.indexes si on si.object_id = st.object_id
	order by IndexType
	

declare @cmdSQL varchar(max) = ''
declare @dbname sysname, @schemaname sysname, @tablename sysname, @indexname sysname, @indextype tinyint
declare cr_looping cursor keyset for
select DatabaseName, SchemaName, TableName, IndexName, IndexType from ##tabela order by IndexType asc
open cr_looping

fetch first from cr_looping into @dbname, @schemaname, @tablename, @indexname, @indextype
while @@FETCH_STATUS = 0
 begin
	begin try
		
		if @indextype = 0
			set @cmdSQL = 'alter table [' + @dbname + '].[' + @schemaname + '].[' + @tablename + '] rebuild with (data_compression = PAGE)'
		else if @indextype in (1, 2)
			set @cmdSQL = 'alter index [' + @indexname + '] on [' + @dbname + '].[' + @schemaname + '].[' + @tablename + '] rebuild with (data_compression = PAGE, fillfactor = 80)'
		
		execute (@cmdSQL)

	end try
	begin catch
		print @cmdSQL
		print ERROR_MESSAGE()
	end catch
	fetch next from cr_looping into @dbname, @schemaname, @tablename, @indexname, @indextype
 end
close cr_looping
deallocate cr_looping
go
