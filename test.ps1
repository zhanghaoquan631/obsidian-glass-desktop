[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$packageRoot = $PSScriptRoot

function Assert-PackagePath {
    param(
        [string]$RelativePath,
        [switch]$Container
    )

    $fullPath = Join-Path $packageRoot $RelativePath
    $pathType = if ($Container) { 'Container' } else { 'Leaf' }
    if (!(Test-Path -LiteralPath $fullPath -PathType $pathType)) {
        throw ('Missing required package path: ' + $RelativePath)
    }
}

function Assert-TextContains {
    param(
        [string]$RelativePath,
        [string[]]$RequiredText
    )

    $fullPath = Join-Path $packageRoot $RelativePath
    $content = [IO.File]::ReadAllText($fullPath)
    foreach ($marker in $RequiredText) {
        if ($content.IndexOf($marker, [StringComparison]::Ordinal) -lt 0) {
            throw ('Missing integration marker in ' + $RelativePath + ': ' + $marker)
        }
    }
}

function Assert-ImageDimensions {
    param(
        [string]$RelativePath,
        [int]$ExpectedWidth,
        [int]$ExpectedHeight,
        [int64]$MinimumBytes
    )

    $fullPath = Join-Path $packageRoot $RelativePath
    $file = Get-Item -LiteralPath $fullPath
    $image = [System.Drawing.Image]::FromFile($fullPath)
    try {
        if (($image.Width -ne $ExpectedWidth) -or ($image.Height -ne $ExpectedHeight)) {
            throw ('Unexpected screenshot dimensions for ' + $RelativePath + ': ' + $image.Width + 'x' + $image.Height)
        }
        if ($file.Length -lt $MinimumBytes) {
            throw ('Screenshot is unexpectedly small: ' + $RelativePath + ' (' + $file.Length + ' bytes)')
        }
    }
    finally {
        $image.Dispose()
    }
}

function Assert-AmbientLightPixels {
    param([string]$RelativePath)

    $fullPath = Join-Path $packageRoot $RelativePath
    $bitmap = New-Object System.Drawing.Bitmap($fullPath)
    $samples = 0
    $cyanSamples = 0
    $redTotal = 0
    $blueTotal = 0
    try {
        for ($y = 450; $y -le 620; $y += 10) {
            for ($x = 300; $x -le 1300; $x += 10) {
                $pixel = $bitmap.GetPixel($x, $y)
                $samples++
                $redTotal += $pixel.R
                $blueTotal += $pixel.B
                if (($pixel.B -ge ($pixel.R + 5)) -and ($pixel.G -ge ($pixel.R + 2)) -and ($pixel.B -ge 15)) {
                    $cyanSamples++
                }
            }
        }
    }
    finally {
        $bitmap.Dispose()
    }

    $cyanRatio = $cyanSamples / [double]$samples
    if (($cyanRatio -lt 0.20) -or ($blueTotal -le ($redTotal + (3 * $samples)))) {
        throw ('Bottom ambient light is not visibly present in ' + $RelativePath)
    }
}

& (Join-Path $packageRoot 'src\Test-StartupKit.ps1')
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$ambientFiles = @(
    'src\components\wallpaper\ambient-light\bottom-ambient-light.css',
    'src\components\wallpaper\ambient-light\bottom-ambient-light.js',
    'src\components\wallpaper\ambient-light\README.md'
)
foreach ($ambientFile in $ambientFiles) {
    Assert-PackagePath -RelativePath $ambientFile
}

Assert-TextContains -RelativePath 'src\components\wallpaper\index.html' -RequiredText @(
    'ambient-light/bottom-ambient-light.css',
    'id="bottom-ambient-light"',
    'ambient-light/bottom-ambient-light.js'
)
Assert-TextContains -RelativePath 'src\components\wallpaper\js\script.js' -RequiredText @(
    'BottomAmbientLightSystem.setPaused',
    'BottomAmbientLightSystem.onAudio',
    'BottomAmbientLightSystem.onProperty'
)

$propertiesPath = Join-Path $packageRoot 'src\components\wallpaper\LivelyProperties.json'
$properties = Get-Content -LiteralPath $propertiesPath -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($propertyName in @(
    'bottomAmbientEnabled',
    'bottomAmbientIntensity',
    'bottomAmbientPalette',
    'bottomAmbientPointerReactive',
    'bottomAmbientAudioReactive',
    'bottomAmbientReset'
)) {
    if ($null -eq $properties.PSObject.Properties[$propertyName]) {
        throw ('Missing Lively property: ' + $propertyName)
    }
}

Add-Type -AssemblyName System.Drawing
Assert-ImageDimensions -RelativePath 'assets\screenshots\04-dashboard.png' -ExpectedWidth 1600 -ExpectedHeight 1000 -MinimumBytes 500000
Assert-ImageDimensions -RelativePath 'assets\screenshots\06-ambient.png' -ExpectedWidth 1600 -ExpectedHeight 693 -MinimumBytes 250000
Assert-AmbientLightPixels -RelativePath 'assets\screenshots\06-ambient.png'

Write-Host 'PASS: 公开包语法、JSON、环境光接入、当前截图、运行时排除项和基础隐私检查通过。' -ForegroundColor Green
