	$Arch = ($env:ARCHITECTURE).ToLower()
	$Worker = $env:APPVEYOR_BUILD_WORKER_IMAGE
	$BuildFolder = $env:APPVEYOR_BUILD_FOLDER
	$DownloadPath = "c:\build-cache"

	Get-ChildItem $DownloadPath

	$ApacheLounge = "https://www.apachelounge.com/download/"

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Write-Output "Checking for downloadable Apache versions..."

	$Releases = @()

	$DownloadsPage = Invoke-WebRequest $ApacheLounge -UserAgent ""
	$DownloadsPage.Links | Where-Object { $_.innerText -match "^httpd-([\d\.]+)-(win\d+)-(VC\d+).zip$" } | ForEach-Object {
		$Matches[2] = $Matches[2].ToLower().Replace("win32", "x86").Replace("win64", "x64")
		$Releases += @{
			DownloadFile = $Matches[0];
			Version = New-Object -TypeName System.Version($Matches[1]);
			VC = $Matches[3];
			VCVersion = "$($Matches[3])_$($Matches[2])";
			Architecture = $Matches[2];
			DownloadUrl = $_.href;
		}
	}


	$Release = $Releases | Where-Object { $_.Architecture -eq $Arch } | Sort-Object -Descending { $_.Version } | Select-Object -First 1

	if (!$Release) {
		throw "Unable to find an installable version of $Arch Apache $Version. Check that the version specified is correct."
	}

	$ApacheDownloadUri = $Release.DownloadUrl
	$ApacheFileName = [Uri]::new([Uri]$ApacheDownloadUri).Segments[-1]
	$ApacheDownloadFile = "$DownloadPath\$ApacheFileName"

	if (!(Test-Path -Path "$BuildFolder\Apache24\bin\httpd.exe" )) {
		if (!(Test-Path -Path "$DownloadPath" )) {
			New-Item -ItemType Directory -Force -Path $DownloadPath | Out-Null
		}

		if (!(Test-Path -Path $ApacheDownloadFile )) {
			Write-Output "Downloading Apache $($Release.Version) ($ApacheFileName)..."
			try {
				Start-BitsTransfer -Source $ApacheDownloadUri -Destination $ApacheDownloadFile
			} catch {
				throw "Unable to download Apache from: $ApacheDownloadUri"
			}
		}

		if ((Test-Path -Path $ApacheDownloadFile )) {
			try {
				Write-Output "Extracting Apache $($Release.Version) ($ApacheFileName) to: $BuildFolder"
				Expand-Archive -LiteralPath $ApacheDownloadFile -DestinationPath $BuildFolder -ErrorAction Stop
			} catch {
				throw "Unable to extract Apache from ZIP"
			}
			Remove-Item $ApacheDownloadFile -Force -ErrorAction SilentlyContinue | Out-Null
		}
	}

	$RepoTagName = $env:APPVEYOR_REPO_TAG_NAME
	if (!($RepoTagName)) {
		$ModNTLMVersion = @{Major = 0; Minor = 0; Build = 0;}
		Get-Content $env:APPVEYOR_BUILD_FOLDER\src\mod_ntlm_version.h | Where-Object {$_ -match "^#define\s+(MOD_NTLM_VERSION_MAJOR|MOD_NTLM_VERSION_MID|MOD_NTLM_VERSION_MINOR)\s+(\d+)$"} | Foreach-Object {
			Switch ($Matches[1]) {
				"MOD_NTLM_VERSION_MAJOR" {$ModNTLMVersion.Major = $Matches[2]}
				"MOD_NTLM_VERSION_MID" {$ModNTLMVersion.Minor = $Matches[2]}
				"MOD_NTLM_VERSION_MINOR" {$ModNTLMVersion.Build = $Matches[2]}
			}
		}
		$ModNTLMVersion = "$($ModNTLMVersion.Major).$($ModNTLMVersion.Minor).$($ModNTLMVersion.Build)"
		$RepoCommit = ($env:APPVEYOR_REPO_COMMIT -replace "^(.{8}).*$", '$1')
		$RepoTagName = "$ModNTLMVersion-$($env:APPVEYOR_REPO_BRANCH)-$RepoCommit"

		Set-AppveyorBuildVariable -Name APPVEYOR_REPO_TAG_NAME -Value $RepoTagName
	}

	if (!(Test-Path -Path "$BuildFolder\artifacts" )) {
		New-Item -ItemType Directory -Force -Path "$BuildFolder\artifacts" | Out-Null
	}

	Copy-Item "$BuildFolder\README.md" -Destination "$BuildFolder\artifacts\README.md" -ErrorAction Stop
	Copy-Item "$BuildFolder\copyright.txt" -Destination "$BuildFolder\artifacts\copyright.txt" -ErrorAction Stop
	Copy-Item "$BuildFolder\CMakeLists.txt" -Destination "$BuildFolder\artifacts\CMakeLists.txt" -ErrorAction Stop
	Copy-Item "$BuildFolder\conf" -Destination "$BuildFolder\artifacts\conf" -Recurse -ErrorAction Stop
	Copy-Item "$BuildFolder\src" -Destination "$BuildFolder\artifacts\src" -Recurse -ErrorAction Stop

	Get-ChildItem $DownloadPath
