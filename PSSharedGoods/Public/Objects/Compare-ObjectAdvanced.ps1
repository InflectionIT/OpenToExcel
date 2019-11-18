function Compare-ObjectsAdvanced {
    param(
        [object] $Object1,
        [object] $Object2,
        [alias('Property')][string] $CommonProperty = 'DistinguishedName',
        [string[]] $AddObjectArrayName,
        [object[]] $AddObjectArray,
        [string] $Object1Property,
        [string] $Object2Property,
        [string] $ObjectPropertySubstitute = 'SpecialValueToCompare',
        [switch] $RemoveSideIndicator,
        [switch] $KeepTemporaryProperty,
        [ValidateSet('Left', 'Right')][string] $Side = 'Left' # May need Both later on
    )
    $Objects = New-GenericList

    if ($null -eq $Object1 -and $null -eq $Object2) {
        # nothing to do, doesn't event need check for distribution groups because it should be empty as well.
    } elseif ($null -eq $Object1) {
        # nothing to do
    } elseif ($null -eq $Object2) {
        foreach ($G in $Object1) {
            #Add-Member -InputObject $G -MemberType NoteProperty -Name 'OrganizationalUnit' -Value $OrganizationalUnit -Force
            #

            for ($a = 0; $a -lt $AddObjectArrayName.Count; $a++) {
                $G | Add-Member -MemberType NoteProperty -Name $AddObjectArrayName[$a] -Value $AddObjectArray[$a] -Force
                
            }
            $Objects.Add($G)
        }
    } else {
        $Terminate = New-GenericList -Type [bool]

        if ($Object1Property -and $Object2Property) {                
            if ($Object1[0].PSObject.Properties.Name -notcontains $Object1Property) {
                Write-Warning -Message "Compare-InfrastructureObjects - Object1 property doesn't exists $Object1Property"
                $Terminate.Add($true)
            }
            if ($Object2[0].PSObject.Properties.Name -notcontains $Object2Property) {
                Write-Warning -Message "Compare-InfrastructureObjects - Object2 property doesn't exists $Object2Property"
                $Terminate.Add($true)
            }
            if ($Terminate -contains $true) {
                return
            }
            $Object1 | Add-Member -MemberType AliasProperty -Name $ObjectPropertySubstitute -Value $Object1Property -Force
            $Object2 | Add-Member -MemberType AliasProperty -Name $ObjectPropertySubstitute -Value $Object2Property -Force
            $Compare = Compare-Object -ReferenceObject $Object1 -DifferenceObject $Object2 -Property  $ObjectPropertySubstitute -PassThru
        } else {
            if ($Object1[0].PSObject.Properties.Name -notcontains $CommonProperty) {
                Write-Warning -Message "Compare-InfrastructureObjects - Object1 property doesn't exists $CommonProperty"
                $Terminate.Add($true)
            }
            if ($Object2[0].PSObject.Properties.Name -notcontains $CommonProperty) {
                Write-Warning -Message "Compare-InfrastructureObjects - Object2 property doesn't exists $CommonProperty"
                $Terminate.Add($true)
            }
            if ($Terminate -contains $true) {
                return
            }
            $Compare = Compare-Object -ReferenceObject $Object1 -DifferenceObject $Object2 -Property $CommonProperty -PassThru
        }
        if ($Side -eq 'Left') {
            $Compare = $Compare | Where-Object { $_.SideIndicator -eq '<=' }
        } elseif ($Side -eq 'Right') {
            $Compare = $Compare | Where-Object { $_.SideIndicator -eq '=>' }
        } else {
            # left just in case Equal is needed
            $Compare = $Compare | Where-Object { $_.SideIndicator -eq '==' }
        }
        foreach ($G in $Compare) {
            if ($RemoveSideIndicator) {
                $G.PSObject.Members.Remove('SideIndicator')
            }
            if (-not $KeepTemporaryProperty) {
                $G.PSObject.Members.Remove($ObjectPropertySubstitute)
            }
            for ($a = 0; $a -lt $AddObjectArrayName.Count; $a++) {
                $G | Add-Member -MemberType NoteProperty -Name $AddObjectArrayName[$a] -Value $AddObjectArray[$a] -Force
            }
            $Objects.Add($G) 
        }
    }  
    return $Objects
}
