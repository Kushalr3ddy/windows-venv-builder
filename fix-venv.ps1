# Repoints a venv built on GitHub Actions at your local Python install.
# Usage:  .\fix-venv.ps1 -Venv .\venv -Python "py -3.12"
#   or:   .\fix-venv.ps1 -Venv .\venv -Python C:\Python312\python.exe
param(
    [string]$Venv = ".\venv",
    [string]$Python = "python"
)

$parts = $Python -split ' '
$exe = $parts[0]
$pyArgs = @($parts | Select-Object -Skip 1)

$base = (& $exe @pyArgs -c "import sys; print(sys.base_prefix)").Trim()
$ver  = (& $exe @pyArgs -c "import sys; print('%d.%d' % sys.version_info[:2])").Trim()

$cfg = Join-Path $Venv "pyvenv.cfg"
if (-not (Test-Path $cfg)) { throw "No pyvenv.cfg in $Venv" }

$venvVer = ((Get-Content $cfg | Where-Object { $_ -match '^version' }) -replace '.*=\s*', '').Trim()
if (-not $venvVer.StartsWith("$ver.")) {
    Write-Warning "venv was built for Python $venvVer but local Python is $ver. Compiled packages will NOT load. Rebuild with matching version."
}

(Get-Content $cfg) `
    -replace '^home\s*=.*', "home = $base" `
    -replace '^executable\s*=.*', "executable = $(Join-Path $base 'python.exe')" |
    Set-Content $cfg

Write-Host "Fixed $cfg -> $base"
Write-Host "Use: $Venv\Scripts\python.exe  (and 'python -m pip', not pip.exe)"
