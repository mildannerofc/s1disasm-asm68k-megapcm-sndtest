param(
    [string]$ProjectRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path),
    [string]$ReturnMode = '$04'
)

$ErrorActionPreference = 'Stop'

$config = Join-Path $ProjectRoot 'soundtest\config\Sound Test Config.asm'
$source = Join-Path $ProjectRoot 'soundtest\src\Sound Test.asm'

if (-not (Test-Path -LiteralPath $config)) {
    throw "Não encontrei: $config"
}
if (-not (Test-Path -LiteralPath $source)) {
    throw "Não encontrei: $source"
}

$text = Get-Content -LiteralPath $config -Raw

# Avoid duplicate definitions. Update an existing definition, otherwise add one.
$pattern = '(?m)^SoundTest_ReturnMode\s*:\s*equ\s+[^\r\n]+'
$line = "SoundTest_ReturnMode:        equ $ReturnMode    ; $((if ($ReturnMode -eq '$04') {'id_Title / Sonic 1 title menu'} else {'configured game-mode value'}))"

if ($text -match $pattern) {
    $text = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $line }, 1)
} else {
    $marker = 'SoundTest_InitialID:         equ SoundTest_MusicID_First'
    if ($text -notmatch [regex]::Escape($marker)) {
        throw 'Não encontrei SoundTest_InitialID para inserir SoundTest_ReturnMode.'
    }
    $text = $text -replace [regex]::Escape($marker), ($marker + "`r`n" + $line), 1
}

# Make a one-time backup next to the config.
$backup = "$config.bak"
if (-not (Test-Path -LiteralPath $backup)) {
    Copy-Item -LiteralPath $config -Destination $backup
}
Set-Content -LiteralPath $config -Value $text -Encoding ASCII

Write-Host 'OK: SoundTest_ReturnMode foi definido.'
Write-Host "Config: $config"
Write-Host "Valor:  $ReturnMode"
