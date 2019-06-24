###############################################################################
#	File:		0030_demo_mimigration.ps1
#
#	Summary:    This script creates the migration porject in DMS
#
#				THIS SCRIPT IS PART OF THE TRACK: Ready for take-off
#                                                 How to get your databases
#                                                 into the cloud
#
#	Date:		June 2019
#
#	SQL Server Version: 2008 / 2012 / 2014 / 2016 / 2017
# ----------------------------------------------------------------------------
#	Written by Andre Essing, Microsoft Deutschland GmbH
#
#   This script is intended only as a supplement to demos and lectures
#   given by Andre Essing.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
#   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#   OTHER DEALINGS IN THE SOFTWARE.
###############################################################################


# INSTALL DMS POWERSHELL MODULE
install-module Az.DataMigration -Force -AllowClobber

###############################################################################
# Prepare some stuff and login
###############################################################################

# DEFINE SOME VARIABLES
$subscriptionName = '###SUBSCRIPTION_NAME###'
$region = 'northeurope'
$rgName = '###RESOURCEGROUP_NAME###'
$vNetName = '###VIRTUALNETWORK_NAME###'
$subnetName = '###SUBNET_NAME###'
$dmsName = '###DATAMIGRATIONSERVICE_NAME###'
$dmsSKU = 'Premium_4vCores'
$projectName = '###MIGRATIONPROJECT_NAME###'
$sourceServer = '###SOURCE_NAME-IP###'
$sourceAuth = 'SqlAuthentication'
$targetServer = '###TARGET-RESOURCEID_NAME###'
$dbname = '###DATABASE_NAME###'
$backupFileSharePath='###FILESHARE_UNC###'
$storageResourceId = '###STORAGEACCOUNT_RESOURCEID###'
$appId = '###APPLICATION_ID###'
$appIdPwd = '###APPLICATION_ID_SECRET###'

# LOGIN TO AZURE
Login-AzAccount
Select-AzSubscription -SubscriptionName  $subscriptionName


###############################################################################
# Create an instance of Azure Database Migration Service
###############################################################################

# CREATE RESSOURCE GROUP
New-AzResourceGroup -ResourceGroupName $rgName -Location $region

# CREATE DMS SERVICE
$vNet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vNetName
$vSubNet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vNet -Name $subnetName
$dmsService = New-AzDms -ResourceGroupName $rgName -ServiceName $dmsName -Location $region -Sku $dmsSKU -VirtualSubnetId $vSubNet.Id 
#$dmsService = Get-AzDms -ResourceGroupName $rgName -ServiceName $dmsName


###############################################################################
# Create a migration project
###############################################################################

# CREATE DATABASE CONNECTION INFO FOR SOURCE
$sourceConnInfo = New-AzDmsConnInfo -ServerType SQL -DataSource $sourceServer -AuthType $sourceAuth -TrustServerCertificate:$true
$sourceCred = Get-Credential

# CREATE DATABASE CONNECTION INFO FOR TARGET
$targetConnInfo = New-AzDmsConnInfo -ServerType SQLMI -MiResourceId $targetServer
$targetCred = Get-Credential

# CREATE MIGRATION PROJECT
$project = New-AzDataMigrationProject -ResourceGroupName $rgName -ServiceName $dmsService.Name -ProjectName $projectName -Location $region -SourceType SQL -TargetType SQLMI 


###############################################################################
# Create and start a migration task
###############################################################################

# CREATE BACKUP FILESHARE OBJECT
$backupCred = Get-Credential
$backupFileShare = New-AzDmsFileShare -Path $backupFileSharePath -Credential $backupCred

# CREATE DB OBJECT FOR SINGLE DATABASE
$selectedDbs = @()
$selectedDbs += New-AzDmsSelectedDB -MigrateSqlServerSqlDbMi -Name $dbname -TargetDatabaseName $dbname -BackupFileShare $backupFileShare

# CONFIGURE AZURE ACTIVE DIRECTORY APP
$AppPasswd = ConvertTo-SecureString $appIdPwd -AsPlainText -Force
$app = New-AzDmsAadApp -ApplicationId $appId -AppKey $AppPasswd

# CREATE FULL BACKUP

# CREATE AND START ONLINE MIGRATION
New-AzDataMigrationTask -TaskType MigrateSqlServerSqlDbMiSync `
    -ResourceGroupName $rgName `
    -ServiceName $dmsService.Name `
    -ProjectName $project.Name `
    -TaskName $dbname `
    -SourceConnection $sourceConnInfo `
    -SourceCred $sourceCred `
    -TargetConnection $targetConnInfo `
    -TargetCred $targetCred `
    -SelectedDatabase  $selectedDbs `
    -BackupFileShare $backupFileShare `
    -AzureActiveDirectoryApp $app `
    -StorageResourceId $storageResourceId


###############################################################################
# EOF