Function Invoke-PSOSDTProcess
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[String]$FilePath,
		[Parameter(Mandatory = $False)]
		[ValidateNotNullOrEmpty()]
		[String]$WorkingDir,
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[String]$Arguments
	)
	If ($WorkingDir -ne "")
	{
		$ExitCode = (Start-Process -FilePath $FilePath -ArgumentList $Arguments -WorkingDirectory $WorkingDir -NoNewWindow -Wait -PassThru).ExitCode
	}
	else
	{
		$ExitCode = (Start-Process -FilePath $FilePath -ArgumentList $Arguments -NoNewWindow -Wait -PassThru).ExitCode
	}
	If ($ExitCode -eq 0) {
		Write-Host "`r`nExit code: $($ExitCode)`r`n" -ForegroundColor Green
	}
	Else {
		Write-Host "`r`nExit code: $($ExitCode)`r`n" -ForegroundColor Red
	}
}

Function Write-PSOSDTLogHeader
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[ValidateNotNullOrEmpty()]
		[String]$Message
	)
	$DateConsole = Get-Date -Format "dd-MM-yyyy"
	$TimeConsole = Get-Date -Format "HH:mm:ss"
	$Message = "`r`n" + ('=' * 80) + "`r`n" + $DateConsole + " " + $TimeConsole + " " + $Message + "`r`n" + ('=' * 80)
	Write-Host $Message -ForegroundColor Cyan
}

Function Set-PSOSDTResizeOutputWindow
{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type @"
	using System;
	using System.Runtime.InteropServices;

	public class Win32 {
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
		
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);
		
		[DllImport("user32.dll")]
		[return: MarshalAs(UnmanagedType.Bool)]
		public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
	}

	public struct RECT {
		public int Left;
		public int Top;
		public int Right;
		public int Bottom;
	}
"@

	$MainWindowHandle = (Get-Process -id $pid).MainWindowHandle

	$rcWindow = New-Object RECT
	$rcClient = New-Object RECT

	[Win32]::GetWindowRect($MainWindowHandle, [ref]$rcWindow) | Out-Null
	[Win32]::GetClientRect($MainWindowHandle, [ref]$rcClient) | Out-Null

	$screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
	$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

	$targetWidth = 833
	$targetHeight = 549
	$targetX = (($screenWidth / 2) - ($targetWidth / 2))
	$targetY = (($screenHeight / 2) - ($targetHeight / 2))
	
	[Win32]::MoveWindow($MainWindowHandle, $targetX, $targetY, $targetWidth, $targetHeight, $true) | Out-Null
	$Host.UI.RawUI.BackgroundColor = "Black"
	Clear-Host
}
