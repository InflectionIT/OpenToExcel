. .\OpenDB.ps1

$opendb = GetOpenDB
$requests = $opendb.GetRequests('Finished', 'New Opportunity')
Write-Host "$($requests.rows.count) rows returned"

# Get Request IDs
$ids = $requests.rows | sort-object -Property id -Unique | select-object id

# Get all question IDs and Names
$questions = @{}
foreach ($row in $requests.rows) {
    $questiondetails = [pscustomobject]@{
        id = $row.questionid;
        name = $row.QuestionName;
        display = $true;
        title = $row.QuestionName;    
    }

    $questions[$questiondetails.id] = $questiondetails
}

$questionsJSON = @()

foreach($key in $questions.keys) {
    $questionsJSON += $questions[$key]
}

$config = [ordered]@{
    attachmentPath = "c:\temp";
    excelPath = "c:\temp\OpenRequests.xlsx";
    questions = $questionsJSON;
}
$config | ConvertTo-Json | Out-File "config.json"

