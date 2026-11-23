# Links the add-on folder of this repository into the game's AddOns folder (a junction, no admin needed), so the game
# loads it straight from here: edit, then /reload in the game.
param([string]$AddOnsPath = 'E:\Games\World of Warcraft\_forever_\Interface\AddOns')

$source = Join-Path $PSScriptRoot '..\SessionGold' | Resolve-Path
$target = Join-Path $AddOnsPath 'SessionGold'
if (Test-Path $target) { Write-Host "Already exists: $target"; exit 0 }
New-Item -ItemType Junction -Path $target -Target $source | Out-Null
Write-Host "Linked $target -> $source"
