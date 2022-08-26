<#

.SYNOPSIS
    PowerShell script to update the machine certificate EKU filter setting for Always On VPN device tunnel connections.

.EXAMPLE
    .\Remediate-MachineCertificateEkuFilter.ps1

.DESCRIPTION
    This PowerShell script is deployed as a remediation script using Proactive Remediations in Microsoft Endpoint Manager/Intune.

.LINK
    https://github.com/richardhicks/endpointmanager/blob/main/Remediate-MachineCertificateEkuFilter.ps1

.LINK
    https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations

.LINK
    https://directaccess.richardhicks.com/2021/12/06/always-on-vpn-and-intune-proactive-remediation/

.LINK
    https://directaccess.richardhicks.com/

.NOTES
    Version:        1.0.1
    Creation Date:  July 15, 2022
    Last Updated:   August 26, 2022
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Web Site:       https://www.richardhicks.com/

#>

[CmdletBinding()]

Param (

)

$ConnectionName = 'Enter your Always On VPN device tunnel connection here'
$Oid = 'Enter your application policy OID here'

$Vpn = Get-VpnConnection -Name $ConnectionName -AllUserConnection

Try {

    If ($Null -eq $Vpn) {

        Write-Warning "VPN connection $VPN not found."
        Exit 0

    }

    Write-Verbose "Updating VPN connection $Vpn with machine certificate filter OID $Oid..."
    Set-VpnConnection -Name $ConnectionName -MachineCertificateEKUFilter $Oid -AllUserConnection

}

Catch {

    $ErrorMessage = $_.Exception.Message
    Write-Warning $ErrorMessage
    Exit 1

}