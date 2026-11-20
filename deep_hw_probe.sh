#!/system/bin/sh
echo "=== DISPLAY DSI TIMINGS ==="
dmesg | grep -iE 'nt36672a|shenchao|dsi_panel|fps|pclk|clk_rate|porch' | head -n 30

echo ""
echo "=== GPU KGSL SYSFS ==="
ls -l /sys/class/kgsl/kgsl-3d0/
for f in gpu_available_frequencies devfreq/available_frequencies devfreq/available_governors devfreq/governor devfreq/cur_freq gpuclk num_pwrlevels min_clock_mhz max_clock_mhz thermal_pwrlevel default_pwrlevel idle_timer; do
    if [ -f "/sys/class/kgsl/kgsl-3d0/$f" ]; then
        echo "$f: $(cat /sys/class/kgsl/kgsl-3d0/$f)"
    fi
done

echo ""
echo "=== GPU PWRLEVELS ==="
for d in /sys/class/kgsl/kgsl-3d0/pwrlevel_*; do
    if [ -d "$d" ]; then
        echo "[$d]: gpuclk=$(cat $d/gpuclk 2>/dev/null)"
    fi
done

echo ""
echo "=== TOUCH DIGITIZER ==="
dmesg | grep -iE 'touch|goodix|focaltech|ft5435|gt9xx|synaptics|input' | head -n 30

echo ""
echo "=== CPU FREQUENCY SCALING & LIMITS ==="
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_min_freq
cat /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq

echo ""
echo "=== THERMAL MITIGATION / CORE CONTROL ==="
for f in /sys/module/msm_thermal/parameters/*; do
    if [ -f "$f" ]; then
        echo "$(basename $f): $(cat $f 2>/dev/null)"
    fi
done

echo ""
echo "=== BINDER STATS ==="
cat /sys/kernel/debug/binder/failed_transaction_log 2>/dev/null | head -n 20
cat /sys/kernel/debug/binder/stats 2>/dev/null | head -n 25

echo ""
echo "=== LOGCAT ANR / CRASH CHECK ==="
logcat -b crash -d | head -n 30
