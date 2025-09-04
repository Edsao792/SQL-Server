--Apenas Estatísticas que necessitam de atualização (Novo Filtro Rotina Administrativa - 10 dias)
SELECT      OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName, 
            stat.name, modification_counter, 
            [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
            last_updated
FROM        sys.objects AS obj
INNER JOIN  sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
AND (sp.modification_counter* 100 / [rows] >= 30 OR sp.rows_sampled* 100 / [rows] <= 70 OR DATEDIFF(DAY, sp.last_updated, GETDATE()) > 10)
AND obj.name not like '%_TTAT_LOG%' COLLATE Latin1_General_CI_AI
ORDER BY    modification_counter DESC


SELECT      OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName, 
            stat.name, modification_counter, 
            [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
            last_updated ,
            'UPDATE STATISTICS ' +OBJECT_SCHEMA_NAME(obj.object_id)+'.'+obj.name+'(['+ stat.name +'])' + ' WITH FULLSCAN'
FROM        sys.objects AS obj
INNER JOIN  sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0
AND (rows_sampled* 100 / [rows]) < 70
ORDER BY    modification_counter DESC
