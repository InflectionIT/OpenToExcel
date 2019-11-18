function Remove-WinADUserGroups {
    [CmdletBinding()]
    [alias("Remove-ADUserGroups")]
    param(
        [parameter(Mandatory = $true)][Object] $User,
        [ValidateSet("Distribution", "Security")][String] $GroupCategory ,
        [ValidateSet("DomainLocal", "Global", "Universal")][String] $GroupScope,
        [string[]] $Groups,
        [switch] $All,
        [switch] $WhatIf
    )
    $Object = @()
    try {
        $ADgroups = Get-ADPrincipalGroupMembership -Identity $User.DistinguishedName -ErrorAction Stop | Where-Object { $_.Name -ne "Domain Users" }
    } catch {
        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
        $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
    }
    if ($ADgroups) {
        if ($All) {
            #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups ', ($ADgroups.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow
            foreach ($Group in $ADgroups) {
                try {
                    if (-not $WhatIf) {
                        Remove-ADPrincipalGroupMembership -Identity $User.DistinguishedName -MemberOf $Group -Confirm:$false -ErrorAction Stop
                    }
                    $Object += @{ Status = $true; Output = $Group.Name; Extended = 'Removed from group.' }
                } catch {
                    $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                    $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
                }
            }
        }
        if ($GroupCategory) {
            $ADGroupsByCategory = $ADgroups | Where-Object { $_.GroupCategory -eq $GroupCategory }
            if ($ADGroupsByCategory) {
                #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by category - ', $GroupCategory, ") ", ($ADGroupsByCategory.Name -join ', '), ' from user ', $User.DisplayName -Colo White, Yellow, Green, White, Yellow, White, Blue
                foreach ($Group in $ADGroupsByCategory) {
                    try {
                        if (-not $WhatIf) {
                            Remove-ADPrincipalGroupMembership -Identity $User.DistinguishedName -MemberOf $Group -Confirm:$false -ErrorAction Stop
                        }
                        $Object += @{ Status = $true; Output = $Group.Name; Extended = 'Removed from group.' }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
                    }
                }
            }
        }
        if ($GroupScope) {
            $ADGroupsByScope = $ADgroups | Where-Object { $_.GroupScope -eq $GroupScope }
            if ($ADGroupsByScope) {
                #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by scope ', " - $GroupScope) ", ($ADGroupsByScope.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow, White, Blue
                foreach ($Group in $ADGroupsByScope) {
                    try {
                        if (-not $WhatIf) {
                            Remove-ADPrincipalGroupMembership -Identity $User.DistinguishedName -MemberOf $Group -Confirm:$false -ErrorAction Stop
                        }
                        $Object += @{ Status = $true; Output = $Group.Name; Extended = 'Removed from group.' }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
                    }
                }
            }
        }
        if ($Groups) {
            foreach ($Group in $Groups) {
                $ADGroupsByName = $ADgroups | Where-Object { $_.Name -like $Group }
                if ($ADGroupsByName) {
                    #Write-Color @Script:WriteParameters -Text '[i]', ' Removing groups (by name) ', ($ADGroupsByName.Name -join ', '), ' from user ', $User.DisplayName -Color White, Yellow, Green, White, Yellow, White, Yellow
                    try {
                        if (-not $WhatIf) {
                            Remove-ADPrincipalGroupMembership -Identity $User.DistinguishedName -MemberOf $ADGroupsByName -Confirm:$false -ErrorAction Stop
                        }
                        $Object += @{ Status = $true; Output = $Group.Name; Extended = 'Removed from group.' }
                    } catch {
                        $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
                        $Object += @{ Status = $false; Output = $Group.Name; Extended = $ErrorMessage }
                    }
                } else {
                    $Object += @{ Status = $false; Output = $Group.Name; Extended = 'Not available on user.' }
                }
            }
        }
    }
    return $Object
}
