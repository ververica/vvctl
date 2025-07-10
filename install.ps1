
<#
.SYNOPSIS
  Simple vvctl installer for Windows

.DESCRIPTION
  Downloads and installs the latest vvctl release (or a specific version, or latest prerelease).
#>

[CmdletBinding()]
param(
    [string]   $Version,
    [switch]   $Preview
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WritablePathDir {
    # Return the first existing, writable folder from $Env:PATH
    foreach ($path in $Env:PATH -split ';') {
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }
        if (-not (Test-Path $path)) {
            continue
        }
        try {
            $testFile = Join-Path $path '__permtest'
            New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null
            Remove-Item -Path $testFile -Force | Out-Null
            return $path
        } catch {
            # skip paths that are not writable
            continue
        }
    }
    return $null
}


function Get-LatestReleaseTag {
    param($repo, $prerelease)

    $uri = if ($prerelease) {
        "https://api.github.com/repos/$repo/releases"
    } else {
        "https://api.github.com/repos/$repo/releases/latest"
    }

    if (-not $prerelease) {
        (Invoke-RestMethod -UseBasicParsing -Uri $uri).tag_name
    } else {
        (Invoke-RestMethod -UseBasicParsing -Uri $uri) |
            Where-Object { $_.prerelease } |
            Select-Object -First 1 |
            Select-Object -ExpandProperty tag_name
    }
}

function Install-vvctl {
    param($Tag, $DestDir)

    Write-Host "Installing vvctl $Tag to $DestDir..."
    $platform = "x86_64-pc-windows-msvc"
    $zipName  = "vvctl-$Tag-$platform.zip"
    $url      = "https://github.com/ververica/vvctl/releases/download/$Tag/$zipName"

    $tmpDir  = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $tmpDir | Out-Null

    $zipPath = Join-Path $tmpDir $zipName
    Write-Host "Downloading $url..."
    Invoke-RestMethod -UseBasicParsing -Uri $url -OutFile $zipPath

    if ((Get-Item $zipPath).Length -eq 0) {
        throw "Downloaded file is missing or empty"
    }

    Write-Host "Extracting..."
    Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force

    $exe = Get-ChildItem -Path $tmpDir -Filter 'vvctl.exe' -Recurse | Select-Object -First 1
    if (-not $exe) {
        throw "Could not locate vvctl.exe in extracted archive"
    }

    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    $destExe = Join-Path $DestDir 'vvctl.exe'
    Write-Host "Copying to $destExe..."
    Copy-Item -Path $exe.FullName -Destination $destExe -Force

    Write-Host "Cleaning up..."
    Remove-Item -LiteralPath $tmpDir -Recurse -Force

    Write-Host "vvctl installation complete!`nRun ` vvctl --help` to get started."
}

# --- Main ---

$repo = 'ververica/vvctl'

# Determine install directory
$InstallDir = Get-WritablePathDir
if (-not $InstallDir) {
    $InstallDir = Join-Path $HOME 'bin'
    Write-Warning "No writable PATH directory found. Falling back to '$InstallDir'"
}

# Determine version/tag
if ($Version) {
    Write-Host "Using specified version: $Version"
    $tag = $Version
}
elseif ($Preview) {
    Write-Host "Fetching latest prerelease…"
    $tag = Get-LatestReleaseTag -repo $repo -prerelease
    Write-Host "Using latest prerelease version: $tag"
}
else {
    Write-Host "Fetching latest stable release…"
    $tag = Get-LatestReleaseTag -repo $repo -prerelease:$false
    Write-Host "Using latest version: $tag"
}

Install-vvctl -Tag $tag -DestDir $InstallDir
