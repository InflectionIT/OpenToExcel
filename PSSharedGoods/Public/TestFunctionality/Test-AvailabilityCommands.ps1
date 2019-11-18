function Test-AvailabilityCommands {
    param (
        [string[]] $Commands
    )
    $CommandsStatus = foreach ($Command in $Commands) {
        $Exists = Search-Command -Command $Command
        if ($Exists) {
            Write-Verbose "Test-AvailabilityCommands - Command $Command is available."
        } else {
            Write-Verbose "Test-AvailabilityCommands - Command $Command is not available."
        }
        $Exists
    }
    return $CommandsStatus
}