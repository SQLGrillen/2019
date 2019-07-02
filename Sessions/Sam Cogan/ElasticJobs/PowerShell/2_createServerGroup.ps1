Write-Output "Creating test target groups..."
$jobAgent= Get-AzSqlElasticJobAgent -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" -Name "sqlDemoAgent"
# Create ServerGroup target group
$TargetServerName="sqlagentdemo.database.windows.net" 
$MasterCredName="mastercred"
$ServerGroup = $JobAgent | New-AzSqlElasticJobTargetGroup -Name 'ServerGroup1'
$ServerGroup | Add-AzSqlElasticJobTarget -ServerName $TargetServerName -RefreshCredentialName $MasterCredName
$ServerGroup | Add-AzSqlElasticJobTarget -ServerName $TargetServerName  -Database "jobdatabase" -Exclude
