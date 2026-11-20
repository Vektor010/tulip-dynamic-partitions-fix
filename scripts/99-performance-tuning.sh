#!/system/bin/sh
# Redmi Note 6 Pro (Tulip) - 4GB RAM & Snapdragon 636 Performance Revival
# Applied on late boot via KernelSU / BakaSU service.d

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done
sleep 3

# 1. Virtual Memory (VM) Optimization for 4GB RAM
echo 100 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 0 > /proc/sys/vm/page-cluster
echo 10 > /proc/sys/vm/dirty_ratio
echo 5 > /proc/sys/vm/dirty_background_ratio
echo 20 > /proc/sys/vm/stat_interval

# 2. ZRAM Optimization (lz4 + 2.5GB)
swapoff /dev/block/zram0 2>/dev/null
echo 1 > /sys/block/zram0/reset 2>/dev/null
echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
echo 2684354560 > /sys/block/zram0/disksize 2>/dev/null
mkswap /dev/block/zram0 2>/dev/null
swapon /dev/block/zram0 -p 32758 2>/dev/null

# 4. Storage I/O Optimization (eMMC 5.1)
echo mq-deadline > /sys/block/mmcblk0/queue/scheduler 2>/dev/null
echo 512 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
echo 0 > /sys/block/mmcblk0/queue/iostats 2>/dev/null

# 5. UI Latency & GPU Optimization
settings put global disable_window_blurs 1
settings put global window_animation_scale 0.5
settings put global transition_animation_scale 0.5
settings put global animator_duration_scale 0.5
settings put secure long_press_timeout 250
device_config put activity_manager_native_boot use_freezer true
