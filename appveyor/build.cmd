@echo off
setlocal enableextensions enabledelayedexpansion
	cd /d %APPVEYOR_BUILD_FOLDER%

	if not exist "Apache24\bin\httpd.exe" (
		echo Apache24 not found
		exit /b 3
	)

	if "%ARCHITECTURE%"=="x64" (
		set GENERATOR="Visual Studio 15 2017 Win64"
	)

	if "%ARCHITECTURE%"=="x86" (
		set GENERATOR="Visual Studio 15 2017 Win32"
	)

	mkdir build
	cd build

	set CMAKE_BUILD_TYPE=Release
	cmd /c appveyor\build-task.cmd

	set CMAKE_BUILD_TYPE=Debug
	cmd /c appveyor\build-task.cmd
endlocal
