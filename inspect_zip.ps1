Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-bouquet-20.11.2026-VANILLA-UNOFFICIAL.zip"
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$zip.Entries | Where-Object { $_.Name -match "dynamic|super|updater|updater-script" } | Select-Object FullName, Length
$zip.Dispose()
