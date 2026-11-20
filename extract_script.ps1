Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-bouquet-20.11.2026-VANILLA-UNOFFICIAL.zip"
$outDir = "C:\Users\User\Documents\redmi\zip_extracted"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
foreach ($name in @("META-INF/com/google/android/updater-script", "dynamic_partitions_op_list", "flash_super_dummy.sh")) {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq $name }
    if ($entry) {
        $dest = Join-Path $outDir (Split-Path $entry.FullName -Leaf)
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    }
}
$zip.Dispose()
Write-Host "Extracted successfully."
