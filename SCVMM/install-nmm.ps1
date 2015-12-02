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
    $Scriptdir = "\\vmware-host\Shared Folders\Scripts",
    $SourcePath = "\\vmware-host\Shared Folders\Sources",
    $logpath = "c:\Scripts",
	[ValidateSet('nmm8221','nmm822','nmm8211','nmm8212','nmm8214','nmm8216','nmm8217','nmm8218','nmm822','nmm821','nmm300', 'nmm301', 'nmm2012', 'nmm3013', 'nmm82','nmm85','nmm85.BR1','nmm85.BR2','nmm85.BR3','nmm85.BR4','nmm90.DA','nmm9001')]
    $nmm_ver,
    [switch]$scvmm
)
$Nodescriptdir = "$Scriptdir\NODE"
$EXScriptDir = "$Scriptdir\$ex_version"
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
######################################################################
$Domain = $env:USERDOMAIN
Write-Verbose $Domain

.$NodeScriptDir\test-sharedfolders.ps1 -Folder $SourcePath
if ($Nmm_ver -lt 'nmm85')
    {
    $Setuppath = "$SourcePath\$nmm_ver\win_x64\networkr\setup.exe" 
    .$NodeScriptDir\test-setup -setup NMM -setuppath $Setuppath
    start-process -filepath "$Setuppath" -ArgumentList '/s /v" /qn /l*v c:\scripts\nmm.log'  -Wait
    start-process -filepath "$Setuppath" -ArgumentList '/s /v" /qn /l*v c:\scripts\nmmglr.log NW_INSTALLLEVEL=200 REBOOTMACHINE=0 NW_GLR_FEATURE=1 WRITECACHEDIR="C:\Program Files\EMC NetWorker\nsr\tmp\nwfs" MOUNTPOINTDIR="C:\Program Files\EMC NetWorker\nsr\tmp\nwfs\NetWorker Virtual File System" HYPERVMOUNTPOINTDIR="C:\Program Files\EMC NetWorker\nsr\tmp" SETUPTYPE=Install"' -Wait
    }
else
    {
    $Setuppath = "$SourcePath\$nmm_ver\win_x64\networkr\nwvss.exe" 
    .$NodeScriptDir\test-setup -setup NMM -setuppath $Setuppath
    Start-Process -Wait -FilePath $Setuppath -ArgumentList "/s /q /log `"C:\scripts\NMM_nw_install_detail.log`" InstallLevel=200 RebootMachine=0 EnableSSMS=1 EnableSSMSBackupTab=1 EnableSSMSScript=1 NwGlrFeature=1 EnableClientPush=1 WriteCacheFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\nwfs`" MountPointFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\nwfs\NetWorker Virtual File System`" BBBMountPointFolder=`"C:\Program Files\EMC NetWorker\nsr\tmp\BBBMountPoint`" SetupType=Install"
    }
if ($scvmm.IsPresent)
    {
    if ($nmm_ver -ge "nmm85" )
        {
        Write-Verbose "Installing Networker Extended Client" 
        $nw_ver = $nmm_ver -replace "nmm","nw"
        $Setuppath = "$SourcePath\$nw_ver\win_x64\networkr\lgtoxtdclnt*.exe" 
        .$NodeScriptDir\test-setup -setup lgtoxtdclnt -setuppath $Setuppath
        Start-Process $Setuppath -ArgumentList "/q" -Wait
        }
    $SCVMMPlugin = $NMM_VER -replace "nmm","scvmm"
    $Setuppath = "$SourcePath\$SCVMMPlugin\win_x64\SCVMM DP Add-in.exe" 
    .$NodeScriptDir\test-setup -setup NMM -setuppath $Setuppath
    Start-Process $Setuppath -ArgumentList "/q" -Wait
    }
if ($PSCmdlet.MyInvocation.BoundParameters["verbose"].IsPresent)
    {
    Pause
    }