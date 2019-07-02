$jobAgent= Get-AzSqlElasticJobAgent -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" -Name "sqlDemoAgent"
$serverGroupName="ServerGroup1"
$credentialName="dbadmin"

$outputDatebase=Get-AzSqlDatabase -DatabaseName "OutputDatabase" -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" 

Write-Output "Creating a new job"
$JobName = "GetFragmentation"
$Job = $JobAgent | New-AzSqlElasticJob -Name $JobName -RunOnce
$Job


Write-Output "Creating job steps"



$SQLCommandString = @"
SELECT 
DB_NAME() AS [Current Database],
SYSDATETIME()  as [QueryDate],
dbschemas.[name] as 'Schema',
dbtables.[name] as 'Table',
dbindexes.[name] as 'Index',
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent desc
"@


$Job | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $serverGroupName -CredentialName $credentialName -CommandText $SQLCommandString -OutputDatabaseObject $outputDatebase -OutputCredentialName $credentialName -OutputTableName "Fragmentation4" -OutputSchemaName "dbo" 
