# Collect comprehensive Android 17 baseline diagnostics
$outDir = "C:\Users\User\Documents\redmi\diagnostics\android17_audit"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

Write-Host "[*] Checking ADB connection and root..."
$dev = adb devices | Select-String "device$"
if (-not $dev) {
    Write-Error "No authorized ADB device found!"
    exit 1
}
$id = adb shell "id"
Write-Host "Connected as: $id"

Write-Host "[*] 1/9 Collecting packages..."
adb shell "pm list packages -f -u" > "$outDir\01_packages_all.txt"
adb shell "pm list packages -s -f" > "$outDir\01_packages_system.txt"
adb shell "pm list packages -3 -f" > "$outDir\01_packages_3rdparty.txt"
adb shell "pm list packages -d" > "$outDir\01_packages_disabled.txt"

Write-Host "[*] 2/9 Collecting processes and meminfo..."
adb shell "ps -efZ" > "$outDir\02_ps_efZ.txt"
adb shell "dumpsys meminfo -a" > "$outDir\02_dumpsys_meminfo.txt"
adb shell "cat /proc/meminfo; echo '--- SWAPS ---'; cat /proc/swaps; echo '--- ZRAM MM_STAT ---'; cat /sys/block/zram0/mm_stat; echo '--- ZRAM STAT ---'; cat /sys/block/zram0/stat" > "$outDir\02_proc_meminfo.txt"

Write-Host "[*] 3/9 Collecting pressure and LMKD..."
adb shell "echo '=== PSI MEMORY ==='; cat /proc/pressure/memory; echo '=== PSI CPU ==='; cat /proc/pressure/cpu; echo '=== PSI IO ==='; cat /proc/pressure/io; echo '=== VMSTAT ==='; cat /proc/vmstat; echo '=== ZONEINFO ==='; cat /proc/zoneinfo" > "$outDir\03_pressure_and_zones.txt"
adb shell "dumpsys meminfo --oom" > "$outDir\03_dumpsys_oom.txt"

Write-Host "[*] 4/9 Collecting CPU and thermals..."
adb shell "dumpsys cpuinfo" > "$outDir\04_dumpsys_cpuinfo.txt"
adb shell "dumpsys thermalservice" > "$outDir\04_dumpsys_thermals.txt"
adb shell "
echo '=== CPU FREQUENCIES ==='
for i in 0 1 2 3 4 5 6 7; do
    echo -n \"cpu\$i cur: \"
    cat /sys/devices/system/cpu/cpu\$i/cpufreq/scaling_cur_freq 2>/dev/null
    echo -n \"cpu\$i gov: \"
    cat /sys/devices/system/cpu/cpu\$i/cpufreq/scaling_governor 2>/dev/null
