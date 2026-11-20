#!/system/bin/sh
# Redmi Note 6 Pro (tulip) Diagnostic Probe Script

echo "================================================================"
echo "REDMI NOTE 6 PRO (TULIP) HARDWARE & SYSTEM PROBE"
echo "DATE: $(date)"
echo "================================================================"

echo ""
echo "--- 1. KERNEL & OS ---"
echo "UNAME: $(uname -a)"
echo "VERSION: $(cat /proc/version)"
echo "CMDLINE: $(cat /proc/cmdline)"
echo "SELINUX: $(getenforce 2>/dev/null)"
echo "ROOT/SU: $(which su 2>/dev/null || echo 'none')"
echo "MAGISK: $(which magisk 2>/dev/null || echo 'none')"
echo "KSU: $(which ksu 2>/dev/null || echo 'none')"

echo ""
echo "--- 2. CPU CORES & FREQUENCIES ---"
echo "Online cores: $(cat /sys/devices/system/cpu/online 2>/dev/null)"
echo "Present cores: $(cat /sys/devices/system/cpu/present 2>/dev/null)"
echo "Possible cores: $(cat /sys/devices/system/cpu/possible 2>/dev/null)"

echo ""
echo "[LITTLE Cluster: cpu0..cpu3]"
echo "Available governors: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)"
echo "Current governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
echo "Available frequencies: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies 2>/dev/null)"
echo "Min freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 2>/dev/null)"
echo "Max freq: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 2>/dev/null)"
echo "Current freq cpu0: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null)"

echo ""
echo "[BIG Cluster: cpu4..cpu7]"
echo "Available governors: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_governors 2>/dev/null)"
echo "Current governor: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor 2>/dev/null)"
echo "Available frequencies: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_available_frequencies 2>/dev/null)"
echo "Min freq: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 2>/dev/null)"
echo "Max freq: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 2>/dev/null)"
echo "Current freq cpu4: $(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq 2>/dev/null)"

echo ""
echo "--- 3. GPU (ADRENO 509 / KGSL) ---"
echo "GPU devfreq governors: $(cat /sys/class/kgsl/kgsl-3d0/devfreq/available_governors 2>/dev/null)"
echo "GPU current governor: $(cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null)"
echo "GPU available freqs: $(cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies 2>/dev/null || cat /sys/class/kgsl/kgsl-3d0/devfreq/available_frequencies 2>/dev/null)"
echo "GPU current freq: $(cat /sys/class/kgsl/kgsl-3d0/gpuclk 2>/dev/null || cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null)"
echo "GPU busy percentage: $(cat /sys/class/kgsl/kgsl-3d0/gpu_busy_percentage 2>/dev/null)"
echo "GPU num pwrlevels: $(cat /sys/class/kgsl/kgsl-3d0/num_pwrlevels 2>/dev/null)"
echo "GPU min clock: $(cat /sys/class/kgsl/kgsl-3d0/min_clock_mhz 2>/dev/null)"
echo "GPU max clock: $(cat /sys/class/kgsl/kgsl-3d0/max_clock_mhz 2>/dev/null)"

echo ""
echo "--- 4. RAM, ZRAM, SWAP & VIRTUAL MEMORY ---"
cat /proc/meminfo
echo ""
echo "Swaps:"
cat /proc/swaps
echo ""
echo "ZRAM disksize: $(cat /sys/block/zram0/disksize 2>/dev/null)"
echo "ZRAM comp_algorithm: $(cat /sys/block/zram0/comp_algorithm 2>/dev/null)"
echo "ZRAM mm_stat: $(cat /sys/block/zram0/mm_stat 2>/dev/null)"
echo "ZRAM max_comp_streams: $(cat /sys/block/zram0/max_comp_streams 2>/dev/null)"

echo ""
echo "VM Tunables:"
echo "swappiness: $(cat /proc/sys/vm/swappiness 2>/dev/null)"
echo "vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null)"
echo "dirty_ratio: $(cat /proc/sys/vm/dirty_ratio 2>/dev/null)"
echo "dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio 2>/dev/null)"
echo "page-cluster: $(cat /proc/sys/vm/page-cluster 2>/dev/null)"
echo "extra_free_kbytes: $(cat /proc/sys/vm/extra_free_kbytes 2>/dev/null)"
echo "min_free_kbytes: $(cat /proc/sys/vm/min_free_kbytes 2>/dev/null)"

echo ""
echo "LMK parameters (if sysfs module exists):"
echo "minfree: $(cat /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null || echo 'not using in-kernel LMK / using userspace lmkd')"
echo "adj: $(cat /sys/module/lowmemorykiller/parameters/adj 2>/dev/null)"

echo ""
echo "PSI (Pressure Stall Information):"
echo "Memory PSI: $(cat /proc/pressure/memory 2>/dev/null || echo 'PSI memory not enabled')"
echo "CPU PSI: $(cat /proc/pressure/cpu 2>/dev/null || echo 'PSI cpu not enabled')"
echo "IO PSI: $(cat /proc/pressure/io 2>/dev/null || echo 'PSI io not enabled')"

echo ""
echo "--- 5. STORAGE & I/O ---"
echo "Filesystem mounts (df -h):"
df -h
echo ""
echo "Block schedulers:"
for d in /sys/block/mmcblk0 /sys/block/mmcblk1 /sys/block/dm-* /sys/block/sda; do
    if [ -f "$d/queue/scheduler" ]; then
        echo "$d: $(cat $d/queue/scheduler 2>/dev/null)"
        echo "$d read_ahead_kb: $(cat $d/queue/read_ahead_kb 2>/dev/null)"
        echo "$d nr_requests: $(cat $d/queue/nr_requests 2>/dev/null)"
    fi
done

echo ""
echo "eMMC CID / Health info:"
for p in /sys/block/mmcblk0/device/*; do
    if [ -f "$p" ]; then
        echo "$(basename $p): $(cat $p 2>/dev/null)"
    fi
done

echo ""
echo "--- 6. BATTERY & CHARGING ---"
for p in /sys/class/power_supply/battery/*; do
    if [ -f "$p" ]; then
        echo "$(basename $p): $(cat $p 2>/dev/null)"
    fi
done

echo ""
echo "--- 7. THERMAL ZONES ---"
for tz in /sys/class/thermal/thermal_zone*; do
    if [ -d "$tz" ]; then
        type=$(cat $tz/type 2>/dev/null)
        temp=$(cat $tz/temp 2>/dev/null)
        echo "$(basename $tz) [$type]: $temp"
    fi
done

echo ""
echo "--- 8. DISPLAY & TOUCH ---"
echo "Display panel: $(cat /sys/class/graphics/fb0/msm_fb_panel_info 2>/dev/null || cat /sys/devices/virtual/graphics/fb0/msm_fb_panel_info 2>/dev/null)"
echo "Display modes: $(cat /sys/class/graphics/fb0/modes 2>/dev/null)"
echo "FPS / Vsync: $(cat /sys/class/graphics/fb0/measured_fps 2>/dev/null || cat /sys/class/drm/card0/sde-crtc-0/measured_fps 2>/dev/null)"

echo ""
echo "--- 9. PARTITIONS & MOUNT DETAILS ---"
echo "Mounts (/proc/mounts):"
cat /proc/mounts

echo ""
echo "by-name partitions:"
ls -la /dev/block/bootdevice/by-name/ 2>/dev/null || ls -la /dev/block/platform/soc/*/by-name/ 2>/dev/null

echo "================================================================"
echo "PROBE COMPLETE"
echo "================================================================"
