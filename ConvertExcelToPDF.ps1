param(
    # Excel file path
    [parameter(mandatory)][string]$filepath
)

$fileitem = Get-Item $filepath

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    $wb = $excel.Workbooks.Open($fileitem.FullName)

    # Generate path of save destination PDF file
    $pdfpath = $fileitem.DirectoryName + "\" + $fileitem.BaseName + ".pdf"

    # Save as PDF
    $wb.ExportAsFixedFormat([Microsoft.Office.Interop.Excel.XlFixedFormatType]::xlTypePDF, $pdfpath)

    $wb.Close()

    $excel.Quit()
}
finally {
    # Release objects
    $sheet, $wb, $excel | ForEach-Object {
        if ($_ -ne $null) {
            [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($_)
        }
    }
}