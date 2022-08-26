<#

.SYNOPSIS
    PowerShell script to detect the machine certificate EKU filter setting for Always On VPN device tunnel connections.

.EXAMPLE
    .\Detect-MachineCertificateEkuFilter.ps1

.DESCRIPTION
    This PowerShell script is deployed as a detection script using Proactive Remediations in Microsoft Endpoint Manager/Intune.

.LINK
    https://github.com/richardhicks/endpointmanager/blob/main/Detect-MachineCertificateEkuFilter.ps1

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

$Vpn = Get-VPnConnection -Name $ConnectionName -AllUserConnection

Try {

    If ($Null -eq $Vpn) {

        Write-Warning "VPN connection $VPN not found."
        Exit 0

    }

    If ($Vpn.MachineCertificateEKUFilter -eq $Oid) {

        Write-Verbose "Machine certificate filter set to $Oid. No remediation required."
        Exit 0

    }

    Else {

        Write-Verbose "Machine certificate filter not set or does not match $Oid. Remediation required."
        Exit 1

    }

}

Catch {

    $ErrorMessage = $_.Exception.Message
    Write-Warning $ErrorMessage
    Exit 1

}