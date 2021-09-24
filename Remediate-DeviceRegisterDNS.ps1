<#

.SYNOPSIS
    PowerShell script to update the value of IpDnsFlags in raspshone.pbk for Always On VPN device tunnel connections.

.EXAMPLE
    .\Remediate-DeviceRegisterDNS.ps1

.DESCRIPTION
    This PowerShell script is deployed as a remediation script using Proactive Remediations in Microsoft Endpoint Manager/Intune.

.LINK
    https://docs.microsoft.com/en-us/mem/analytics/proactive-remediations

.LINK
    https://directaccess.richardhicks.com/

.NOTES
    Version:        1.0
    Creation Date:  September 24, 2021
    Last Updated:   September 24, 2021
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Web Site:       https://directaccess.richardhicks.com/

#>

[CmdletBinding()]

Param (

)

$RasphonePath = Join-Path -Path $env:programdata -ChildPath '\Microsoft\Network\Connections\Pbk\rasphone.pbk'
$RasphoneData = Get-Content $RasphonePath

Try {

    Write-Verbose 'Updating IpDnsFlags setting in rasphone.pbk...'
    $RasphoneData | ForEach-Object { $_ -Replace 'IpDnsFlags=.*', 'IpDnsFlags=1' } | Set-Content -Path $RasphonePath -Force

}

Catch {

    $ErrorMessage = $_.Exception.Message 
    Write-Warning $ErrorMessage
    Exit 1

}
