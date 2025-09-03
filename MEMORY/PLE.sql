--Page Life Expectancy
SELECT [object_name]
    ,[counter_name]
    ,[cntr_value] 
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
AND [counter_name] = 'Page life expectancy'

SELECT*
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Page life expectancy'



-- PAGE LIFE EXPECTANCY INDICADO
WITH 
    tm_cte AS (
        SELECT CONVERT(int, value_in_use) / 1024. [memory_gb],
            CONVERT(int, value_in_use) / 1024. / 4. * 300 [counter_by_memory]
        FROM sys.configurations
        WHERE name like 'max server memory%'
    ),
    cached_cte AS (
        SELECT 
        COUNT(*) * 8. / 1024. / 1024. [cached_gb],
            COUNT(*) * 8. / 1024. / 1024.  / 4. * 300 [counter_by_cache]
        FROM [sys].[dm_os_buffer_descriptors]
)
SELECT CEILING(counter_by_memory) [Limite 1],
    CEILING(counter_by_cache) [Limite 2]
FROM tm_cte, cached_cte;



--Verifica o PLE de dentro do SQL Server
-- Coluna PageLife o ideal é maior que 1000
--
SELECT
    ple.[node]
, LTRIM(STR([PageLife_S]/3600))+':'+REPLACE(STR([PageLife_S]%3600/60,2),SPACE(1),'0') +':'+REPLACE(STR([PageLife_S]%60,2),SPACE(1),'0') [PageLife]
, ple.[PageLife_S]
, dp.[DatabasePages] [BufferPool_Pages]
, CONVERT(DECIMAL(15,3),dp.[DatabasePages]*0.0078125) [BufferPool_Mib]
, CONVERT(DECIMAL(15,3),dp.[DatabasePages]*0.0078125/[PageLife_S]) [BufferPool_Mib_S]
FROM
    (
SELECT [instance_name] [node], [cntr_value] [PageLife_S]
    FROM sys.dm_os_performance_counters
    where [counter_name] = 'Page life expectancy'
) ple
    INNER JOIN
    (
SELECT [instance_name] [node], [cntr_value] [DatabasePages]
    from sys.dm_os_performance_counters
    where [counter_name] = 'Database pages'
) dp on ple.[node] = dp.[node]
-- Page Life Expectancy
SELECT [object_name],
    [counter_name],
    [cntr_value]
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
    AND [counter_name] = 'Page life expectancy'


-- fonte: https://www.youtube.com/watch?v=qo8FNtCVXCs
