﻿<#
.Synopsis
   script tests if shared folders are vailable within guest os
.DESCRIPTION
   labbuildr builds your on-demand labs
.LINK
   https://github.com/bottkars/labbuildr/wiki
#>
#requires -version 3
[CmdletBinding()]
param (
$Folder = "\\vmware-host\shared folders"
)
Write-Host -ForegroundColor Gray " ==>testing shared folders $Folder"
do {

    $Enabled = Test-Path $folder
    if ($Enabled -notmatch $True)
        { 
        write-warning "Shared folders $Folder not available."
        write-warning "Script will continue once enabled"
        $([char]7)
        Start-Sleep -Seconds 5
        }
    }
until ($Enabled -match $true)
write-host -ForegroundColor Gray " ==>shared folders $Folder are enabled"
return
