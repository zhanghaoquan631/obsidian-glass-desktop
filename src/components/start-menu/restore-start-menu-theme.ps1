#requires -version 5.1

[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'

$RegistryKey = 'HKLM:\Software\Windhawk\Engine\Mods\windows-11-start-menu-styler'
$StateRoot = "$env:LOCALAPPDATA\ObsidianGlassDesktop\start-menu-theme"
$BaselinePath = $StateRoot + '\backups\baseline-before-obsidian-crimson.reg'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Path -LiteralPath $BaselinePath)) {
    throw '没有找到本机首次应用前的 Windhawk 开始菜单备份，未执行任何恢复操作。'
}

Write-Host '计划恢复本机在首次应用该主题前的 Windhawk Start Menu Styler 设置。'
Write-Host '不会：卸载 Windhawk、重启 Explorer、删除软件或删除个人文件。'
if (-not $Apply) {
    Write-Host '这是预览；没有写入任何设置。确认后加 -Apply。' -ForegroundColor Yellow
    return
}

if (-not (Test-IsAdministrator)) {
    throw '实际恢复需要管理员 PowerShell。脚本不会主动弹出 UAC。'
}

& reg.exe import $BaselinePath | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw '导入本机 Windhawk 开始菜单备份失败。'
}

$unixTime = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
New-ItemProperty -Path $RegistryKey -Name 'SettingsChangeTime' -Value $unixTime -PropertyType DWord -Force | Out-Null

Get-Process -Name 'StartMenuExperienceHost' -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name 'SearchHost' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host '开始菜单主题已恢复为本机应用前的 Windhawk 设置。' -ForegroundColor Green
