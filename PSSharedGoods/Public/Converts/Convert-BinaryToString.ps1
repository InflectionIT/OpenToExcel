function Convert-BinaryToString {
    param(
        [alias('Bin')]
        [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
        [Byte[]]$Binary
    )
    if ($null -ne $Binary) {
        return [System.Text.Encoding]::Unicode.GetString($Binary)
    }
}