<#
Output of Get-ADPrincipalGroupmembership:

distinguishedName : CN=Organization Management,OU=Microsoft Exchange Security Groups,DC=ad,DC=evotec,DC=xyz
GroupCategory     : Security
GroupScope        : Universal
name              : Organization Management
objectClass       : group
objectGUID        : 551c2400-f0d2-4aa6-8dbf-f9722ceb8675
SamAccountName    : Organization Management
SID               : S-1-5-21-853615985-2870445339-3163598659-1117

#>

function Add-WinADUserGroups {
    [CmdletBinding()]
    [alias("Add-ADUserGroups")]
    param(
        [parameter(Mandatory = $true)][Object] $User,
        [string[]] $Groups,
        [string] $FieldSearch = 'Name',
        [switch] $WhatIf
    )
    $Object = @()
    try {
        $ADgroups = Get-ADPrincipalGroupMembership -Identity $User.DistinguishedName | Where-Object {$_.Name -ne "Domain Users" }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
    }
    if ($Groups) {
        foreach ($Group in $Groups) {
            if ($ADgroups.$FieldSearch -notcontains $Group) {
                try {
                    if (-not $WhatIf) {
                        Add-ADGroupMember -Identity $Group -Members $User.DistinguishedName -ErrorAction Stop
                    }
                    $Object += @{ Status = $true; Output = $Group; Extended = 'Added to group.' }

                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    $Object += @{ Status = $false; Output = $Group; Extended = $ErrorMessage }
                }
            } else {
                # Turned off to not clutter view, may required turning back on.
                #$Object += @{ Status = $false; Output = $Group; Extended = 'Already exists.' }
            }
        }
    }
    return $Object
}