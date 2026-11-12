[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Uninstall,
    [ValidateSet('default', 'hide-project-chats')][string]$Variant = 'default',
    [string]$TargetPath = (Join-Path $env:APPDATA 'Bitrix\Desktop\3.0\user_style.css'),
    [string]$ConfigPath
)
$ErrorActionPreference = 'Stop'
$taskName = 'Bitrix24ThemeUpdater'
$stateDir = Join-Path $env:LOCALAPPDATA 'Bitrix24ThemeUpdater'

if ($Uninstall) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Output 'Automatic updates disabled. Current CSS and backups are retained.'
    return
}
if ($ConfigPath) {
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    $Variant = [string]$config.Variant
    if ($Variant -notin @('default', 'hide-project-chats')) { throw 'Unknown stylesheet variant.' }
    $TargetPath = [string]$config.TargetPath
}
$TargetPath = [IO.Path]::GetFullPath($TargetPath)
if ([IO.Path]::GetFileName($TargetPath) -ne 'user_style.css') { throw 'Target must be named user_style.css.' }
$parent = Split-Path -Parent $TargetPath
if (-not (Test-Path -LiteralPath $parent -PathType Container)) { throw "Application folder does not exist: $parent" }

function Update-Stylesheet {
    $pending = Join-Path $parent ('.user_style.' + [guid]::NewGuid().ToString('N') + '.tmp')
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $url = "https://raw.githubusercontent.com/seatgimls/bitrix24-dark-theme/main/$Variant/user_style.css"
        Invoke-WebRequest -Uri $url -OutFile $pending -UseBasicParsing -TimeoutSec 30
        $bytes = [IO.File]::ReadAllBytes($pending)
        $text = [Text.UTF8Encoding]::new($false, $true).GetString($bytes)
        if ($bytes.Length -lt 100 -or $bytes.Length -gt 2097152 -or $text -match '(?i)<(?:!doctype|html|script)\b' -or $text -notmatch '\{[^}]+\}') {
            throw 'Response is not a supported stylesheet.'
        }
        if (Test-Path -LiteralPath $TargetPath) {
            if ((Get-FileHash -LiteralPath $pending).Hash -eq (Get-FileHash -LiteralPath $TargetPath).Hash) {
                Write-Output 'Stylesheet is already current.'
                return
            }
            $original = $TargetPath + '.original'
            if (-not (Test-Path -LiteralPath $original)) { [IO.File]::Copy($TargetPath, $original, $false) }
            [IO.File]::Replace($pending, $TargetPath, ($TargetPath + '.previous'))
        } else {
            [IO.File]::Move($pending, $TargetPath)
        }
        Write-Output "Stylesheet updated: $TargetPath"
    } finally {
        if (Test-Path -LiteralPath $pending) { Remove-Item -LiteralPath $pending -Force }
    }
}

try {
    Update-Stylesheet
    if ($Install) {
        New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
        $installedScript = Join-Path $stateDir 'Update-Theme.ps1'
        if ([IO.Path]::GetFullPath($PSCommandPath) -ne $installedScript) {
            Copy-Item -LiteralPath $PSCommandPath -Destination $installedScript -Force
        }
        $settings = Join-Path $stateDir 'config.json'
        @{Variant=$Variant; TargetPath=$TargetPath} | ConvertTo-Json | Set-Content -LiteralPath $settings -Encoding UTF8
        $arguments = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $installedScript + '" -ConfigPath "' + $settings + '"'
        $action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $arguments
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $login = New-ScheduledTaskTrigger -AtLogOn -User $identity
        $hourly = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(60) -RepetitionInterval (New-TimeSpan -Hours 1)
        $principal = New-ScheduledTaskPrincipal -UserId $identity -LogonType Interactive -RunLevel Limited
        $options = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger @($login,$hourly) -Principal $principal -Settings $options -Force | Out-Null
        Write-Output 'Automatic updates enabled at sign-in and hourly while signed in.'
    }
} catch {
    if ($ConfigPath) {
        ('{0:u} {1}' -f (Get-Date), $_.Exception.Message) | Set-Content -LiteralPath (Join-Path $stateDir 'last-error.log')
    }
    throw
}
