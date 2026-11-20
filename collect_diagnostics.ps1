# Redmi Note 6 Pro (tulip) Diagnostic Collector
$ErrorActionPreference = "Continue"
$diagDir = "C:\Users\User\Documents\redmi\diagnostics"
if (-not (Test-Path $diagDir)) {
    New-Item -ItemType Directory -Force -Path $diagDir | Out-Null
}

function Run-AdbCommand {
    param (
        [string]$command,
        [string]$outputFile,
        [string]$description
    )
    Write-Host "[*] Collecting: $description..."
    $cmd = "adb shell `"$command`""
    $output = Invoke-Expression $cmd 2>&1 | Out-String
    $targetPath = Join-Path $diagDir $outputFile
    [System.IO.File]::WriteAllText($targetPath, $output, [System.Text.Encoding]::UTF8)
}

function Run-HostAdb {
    param (
        [string]$arguments,
        [string]$outputFile,
        [string]$description
    )
    Write-Host "[*] Host ADB: $description..."
    $cmd = "adb $arguments"
    $output = Invoke-Expression $cmd 2>&1 | Out-String
    $targetPath = Join-Path $diagDir $outputFile
    [System.IO.File]::WriteAllText($targetPath, $output, [System.Text.Encoding]::UTF8)
}

Write-Host "=== Starting Diagnostic Collection for Redmi Note 6 Pro ==="

# 1. Properties and Host Info
Run-HostAdb "devices -l" "adb_devices.txt" "ADB Devices List"
Run-AdbCommand "getprop" "getprop_all.txt" "All System Properties"

# 2. Kernel, OS and CPU Info
Run-AdbCommand "uname -a; cat /proc/version" "kernel_version.txt" "Kernel Version"
Run-AdbCommand "cat /proc/cpuinfo" "cpuinfo.txt" "CPU Info"
Run-AdbCommand "cat /proc/cmdline" "cmdline.txt" "Kernel Commandline"

# 3. CPU Frequencies and Governors
$cpuScript = @'
echo "=== CPU Online / Present ==="
cat /sys/devices/system/cpu/online
cat /sys/devices/system/cpu/present

echo "=== CPU0 (LITTLE Cluster) ==="
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

echo "=== CPU4 (BIG Cluster) ==="
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_governors
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq

echo "=== Schedulers / EAS ==="
ls -l /sys/devices/system/cpu/cpu0/cpufreq/
ls -l /sys/devices/system/cpu/cpu4/cpufreq/
'@
Run-AdbCommand $cpuScript "cpu_freq_governors.txt" "CPU Frequencies and Governors"

# 4. GPU Information
$gpuScript = @'
echo "=== GPU Clock and Frequencies ==="
cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/available_governors 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage 2>/dev/null
cat /sys/class/kgsl/kgsl-3d0/num_pwrlevels 2>/dev/null
'@
Run-AdbCommand $gpuScript "gpu_info.txt" "GPU Info"

# 5. Memory, ZRAM, SWAP, LMK
$memScript = @'
echo "=== /proc/meminfo ==="
cat /proc/meminfo

echo "=== Swaps ==="
cat /proc/swaps

echo "=== ZRAM ==="
cat /sys/block/zram0/disksize 2>/dev/null
cat /sys/block/zram0/comp_algorithm 2>/dev/null
cat /sys/block/zram0/mm_stat 2>/dev/null

echo "=== VM Tunables ==="
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure
cat /proc/sys/vm/dirty_ratio
cat /proc/sys/vm/dirty_background_ratio
cat /proc/sys/vm/extra_free_kbytes 2>/dev/null

echo "=== LMK ==="
cat /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null
cat /sys/module/lowmemorykiller/parameters/adj 2>/dev/null

echo "=== PSI (Pressure Stall Information) ==="
cat /proc/pressure/memory 2>/dev/null
cat /proc/pressure/cpu 2>/dev/null
cat /proc/pressure/io 2>/dev/null
'@
Run-AdbCommand $memScript "mem_zram_lmk.txt" "Memory, ZRAM and LMK"
Run-AdbCommand "dumpsys meminfo" "dumpsys_meminfo.txt" "Dumpsys Meminfo"

# 6. Storage, I/O Schedulers, eMMC health
$storageScript = @'
echo "=== Storage Filesystems (df -h) ==="
df -h

echo "=== Partitions ==="
cat /proc/partitions

echo "=== Block Schedulers ==="
for f in /sys/block/*/queue/scheduler; do
    echo "$f: $(cat $f)"
done

echo "=== eMMC Device Info ==="
for dev in /sys/block/mmcblk0/device/*; do
    if [ -f "$dev" ]; then
        echo "$(basename $dev): $(cat $dev 2>/dev/null)"
    fi
done
'@
Run-AdbCommand $storageScript "storage_emmc.txt" "Storage and eMMC Status"
Run-AdbCommand "dumpsys diskstats" "dumpsys_diskstats.txt" "Dumpsys Diskstats"

# 7. Battery and Thermal
$battScript = @'
echo "=== Dumpsys Battery ==="
dumpsys battery

echo "=== Power Supply Battery Sysfs ==="
for f in /sys/class/power_supply/battery/*; do
    if [ -f "$f" ]; then
        echo "$(basename $f): $(cat $f 2>/dev/null)"
    fi
done

echo "=== Thermal Zones ==="
for z in /sys/class/thermal/thermal_zone*; do
    if [ -d "$z" ]; then
        type=$(cat $z/type 2>/dev/null)
        temp=$(cat $z/temp 2>/dev/null)
        echo "$(basename $z) [$type]: $temp"
    fi
done
'@
Run-AdbCommand $battScript "battery_thermal.txt" "Battery and Thermal Status"

# 8. Processes, Services and Resource Usage
Run-AdbCommand "ps -A -o USER,PID,PPID,VSZ,RSS,WCHAN,ADDR,NAME" "process_list.txt" "Process List"
Run-AdbCommand "top -b -n 1" "top_snapshot.txt" "Top Snapshot"
Run-AdbCommand "dumpsys activity services" "dumpsys_services.txt" "Running Services"

# 9. Packages and Autostart
Run-AdbCommand "pm list packages -f" "packages_all.txt" "All Packages"
Run-AdbCommand "pm list packages -3" "packages_third_party.txt" "Third-Party Packages"
Run-AdbCommand "pm list packages -d" "packages_disabled.txt" "Disabled Packages"

# 10. Security, SELinux, Root, Bootloader
$secScript = @'
echo "=== SELinux Status ==="
getenforce

echo "=== Root / Magisk / su check ==="
which su 2>/dev/null
which magisk 2>/dev/null
which ksu 2>/dev/null
ls -l /system/xbin/su 2>/dev/null
ls -l /system/bin/su 2>/dev/null
ls -l /sbin/su 2>/dev/null

echo "=== Bootloader and Lock State Props ==="
getprop ro.boot.verifiedbootstate
getprop ro.boot.flash.locked
getprop ro.secure
getprop ro.debuggable
getprop sys.oem_unlock_allowed
getprop ro.boot.bootloader
'@
Run-AdbCommand $secScript "security_bootloader.txt" "Security, Bootloader and Root Status"

# 11. Partition Layout and Mounts
$partScript = @'
echo "=== Mounts ==="
cat /proc/mounts

echo "=== Partition by-name ==="
ls -la /dev/block/bootdevice/by-name/ 2>/dev/null || ls -la /dev/block/platform/*/by-name/ 2>/dev/null

echo "=== AB Update State ==="
getprop ro.build.ab_update
getprop ro.boot.slot_suffix
'@
Run-AdbCommand $partScript "partitions_mounts.txt" "Partition Layout and Mounts"

# 12. Power Management & Doze
Run-AdbCommand "dumpsys deviceidle" "dumpsys_deviceidle.txt" "Device Idle (Doze) State"

Write-Host "=== Diagnostic Collection Complete ==="
