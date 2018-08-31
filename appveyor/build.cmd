@echo off
setlocal enableextensions enabledelayedexpansion
	cd /d %APPVEYOR_BUILD_FOLDER%

	if not exist "Apache24\bin\httpd.exe" (
		echo Apache24 not found
		exit /b 3
	)

	mkdir build

	cd build

	if "%ARCHITECTURE%"=="x64" (
		set GENERATOR="Visual Studio 15 2017 Win64"
	)

	if "%ARCHITECTURE%"=="x86" (
		set GENERATOR="Visual Studio 15 2017 Win32"
	)

	set CMAKE_BUILD_TYPE=Release

	cmake -G %GENERATOR% -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ..
	cmake --build . --config %CMAKE_BUILD_TYPE%

endlocal