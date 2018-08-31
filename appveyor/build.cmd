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

	rename "%APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\mod_authn_ntlm.dll" "%APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\mod_authn_ntlm.so"

	xcopy %APPVEYOR_BUILD_FOLDER%\copyright.txt %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%\ /y /f
	xcopy %APPVEYOR_BUILD_FOLDER%\conf %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%\conf\ /y /f
	xcopy %APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE%\* %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%\ /y /f
	7z a mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%.zip %APPVEYOR_BUILD_FOLDER%\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%\*
	appveyor PushArtifact mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%.zip -FileName mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%-%CMAKE_BUILD_TYPE%.zip

	xcopy %APPVEYOR_BUILD_FOLDER%\build\%CMAKE_BUILD_TYPE% artifacts\mod_authn_ntlm-%MOD_NTL_VERSION%-%ARCHITECTURE%-%BUILD_CRT%\%CMAKE_BUILD_TYPE%\ /y /f

endlocal
