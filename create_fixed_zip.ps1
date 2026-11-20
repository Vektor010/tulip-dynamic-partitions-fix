$staging = "C:\Users\User\Documents\redmi\zip_staging"
if (-not (Test-Path $staging)) { New-Item -ItemType Directory -Path $staging | Out-Null }
Copy-Item "C:\Users\User\Documents\redmi\zip_extracted\unsparse_super_empty_tulip.img" (Join-Path $staging "unsparse_super_empty.img") -Force
Copy-Item "C:\Users\User\Documents\redmi\zip_extracted\super_dummy_tulip.img" (Join-Path $staging "super_dummy.img") -Force

$srcZip = "C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-bouquet-20.11.2026-VANILLA-UNOFFICIAL.zip"
$dstZip = "C:\Users\User\Downloads\Yurigram\Project_Infinity-X-4.2-tulip-fixed.zip"

Write-Host "Copying base zip..."
Copy-Item $srcZip $dstZip -Force
Write-Host "Updating entries with 7-Zip..."
Push-Location $staging
& "C:\Program Files\7-Zip\7z.exe" u $dstZip unsparse_super_empty.img super_dummy.img
Pop-Location
Write-Host "Done!"
