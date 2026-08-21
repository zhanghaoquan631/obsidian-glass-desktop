#requires -version 5.1

[CmdletBinding()]
param(
    [switch]$Apply,
    [string]$BackgroundImage
)

$ErrorActionPreference = 'Stop'

$ThemeName = 'Obsidian Crimson Glass'
$RegistryKey = 'HKLM:\Software\Windhawk\Engine\Mods\windows-11-start-menu-styler'
$SettingsKey = $RegistryKey + '\Settings'
$RegistryExportKey = 'HKLM\Software\Windhawk\Engine\Mods\windows-11-start-menu-styler'
$StateRoot = "$env:LOCALAPPDATA\ObsidianGlassDesktop\start-menu-theme"
$BackupRoot = $StateRoot + '\backups'
$LogRoot = $StateRoot + '\logs'
$BaselinePath = $BackupRoot + '\baseline-before-obsidian-crimson.reg'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupPath = $BackupRoot + '\before-apply-' + $Timestamp + '.reg'
$LogPath = $LogRoot + '\apply-' + $Timestamp + '.log'

function Write-ThemeLog {
    param([string]$Message)

    $line = '[' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + '] ' + $Message
    Write-Host $line
    if (Test-Path -LiteralPath $LogRoot) {
        Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
    }
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function ConvertTo-LocalImageBrush {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return '<WindhawkBlur BlurAmount="28" TintColor="#B20A050D"/>'
    }

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    $extension = [IO.Path]::GetExtension($resolved.Path).ToLowerInvariant()
    if ($extension -notin @('.png', '.jpg', '.jpeg', '.bmp')) {
        throw '背景图片仅支持 PNG、JPG、JPEG 或 BMP。'
    }

    $uri = [Uri]$resolved.Path
    $escapedUri = [Security.SecurityElement]::Escape($uri.AbsoluteUri)
    return '<ImageBrush ImageSource="' + $escapedUri + '" Stretch="UniformToFill" AlignmentX="Right" AlignmentY="Center" Opacity="0.72"/>'
}

function Set-RegistryText {
    param(
        [string]$Name,
        [string]$Value
    )

    New-ItemProperty -Path $SettingsKey -Name $Name -Value $Value -PropertyType String -Force | Out-Null
}

function Add-ControlStyle {
    param(
        [int]$Index,
        [string]$Target,
        [string[]]$Styles
    )

    Set-RegistryText -Name ('controlStyles[' + $Index + '].target') -Value $Target
    for ($styleIndex = 0; $styleIndex -lt $Styles.Count; $styleIndex++) {
        Set-RegistryText -Name ('controlStyles[' + $Index + '].styles[' + $styleIndex + ']') -Value $Styles[$styleIndex]
    }
}

if (-not (Test-Path -LiteralPath $RegistryKey)) {
    throw '未找到 Windhawk Windows 11 Start Menu Styler。请先从 Windhawk 官方渠道安装并启用该模块。'
}

$backgroundBrush = ConvertTo-LocalImageBrush -Path $BackgroundImage

Write-Host ''
Write-Host ('计划应用：' + $ThemeName) -ForegroundColor Cyan
Write-Host '范围：仅 Windhawk 的 Windows 11 Start Menu Styler 设置。'
Write-Host '不会：启动项、桌面壁纸、Dock、Explorer、个人文件或 Windows 核心设置。'
if ($BackgroundImage) {
    Write-Host ('背景：当前电脑上的本地文件 ' + (Resolve-Path -LiteralPath $BackgroundImage).Path)
} else {
    Write-Host '背景：内置深色毛玻璃，不使用或上传图片。'
}
if (-not $Apply) {
    Write-Host ''
    Write-Host '这是预览；没有写入任何设置。确认后加 -Apply。' -ForegroundColor Yellow
    return
}

if (-not (Test-IsAdministrator)) {
    throw '实际应用需要管理员 PowerShell。脚本不会主动弹出 UAC。'
}

