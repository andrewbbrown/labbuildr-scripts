﻿<#
.Synopsis
   Short description
.DESCRIPTION
   labbuildr builds your on-demand labs
.LINK
   https://github.com/bottkars/labbuildr/wiki
#>
#requires -version 3
[CmdletBinding()]
param(
    $Scriptdir = "\\vmware-host\Shared Folders\Scripts",
    $SourcePath = "\\vmware-host\Shared Folders\Sources",
    $logpath = "c:\Scripts",
    $docker_registry = "192.168.2.40"
    <#[ValidateSet(
    '1.12.0','latest'
    )]
    $Docker_VER='latest'
    #>
	)
$Nodescriptdir = "$Scriptdir\Node"
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
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
$content = "
{`"insecure-registries`":[`"$($docker_registry):5000`"],
`"allow-nondistributable-artifacts`": [`"$($docker_registry):5000`"]}"
$content | set-content -Path c:\programdata\docker\config\daemon.json 

<#
.$Nodescriptdir\test-sharedfolders.ps1 -Folder $Sourcepath
$Docker_Downloadfile = "docker-$($Docker_VER).zip"
$Docker_Uri = "https://get.docker.com/builds/Windows/x86_64"
$Uri = "$Docker_Uri/$Docker_Downloadfile"
Start-BitsTransfer $Uri -Description "Downloding Docker $Docker_VER" -Destination $env:TEMP
Write-Host -ForegroundColor Gray " ==>expanding archive $Docker_Downloadfile"
Expand-Archive -Path "$env:TEMP\$Docker_Downloadfile" -DestinationPath $env:ProgramFiles
Write-Host -ForegroundColor Gray " ==>adding docker path to environment"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)
$env:Path = $env:Path + ";C:\Program Files\Docker"
Write-Host -ForegroundColor Gray " ==>registering docker service"
& $env:ProgramFiles\docker\dockerd.exe --register-service
Write-Host -ForegroundColor Gray " ==>starting docker service"
Start-Service Docker
# Install-PackageProvider ContainerImage -Force
# Install-ContainerImage -Name WindowsServerCore
# 
#Write-Host -ForegroundColor Gray " ==>getting nanoserver containerimage from dockerhub"
# docker pull microsoft/windowsservercore:10.0.14300.1030
#>
Restart-Service docker
#Start-Process "docker" -ArgumentList "pull microsoft/nanoserver:10.0.14300.1030" -Wait -PassThru
# Write-Host -ForegroundColor Gray " ==>starting nanoserver container using hyper-v as isolator"
#Start-Process "docker" -ArgumentList "run -it --isolation=hyperv microsoft/nanoserver:10.0.14300.1030 cmd"
#Write-Host -ForegroundColor Gray " ==>starting docker statistics"
#Start-Process "docker" -ArgumentList "stats"
# docker tag windowsservercore:10.0.14300.1030 windowsservercore:latest
