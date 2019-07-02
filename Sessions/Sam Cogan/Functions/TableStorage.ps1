

    param($request,$inputValues, $TriggerMetadata)

    $VerbosePreference="Continue"

$SqlServerPort = 1433
$RebuildOffline = $False

    $VerbosePreference="Continue"

    # # Get the stored username and password from the Automation credential
    # $SqlCredential = Get-AutomationPSCredential -Name $SQLCredentialName

write-output "input:" + $($inputValues | out-string)
   
   write-output "username: $($inputValues.SQLCredentialUsername)"



    # if ($SqlCredential -eq $null)
    # {
    #     throw "Could not retrieve '$SQLCredentialName' credential asset. Check that you created this first in the Automation service."
    # }
    $SqlServer= $inputValues.SQLServer
    $Database= $inputValues.Database
    $SqlUsername = $inputValues.SQLCredentialUsername
    $SqlPass =  $inputValues.SQLCredentialPassword
    write-output "Fragmentation Level = $REQ_QUERY_FragPercentage"
    if($REQ_QUERY_FragPercentage){
        $FragPercentage = $REQ_QUERY_FragPercentage
    }
    else{
        $FragPercentage=20
    }

    $TableNames=@()
    write-output "Server=tcp:$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"
        # Define the connection to the SQL Database
        $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")
        
        # Open the SQL connection
        $Conn.Open()
        
        # SQL command to find tables and their average fragmentation
        $SQLCommandString = @"
        SELECT a.object_id, avg_fragmentation_in_percent
        FROM sys.dm_db_index_physical_stats (
            DB_ID(N'$Database')
            , OBJECT_ID(0)
            , NULL
            , NULL
            , NULL) AS a
        JOIN sys.indexes AS b 
        ON a.object_id = b.object_id AND a.index_id = b.index_id;
"@
        # Return the tables with their corresponding average fragmentation
        $Cmd=new-object system.Data.SqlClient.SqlCommand($SQLCommandString, $Conn)
        $Cmd.CommandTimeout=120
        
        # Execute the SQL command
        $FragmentedTable=New-Object system.Data.DataSet
        $Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
        [void]$Da.fill($FragmentedTable)


        # Get the list of tables with their object ids
        $SQLCommandString = @"
        SELECT  t.name AS TableName, t.OBJECT_ID FROM sys.tables t
"@

        $Cmd=new-object system.Data.SqlClient.SqlCommand($SQLCommandString, $Conn)
        $Cmd.CommandTimeout=120

        # Execute the SQL command
        $TableSchema =New-Object system.Data.DataSet
        $Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
        [void]$Da.fill($TableSchema)


        # Return the table names that have high fragmentation
        ForEach ($FragTable in $FragmentedTable.Tables[0])
        {
            Write-Output ("Table Object ID:" + $FragTable.Item("object_id"))
            Write-Output ("Fragmentation:" + $FragTable.Item("avg_fragmentation_in_percent"))
            
            If ($FragTable.avg_fragmentation_in_percent -ge $FragPercentage)
            {
                # Table is fragmented. Return this table for indexing by finding its name
                ForEach($Id in $TableSchema.Tables[0])
                {
                    if ($Id.OBJECT_ID -eq $FragTable.object_id.ToString())
                    {
                        # Found the table name for this table object id. Return it
                        Write-Output ("Found a table to index! : " +  $Id.Item("TableName"))
                        $TableNames+=$Id.TableName
                    }
                }
            }
        }

        $Conn.Close()
    

    # If a specific table was specified, then find this table if it needs to indexed, otherwise
    # set the TableNames to $null since we shouldn't process any other tables.
    If ($Table)
    {
        Write-Output ("Single Table specified: $Table")
        If ($TableNames -contains $Table)
        {
            $TableNames = $Table
        }
        Else
        {
            # Remove other tables since only a specific table was specified.
            Write-Output ("Table not found: $Table")
            $TableNames = $Null
        }
    }

    # Interate through tables with high fragmentation and rebuild indexes
    ForEach ($TableName in $TableNames)
    {


    Write-Output "Indexing Table $TableName..."
    
  
        
        $SQLCommandString = @"
        EXEC('ALTER INDEX ALL ON $TableName REBUILD with (ONLINE=ON)')
"@

        # Define the connection to the SQL Database
        $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")
        
        # Open the SQL connection
        $Conn.Open()

        # Define the SQL command to run. In this case we are getting the number of rows in the table
        $Cmd=new-object system.Data.SqlClient.SqlCommand($SQLCommandString, $Conn)
        # Set the Timeout to be less than 30 minutes since the job will get queued if > 30
        # Setting to 25 minutes to be safe.
        $Cmd.CommandTimeout=1500

        # Execute the SQL command
        Try 
        {
            $Ds=New-Object system.Data.DataSet
            $Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
            [void]$Da.fill($Ds)
        }
        Catch
        {
            if (($_.Exception -match "offline") -and ($RebuildOffline) )
            {
                Write-Output ("Building table $TableName offline")
                $SQLCommandString = @"
                EXEC('ALTER INDEX ALL ON $TableName REBUILD')
"@              

                # Define the SQL command to run. 
                $Cmd=new-object system.Data.SqlClient.SqlCommand($SQLCommandString, $Conn)
                # Set the Timeout to be less than 30 minutes since the job will get queued if > 30
                # Setting to 25 minutes to be safe.
                $Cmd.CommandTimeout=1500

                # Execute the SQL command
                $Ds=New-Object system.Data.DataSet
                $Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd)
                [void]$Da.fill($Ds)
            }
            Else
            {
                # Will catch the exception here so other tables can be processed.
                Write-Error "Table $TableName could not be indexed. Investigate indexing each index instead of the complete table $_"
            }
        }
        # Close the SQL connection
        $Conn.Close()
    }  
    

    Write-Output "Finished Indexing"
