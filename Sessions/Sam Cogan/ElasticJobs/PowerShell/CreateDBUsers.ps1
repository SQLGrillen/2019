# In the master database (target server)
# - Create the master user login
# - Create the master user from master user login
# - Create the job user login
$TargetServer = Get-AzSqlServer -ResourceGroupName SQLAgentDemos -ServerName sqlagentdemo
$DB1=Get-AzSqlDatabase -ResourceGroupName SQLAgentDemos -DatabaseName "sqlAgentDemoDB01" -ServerName $TargetServer.ServerName
$DB2=Get-AzSqlDatabase -ResourceGroupName SQLAgentDemos -DatabaseName "sqlAgentDemoDB02" -ServerName $TargetServer.ServerName
$DB3=Get-AzSqlDatabase -ResourceGroupName SQLAgentDemos -DatabaseName "OutputDatabase" -ServerName $TargetServer.ServerName

$AdminLogin="DBAdmin"
$AdminPassword="4IvufzC64R3z"


$Params = @{
  'Database' = 'master'
  'ServerInstance' =  $TargetServer.ServerName + '.database.windows.net'
  'Username' = $AdminLogin
  'Password' = $AdminPassword
  'OutputSqlErrors' = $true
  'Query' = "CREATE LOGIN masteruser WITH PASSWORD='password!123'"
}
Invoke-SqlCmd @Params
$Params.Query = "CREATE USER masteruser FROM LOGIN masteruser"
Invoke-SqlCmd @Params
$Params.Query = "CREATE LOGIN jobuser WITH PASSWORD='password!123'"
Invoke-SqlCmd @Params

# For each of the target databases
# - Create the jobuser from jobuser login
# - Make sure they have the right permissions for successful script execution
$TargetDatabases = @($Db1.DatabaseName,$Db2.DatabaseName, $Db3.DatabaseName )
$CreateJobUserScript =  "CREATE USER jobuser FROM LOGIN jobuser"
$GrantAlterSchemaScript = "GRANT ALTER ON SCHEMA::dbo TO jobuser"
$GrantCreateScript = "GRANT CREATE TABLE TO jobuser"

$TargetDatabases | % {
  $Params.Database = $_

  $Params.Query = $CreateJobUserScript
  Invoke-SqlCmd @Params

  $Params.Query = $GrantAlterSchemaScript
  Invoke-SqlCmd @Params

  $Params.Query = $GrantCreateScript
  Invoke-SqlCmd @Params
}