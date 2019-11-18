Import-Module .\PSWriteColor\PSWriteColor.psm1 -Force
Import-Module .\PSSharedGoods\PSSharedGoods.psm1 -Force
Import-Module .\PSWriteExcel\PSWriteExcel.psm1 -Force
. .\OpenDB.ps1

# function ConvertHashtableTo-Object {
#     [CmdletBinding()]
#     Param([Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
#         [hashtable]$ht
#     )
#     PROCESS {
#         $requests = @()

#         $ht | % {
#             $result = New-Object psobject;
#             foreach ($key in $_.keys) {
#                 $result | Add-Member -MemberType NoteProperty -Name $key -Value $_[$key]
#             }
#             $requests += $result;
#         }
#         return $requests
#     }
# }

$opendb = GetOpenDB
$requests = $opendb.GetRequests('Finished', 'New Opportunity')
Write-Host "$($requests.rows.count) rows returned"

# Get Request IDs
$ids = $requests.rows | sort-object -Property id -Unique | select-object id

# Get all question IDs and Names
$questions = @{ }
foreach ($row in $requests.rows) {
    $questions[$row.questionid] = $row.QuestionName
}

$requestanswers = @()
foreach($reqID in $ids) {
    #Get rows for specific request
    Write-Host "Getting rows for Request $reqId"
    $rows = $requests.rows | Where-Object -FilterScript { $_.id -eq $reqId.id}
    Write-Host "$($rows.count) rows returned"
    # Build object for each request
    $obj = [pscustomobject]@{
        RequestID = $reqID.id;
        RequestName = $rows[0].name;
    }
    foreach($question in $questions.Keys) {
        $answer = $rows | Where-Object -FilterScript { $_.questionid -eq $question }
        $obj | Add-Member -MemberType NoteProperty -Name $questions[$question] -Value $answer.AnswerDisplayValue
    }

    # Add request obj to list
    Write-Host "Adding $($obj.RequestID) to list"
    $requestanswers += $obj
    #$requestanswers += ConvertHashtableTo-Object($obj)
}
Write-Host "$($requestanswers.count) requestanswers added"

# $values = @()
# $values += foreach ($row in $requests.rows) {
#     [pscustomobject]@{
#         name         = $row.name
#         questionid   = $row.questionid;
#         questionname = $row.QuestionName;
#         answervalue  = $row.AnswerValue;
#     }
# }

#$requests.rows | select questionid, AnswerValue, QuestionName, name | ConvertTo-Excel -Path 'TestExcel.xlsx' -WorkSheetName 'Requests' -AutoFilter
$requestanswers | ConvertTo-Excel -Path 'TestExcel2.xlsx' -WorkSheetName 'Requests' -AutoFilter




# Workflow
# - Get all questions associated with query - select distinct questionid, questionname from FormAnswers fa
#                                             JOIN Requests r on r.Form_Id = fa.Form_Id
#                                             where r.RequestType = 'New Opportunity' and r.Environment = 'Production' and r.Status = 'Finished' and len(fa.questionname) > 0
# - Load all questions into hashtable
# - Get unique request IDs associated with query - select distinct r.id FROM Requests r 
#                                                  where r.RequestType = 'New Opportunity' and r.Environment = 'Production' and r.Status = 'Finished'                                     
# - Loop over each request to retrieve data

# Configuration
# Request Status
# Request Type
# List of questions by name