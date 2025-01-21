	use data_lake;

	SELECT
		 t.object_id									AS object_id
		,s.Name											AS SchemaName
		,t.Name											AS TableName
		,p.Rows											AS RowCounts
		,(a.total_pages) * 8							AS TotalSpaceKB
		,(a.used_pages) * 8								AS UsedSpaceKB
		,(a.total_pages) - (a.used_pages) * 8			AS UnusedSpaceKB
		,o.create_date									AS create_date
		,o.modify_date									AS modify_date			
		,CASE 
			WHEN coalesce(st.last_user_seek, '19000101') > coalesce(st.last_user_scan, '19000101') AND coalesce(st.last_user_seek, '19000101') > coalesce(st.last_user_lookup, '19000101') AND coalesce(st.last_user_seek, '19000101') > coalesce(st.last_user_update, '19000101') THEN  last_user_seek
			WHEN coalesce(st.last_user_scan, '19000101') > coalesce(st.last_user_seek, '19000101') AND coalesce(st.last_user_scan, '19000101') > coalesce(st.last_user_lookup, '19000101') AND coalesce(st.last_user_scan, '19000101') > coalesce(st.last_user_update, '19000101') THEN  last_user_scan
			WHEN coalesce(st.last_user_lookup, '19000101') > coalesce(st.last_user_scan, '19000101') AND coalesce(st.last_user_lookup, '19000101') > coalesce(st.last_user_seek, '19000101') AND coalesce(st.last_user_lookup, '19000101') > coalesce(st.last_user_update, '19000101') THEN  last_user_lookup
			ELSE last_user_update
		END												AS last_user_RW
		,last_user_seek
		,last_user_scan
		,last_user_lookup
		,last_user_update
	--	,st.*
	FROM sys.tables t
		INNER JOIN sys.all_objects o ON t.object_id = o.object_id
		LEFT JOIN sys.indexes i ON t.object_id = i.object_id
		LEFT JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
		LEFT JOIN sys.allocation_units a ON p.partition_id = a.container_id
		LEFT JOIN sys.schemas s ON t.schema_id = s.schema_id
		LEFT JOIN sys.dm_db_index_usage_stats st ON st.object_id = o.object_id
			and st.database_id = 15
	WHERE 1 = 1
		--and t.Name LIKE 'de%'
		AND t.is_ms_shipped = 0
		AND i.object_id > 255
		AND s.Name = 'process'
	--GROUP BY
	--	t.Name, s.Name, p.Rows, t.object_id, o.create_date, o.modify_date	
	ORDER BY
		TotalSpaceKB desc
