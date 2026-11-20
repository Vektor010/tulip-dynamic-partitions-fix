#!/system/bin/sh
# Low-level root read-only diagnostic probe
echo "=== CMDLINE ==="
cat /proc/cmdline
echo ""
echo "=== SWAPS ==="
cat /proc/swaps
echo ""
echo "=== ZRAM SYSFS ==="
echo "disksize: $(cat /sys/block/zram0/disksize)"
echo "comp_algorithm: $(cat /sys/block/zram0/comp_algorithm)"
echo "mm_stat: $(cat /sys/block/zram0/mm_stat)"
echo "max_comp_streams: $(cat /sys/block/zram0/max_comp_streams)"
echo ""
echo "=== VM TUNABLES ==="
echo "swappiness: $(cat /proc/sys/vm/swappiness)"
echo "vfs_cache_pressure: $(cat /proc/sys/vm/vfs_cache_pressure)"
echo "dirty_ratio: $(cat /proc/sys/vm/dirty_ratio)"
echo "dirty_background_ratio: $(cat /proc/sys/vm/dirty_background_ratio)"
echo "page-cluster: $(cat /proc/sys/vm/page-cluster)"
echo "extra_free_kbytes: $(cat /proc/sys/vm/extra_free_kbytes 2>/dev/null)"
echo "min_free_kbytes: $(cat /proc/sys/vm/min_free_kbytes)"
echo ""
echo "=== EMMC HEALTH & CID ==="
for f in cid csd date enh_alloc_size erase_size fwrev hwrev manfid name oemid prv serial_number type life_time pre_eol_info rev; do
    if [ -f "/sys/block/mmcblk0/device/$f" ]; then
        echo "$f: $(cat /sys/block/mmcblk0/device/$f 2>/dev/null)"
    fi
done
echo ""
echo "=== BLOCK SCHEDULERS ==="
for d in /sys/block/mmcblk0 /sys/block/mmcblk0boot0 /sys/block/dm-* /sys/block/zram0; do
    if [ -f "$d/queue/scheduler" ]; then
        echo "$d: $(cat $d/queue/scheduler 2>/dev/null)"
        echo "$d read_ahead_kb: $(cat $d/queue/read_ahead_kb 2>/dev/null)"
    fi
done
echo ""
echo "=== MAGISK MODULES ==="
ls -la /data/adb/modules 2>/dev/null
echo ""
echo "=== TOUCH & DISPLAY PANEL ==="
dmesg | grep -iE 'panel|touch|dsi|mdss|focaltech|goodix|synaptics|novatek|tianma|shenchao|ebbg' | head -n 30
echo ""
echo "=== RECOVERY LOG / PARTITION ==="
ls -l /dev/block/bootdevice/by-name/recovery
