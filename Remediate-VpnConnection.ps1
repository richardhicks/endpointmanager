<#

.SYNOPSIS
    PowerShell script to remove an existing VPN connection.

.EXAMPLE
    .\Remediate-VpnConnection.ps1

.DESCRIPTION
    This PowerShell script is deployed as a remediation script using Microsoft Intune remediations.

.LINK
    https://github.com/richardhicks/endpointmanager/blob/main/Remediate-VpnConnection.ps1

.LINK
    https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations

.LINK
    https://directaccess.richardhicks.com/2021/12/06/always-on-vpn-and-intune-proactive-remediation/

.LINK
    https://directaccess.richardhicks.com/

.NOTES
    Version:        1.0
    Creation Date:  September 26, 2023
    Last Updated:   September 26, 2023
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

)

$ConnectionName = 'Always On VPN'

$Vpn = Get-VpnConnection -Name $ConnectionName -ErrorAction SilentlyContinue

Try {

    If ($Null -eq $Vpn) {

        Write-Warning "VPN connection `'$ConnectionName`' not found."
        Exit 0

    }

    Write-Verbose "Removing VPN connection `'$ConnectionName`'..."
    Get-VpnConnection -Name $ConnectionName | Remove-VpnConnection -Force

}

Catch {

    $ErrorMessage = $_.Exception.Message
    Write-Warning $ErrorMessage
    Exit 1

}