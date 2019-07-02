$jobAgent= Get-AzSqlElasticJobAgent -ResourceGroupName "SQLAgentDemos" -ServerName "SQLAgentDemo" -Name "sqlDemoAgent"
$serverGroupName="ServerGroup1"
$credentialName="jobcred"

Write-Output "Creating a new job"
$JobName = "CreateTablePS"
$Job = $JobAgent | New-AzSqlElasticJob -Name $JobName -RunOnce
$Job


Write-Output "Creating job steps"
$SqlText1 = "IF NOT EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('Step1Table')) CREATE TABLE [dbo].[Step1Table]([TestId] [int] NOT NULL);"
$Job | Add-AzSqlElasticJobStep -Name "step1" -TargetGroupName $serverGroupName -CredentialName $credentialName -CommandText $SqlText1
