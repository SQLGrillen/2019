#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI under Source Control
# Demo 3: Getting some data
#-------------------------------------------------------
break

    # This is a wrapper module
    # Install-Module MicrosoftPowerBIMgmt
    # Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable

#-------------------------------------------------------
# Authenticate to Power BI

    Login-PowerBI

#-------------------------------------------------------
# The module can't handle API call to export reports yet.
# We can still use the module to skip some of the authentication 
# steps and invoke the REST API manually

    $token = Get-PowerBIAccessToken

    #Build the access token into the authentication header
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'= $token.Authorization
    }

#-------------------------------------------------------
#Loop through all of the workspaces, exporting reports locally as we go
#We can't pipe this "easily" because the URI changes for each command

    $uri = "https://api.powerbi.com/v1.0/myorg/groups"
    
    $workspaces = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    foreach($workspace in $workspaces.value){
        $workspaceid = $workspace.id
        $workspacename = $workspace.name

        #Create path for workspace if it doesnt exist
        if(!(Test-Path -path "C:\PowerBI_Backups\$($workspacename)")){
            New-Item -ItemType Directory -Path "C:\PowerBI_Backups\$($workspacename)"
        }

        $reporturi = "https://api.powerbi.com/v1.0/myorg/groups/$($workspaceid)/reports"

        $reports = Invoke-RestMethod -Uri $reporturi -Headers $authHeader -Method GET

        foreach($report in $reports.value){
            $reportid = $report.id
            $reportname = $report.name
   
            $exporturi = "https://api.powerbi.com/v1.0/myorg/groups/$($workspaceid)/reports/$($reportid)/Export"
            
            Invoke-RestMethod -Uri $exporturi -Headers $authHeader -Method GET | Out-File -Force -FilePath "C:\PowerBI_Backups\$($workspacename)\$($reportname).pbix"
        }        
    }

    Start-Process "C:\PowerBI_Backups"