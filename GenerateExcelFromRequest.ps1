Import-Module .\PSWriteColor\PSWriteColor.psm1 -Force
Import-Module .\PSSharedGoods\PSSharedGoods.psm1 -Force
Import-Module .\PSWriteExcel\PSWriteExcel.psm1 -Force
. .\OpenDB.ps1

function GenerateExcelFromRequest([int]$requestID) {
    $stopwatch = [system.diagnostics.stopwatch]::StartNew()

    $config = Get-Content -Raw -Path "config.json" | ConvertFrom-Json
    $questions = @{}
    $questionsJSON = $config.questions | Where-Object -FilterScript { $_.display -eq $true } | select id, name, display, title, value
    foreach ($row in $questionsJSON) {
        $questions[$row.id] = $row
    }

    # Get all Request answers
    $opendb = GetOpenDB
    #$requests = $opendb.GetRequests('Finished', 'New Opportunity')
    $requests = $opendb.GetRequestById($requestID) #445

    # Get unique Request IDs
    #$ids = $requests.rows | sort-object -Property id -Unique | select-object id, name
    Write-Host "$($requests.rows.count) requests found"

    # Parse answers for each request
    $requestanswers = @()
    #Get rows for specific request
    Write-Host "Processing request: $($requests.rows[0].name)"
    Write-Host "Parsing answers for request: $($requests.rows[0].name)"
    #$rows = $requests.rows | Where-Object -FilterScript { $_.id -eq $reqId.id }
    # Build object for each request
    # $obj = [pscustomobject]@{
    #     RequestID   = $reqID.id;
    #     RequestName = $rows[0].name;
    # }
    foreach ($questionkey in $questions.Keys) {
        $questionconfig = $questions[$questionkey]
        if ($questionconfig.display -eq 'True') {
            $answer = $requests.rows | Where-Object -FilterScript { $_.questionid -eq $questionconfig.id }
            $answervalue = $opendb.GetAnswerValue($answer)
            #$obj | Add-Member -MemberType NoteProperty -Name $questionconfig.title -Value $answervalue 
            $requestanswers += [pscustomobject]@{ 
                Question = $questionconfig.title
                Answer   = $answervalue
            }
        }
    }
    #$requestanswers += $obj
    Write-Host "Extracting attachments for request: $($requests.rows[0].name)"
    $opendb.SaveRequestAttachmentsToDisk($requestID, $config.attachmentPath)
    Write-Host "-------------------------------"

    Write-Host "Finished parsing requests"
    $filename = $requests.rows[0].name.Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
    $filepath = $config.attachmentPath + $filename + '.xlsx'
    $requestanswers | ConvertTo-Excel -Path $filepath -WorkSheetName 'Requests' -AutoFilter
    Write-Host "Excel spreadsheet has been created"

    $stopwatch.Stop()
    $stopwatch.Elapsed
}

