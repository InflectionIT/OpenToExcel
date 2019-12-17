class OpenDB
{
    [string] $connectionString = 'Data Source=172.83.12.210;Initial Catalog=Flowdb;User ID=sa;Password=Tsunami9!'
    [SQLHelper]$sql 

    OpenDB()
    {
        $this.sql = [SQLHelper]::new($this.connectionString)
    }

    [array] ExecuteSQL($query)
    {
        return $this.sql.ExecuteQuery($query)
    }

    [array] GetRequestById([int]$RequestID) {
        $query = "select r.id, r.name, fa.questionid, fa.AnswerType, fa.AnswerValue, fa.AnswerDisplayValue, fa.QuestionName, r.Environment, r.status, r.RequestType from FormAnswers fa
            JOIN Requests r on r.Form_Id = fa.Form_Id
            where r.id = $RequestID"

        return $this.ExecuteSQL($query)
    } 

    SaveRequestAttachmentsToDisk([int]$RequestID, [string]$filepath) {
        $attachments = $this.GetAttachmentsForRequest($RequestID)

        foreach($att in $attachments.rows) {
            $filename = $att.Name
            $path = $filepath + $filename
            if ($att.ContentType -eq 'text/plain') {
                $bytes = $att.Content
                $output = [System.Text.Encoding]::ASCII.GetString($bytes)
                $output | Out-File -LiteralPath $path
            }
            else {
                $bytes = $att.Content
                [io.file]::WriteAllBytes($path, $bytes) 
            }
        }
    }    

    [array] GetAttachmentsForRequest([int]$RequestID) {
        $query = "select Component_Id FROM Requests WHERE id = $RequestID"
        $results = $this.ExecuteSQL($query)
        $ComponentID = $results.Component_Id

        $query = "select a.Name, a.ContentType, c.Content from DocumentsContent c
            JOIN Attachments a on a.DocumentsContentId = c.Id
            where c.Id in (select DocumentsContentId from Attachments where RootComponent_Id = $ComponentID)"

        return $this.ExecuteSQL($query)
    }

    #[string] GetAttachment($id) {
    #    $query = "SELECT CONVERT(VARCHAR(MAX), Content) from DocumentsContent WHERE Id = '$id'"
    #
    #    return $this.ExecuteSQL($query)
    #}

    [string] GetAnswerValue($answer) {
        # Attachments
        if ($answer.AnswerType -eq 'IntApp.Wilco.Model.Forms.AnswerTypes.AttachmentAnswer') { 
            return "<Invalid question type>"
        }
        # DataTables
        elseif ($answer.AnswerType -eq 'System.Data.DataTable') {
            return $this.GetGridAnswerValue([xml]$answer.AnswerValue)
        }
        else {
            return $answer.AnswerDisplayValue
        }
    
    }

    [string] GetGridAnswerValue($gridXML) {
        #Get Grid ID
        $gridid = $gridXML.DataTable.schema.element.MainDataTable

        #Get all question answers
        $rows = Select-XML -xml $gridXML -XPath "//$gridid"

        $gridOutput = ''
        #Loop over each grid row and extract results
        foreach($row in $rows.Node) {
            foreach($props in $row.PSObject.Properties) {
                if ($props.Name.StartsWith("col_")) {
                    $propName = $props.Name
                    $property = $row | Select-Object -ExpandProperty $propName
                    if ([bool]($property.PSObject.Properties.name -match "Value")) {
                        $gridOutput += $property.Value + '|'
                    }
                    else {
                        $gridOutput += $property + '|'
                    }
                }
            }
            $gridOutput += "`r`n"
        }

        return $gridOutput
    }
    
    [array] GetRequests([string]$Status, [string]$RequestType) {
        $query = "select r.id, r.name, fa.questionid, fa.AnswerType, fa.AnswerValue, fa.AnswerDisplayValue, fa.QuestionName, r.Environment, r.status, r.RequestType from FormAnswers fa
            JOIN Requests r on r.Form_Id = fa.Form_Id
            where r.Status = '$Status' 
            and r.RequestType = '$RequestType' 
            and r.Environment = 'Production' and LEN(fa.questionname) > 0"

        return $this.ExecuteSQL($query)
    }

    [array] GetProjects() {
        $data = @()

        $projsql = "Select * from contracts where status not like 'opportunity%'"
        $response = $this.ExecuteSQL($projsql)
        
        $data += foreach ($project in $response[0]) {
            [pscustomobject]@{
                SmartsheetId = $project.SmartsheetId;
                SOW = $project.SOW;
                LinkedSOW = $project.LinkedSOW;
                Firm = $project.Firm;
                Name = $project.Name;
                SE = $project.SE;
                Practice = $project.Practice;
                Status = $project.Status;
                Revenue = $project.Revenue;
                Amount = $project.Amount;       
            }
        }   
        
        return $data
    }    
}

class SQLHelper 
{
    [string] $Connectionstring

    SQLHelper([string] $Connectionstring) 
    {
        $this.Connectionstring = $Connectionstring
    }

    [boolean] TestConnection()
    {
        try
        {
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $this.Connectionstring;
            $sqlConnection.Open();
            $sqlConnection.Close();

            return $true;
        }
        catch
        {
            return $false;
        }
    }

    [array] ExecuteQuery ([string]$Query)
    {
        #connect to database
        $connection = New-Object System.Data.SqlClient.SqlConnection($this.Connectionstring)
        $connection.Open()
        
        #build query object
        $command = $connection.CreateCommand()
        $command.CommandText = $Query
        $command.CommandTimeout = 0
        
        #run query
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $dataset = New-Object System.Data.DataSet
        [void]$adapter.Fill($dataset) #| out-null
        
        #return the first collection of results or an empty array
        If ($null -ne $dataset.Tables[0]) { 
            $table = $dataset.Tables[0] 
            if ($table.Rows.Count -eq 0) { 
                $table = New-Object System.Collections.ArrayList 
            }
        }
        Else { 
            $table = New-Object System.Collections.ArrayList 
        }
        
        $connection.Close()
        return ,$table
    }
}

function GetOpenDB() {
    return [OpenDB]::new()
}
