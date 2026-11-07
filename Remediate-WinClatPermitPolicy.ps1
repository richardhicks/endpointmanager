<#

.SYNOPSIS
    Intune Remediations remediation script for the WinCLAT permit policy.

.DESCRIPTION
    Sets the PermitNonCellularCLAT policy value (DWORD) under HKLM\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc to the state set in $DesiredState. This is the value the "Permit non-cellular CLAT" Group Policy setting writes.

    Set $DesiredState to one of the following values, matching the value in the detection script:

    Enabled        Writes 1, creating the key if needed. WinCLAT is permitted and the setting is under policy control.
    Disabled       Writes 0, creating the key if needed. WinCLAT is not permitted and the setting is under policy control.
    NotConfigured  Deletes the value, and the IPxlatCfgSvc key if it is then empty. The setting returns to the local configuration.

    The script changes the registry only. It does not run netsh or restart the IP Translation Configuration Service, because Windows applies the change on its own.

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

# Enabled, Disabled, or NotConfigured. Must match the detection script.
$DesiredState = 'Enabled'

$KeyPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\TCPIP\v6Transition\IPxlatCfgSvc'
$ValueName = 'PermitNonCellularCLAT'
$StateValues = @{ Enabled = 1; Disabled = 0 }

If ($DesiredState -notin @('Enabled', 'Disabled', 'NotConfigured')) {

    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Invalid DesiredState '$DesiredState'. Use Enabled, Disabled, or NotConfigured."
    Exit 1

}

Try {

    If ($DesiredState -eq 'NotConfigured') {

        $Message = "$ValueName was not present."

        If ($null -ne (Get-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction SilentlyContinue)) {

            Remove-ItemProperty -Path $KeyPath -Name $ValueName -ErrorAction Stop
            $Message = "Removed $ValueName."

        }

        If (Test-Path -Path $KeyPath) {

            $Key = Get-Item -Path $KeyPath -ErrorAction Stop

            If ($Key.ValueCount -eq 0 -and $Key.SubKeyCount -eq 0) {

                Remove-Item -Path $KeyPath -ErrorAction Stop
                $Message = "$Message Removed the empty IPxlatCfgSvc key."

            }

        }

        Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
        Exit 0

    }

    $RequiredValue = $StateValues[$DesiredState]

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

    Write-Output "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Failed to set $ValueName to ${DesiredState}: $($_.Exception.Message)"
    Exit 1

}
