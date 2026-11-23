# Builds the .zip to upload to CurseForge: the SessionGold folder at the root of the archive, as the game
# expects it inside Interface\AddOns. The version comes from the .toc. Entries are written by hand with "/" separators:
# Compress-Archive in Windows PowerShell uses "\", which other unzip tools read as part of the file name.
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$addOnFolder = (Join-Path $PSScriptRoot '..\SessionGold' | Resolve-Path).Path
$version = (Select-String -Path (Join-Path $addOnFolder 'SessionGold.toc') -Pattern '^## Version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$distFolder = Join-Path $PSScriptRoot '..\dist'
New-Item -ItemType Directory -Force -Path $distFolder | Out-Null
$zipPath = Join-Path (Resolve-Path $distFolder).Path "SessionGold-$version.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }

$zip = [IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
  foreach ($file in Get-ChildItem -Path $addOnFolder -Recurse -File) {
    $entryName = 'SessionGold/' + $file.FullName.Substring($addOnFolder.Length + 1).Replace('\', '/')
    [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $entryName) | Out-Null
  }
} finally {
  $zip.Dispose()
}
Write-Host "Created $zipPath"
