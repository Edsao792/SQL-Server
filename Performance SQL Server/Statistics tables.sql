--Statistics rows sample
SELECT sp.stats_id, 
       name, 
       filter_definition, 
       last_updated, 
       rows, 
       rows_sampled, 
	   rows_sampled*100/rows [% Sample],
       steps, 
       unfiltered_rows, 
       modification_counter
FROM sys.stats AS stat
     CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE stat.object_id = OBJECT_ID('BD6010');

with stat as (
sELECT      OBJECT_SCHEMA_NAME(obj.object_id) SchemaName, obj.name TableName,
            stat.name, modification_counter,
            [rows], rows_sampled, rows_sampled* 100 / [rows] AS [% Rows Sampled],
            last_updated
FROM        sys.objects AS obj
INNER JOIN  sys.stats AS stat ON stat.object_id = obj.object_id
CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
WHERE       obj.is_ms_shipped = 0)
select TableName, 'update statistics '+TableName+ ' ('+name+') WITH FULLSCAN' as command, [% Rows Sampled],rows,last_updated from stat 
WHERE TableName in ('HISTOR_PROCES','TAR_PROCES')
order by rows
