﻿<#
.Synopsis
   This script builds the scaleio mdm, sds and sdc for a hyper-v cluster
.DESCRIPTION
   labbuildr builds your on-demand labs
.LINK
   https://github.com/bottkars/labbuildr/wiki
#>
[CmdletBinding()]
param (
[parameter(mandatory = $false)][ValidateRange(1,10)]$CSVnum = 2,
[parameter(mandatory = $false)]$password = "Password123!",
[parameter(mandatory = $false)]$IPv4Subnet = "192.168.2",

[switch]$reconfigure
)
 
function Create-CSV {
param ($Number)
$CSVName =  "iSCSI_CSV_"+$Number
$WinVollabel = "iSCSI_VOL"+$Number
Set-Disk -Number $Number -IsReadOnly  $false 
Set-Disk -Number $Number -IsOffline  $false
Clear-Disk -Number $Number -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
Write-Host " ==> Initializing Disk $Number"
Initialize-Disk -Number $Number -PartitionStyle GPT 
Write-Host " ==> Partitioning $Number"
$Partition = New-Partition -DiskNumber $Number -UseMaximumSize 
Write-Host " ==> Formatting Disk $Number"
#$Job = Format-Volume -Partition $Partition -NewFileSystemLabel $WinVolName -AllocationUnitSize 64kb -FileSystem NTFS -Force -Confirm:$false -AsJob
# while ($JOB.state -ne "completed"){}
$Disk = Get-Disk -Number $Number
$Partition | Format-Volume -NewFileSystemLabel $WinVollabel -Confirm:$false
Write-Host " ==> Adding Disk $Number to CLUSTER"
$Clusterdisk = $Disk  | Add-ClusterDisk
$Clusterdisk.Name = $CSVName
Write-Host " ==> Adding $($Clusterdisk.name) as CSV"
Get-ClusterResource -Name $Clusterdisk.Name | Add-ClusterSharedVolume
}

Start-Process .\fsutil.exe -ArgumentList "behavior set DisableDeleteNotify 1" -NoNewWindow -Wait
foreach ($number in 1..$CSVnum)
    {
	Create-CSV -Number $number
    Write-Output "Waiting for Disk to Appear in Failover Cluster"
}
Start-Process .\fsutil.exe -ArgumentList "behavior set DisableDeleteNotify 0" -NoNewWindow -Wait

