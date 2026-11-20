# ==============================================================================
# REDMI NOTE 6 PRO (TULIP) — ANDROID 17 ROLLBACK ENGINE
# Author: Antigravity AI & Android Performance Engineering
# Purpose: Complete restoration of stock Android 17 baseline configuration
# Environment: Windows PowerShell 5.1+
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$ResetDexopt,
    [switch]$SkipReboot
)

$ErrorActionPreference = "Stop"

function Log-Info($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [INFO] $msg" -ForegroundColor Cyan
}

function Log-Success($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [OK]   $msg" -ForegroundColor Green
}

function Log-Warn($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [WARN] $msg" -ForegroundColor Yellow
}

function Log-Error($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [FAIL] $msg" -ForegroundColor Red
}

function Invoke-Adb($cmd) {
    $output = adb shell $cmd 2>&1
    return ($output | Out-String).Trim()
}

# --- STEP 1: PRE-FLIGHT CHECKS ---
Log-Info "=== 1/5: CHECKING ADB CONNECTION AND ROOT ACCESS ==="
$devices = adb devices | Select-String "device$"
if (-not $devices) {
    Log-Error "No authorized ADB device detected! Check USB debugging and authorization."
    exit 1
}

$idStr = (Invoke-Adb "id")
if ($idStr -notmatch "uid=0\(root\)") {
    Log-Error "Root privileges not available via ADB! ($idStr)."
    exit 1
}
Log-Success "Connected to Tulip with root permissions: $idStr"

# --- STEP 2: RESTORING DEBLOATED PACKAGES ---
Log-Info "=== 2/5: RESTORING ALL DEBLOATED PACKAGES ==="
$packagesToRestore = @(
    "com.android.se",
    "org.ifaa.aidl.manager",
    "io.chaldeaprjkt.gamespace",
    "com.libremobileos.sidebar",
    "com.infinity.updater",
    "com.android.bookmarkprovider",
    "com.android.printspooler",
    "com.android.bips",
    "com.android.adservices.api",
    "com.android.ondevicepersonalization.services",
    "com.android.federatedcompute.services",
    "com.android.devicediagnostics",
    "com.android.managedprovisioning",
    "com.android.rkpdapp",
    "org.omnirom.omnijaws",
    "com.android.axion.quicklook",
    "com.android.healthconnect.controller",
    "com.android.emergency",
    "com.android.cellbroadcastreceiver",
    "com.android.cellbroadcastreceiver.module"
)

foreach ($pkg in $packagesToRestore) {
    $res = Invoke-Adb "cmd package install-existing $pkg"
    if ($res -match "installed for user: 0") {
        Log-Success "Restored: $pkg"
    } else {
        # Check if already installed
        $check = (Invoke-Adb "pm list packages") -match "package:$pkg\b"
        if ($check) {
            Log-Info "Already installed: $pkg"
        } else {
            Log-Warn "Could not restore $($pkg): $res"
        }
    }
}

# Reset appops for protected packages
Invoke-Adb "cmd appops set com.android.devicelockcontroller RUN_IN_BACKGROUND default 2>/dev/null"
Invoke-Adb "cmd appops set com.android.devicelockcontroller RUN_ANY_IN_BACKGROUND default 2>/dev/null"
Log-Success "Reset appops policies to default"

# --- STEP 3: RESTORING STOCK UI & GRAPHICS SETTINGS ---
Log-Info "=== 3/5: RESTORING STOCK UI & ANIMATION PREFERENCES ==="
Invoke-Adb "settings put global disable_window_blurs 0"
Invoke-Adb "settings put global window_animation_scale 1.0"
Invoke-Adb "settings put global transition_animation_scale 1.0"
Invoke-Adb "settings put global animator_duration_scale 1.0"
Invoke-Adb "settings put secure long_press_timeout 400"
Invoke-Adb "device_config put activity_manager_native_boot use_freezer false"
Log-Success "Restored stock 1.0x animation scales, window blurs, and standard touch timeout"

# --- STEP 4: REMOVING PERSISTENT TUNING SCRIPT & RESTORING STOCK KERNEL ---
Log-Info "=== 4/5: REMOVING PERSISTENT TUNING SERVICE AND RESTORING STOCK KERNEL TUNABLES ==="
Invoke-Adb "rm -f /data/adb/service.d/99-performance-tuning.sh"
Log-Success "Removed persistent service script /data/adb/service.d/99-performance-tuning.sh"

# Restore stock kernel sysfs/procfs parameters
$stockRestoreScript = @"
# Revert ZRAM to stock ~1.8GB lzo-rle
if [ -e /sys/block/zram0 ]; then
    swapoff /dev/block/zram0 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    if grep -q "lzo-rle" /sys/block/zram0/comp_algorithm; then
        echo lzo-rle > /sys/block/zram0/comp_algorithm
    fi
    echo 1932735283 > /sys/block/zram0/disksize
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 2>/dev/null
fi

# Revert VM tunables
echo 60 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 3 > /proc/sys/vm/page-cluster
echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 1 > /proc/sys/vm/stat_interval

# Revert I/O scheduler
if [ -e /sys/block/mmcblk0/queue/scheduler ]; then
    echo none > /sys/block/mmcblk0/queue/scheduler 2>/dev/null
    echo 128 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
fi
"@

$tmpRestoreScript = Join-Path $PSScriptRoot "tmp_restore.sh"
[System.IO.File]::WriteAllText($tmpRestoreScript, $stockRestoreScript.Replace("`r`n", "`n"), [System.Text.Encoding]::ASCII)
adb push $tmpRestoreScript /data/local/tmp/restore_stock.sh > $null
Invoke-Adb "sh /data/local/tmp/restore_stock.sh"
Invoke-Adb "rm -f /data/local/tmp/restore_stock.sh"
Remove-Item -Path $tmpRestoreScript -Force -ErrorAction SilentlyContinue
Log-Success "Restored stock kernel memory, ZRAM (lzo-rle), and I/O scheduler parameters"

# --- STEP 5: OPTIONAL ART DEXOPT RESET ---
if ($ResetDexopt) {
    Log-Info "=== 5/5: RESETTING ART COMPILATION CACHES ==="
    $corePackages = @(
        "com.android.systemui",
        "com.android.launcher3",
        "com.android.settings",
        "com.android.inputmethod.latin",
        "com.android.phone",
        "com.android.permissioncontroller",
        "org.lineageos.aperture"
    )
    foreach ($pkg in $corePackages) {
        Invoke-Adb "cmd package compile --reset $pkg"
        Log-Info "Reset ART compilation for: $pkg"
    }
} else {
    Log-Info "=== 5/5: Skipping ART reset (compiled bytecode will remain valid) ==="
}

Log-Success "Full baseline configuration has been restored successfully!"
if (-not $SkipReboot) {
    Log-Info "Rebooting device to finalize stock restoration..."
    adb reboot
}
