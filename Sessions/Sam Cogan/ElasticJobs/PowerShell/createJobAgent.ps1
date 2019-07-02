Write-Output "Creating job agent..."
$AgentName = "sqlDemoAgent"
$JobDatabase = Get-AzSqlDatabase -ResourceGroupName "SQLAgentDemos" -ServerName "sqlagentdemo" -databasename "jobdatabase"
$JobAgent = $JobDatabase | New-AzSqlElasticJobAgent -Name $AgentName