<#

.SYNOPSIS
    Intune Remediations detection script for the WinCLAT permit policy.

.DESCRIPTION
    Checks whether the PermitNonCellularCLAT policy value under HKLM\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc matches the state set in $DesiredState. Exits 0 when it does, and 1 when it does not, so that Intune runs the remediation script.

    Set $DesiredState to one of the following values, matching the value in the remediation script:

    Enabled        The value must be 1. WinCLAT is permitted and the setting is under policy control.
    Disabled       The value must be 0. WinCLAT is not permitted and the setting is under policy control.
    NotConfigured  The value must not be present. The setting is controlled by the local configuration.

    The script reads the registry only and makes no changes.

.INPUTS
    None.

.OUTPUTS
    A single line of text for the Intune detection output.

.EXAMPLE
    .\Detect-WinClatPermitPolicy.ps1

    Run by Intune Remediations as SYSTEM in 64-bit PowerShell.

.LINK
    https://learn.microsoft.com/intune/intune-service/fundamentals/remediations

.NOTES
    Version:        1.1
    Creation Date:  November 4, 2026
    Last Updated:   November 7, 2026
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

)

# Enabled, Disabled, or NotConfigured. Must match the remediation script.
$DesiredState = 'Enabled'

$KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc'
$ValueName = 'PermitNonCellularCLAT'
$StateValues = @{ Enabled = 1; Disabled = 0 }
$TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

If ($DesiredState -notin @('Enabled', 'Disabled', 'NotConfigured')) {

    Write-Output "$TimeStamp Invalid DesiredState '$DesiredState'. Use Enabled, Disabled, or NotConfigured."
    Exit 1

}

$Current = $null
$Item = Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction SilentlyContinue

If ($null -ne $Item) {

    $Current = $Item.$ValueName

}

If ($DesiredState -eq 'NotConfigured') {

    If ($null -eq $Current) {

        Write-Output "$TimeStamp Compliant: $ValueName is not present."
        Exit 0

    }

    Write-Output "$TimeStamp Not compliant: $ValueName is $Current, required not present."
    Exit 1

}

$RequiredValue = $StateValues[$DesiredState]

If ($null -eq $Current) {

    Write-Output "$TimeStamp Not compliant: $ValueName is not present, required $RequiredValue."
    Exit 1

}

If ($Current -eq $RequiredValue) {

    Write-Output "$TimeStamp Compliant: $ValueName is $Current."
    Exit 0

}

Write-Output "$TimeStamp Not compliant: $ValueName is $Current, required $RequiredValue."
Exit 1
