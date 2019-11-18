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

    [string] GetAnswerValue($answer) {
        # Attachments
        if ($answer.AnswerType -eq 'IntApp.Wilco.Model.Forms.AnswerTypes.AttachmentAnswer') { 
            return "<Invalid question type>"
        }
        # DataTables
        elseif ($answer.AnswerType -eq 'System.Data.DataTable') {
            return "<Invalid question type>"
        }
        else {
            return $answer.AnswerDisplayValue
        }
    
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
