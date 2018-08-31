@echo off
setlocal enableextensions enabledelayedexpansion

	PowerShell -ExecutionPolicy RemoteSigned %~dp0\Get-Apache.ps1 -Arch %ARCHITECTURE% -DownloadPath %APPVEYOR_BUILD_FOLDER%

endlocal