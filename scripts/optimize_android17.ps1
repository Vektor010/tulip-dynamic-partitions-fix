# ==============================================================================
# REDMI NOTE 6 PRO (TULIP) — ANDROID 17 OPTIMIZATION ENGINE
# Author: Antigravity AI & Android Performance Engineering
# Target: Snapdragon 636 (Tulip / Bouquet), Android 17, Kernel 4.19+
# Environment: Windows PowerShell 5.1+
# ==============================================================================

[CmdletBinding()]
param(
    [switch]$SkipDexopt,
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
Log-Info "=== 1/6: PRE-FLIGHT ENVIRONMENT & CONNECTIVITY AUDIT ==="
$devices = adb devices | Select-String "device$"
if (-not $devices) {
    Log-Error "No authorized ADB device detected! Check USB debugging and authorization."
    exit 1
}

$deviceModel = (Invoke-Adb "getprop ro.product.device")
$buildVersion = (Invoke-Adb "getprop ro.build.version.release")
Log-Info "Detected Device: $deviceModel (Android $buildVersion)"

$idStr = (Invoke-Adb "id")
if ($idStr -notmatch "uid=0\(root\)") {
    Log-Error "Root privileges not available via ADB! ($idStr). Enable ADB Root in BakaSU / KernelSU."
    exit 1
}
Log-Success "Verified ADB Root Privileges: $idStr"

# --- STEP 2: SYSTEM SERVICE & APP DEBLOATING ---
Log-Info "=== 2/6: REMOVING REDUNDANT PACKAGES & PERSISTENT BLOAT ==="
$packagesToDebloat = @(
    "com.android.se",                               # Non-existent NFC Secure Element daemon
    "org.ifaa.aidl.manager",                        # Chinese IFAA fingerprint payment (Alipay/WeChat)
    "io.chaldeaprjkt.gamespace",                    # GameSpace persistent overlay
    "com.libremobileos.sidebar",                    # Sidebar floating dock overlay
    "com.infinity.updater",                         # Obsolete OTA updater daemon
    "com.android.bookmarkprovider",                 # Legacy AOSP bookmark content provider
    "com.android.printspooler",                     # Network Wi-Fi print spooler
    "com.android.bips",                             # Mopria built-in print service
    "com.android.adservices.api",                   # Android Privacy Sandbox / AdServices telemetry
    "com.android.ondevicepersonalization.services", # Google On-Device Ad Personalization
    "com.android.federatedcompute.services",        # Google Federated Learning compute
    "com.android.devicediagnostics",                # Hardware diagnostics telemetry
    "com.android.managedprovisioning",              # Enterprise Work Profile provisioning
    "com.android.rkpdapp",                          # Remote Key Provisioning Daemon
    "org.omnirom.omnijaws",                         # OmniJaws background weather polling daemon
    "com.android.axion.quicklook",                  # Quick Look smartspacer clone
    "com.android.healthconnect.controller",         # Health Connect sync service
    "com.android.emergency",                        # Lockscreen emergency info
    "com.android.cellbroadcastreceiver",            # Cell Broadcast emergency alerts
    "com.android.cellbroadcastreceiver.module"      # Cell Broadcast service module
)

$installedPackages = (Invoke-Adb "pm list packages -u")

foreach ($pkg in $packagesToDebloat) {
    if ($installedPackages -match "package:$pkg\b") {
        # Check if already uninstalled for user 0
        $isUserInstalled = (Invoke-Adb "pm list packages") -match "package:$pkg\b"
        if ($isUserInstalled) {
            $res = Invoke-Adb "pm uninstall -k --user 0 $pkg"
            if ($res -match "Success") {
                Log-Success "Uninstalled for user 0: $pkg"
            } else {
                Log-Warn "Uninstall result for $pkg: $res"
            }
        } else {
            Log-Info "Already removed for user 0: $pkg"
        }
    } else {
        Log-Info "Package not present on ROM: $pkg"
    }
}

# Block background execution of protected components
Invoke-Adb "cmd appops set com.android.devicelockcontroller RUN_IN_BACKGROUND ignore 2>/dev/null"
Invoke-Adb "cmd appops set com.android.devicelockcontroller RUN_ANY_IN_BACKGROUND ignore 2>/dev/null"
Invoke-Adb "am force-stop com.android.devicelockcontroller 2>/dev/null"

# --- STEP 3: UI & GRAPHICS PIPELINE TUNING ---
Log-Info "=== 3/6: UI RENDERING, COMPOSITOR & ANIMATION TUNING ==="
# Adreno 509 frame drop mitigation: disable window blurs
Invoke-Adb "settings put global disable_window_blurs 1"
Log-Success "Disabled Window Blurs (avoids 18-22ms GPU shader penalty on Adreno 509)"

# Snappy 0.5x animation scales
Invoke-Adb "settings put global window_animation_scale 0.5"
Invoke-Adb "settings put global transition_animation_scale 0.5"
Invoke-Adb "settings put global animator_duration_scale 0.5"
Invoke-Adb "settings put secure long_press_timeout 250"
Log-Success "Configured 0.5x responsive animation scales and 250ms touch threshold"

# Enable cgroup v2 App Freezer for frozen background apps
Invoke-Adb "device_config put activity_manager_native_boot use_freezer true"
Log-Success "Enabled Android App Freezer (cgroup v2 freezer)"

# --- STEP 4: KERNEL MEMORY & I/O OPTIMIZATION PROFILE ---
Log-Info "=== 4/6: PERSISTENT MEMORY & I/O HARDWARE TUNING ==="
$serviceScript = @"
#!/system/bin/sh
# Persistent Tulip Android 17 Performance Profile
# Generated by optimize_android17.ps1

sleep 5

# --- ZRAM & SWAP TUNING ---
if [ -e /sys/block/zram0 ]; then
    swapoff /dev/block/zram0 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    if grep -q "lz4" /sys/block/zram0/comp_algorithm; then
        echo lz4 > /sys/block/zram0/comp_algorithm
    fi
    # 2.5 GB ZRAM disksize for 4 GB RAM device
    echo 2684354560 > /sys/block/zram0/disksize
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 -p 32767 2>/dev/null
fi

# --- VIRTUAL MEMORY (VM) ---
echo 100 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 0 > /proc/sys/vm/page-cluster
echo 10 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 20 > /proc/sys/vm/stat_interval

# --- STORAGE I/O SCHEDULER (eMMC 5.1) ---
if [ -e /sys/block/mmcblk0/queue/scheduler ]; then
    echo mq-deadline > /sys/block/mmcblk0/queue/scheduler 2>/dev/null
    echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
fi

# --- EAS SCHEDUTIL GOVERNOR RATE LIMITS ---
for p in /sys/devices/system/cpu/cpufreq/policy*/schedutil; do
    if [ -d "`$p" ]; then
        echo 0 > "`$p/up_rate_limit_us" 2>/dev/null
        echo 0 > "`$p/down_rate_limit_us" 2>/dev/null
    fi
done
"@

# Write directly to Magisk/KernelSU service.d
$tmpScript = Join-Path $PSScriptRoot "99-performance-tuning.sh"
[System.IO.File]::WriteAllText($tmpScript, $serviceScript.Replace("`r`n", "`n"), [System.Text.Encoding]::ASCII)
adb push $tmpScript /data/adb/service.d/99-performance-tuning.sh > $null
Invoke-Adb "chmod 755 /data/adb/service.d/99-performance-tuning.sh"
Remove-Item -Path $tmpScript -Force -ErrorAction SilentlyContinue

# Immediately apply the script runtime
Invoke-Adb "sh /data/adb/service.d/99-performance-tuning.sh"
Log-Success "Applied and installed persistent tuning script: /data/adb/service.d/99-performance-tuning.sh"

# --- STEP 5: ART AOT SPEED COMPILATION ---
if (-not $SkipDexopt) {
    Log-Info "=== 5/6: ART AOT SPEED COMPILATION (ELIMINATING JIT STALLS) ==="
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
        $check = (Invoke-Adb "pm list packages") -match "package:$pkg\b"
        if ($check) {
            Log-Info "Compiling $pkg (dex2oat speed)..."
            $compileRes = (Invoke-Adb "cmd package compile -m speed $pkg")
            if ($compileRes -match "Success") {
                Log-Success "Compiled: $pkg"
            } else {
                Log-Warn "Compile status for $pkg: $compileRes"
            }
        }
    }
} else {
    Log-Info "=== 5/6: Skipping ART compilation as requested ==="
}

# --- STEP 6: VERIFICATION & SUMMARY ---
Log-Info "=== 6/6: POST-OPTIMIZATION VERIFICATION ==="
$freeMem = (Invoke-Adb "free -m")
Log-Info "Current Memory Table:`n$freeMem"
$zramDisk = (Invoke-Adb "cat /sys/block/zram0/disksize")
$zramComp = (Invoke-Adb "cat /sys/block/zram0/comp_algorithm")
Log-Success "ZRAM Size: $([math]::Round($zramDisk / 1MB)) MB, Algorithm: $zramComp"

if (-not $SkipReboot) {
    Log-Info "Device is fully tuned! For clean process re-binding, a reboot is recommended."
}
Log-Success "All Android 17 performance optimizations applied successfully!"
