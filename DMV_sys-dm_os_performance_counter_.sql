DECLARE @CounterPrefix NVARCHAR(30)
SET @CounterPrefix = CASE WHEN @@SERVICENAME = 'MSSQLSERVER'
THEN 'SQLServer:'
ELSE 'MSSQL$' + @@SERVICENAME + ':'
END ;
-- Capture the first counter set
SELECT CAST(1 AS INT) AS collection_instance ,
[object_name],
counter_name ,
instance_name ,
cntr_value ,
cntr_type ,
CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_init
FROM sys.dm_os_performance_counters
WHERE ( object_name = @CounterPrefix + 'Access Methods'
AND counter_name = 'Full Scans/sec'
)
OR ( object_name = @CounterPrefix + 'Access Methods'
AND counter_name = 'Index Searches/sec'
)
OR ( object_name = @CounterPrefix + 'Buffer Manager'
AND counter_name = 'Lazy Writes/sec'
)
OR ( object_name = @CounterPrefix + 'Buffer Manager'
AND counter_name = 'Page life expectancy'
)
OR ( object_name = @CounterPrefix + 'General Statistics'
AND counter_name = 'Processes Blocked'
)
OR ( object_name = @CounterPrefix + 'General Statistics'
AND counter_name = 'User Connections'
)
OR ( object_name = @CounterPrefix + 'Locks'
AND counter_name = 'Lock Waits/sec'
)
OR ( object_name = @CounterPrefix + 'Locks'
AND counter_name = 'Lock Wait Time (ms)'
)

OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'SQL Re-Compilations/sec'
)
OR ( object_name = @CounterPrefix + 'Memory Manager'
AND counter_name = 'Memory Grants Pending'
)
OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'Batch Requests/sec'
)
OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'SQL Compilations/sec'
)
-- Wait on Second between data collection
WAITFOR DELAY '00:00:01'
-- Capture the second counter set
SELECT CAST(2 AS INT) AS collection_instance ,
object_name ,
counter_name ,
instance_name ,
cntr_value ,
cntr_type ,
CURRENT_TIMESTAMP AS collection_time
INTO #perf_counters_second
FROM sys.dm_os_performance_counters
WHERE ( object_name = @CounterPrefix + 'Access Methods'
AND counter_name = 'Full Scans/sec'
)
OR ( object_name = @CounterPrefix + 'Access Methods'
AND counter_name = 'Index Searches/sec'
)
OR ( object_name = @CounterPrefix + 'Buffer Manager'
AND counter_name = 'Lazy Writes/sec'
)
OR ( object_name = @CounterPrefix + 'Buffer Manager'
AND counter_name = 'Page life expectancy'
)
OR ( object_name = @CounterPrefix + 'General Statistics'
AND counter_name = 'Processes Blocked'
)
OR ( object_name = @CounterPrefix + 'General Statistics'
AND counter_name = 'User Connections'
)
OR ( object_name = @CounterPrefix + 'Locks'
AND counter_name = 'Lock Waits/sec'
)
OR ( object_name = @CounterPrefix + 'Locks'
AND counter_name = 'Lock Wait Time (ms)'
)
OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'SQL Re-Compilations/sec'
)
OR ( object_name = @CounterPrefix + 'Memory Manager'
AND counter_name = 'Memory Grants Pending'
)
OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'Batch Requests/sec'
)
OR ( object_name = @CounterPrefix + 'SQL Statistics'
AND counter_name = 'SQL Compilations/sec'
)
-- Calculate the cumulative counter values
SELECT i.object_name ,
i.counter_name ,
i.instance_name ,
CASE WHEN i.cntr_type = 272696576
THEN s.cntr_value - i.cntr_value
WHEN i.cntr_type = 65792 THEN s.cntr_value
END AS cntr_value
FROM #perf_counters_init AS i
JOIN #perf_counters_second AS s
ON i.collection_instance + 1 = s.collection_instance
AND i.object_name = s.object_name
AND i.counter_name = s.counter_name
AND i.instance_name = s.instance_name
ORDER BY object_name
-- Cleanup tables
DROP TABLE #perf_counters_init
DROP TABLE #perf_counters_second
