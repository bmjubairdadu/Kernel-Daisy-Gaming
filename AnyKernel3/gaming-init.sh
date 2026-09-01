#!/system/bin/sh
# Kernel Daisy for Gaming - Post-boot tweaks (runs on every boot via init)
# Applied automatically by AnyKernel3 + init.d / system/etc/init

# Wait for boot complete
while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 2; done
sleep 5

# === CPU ===
# Schedutil gaming tuning
echo schedutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null
echo schedutil > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor 2>/dev/null
echo 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us 2>/dev/null
echo 20000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpufreq/schedutil/iowait_boost_enabled 2>/dev/null
echo 1 > /sys/devices/system/cpu/cpufreq/schedutil/hispeed_load 2>/dev/null

# Input boost - instant 1.4GHz on touch
echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled 2>/dev/null
echo 0:1400000 1:1400000 2:1400000 3:1400000 4:1400000 5:1400000 6:1400000 7:1400000 > /sys/module/cpu_boost/parameters/input_boost_freq 2>/dev/null
echo 2000 > /sys/module/cpu_boost/parameters/input_boost_ms 2>/dev/null
echo 1 > /sys/module/cpu_boost/parameters/sched_boost_on_input 2>/dev/null

# === GPU ===
# Adreno 506 - default 650MHz, allow OC to 725 via app
echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
echo 0 > /sys/class/kgsl/kgsl-3d0/min_pwrlevel 2>/dev/null
# thermal mitigation stays active
echo 1 > /sys/class/kgsl/kgsl-3d0/thermal 2>/dev/null

# === I/O ===
echo maple > /sys/block/mmcblk0/queue/scheduler 2>/dev/null
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb 2>/dev/null
echo 0 > /sys/block/mmcblk0/queue/iostats 2>/dev/null
echo 0 > /sys/block/mmcblk0/queue/add_random 2>/dev/null

# === Memory ===
echo 0 > /proc/sys/vm/swappiness 2>/dev/null
echo 10 > /proc/sys/vm/dirty_ratio 2>/dev/null
echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo 1 > /proc/sys/vm/compact_memory 2>/dev/null

# === Thermal - rely on thermal-engine-daisy-gaming.conf ===
# Disable stock throttling, let custom config handle
stop thermal-engine 2>/dev/null
start thermal-engine 2>/dev/null

# === Network - low ping for gaming ===
echo westwood > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
echo 1 > /proc/sys/net/ipv4/tcp_low_latency 2>/dev/null

# === Misc ===
echo 0 > /sys/module/sync/parameters/fsync_enabled 2>/dev/null # optional fsync off
echo N > /sys/kernel/debug/debug_enabled 2>/dev/null

# KCAL vivid
echo "256 256 256" > /sys/devices/platform/kcal_ctrl.0/kcal 2>/dev/null
echo 255 > /sys/devices/platform/kcal_ctrl.0/kcal_sat 2>/dev/null

# Vibration
echo 80 > /sys/class/timed_output/vibrator/vtg_level 2>/dev/null

# Log
echo "[Kernel Daisy Gaming] Tweaks applied $(date)" > /dev/kmsg 2>/dev/null
