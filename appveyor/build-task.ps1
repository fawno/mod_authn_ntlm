	$BuildFolder = $env:APPVEYOR_BUILD_FOLDER
	$Generator = $env:GENERATOR
	$BuildType = $env:CMAKE_BUILD_TYPE

	if (!(Test-Path -Path "$BuildFolder\build" )) {
		New-Item -ItemType Directory -Force -Path "$BuildFolder\build" | Out-Null
	}

	Set-Location "$BuildFolder\build"

	&cmake -G "$Generator" -DCMAKE_BUILD_TYPE=$BuildType ..
	&cmake --build . --config $BuildType

	if (!(Test-Path -Path "$BuildFolder\build\$BuildType\mod_authn_ntlm.dll" )) {
		throw "Build faild"
	}

	Rename-Item -Path "$BuildFolder\build\$BuildType\mod_authn_ntlm.dll" -NewName "$BuildFolder\build\$BuildType\mod_authn_ntlm.so"

	Copy-Item "$BuildFolder\build\$BuildType" -Destination "$BuildFolder\artifacts\$BuildType" -Recurse -ErrorAction Stop


	$ArtifactName = "mod_authn_ntlm-$($env:APPVEYOR_REPO_TAG_NAME)-$($env:ARCHITECTURE)-$($env:BUILD_CRT)-$BuildType"

	if (!(Test-Path -Path "$BuildFolder\$ArtifactName" )) {
		New-Item -ItemType Directory -Force -Path "$BuildFolder\$ArtifactName" | Out-Null
	}

	Copy-Item "$BuildFolder\README.md" -Destination "$BuildFolder\$ArtifactName\README.md" -ErrorAction Stop
	Copy-Item "$BuildFolder\copyright.txt" -Destination "$BuildFolder\$ArtifactName\copyright.txt" -ErrorAction Stop
	Copy-Item "$BuildFolder\CMakeLists.txt" -Destination "$BuildFolder\$ArtifactName\CMakeLists.txt" -ErrorAction Stop
	Copy-Item "$BuildFolder\conf" -Destination "$BuildFolder\$ArtifactName\conf" -Recurse -ErrorAction Stop
	Copy-Item "$BuildFolder\src" -Destination "$BuildFolder\$ArtifactName\src" -Recurse -ErrorAction Stop
	Copy-Item "$BuildFolder\build\$BuildType" -Destination "$BuildFolder\$ArtifactName\bin" -Recurse -ErrorAction Stop
	Compress-Archive -Path $BuildFolder\$ArtifactName\* -DestinationPath $BuildFolder\$ArtifactName.zip
	Push-AppveyorArtifact $BuildFolder\$ArtifactName.zip -FileName $ArtifactName.zip -Type zip
