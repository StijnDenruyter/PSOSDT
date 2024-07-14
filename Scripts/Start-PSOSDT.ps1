<#
.SYNOPSIS
	Orchestrates the PSOSDT installation
.DESCRIPTION
	This script orchestrates the OSDCloud installation in combination with the PowerShell OSD Toolkit
.NOTES
	FileName:		Start-PSOSDT.ps1
	Version:		1.0
	Author:			Stijn Denruyter
	Created:		30-06-2024
	Updated:		30-06-2024

	Version history:
	1.0 - (30-06-2024)	First version.
#>

$ScriptName = "Start-PSOSDT"
$ScriptVersion = "1.0"

$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$ScriptName.log"
$Null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

Invoke-Expression (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/StijnDenruyter/PSOSDT/main/Functions/PSOSDT.ps1")
$host.UI.RawUI.WindowTitle = "PowerShell OSD Toolkit"
Set-PSOSDTResizeOutputWindow

If ($env:SystemDrive -eq "X:") {
	$WindowsPhase = "WinPE"
}
Else {
	$ImageState = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State" -ErrorAction Ignore).ImageState
	If ($env:UserName -eq "defaultuser0") {$WindowsPhase = "OOBE"}
	ElseIf ($ImageState -eq "IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE") {$WindowsPhase = "Specialize"}
	ElseIf ($ImageState -eq "IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT") {$WindowsPhase = "AuditMode"}
	Else {$WindowsPhase = "Windows"}
}

Write-Host -ForegroundColor Green "[+] $ScriptName $ScriptVersion ($WindowsPhase Phase)"

$WhoIAm = [system.security.principal.windowsidentity]::getcurrent().name
$IsElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

If ($IsElevated) {
	Write-Host -ForegroundColor Green "[+] Running as $WhoIAm (Admin Elevated)"
}
Else {
	Write-Host -ForegroundColor Red "[!] Running as $WhoIAm (NOT Admin Elevated)"
	Break
}

Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

If ($WindowsPhase -eq "WinPE") {
	Hide-StartNetWindow -NirCmdPath "X:\OSDCloud\Config\Scripts\PSOSDT\nircmd.exe" 
	Write-Host -ForegroundColor Cyan "Start OSDCloud"
	If (Test-Connection -ComputerName osdcloud.apps.denruyter.net -Count 1 -Quiet) {
		Start-OSDCloud -ImageFileUrl "http://osdcloud.apps.denruyter.net/images/Win11_Ent_23H2_EN.wim" -Firmware -ZTI -OSImageIndex 3
	}
	Else {
		Start-OSDCloudGUI -BrandName "PowerShell OSD Toolkit" 
	}
	Write-Host -ForegroundColor Cyan "Install Unattend.xml"
	Invoke-WebRequest -Uri "https://raw.githubusercontent.com/StijnDenruyter/PSOSDT/main/Answer%20files/Unattend.xml" -OutFile "C:\Windows\Panther\Unattend.xml"
	New-Item -Path "C:\OSDCloud\Scripts\PSOSDT" -ItemType Directory | Out-Null
	Write-Host -ForegroundColor Cyan "Copy Start-PSOSDT"
	Copy-Item -Path "X:\OSDCloud\Config\Scripts\PSOSDT\Start-PSOSDT.ps1" -Destination "C:\OSDCloud\Scripts\PSOSDT\Start-PSOSDT.ps1"
	Write-Host -ForegroundColor Cyan "Reboot system in 10 seconds..."
	Start-Sleep -Seconds 10
	Restart-Computer -Force
	$Null = Stop-Transcript -ErrorAction Ignore
	Copy-Item -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -Destination (Join-Path "C:\OSDCloud\Logs" $Transcript)
}

If ($WindowsPhase -eq "Specialize") {

	$Null = Stop-Transcript -ErrorAction Ignore
}

If ($WindowsPhase -eq "AuditMode") {

	$Null = Stop-Transcript -ErrorAction Ignore
}

If ($WindowsPhase -eq "OOBE") {

	$Null = Stop-Transcript -ErrorAction Ignore
}

If ($WindowsPhase -eq "Windows") {
	Write-Host "Initializing..."
	Start-Sleep -Seconds 80
	Write-Host "1"
	Start-Sleep -Seconds 5
	Write-Host "2"
	Start-Sleep -Seconds 5
	Write-Host "3"
	Start-Sleep -Seconds 5
	Write-Host "4"
	Start-Sleep -Seconds 5
	Write-Host "5"
	Start-Sleep -Seconds 5
	Write-Host "6"
	Start-Sleep -Seconds 5
	Write-Host "7"
	Start-Sleep -Seconds 5
	Write-Host "8"
	Start-Sleep -Seconds 5
	Write-Host "9"
	Start-Sleep -Seconds 5
	Write-Host "10"
	Start-Sleep -Seconds 5
	Write-Host "11"
	Start-Sleep -Seconds 5
	Write-Host "12"
	Start-Sleep -Seconds 5
	systeminfo
	ipconfig /all
	Start-BitsTransfer -Source "https://github.com/StijnDenruyter/PSOSDT/raw/main/PSAppDeployToolkit/PSADT_v3.10.1.zip" -Destination "C:\PSADT.zip"
	Expand-Archive -Path "C:\PSADT.zip" -DestinationPath "C:\PSADT"
	$Null = Stop-Transcript -ErrorAction Ignore
	Copy-Item -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -Destination (Join-Path "C:\OSDCloud\Logs" $Transcript)
}