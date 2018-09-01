	$Arch = ($env:ARCHITECTURE).ToLower()
	$Worker = $env:APPVEYOR_BUILD_WORKER_IMAGE
	$BuildFolder = $env:APPVEYOR_BUILD_FOLDER

	if (!(Test-Path -Path "$BuildFolder\Apache24\bin\httpd.exe" )) {
		throw "$BuildFolder\Apache24 not found"
	}

	if ($Arch -eq "x64") {
		$Generator = "Visual Studio 15 2017 Win64"
	}

	if ($Arch -eq "x86") {
		$Generator = "Visual Studio 15 2017"
	}
	$env:GENERATOR = $Generator

	$env:CMAKE_BUILD_TYPE = "Release"
	Invoke-Expression $BuildFolder\appveyor\build-task.ps1

	$env:CMAKE_BUILD_TYPE = "Debug"
	Invoke-Expression $BuildFolder\appveyor\build-task.ps1
