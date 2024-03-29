<#

.SYNOPSIS
    PowerShell script to remediate an Always On VPN profile listed in the AutoTriggerDisbledProfiles list. This script is designed to be deployed using Intune remediations. In addition, it requires the user to have administrative rights when remediating a user tunnel profile not deployed in the All Users context.

.EXAMPLE
    .\Remediate-AutoTriggerDisabledProfile.ps1

.DESCRIPTION
    When a user unchecks the 'Connect Automatically' box on their Always On VPN profile, the VPN profile is added to the AutoTriggerDisabledProfilesList registry key. This prevents the VPN profile from automatically connecting when the user's device starts up or when the user signs in. This PowerShell script remediates the issue by removing the VPN profile from the AutoTriggerDisabledProfilesList registry key.

.LINK
    https://github.com/richardhicks/endpointmanager/blob/main/Remediate-AutoTriggerDisabledProfile.ps1

.LINK
    https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations

.LINK
    https://directaccess.richardhicks.com/

.NOTES
    Version:        1.1
    Creation Date:  December 29, 2023
    Last Updated:   February 22, 2024
    Author:         Richard Hicks
    Organization:   Richard M. Hicks Consulting, Inc.
    Contact:        rich@richardhicks.com
    Website:        https://directaccess.richardhicks.com/

#>

[CmdletBinding()]

Param (

    # Update the $ProfileName value to reflect the name of the Always On VPN profile to remove from the AutoTriggerDisabledProfilesList registry key
    [string]$ProfileName = 'Always On VPN',
    # Remove the comment in the next line to remediate the profile in the 'all users' context
    [switch]$AllUserConnection # = [switch]::Present

)

# Enable logging
Start-Transcript -Path $env:TEMP\Remediate-AutoTriggerDisabledProfile.log

# Use transaction for registry updates
Start-Transaction

# Search AutoTriggerDisabledProfilesList for VPN profile
$Path = 'HKLM:\System\CurrentControlSet\Services\RasMan\Config\'
$Name = 'AutoTriggerDisabledProfilesList'

Write-Verbose "Searching $Name in $Path for VPN profile `"$ProfileName`"..."

Try {

    # Get the current registry values as an array of strings
    [string[]]$DisabledProfiles = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction Stop

}

Catch {

    Write-Verbose "$Name does not exist in $Path. No action required."
    Return

}

If ($DisabledProfiles) {

    # Create ordered hashtable
    $List = [Ordered]@{}
    $DisabledProfiles | ForEach-Object { $List.Add("$($_.ToLower())", $_) }

    # Search hashtable for matching VPN profile and remove if present
    If ($List.Contains($ProfileName)) {

        Write-Verbose 'Profile found. Removing entry...'
        $List.Remove($ProfileName)
        Write-Verbose 'Updating the registry...'
        Set-ItemProperty -Path $Path -Name $Name -Value $List.Values -UseTransaction

    }

}

Else {

    Write-Verbose "No profiles found matching `"$ProfileName`"."
    Return

}

# Add user SID to registry
If ($AllUserConnection) {

    $SID = 'S-1-1-0'
    Write-Verbose "Adding SYSTEM SID $SID to registry..."

}

Else {

    Try {

        $SID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        Write-Verbose "Adding user SID $SID to registry..."

    }

    Catch {

        Write-Warning $_.Exception.Message
        Return

    }

}

$Parameters = @{

    Path           = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Config\'
    Name           = 'UserSID'
    PropertyType   = 'String'
    Value          = $SID
    UseTransaction = $True

}

New-ItemProperty @Parameters -Force | Out-Null

# Add VPN profile name to registry
$Parameters = @{

    Path           = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Config\'
    Name           = 'AutoTriggerProfileEntryName'
    PropertyType   = 'String'
    Value          = $ProfileName
    UseTransaction = $True

}

New-ItemProperty @Parameters | Out-Null

# Add VPN profile GUID to registry
Write-Verbose "Adding VPN GUID $GUID to registry..."
[guid]$Guid = $Vpn | Select-Object -ExpandProperty Guid
$Binary = $Guid.ToByteArray()

$Parameters = @{

    Path           = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Config\'
    Name           = 'AutoTriggerProfileGUID'
    PropertyType   = 'Binary'
    Value          = $Binary
    UseTransaction = $True

}

New-ItemProperty @Parameters | Out-Null

# Add phonebook path to registry
If ($AllUserConnection) {

    $Path = Join-Path -Path $env:programdata -ChildPath Microsoft\Network\Connections\Pbk\rasphone.pbk
    Write-Verbose "RAS phonebook path is $Path."

}

Else {

    $Path = Join-Path -Path $env:userprofile -ChildPath AppData\Roaming\Microsoft\Network\Connections\Pbk\rasphone.pbk
    Write-Verbose "RAS phonebook path is $Path."

}

$Parameters = @{

    Path           = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Config\'
    Name           = 'AutoTriggerProfilePhonebookPath'
    PropertyType   = 'String'
    Value          = $Path
    UseTransaction = $True

}

New-ItemProperty @Parameters | Out-Null

# Commit registry changes
Complete-Transaction

# Stop the RasMan service
$Id = Get-CimInstance -ClassName win32_service | Where-Object Name -eq 'RasMan' | Select-Object -ExpandProperty ProcessId
Write-Verbose "RasMan process ID is $Id..."
Write-Verbose 'Restarting the RasMan service...'
Stop-Process -Id $Id -Force

# Pause before restarting the RasMan service
Start-Sleep -Seconds 5
Start-Service RasMan

# Stop logging
Stop-Transcript
