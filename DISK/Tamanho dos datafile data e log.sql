-- TAMANHO DOS DATAFILES COM O CAMINHO
SELECT 
db.name AS [Database Name], 
mf.name AS [Logical Name], 
mf.type_desc AS [File Type], 
mf.physical_name AS [Path], 
substring(mf.physical_name,1,1) [Disk Letter],
REPLACE(CAST(
        (mf.Size * 8
        ) / 1024.0 / 1024.0 AS decimal(10,2)),'.',',') AS [Initial Size (GB)]
FROM 
 sys.master_files AS mf
 INNER JOIN sys.databases AS db ON
                db.database_id = mf.database_id
where upper(db.name) in ('NOME_DATABASE')
--and mf.physical_name like 'G%'
order by mf.type_desc desc
