<#

.SYNOPSIS
    Intune Remediations detection script for the WinCLAT permit policy.

.DESCRIPTION
    Checks whether the PermitNonCellularCLAT policy value is present under HKLM\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc with the required value. Exits 0 when it is, and 1 when it is missing or different, so that Intune runs the remediation script.

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
    Version:        1.0
    Creation Date:  November 4, 2026
    Last Updated:   November 4, 2026
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

)

$KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc'
$ValueName = 'PermitNonCellularCLAT'
$RequiredValue = 1
$TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Try {

    $Current = Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction Stop | Select-Object -ExpandProperty $ValueName

}

Catch {

    Write-Output "$TimeStamp Not compliant: $ValueName is not present."
    Exit 1

}

If ($Current -eq $RequiredValue) {

    Write-Output "$TimeStamp Compliant: $ValueName is $Current."
    Exit 0

}

Write-Output "$TimeStamp Not compliant: $ValueName is $Current, required $RequiredValue."
Exit 1
