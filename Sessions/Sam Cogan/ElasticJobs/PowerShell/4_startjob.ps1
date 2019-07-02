$jobName="CreateTablePS"

$jobexecution= Start-AzSqlElasticJob -JobName $jobName -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" -AgentName "sqlDemoAgent"
$jobexecution


# $jobName="GetFragmentation"

# $jobexecution= Start-AzSqlElasticJob -JobName $jobName -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" -AgentName "sqlDemoAgent"
# $jobexecution