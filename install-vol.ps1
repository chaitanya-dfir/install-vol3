<# 
  Title: Install Vol (Volatility 3 Safe Installer)
  Author: Chaitanya Shah
  Version: 1.0
  Description:
    - Prompts user for installation directory (default: C:\DFIR Tools\Volatility3)
    - Prompts for cache, output, and symbols paths (defaults under install dir)
    - Creates a Python virtual environment, installs Volatility 3 (stable)
    - Adds a safe 'vol' command (user-level, no admin needed)
    - Verifies install and provides cleanup/update instructions
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info($m){ Write-Host "[*] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[+] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[!] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[X] $m" -ForegroundColor Red }

Write-Host ""
Write-Host "=============================================================" -ForegroundColor Gray
Write-Host "           Install Vol (Volatility 3 Installer)              " -ForegroundColor Yellow
Write-Host "                 Author: Chaitanya Shah                      " -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Gray
Write-Host ""

#  Ask for install folder
$defaultInstall = "C:\DFIR Tools\Volatility3"
$installPath = Read-Host "Enter installation path or press Enter for default [$defaultInstall]"
if ([string]::IsNullOrWhiteSpace($installPath)) { $installPath = $defaultInstall }

try { $tmp = Resolve-Path -Path $installPath -ErrorAction Stop; $installPath = $tmp.Path } catch { $installPath = [IO.Path]::GetFullPath($installPath) }
Info "Install path set to: $installPath"

#  Ask for cache/output/symbols paths
$cacheDefault   = Join-Path $installPath "cache"
$outputDefault  = Join-Path $installPath "output"
$symbolsDefault = Join-Path $installPath "symbols"

$cachePath = Read-Host "Enter path for Vol3 cache (Press Enter for default [$cacheDefault])"
if ([string]::IsNullOrWhiteSpace($cachePath)) { $cachePath = $cacheDefault }

$outputPath = Read-Host "Enter path for Vol3 output (Press Enter for default [$outputDefault])"
if ([string]::IsNullOrWhiteSpace($outputPath)) { $outputPath = $outputDefault }

$symbolsPath = Read-Host "Enter path for Vol3 symbols (Press Enter for default [$symbolsDefault])"
if ([string]::IsNullOrWhiteSpace($symbolsPath)) { $symbolsPath = $symbolsDefault }

Write-Host ""
Info "Final Paths:"
Write-Host "  Install : $installPath"
Write-Host "  Cache   : $cachePath"
Write-Host "  Output  : $outputPath"
Write-Host "  Symbols : $symbolsPath"

#  Check Python
Info "Checking Python installation..."
try { $pyVer = & python --version 2>&1 } catch { Err "Python not found. Install Python 3.8+ and ensure it's on PATH."; exit 1 }
Ok "Python detected: $pyVer"

#  Create folders
foreach ($f in @($installPath, $cachePath, $outputPath, $symbolsPath)) {
    if (-not (Test-Path $f)) { Info "Creating folder: $f"; New-Item -ItemType Directory -Path $f -Force | Out-Null }
}

#  Create venv
$venvDir = Join-Path $installPath "venv"
Info "Creating virtual environment at $venvDir ..."
& python -m venv $venvDir
$venvPy  = Join-Path $venvDir "Scripts\python.exe"
$venvPip = Join-Path $venvDir "Scripts\pip.exe"
if (-not (Test-Path $venvPy)) { Err "Venv creation failed. Ensure Python supports venv."; exit 1 }

#  Install Volatility3 (stable)
Info "Upgrading pip inside venv..."
& $venvPy -m pip install --upgrade pip setuptools wheel | Out-Null
Info "Installing Volatility 3 (stable)..."
& $venvPip install --no-cache-dir volatility3 | Out-Null
Ok "Volatility 3 installed successfully."

# Verify vol.exe and create shim
$volExe = Join-Path $venvDir "Scripts\vol.exe"
$useVolExe = $false
if (Test-Path $volExe) { $useVolExe = $true; Ok "Found vol.exe" } else {
    Warn "vol.exe not found; attempting reinstall..."
    & $venvPip install --upgrade --force-reinstall volatility3 | Out-Null
    if (Test-Path $volExe) { $useVolExe = $true }
}

# Create global shim for 'vol'
$shimDir = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps"
if (-not (Test-Path $shimDir)) { New-Item -ItemType Directory -Path $shimDir -Force | Out-Null }
$shim = Join-Path $shimDir "vol.cmd"

if ($useVolExe) {
  $shimContent = '@echo off' + "`r`n" + 'call "' + $volExe + '" --cache-path "' + $cachePath + '" -o "' + $outputPath + '" -s "' + $symbolsPath + '" %*'
} else {
  $shimContent = '@echo off' + "`r`n" + 'call "' + $venvPy + '" -m volatility3.cli --cache-path "' + $cachePath + '" -o "' + $outputPath + '" -s "' + $symbolsPath + '" %*'
}

Set-Content -Path $shim -Value $shimContent -Encoding ASCII -Force
Ok "Shim created: $shim"

# Verify installation
Write-Host ""
Info "Verifying Volatility 3..."
try {
    if ($useVolExe) { $v = & $volExe --version 2>&1 } else { $v = & $venvPy -m volatility3.cli --version 2>&1 }
    Ok "Volatility responds: $v"
} catch {
    Warn "Could not verify version, but installation likely succeeded."
}

# Final message
Write-Host ""
Ok "Installation complete!"
Write-Host "--------------------------------------"
Write-Host "Open a new PowerShell window and try:"
Write-Host "  vol --version"
Write-Host "  vol -f ""$installPath\cases\dump.vmem"" windows.info"
Write-Host ""
Write-Host "Update Vol3 later:"
Write-Host "  `"$venvDir\Scripts\Activate.ps1`"; pip install --upgrade volatility3"
Write-Host ""
Write-Host "Uninstall:"
Write-Host "  Remove-Item `"$shim`" -Force"
Write-Host "  Remove-Item `"$installPath`" -Recurse -Force"
Write-Host "--------------------------------------"
