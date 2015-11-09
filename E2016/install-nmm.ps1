﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr is a Self Installing Windows/Networker/NMM Environemnt Supporting Exchange 2013 and NMM 3.0
.LINK
   https://community.emc.com/blogs/bottk/2015/03/30/labbuildrbeta
#>
#requires -version 3
[CmdletBinding()]
param(
	[ValidateSet('nmm8211','nmm8212','nmm8214','nmm8216','nmm8217','nmm8218','nmm822','nmm821','nmm300', 'nmm301', 'nmm2012', 'nmm3012', 'nmm82','nmm85','nmm85.BR1','nmm85.BR2','nmm85.BR3','nmm85.BR4','nmm90.DA')]
    $nmm_ver,
    $nmmusername = "NMMBackupUser",
    $nmmPassword = "Password123!",
    $nmmdatabase = "DB1_$Env:COMPUTERNAME",
    $Scriptdir = "\\vmware-host\Shared Folders\Scripts",
    $SourcePath = "\\vmware-host\Shared Folders\Sources",
    $logpath = "c:\Scripts",
    $ex_version= "E2016",
    $Prereq ="Prereq" 
)
$Nodescriptdir = "$Scriptdir\NODE"
$ScriptName = $MyInvocation.MyCommand.Name
$Host.UI.RawUI.WindowTitle = "$ScriptName"
$Builddir = $PSScriptRoot
$Logtime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
if (!(Test-Path $logpath))
    {
    New-Item -ItemType Directory -Path $logpath -Force
    }
$Logfile = New-Item -ItemType file  "$logpath\$ScriptName$Logtime.log"
Set-Content -Path $Logfile $MyInvocation.BoundParameters
############
$Domain = $env:USERDNSDOMAIN
Write-Verbose $Domain
.$Nodescriptdir\test-sharedfolders.ps1
if ($Nmm_ver -lt 'nmm85')
    {
    $Setuppath = "$SourcePath\$nmm_ver\win_x64\networkr\setup.exe" 
    .$Nodescriptdir\test-setup -setup NMM -setuppath $Setuppath
    $argumentlist = '/s /v" /qn /l*v c:\scripts\nmm.log RMEXCHDOMAIN='+$Domain+' RMEXCHUSER=NMMBackupUser RMEXCHPASSWORD=Password123! RMCPORT=6730 RMDPORT=6731"'
    start-process -filepath "$Setuppath\setup.exe" -ArgumentList $argumentlist -wait
    }
else
    {
    $Setuppath = "$SourcePath\$nmm_ver\win_x64\networkr\nwvss.exe" 
    .$Nodescriptdir\test-setup -setup NMM -setuppath $Setuppath
    Start-Process -Wait -FilePath $Setuppath -ArgumentList "/s /q /log `"C:\scripts\NMM_nw_install_detail.log`" InstallLevel=200 RebootMachine=0 NwGlrFeature=1 EnableClientPush=1 WriteCacheFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\nwfs`" MountPointFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\nwfs\NetWorker Virtual File System`" BBBMountPointFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\BBBMountPoint`" SetupType=Install"
    Write-Verbose "Configuring NMM Backup User"
    Start-Process -Wait -FilePath "C:\Program Files\EMC NetWorker\nsr\bin\UserConfigCLI.exe"  -ArgumentList "$nmmusername $nmmPassword $nmmdatabase"
    }
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    Pause
    }
