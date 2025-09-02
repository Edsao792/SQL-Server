-- VERIFICAR ONDE AS TABELAS ESTÃO NO FILEGROUP
SELECT
FileGroup = FILEGROUP_NAME(a.data_space_id) ,
TableName = OBJECT_NAME(p.object_id) ,
IndexName = i.name ,
8 * SUM(a.used_pages) AS 'Size(KB)' ,
8 * SUM(a.used_pages) / 1024 AS 'Size(MB)' ,
8 * SUM(a.used_pages) / 1024 / 1024 AS 'Size(GB)'
FROM
sys.allocation_units a
INNER JOIN sys.partitions p
ON  a.container_id = CASE WHEN a.type IN ( 1 , 3 ) THEN p.hobt_id
ELSE p.partition_id
END
AND p.object_id > 1024
LEFT JOIN sys.indexes i
ON  i.object_id = p.object_id
AND i.index_id = p.index_id
WHERE FILEGROUP_NAME(a.data_space_id) = 'AUDIT'
--Uncomment if you want to see indexes for one filegroup
--WHERE a.data_space_id = 2
--AND OBJECT_NAME(p.object_id) like 'SRR%'
GROUP BY
a.data_space_id ,
p.object_id ,
i.object_id ,
i.index_id ,
i.name
ORDER BY
FILEGROUP_NAME(a.data_space_id) ,
SUM(a.used_pages) DESC;