New-Item -ItemType Directory -Force -Path $BackupRoot, $LogRoot | Out-Null
Write-ThemeLog '开始备份当前 Windhawk 开始菜单规则。'
& reg.exe export $RegistryExportKey $BackupPath /y | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw '导出当前 Windhawk 开始菜单设置失败。'
}
if (-not (Test-Path -LiteralPath $BaselinePath)) {
    Copy-Item -LiteralPath $BackupPath -Destination $BaselinePath -Force
    Write-ThemeLog '已保存首次应用前的恢复基线。'
}

Write-ThemeLog '写入黑曜石血红紫玻璃规则。'
if (Test-Path -LiteralPath $SettingsKey) {
    Remove-Item -LiteralPath $SettingsKey -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $SettingsKey | Out-Null

Set-RegistryText -Name 'theme' -Value ''
Set-RegistryText -Name 'disableNewStartMenuLayout' -Value 'default'

Add-ControlStyle 0 'Border#AcrylicBorder' @(
    ('Background:=' + $backgroundBrush),
    'BorderBrush:=<LinearGradientBrush StartPoint="0,0" EndPoint="1,1"><GradientStop Color="#FFEAF7FF" Offset="0"/><GradientStop Color="#FFFF3978" Offset="0.30"/><GradientStop Color="#FF9A4DFF" Offset="0.68"/><GradientStop Color="#FF63D7FF" Offset="1"/></LinearGradientBrush>',
    'BorderThickness=1.5',
    'CornerRadius=24'
)
Add-ControlStyle 1 'Border#AcrylicOverlay' @(
    'Visibility=Visible',
    'Background:=<LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#F207070B" Offset="0"/><GradientStop Color="#E30A0610" Offset="0.52"/><GradientStop Color="#9E190317" Offset="0.78"/><GradientStop Color="#6A10001B" Offset="1"/></LinearGradientBrush>',
    'CornerRadius=24'
)
Add-ControlStyle 2 'Border#LayerBorder' @(
    'Background:=<WindhawkBlur BlurAmount="28" TintColor="#A608050B"/>',
    'BorderThickness=0',
    'CornerRadius=24'
)
Add-ControlStyle 3 'Grid#MainMenu' @(
    'MinWidth=680',
    'MaxWidth=760'
)
Add-ControlStyle 4 'StartMenu.SearchBoxToggleButton > Grid > Border#BorderElement' @(
    'Background:=<WindhawkBlur BlurAmount="24" TintColor="#C20C0711"/>',
    'BorderBrush:=<LinearGradientBrush StartPoint="0,0" EndPoint="1,0"><GradientStop Color="#B8FF5B88" Offset="0"/><GradientStop Color="#A79B65FF" Offset="0.55"/><GradientStop Color="#B866D9FF" Offset="1"/></LinearGradientBrush>',
    'BorderThickness=1',
    'CornerRadius=18'
)
Add-ControlStyle 5 'StartDocked.SearchBoxToggleButton#StartMenuSearchBox > Grid > Border#BorderElement' @(
    'Background:=<WindhawkBlur BlurAmount="24" TintColor="#C20C0711"/>',
    'BorderBrush=#B8FF5B88',
    'BorderThickness=1',
    'CornerRadius=18'
)
Add-ControlStyle 6 'Button#ShowAllAppsButton > ContentPresenter@CommonStates' @(
    'Background@Normal=#5214071C',
    'Background@PointerOver=#8A4A0B32',
    'BorderBrush@Normal=#769A4DFF',
    'BorderBrush@PointerOver=#DFFF5B88',
    'BorderThickness=1',
    'CornerRadius=12'
)
Add-ControlStyle 7 'Button#CloseAllAppsButton > ContentPresenter@CommonStates' @(
    'Background@Normal=#5214071C',
    'Background@PointerOver=#8A4A0B32',
    'BorderBrush@Normal=#769A4DFF',
    'BorderBrush@PointerOver=#DFFF5B88',
    'BorderThickness=1',
    'CornerRadius=12'
)
Add-ControlStyle 8 'Border#ContentBorder@CommonStates > Grid#DroppedFlickerWorkaroundWrapper > Border' @(
    'Background@Normal=#12000000',
    'Background@PointerOver=#71330A2B',
    'Background@Pressed=#944E103C',
    'BorderBrush@PointerOver=#CFFF5D9A',
    'BorderBrush@Pressed=#E69C67FF',
    'BorderThickness=1',
    'CornerRadius=12'
)
Add-ControlStyle 9 'StartDocked.AppListViewItem > Grid@CommonStates > Border' @(
    'Background@Normal=#12000000',
    'Background@PointerOver=#6933072A',
    'BorderBrush@PointerOver=#BFFF5B88',
    'BorderThickness=1',
    'CornerRadius=11',
    'Margin@Normal=3'
)
Add-ControlStyle 10 'StartDocked.AllAppsGridListViewItem > Grid@CommonStates > Border' @(
    'Background@Normal=#10000000',
    'Background@PointerOver=#66340A30',
    'BorderBrush@PointerOver=#B69A5EFF',
    'BorderThickness=1',
    'CornerRadius=11'
)
Add-ControlStyle 11 'StartDocked.NavigationPaneButton#UserTileButton > Grid@CommonStates > Border' @(
    'Background@Normal=#4713071A',
    'Background@PointerOver=#7A3A0A31',
    'BorderBrush@PointerOver=#C9FF668F',
    'BorderThickness=1',
    'CornerRadius=14'
)
Add-ControlStyle 12 'StartDocked.NavigationPaneButton#PowerButton > Grid@CommonStates > Border' @(
    'Background@Normal=#4713071A',
    'Background@PointerOver=#8C4B0B32',
    'BorderBrush@PointerOver=#D9FF527E',
    'BorderThickness=1',
    'CornerRadius=14'
)
Add-ControlStyle 13 'MenuFlyoutPresenter > Border' @(
    'Background:=<WindhawkBlur BlurAmount="26" TintColor="#ED0A050D"/>',
    'BorderBrush=#B88F4DFF',
    'BorderThickness=1',
    'CornerRadius=16'
)
Add-ControlStyle 14 'TextBlock#Text' @(
    'Foreground=#FFF7F2FA'
)
Add-ControlStyle 15 'Border#StartDropShadow' @(
    'CornerRadius=24',
    'Margin=-2'
)
Add-ControlStyle 16 'Border#dropshadow' @(
    'CornerRadius=24',
    'Margin=-2'
)
Add-ControlStyle 17 'ToolTip > ContentPresenter#LayoutRoot' @(
    'Background:=<WindhawkBlur BlurAmount="22" TintColor="#E90A050D"/>',
    'BorderBrush=#8A9D60FF',
    'BorderThickness=1',
    'CornerRadius=10'
)

Set-RegistryText -Name 'styleConstants[0]' -Value ''
Set-RegistryText -Name 'themeResourceVariables[0]' -Value ''
Set-RegistryText -Name 'webContentStyles[0].target' -Value ''
Set-RegistryText -Name 'webContentStyles[0].styles[0]' -Value ''
Set-RegistryText -Name 'webContentCustomJs' -Value ''

$unixTime = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
New-ItemProperty -Path $RegistryKey -Name 'SettingsChangeTime' -Value $unixTime -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $RegistryKey -Name 'Disabled' -Value 0 -PropertyType DWord -Force | Out-Null

Write-ThemeLog '刷新当前用户的开始菜单与搜索宿主；不会重启 Explorer。'
Get-Process -Name 'StartMenuExperienceHost' -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name 'SearchHost' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-ThemeLog '完成。恢复命令在 README 中，基线备份位于 LocalAppData。'
