
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

    # Give this invocation's staging file a unique name so two concurrent
    # installs (e.g. a -Version run and a -Preview run) never share a
    # "vvctl.exe.new" path and overwrite or consume each other's download.
    $stagingSuffix = [Guid]::NewGuid().ToString('N')
    $destExe = Join-Path $DestDir 'vvctl.exe'
    $newExe  = Join-Path $DestDir "vvctl.exe.new.$stagingSuffix"
    $oldExe  = Join-Path $DestDir 'vvctl.exe.old'

    Write-Host "Copying to $newExe..."
    Copy-Item -Path $exe.FullName -Destination $newExe -Force

    # Swap by rename-aside: Windows refuses to overwrite a running .exe but
    # allows renaming it, so move the current binary aside before moving the
    # new one in. A stale .old from an interrupted previous swap can still be
    # held open by a running process; if it cannot be removed, rename it
    # aside with a unique suffix instead of letting it block this swap. Roll
    # back if the second move fails, and surface the original failure even
    # if the rollback itself also fails.
    Write-Host "Swapping in $destExe..."
    if (Test-Path -LiteralPath $oldExe) {
        try {
            Remove-Item -LiteralPath $oldExe -Force -ErrorAction Stop
        } catch {
            $staleOld = Join-Path $DestDir "vvctl.exe.old.$([Guid]::NewGuid())"
            Move-Item -LiteralPath $oldExe -Destination $staleOld -Force
        }
    }
    # Best-effort cleanup of any vvctl.exe.old* left behind by earlier runs,
    # including ones renamed aside above because they were still in use.
    Get-ChildItem -LiteralPath $DestDir -Filter 'vvctl.exe.old*' -ErrorAction SilentlyContinue |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue }

    $movedOldAside = $false
    if (Test-Path -LiteralPath $destExe) {
        Move-Item -LiteralPath $destExe -Destination $oldExe -Force
        $movedOldAside = $true
    }
    try {
        Move-Item -LiteralPath $newExe -Destination $destExe -Force
    } catch {
        $swapError = $_
        if ($movedOldAside) {
            try {
                Move-Item -LiteralPath $oldExe -Destination $destExe -Force
            } catch {
                # Rollback failed too; the original swap error below is what matters.
            }
        }
        Remove-Item -LiteralPath $newExe -Force -ErrorAction SilentlyContinue
        throw $swapError
    }

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
