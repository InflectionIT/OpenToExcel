[xml]$grid = Get-Content -Path C:\Users\alanr\Documents\Alan\InflectionIT\Projects\OpenToExcel\gridanswerxml.xml

#Get Grid ID
$gridid = $grid.DataTable.schema.element.MainDataTable

#Get all question answers
$rows = Select-XML -xml $grid -XPath "//$gridid"

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

$gridOutput
