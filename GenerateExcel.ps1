Import-Module .\PSWriteColor\PSWriteColor.psm1 -Force
Import-Module .\PSSharedGoods\PSSharedGoods.psm1 -Force
Import-Module .\PSWriteExcel\PSWriteExcel.psm1 -Force
. .\OpenDB.ps1

$stopwatch = [system.diagnostics.stopwatch]::StartNew()

$config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json
$questions = @{}
$config = $config | Where-Object -FilterScript { $_.display -eq $true} | select id, name, display, title, value
foreach ($row in $config) {
    $questions[$row.id] = $row
}

# Get all Request answers
$opendb = GetOpenDB
$requests = $opendb.GetRequests('Finished', 'New Opportunity')

# Get unique Request IDs
$ids = $requests.rows | sort-object -Property id -Unique | select-object id, name
Write-Host "$($ids.count) requests found"

# Parse answers for each request
$requestanswers = @()
foreach($reqID in $ids) {
    #Get rows for specific request
    Write-Host "Processing request: $($reqId.name)"
    Write-Host "Parsing answers for request: $($reqId.name)"
    $rows = $requests.rows | Where-Object -FilterScript { $_.id -eq $reqId.id}
    # Build object for each request
    $obj = [pscustomobject]@{
        RequestID = $reqID.id;
        RequestName = $rows[0].name;
    }
    foreach($questionkey in $questions.Keys) {
        $questionconfig = $questions[$questionkey]
        if ($questionconfig.display -eq 'True') {
            $answer = $rows | Where-Object -FilterScript { $_.questionid -eq $questionconfig.id }
            $answervalue = $opendb.GetAnswerValue($answer)
            $obj | Add-Member -MemberType NoteProperty -Name $questionconfig.title -Value $answervalue #$answer.AnswerDisplayValue #$answer.Properties[$answervalue].Value
        }
    }
    $requestanswers += $obj
    Write-Host "Extracting attachments for request: $($reqId.name)"
    $opendb.SaveRequestAttachmentsToDisk($reqId.id, "c:\temp\")
    Write-Host "-------------------------------"
}

Write-Host "Finished parsing requests"
$requestanswers | ConvertTo-Excel -Path 'OpenRequests.xlsx' -WorkSheetName 'Requests' -AutoFilter
Write-Host "Excel spreadsheet has been created"

#$opendb.SaveRequestAttachmentsToDisk(92, "c:\temp\")

$stopwatch.Stop()
$stopwatch.Elapsed
