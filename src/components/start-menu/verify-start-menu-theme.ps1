#requires -version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$RegistryKey = 'HKLM:\Software\Windhawk\Engine\Mods\windows-11-start-menu-styler'
$SettingsKey = $RegistryKey + '\Settings'
$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail
    )

    $checks.Add([pscustomobject]@{
        Check = $Name
        Status = if ($Passed) { 'PASS' } else { 'FAIL' }
        Detail = $Detail
    })
}

$registryExists = Test-Path -LiteralPath $RegistryKey
Add-Check -Name 'Windhawk Start Menu Styler' -Passed $registryExists -Detail '需要已安装 Windows 11 Start Menu Styler 模块'

$settings = $null
if ($registryExists) {
    $settings = Get-ItemProperty -LiteralPath $SettingsKey -ErrorAction SilentlyContinue
}

$enabled = $false
if ($registryExists) {
    $enabled = ((Get-ItemProperty -LiteralPath $RegistryKey -Name Disabled -ErrorAction SilentlyContinue).Disabled -eq 0)
}
Add-Check -Name '模块启用状态' -Passed $enabled -Detail 'Disabled=0 表示 Windhawk 模块已启用'

$mainTarget = ''
$mainBackground = ''
$mainBorder = ''
if ($null -ne $settings) {
    $mainTarget = [string]$settings.'controlStyles[0].target'
    $mainBackground = [string]$settings.'controlStyles[0].styles[0]'
    $mainBorder = [string]$settings.'controlStyles[0].styles[1]'
}
Add-Check -Name '开始菜单主玻璃规则' -Passed ($mainTarget -eq 'Border#AcrylicBorder') -Detail 'AcrylicBorder 是主题主容器'
Add-Check -Name '黑曜石背景' -Passed (($mainBackground -match 'WindhawkBlur') -or ($mainBackground -match 'ImageBrush')) -Detail '使用内置毛玻璃或用户提供的本地图片'
Add-Check -Name '血红紫边缘光' -Passed ($mainBorder -match 'LinearGradientBrush') -Detail '渐变边框规则已写入'

$blurFound = $false
if ($null -ne $settings) {
    foreach ($property in $settings.PSObject.Properties) {
        if ($property.Name.StartsWith('controlStyles[') -and ([string]$property.Value -match 'WindhawkBlur')) {
            $blurFound = $true
            break
        }
    }
}
Add-Check -Name '毛玻璃层' -Passed $blurFound -Detail '至少一个视觉规则使用 WindhawkBlur'

$startHost = Get-Process -Name 'StartMenuExperienceHost' -ErrorAction SilentlyContinue
Add-Check -Name '开始菜单宿主' -Passed ($null -ne $startHost) -Detail 'StartMenuExperienceHost 当前正在运行'

$checks | Format-Table -AutoSize
if (@($checks | Where-Object { $_.Status -eq 'FAIL' }).Count -gt 0) {
    exit 1
}