done
echo '=== SCHEDUTIL TUNABLES ==='
cat /sys/devices/system/cpu/cpufreq/policy0/schedutil/* 2>/dev/null
cat /sys/devices/system/cpu/cpufreq/policy4/schedutil/* 2>/dev/null
echo '=== THERMAL ZONES ==='
for tz in /sys/class/thermal/thermal_zone*; do
    if [ -f \"\$tz/type\" ]; then
        echo \"\$(cat \$tz/type): \$(cat \$tz/temp 2>/dev/null)\"
    fi
done
" > "$outDir\04_cpu_and_thermal_details.txt"

Write-Host "[*] 5/9 Collecting GPU and SurfaceFlinger..."
adb shell "
echo '=== GPU KGSL ==='
cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/available_governors 2>/dev/null
" > "$outDir\05_gpu_status.txt"
adb shell "dumpsys SurfaceFlinger" > "$outDir\05_surfaceflinger.txt"
adb shell "dumpsys gfxinfo com.android.systemui framestats" > "$outDir\05_gfxinfo_systemui.txt"
adb shell "dumpsys gfxinfo com.android.launcher3 framestats" > "$outDir\05_gfxinfo_launcher3.txt"

Write-Host "[*] 6/9 Collecting services and background..."
adb shell "service list" > "$outDir\06_service_list.txt"
adb shell "dumpsys activity services" > "$outDir\06_activity_services.txt"
adb shell "dumpsys jobscheduler" > "$outDir\06_jobscheduler.txt"
adb shell "dumpsys alarm" > "$outDir\06_alarm.txt"
adb shell "dumpsys deviceidle" > "$outDir\06_deviceidle.txt"

Write-Host "[*] 7/9 Collecting wakelocks and battery..."
adb shell "dumpsys power" > "$outDir\07_power.txt"
adb shell "dumpsys batterystats" > "$outDir\07_batterystats.txt"

Write-Host "[*] 8/9 Collecting binder and ART dexopt..."
adb shell "cat /dev/binderfs/binder_logs/stats 2>/dev/null || cat /proc/binder/stats 2>/dev/null" > "$outDir\08_binder_stats.txt"
adb shell "dumpsys activity binder-proxies" > "$outDir\08_binder_proxies.txt"
adb shell "dumpsys package dexopt" > "$outDir\08_package_dexopt.txt"

Write-Host "[*] 9/9 Collecting stability logs..."
adb shell "ls -la /data/anr/" > "$outDir\09_anr_list.txt"
adb shell "logcat -d -b crash -t 150" > "$outDir\09_logcat_crash.txt"
adb shell "logcat -d -b system -t 300 *:W" > "$outDir\09_logcat_system_warn.txt"
adb shell "dmesg | tail -n 250" > "$outDir\09_dmesg_tail.txt"

Write-Host "[*] Aggregating core metrics into android17_baseline.txt..."
$baselineFile = "C:\Users\User\Documents\redmi\android17_baseline.txt"
$summary = @()
$summary += "================================================================================"
$summary += "REDMI NOTE 6 PRO (TULIP) - ANDROID 17 BASELINE DIAGNOSTIC AUDIT"
$summary += "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summary += "OS: Android 17 (Project Infinity-X 4.2 bouquet)"
$summary += "Kernel: $(adb shell 'uname -a')"
$summary += "SELinux: $(adb shell 'getenforce')"
$summary += "ADB UID: $(adb shell 'id')"
$summary += "================================================================================"
$summary += ""
$summary += "--- 1. SYSTEM IDENTITY ---"
$summary += "ro.product.model: $(adb shell 'getprop ro.product.model')"
$summary += "ro.product.device: $(adb shell 'getprop ro.product.device')"
$summary += "ro.build.display.id: $(adb shell 'getprop ro.build.display.id')"
$summary += "ro.build.date: $(adb shell 'getprop ro.build.date')"
$summary += ""
$summary += "--- 2. MEMORY AND ZRAM METRICS ---"
$summary += (adb shell "free -m")
$summary += ""
$summary += "ZRAM mm_stat (orig_data_size, compr_data_size, mem_used_total, zero_pages, max_used):"
$summary += (adb shell "cat /sys/block/zram0/mm_stat 2>/dev/null")
$summary += "ZRAM comp_algorithm: $(adb shell 'cat /sys/block/zram0/comp_algorithm 2>/dev/null')"
$summary += "ZRAM disksize: $(adb shell 'cat /sys/block/zram0/disksize 2>/dev/null')"
$summary += ""
$summary += "--- 3. VIRTUAL MEMORY (VM) TUNABLES ---"
$summary += "vm.swappiness: $(adb shell 'cat /proc/sys/vm/swappiness')"
$summary += "vm.vfs_cache_pressure: $(adb shell 'cat /proc/sys/vm/vfs_cache_pressure')"
$summary += "vm.page-cluster: $(adb shell 'cat /proc/sys/vm/page-cluster')"
$summary += "vm.dirty_ratio: $(adb shell 'cat /proc/sys/vm/dirty_ratio')"
$summary += "vm.dirty_background_ratio: $(adb shell 'cat /proc/sys/vm/dirty_background_ratio')"
$summary += "vm.stat_interval: $(adb shell 'cat /proc/sys/vm/stat_interval')"
$summary += ""
$summary += "--- 4. PRESSURE STALL INFORMATION (PSI) ---"
$summary += "Memory Pressure:"
$summary += (adb shell "cat /proc/pressure/memory")
$summary += "CPU Pressure:"
$summary += (adb shell "cat /proc/pressure/cpu")
$summary += "IO Pressure:"
$summary += (adb shell "cat /proc/pressure/io")
$summary += ""
$summary += "--- 5. STORAGE I/O METRICS ---"
$summary += "mmcblk0 scheduler: $(adb shell 'cat /sys/block/mmcblk0/queue/scheduler 2>/dev/null')"
$summary += "mmcblk0 read_ahead_kb: $(adb shell 'cat /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null')"
$summary += ""
$summary += "--- 6. TOP 25 RAM CONSUMERS (PSS) ---"
$summary += (adb shell "dumpsys meminfo | head -n 45")
$summary += ""
$summary += "--- 7. CPU UTILIZATION ---"
$summary += (adb shell "dumpsys cpuinfo | head -n 35")
$summary += ""
$summary += "--- 8. GRAPHICS & FRAME PACING ---"
$summary += "SystemUI 50th/90th/95th GPU percentile:"
$summary += (adb shell "dumpsys gfxinfo com.android.systemui | grep -E 'percentile|Janky|Total frames|Number'")
$summary += "Launcher3 50th/90th/95th GPU percentile:"
$summary += (adb shell "dumpsys gfxinfo com.android.launcher3 | grep -E 'percentile|Janky|Total frames|Number'")
$summary += ""
$summary += "--- 9. BATTERY & THERMALS ---"
$summary += (adb shell "dumpsys battery")
$summary += "================================================================================"

$summary | Set-Content -Path $baselineFile -Encoding UTF8
Write-Host "[+] Stage 1 Audit Complete! Saved to: $baselineFile"
