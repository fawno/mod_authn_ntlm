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

	if not exist "%APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\mod_authn_ntlm.dll" exit /b 3

	xcopy %APPVEYOR_BUILD_FOLDER%\copyright.txt %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%\ /y /f
	xcopy %APPVEYOR_BUILD_FOLDER%\conf %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%\conf\ /y /f

	xcopy %APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\mod_authn_ntlm.dll %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%\mod_authn_ntlm.so /y /f
	7z a mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%.zip %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%\*
	appveyor PushArtifact mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%.zip -FileName mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%.zip

	move %APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\mod_authn_ntlm.dll artifacts\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%.so

endlocal
