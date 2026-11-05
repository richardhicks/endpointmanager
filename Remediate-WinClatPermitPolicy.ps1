<#

.SYNOPSIS
    Intune Remediations remediation script for the WinCLAT permit policy.

.DESCRIPTION
    Writes the PermitNonCellularCLAT policy value (DWORD) under HKLM\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc, creating the key if needed. This is the value the "Permit non-cellular CLAT" Group Policy setting writes. A value of 1 permits WinCLAT and 0 prevents it; either value places the setting under policy control.

    The script writes the registry only. It does not run netsh or restart the IP Translation Configuration Service, because Windows applies the new value on its own.

.INPUTS
    None.

.OUTPUTS
    A single line of text for the Intune remediation output.

.EXAMPLE
    .\Remediate-WinClatPermitPolicy.ps1

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

Try {

    If (-not (Test-Path -Path $KeyPath)) {

        New-Item -Path $KeyPath -Force -ErrorAction Stop | Out-Null

    }

    $ItemProperty = @{

        Path         = $KeyPath
        Name         = $ValueName
        Value        = $RequiredValue
        PropertyType = 'DWord'
        Force        = $true
        ErrorAction  = 'Stop'

    }

    New-ItemProperty @ItemProperty | Out-Null
    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Wrote $ValueName = $RequiredValue."
    Exit 0

}

Catch {

    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Failed to write ${ValueName}: $($_.Exception.Message)"
    Exit 1

}
