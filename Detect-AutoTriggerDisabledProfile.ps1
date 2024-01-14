<#

.SYNOPSIS
    PowerShell script to detect if an Always On VPN profile is listed in the AutoTriggerDisbledProfiles list.

.EXAMPLE
    .\Detect-AutoTriggerDisabledProfile.ps1

.DESCRIPTION
    This PowerShell script is deployed as a detection script using Intune remediations.

.LINK
    https://github.com/richardhicks/endpointmanager/blob/main/Detect-AutoTriggerDisabledProfile.ps1

.LINK
    https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations

.LINK
    https://directaccess.richardhicks.com/

.NOTES
    Version:        1.0.3
    Creation Date:  February 2, 2022
    Last Updated:   December 29, 2023
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://directaccess.richardhicks.com/

#>

[CmdletBinding()]

Param (

    # Update the $ProfileName value to reflect the name of the Always On VPN profile to check for in the AutoTriggerDisabledProfilesList registry key
    $ProfileName = 'Always On VPN',
    $AutoTriggerDisabledProfile = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Config\ | Select-Object -ExpandProperty AutoTriggerDisabledProfilesList -ErrorAction SilentlyContinue)

)

Try {

    If ($AutoTriggerDisabledProfile -eq $ProfileName) {

        Write-Warning "The AutoTriggerDisabledProfilesList registry key includes the Always On VPN profile ""$ProfileName""."
        Exit 1

    }

    Else {

        Write-Warning "The AutoTriggerDisabledProfilesList registy key does not include the Always On VPN profile ""$ProfileName""."
        Exit 0

    }

}

Catch {

    $ErrorMessage = $_.Exception.Message
    Write-Warning $ErrorMessage
    Exit 1

}
