Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-bouquet-20.11.2026-VANILLA-UNOFFICIAL.zip"
$outDir = "C:\Users\User\Documents\redmi\zip_extracted"
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq "unsparse_super_empty.img" }
if ($entry) {
    $dest = Join-Path $outDir "unsparse_super_empty.img"
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
    Write-Host "Extracted unsparse_super_empty.img, size: $($entry.Length)"
}
$zip.Dispose()
