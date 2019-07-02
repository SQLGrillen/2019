$resourceGroup="SQLAgentDemos" 
$ServerName= "SQLAgentDemo" 
$AgentName= "sqlDemoAgent"

Get-AzSqlElasticJob -ResourceGroupName $resourceGroup -ServerName $ServerName -AgentName $AgentName | Remove-AzSqlElasticJob -Force

Remove-AzSqlElasticJobTargetGroup -Name ServerGroup1 -ResourceGroupName $resourceGroup -ServerName $ServerName -AgentName $AgentName -Force


Remove-AzSqlElasticJobCredential -ResourceGroupName $resourceGroup -ServerName $ServerName -AgentName $AgentName -Name "mastercred"
Remove-AzSqlElasticJobCredential -ResourceGroupName $resourceGroup -ServerName $ServerName -AgentName $AgentName -Name "jobcred"
Remove-AzSqlElasticJobCredential -ResourceGroupName $resourceGroup -ServerName $ServerName -AgentName $AgentName -Name "dbadmin"

