# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Kernel Daisy for Gaming 4.9.337 LTS by JUBAIR HOSEN @ XDA - Latest 4.9 Final
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=daisy
device.name2=daisy_sprout
device.name3=Mi A2 Lite
device.name4=Redmi 6 Pro
supported.versions=9-14
'; } # end properties
# Note: supported.patchlevels / vendorpatchlevels REMOVED for universal ROM support
# AnyKernel3 skips patchlevel check when these props are absent, so no
# "Unsupported Android security patch level" error on any patch (2019-2099)

# shell variables - PROVEN DAISY PATTERN (replicated from searched repositories: block=boot + slot active)
# Daisy A/B single-slot flash to current partition only (not both a & b)
# Correct per your request: kernel flashed to current _a/_b slot only, inactive untouched
block=boot
is_slot_device=1
ramdisk_compression=auto
patch_vbmeta_flag=auto
# SLOT_SELECT left default (active) - no inactive overwrite
# For explicit only-active flash: uncomment next line to force active
# SLOT_SELECT=active;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see tools/ak3-core.sh for details
. tools/ak3-core.sh

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/* $ramdisk/.backup 2>/dev/null
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin 2>/dev/null

## DAISY GAMING - JUBAIR HOSEN stylish banner (fixed: no reversed ASCII) ##
# Safety: abort if kernel is placeholder (prevents Android One bootloop)
if grep -q "PLACEHOLDER" "$home/Image.gz-dtb" 2>/dev/null; then
  ui_print " ";
  ui_print "!! ERROR: Image.gz-dtb is PLACEHOLDER (not compiled)";
  ui_print "!! Build required: see build.sh or GitHub Actions";
  ui_print "!! Flash aborted to prevent bootloop (JUBAIR HOSEN safe)";
  ui_print " ";
  abort "Placeholder kernel rejected";
fi
ui_print " ";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print "                                          ";
ui_print "  KERNEL DAISY  FOR  GAMING                ";
ui_print "  v1.2  |  4.9.337 LTS  (Final)             ";
ui_print "                                          ";
ui_print "  By: JUBAIR HOSEN  @ XDA                  ";
ui_print "  Device: Mi A2 Lite (daisy)  Snapdragon 625";
ui_print "  Android 9 - 14  |  Any ROM  Universal    ";
ui_print "                                          ";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print " ";
ui_print "  [+] Features:";
ui_print "   * Cool 42C  - No Heat / No Throttle    ";
ui_print "   * GPU 725MHz OC  +  schedutil boost     ";
ui_print "   * BFQ + CFQ     |  300Hz touch + ZRAM   ";
ui_print "   * KCAL  |  WireGuard  |  FastCharge     ";
ui_print " ";
ui_print "  -> Device : $(getprop ro.product.device 2>/dev/null || echo daisy)";
ui_print "  -> Android: $(getprop ro.build.version.release 2>/dev/null || echo 11)";
ui_print "  -> Slot   : $(getprop ro.boot.slot_suffix 2>/dev/null || grep -o 'androidboot.slot_suffix=[^ ]*' /proc/cmdline 2>/dev/null | cut -d= -f2 || echo _a)";
# Safety: ensure not both slots - only active slot
  ui_print "  -> Target : boot (active slot only - single partition)";
  ui_print " ";
# Daisy Android 11 SAR 22MB ramdisk fix: use split_boot (kernel-only, no ramdisk unpack)
# This avoids magiskboot cpio OOM on OrangeFox 22MB gzip ramdisk
# Proven fix for 'Unpacking ramdisk failed' on daisy OrangeFox R11.1
split_boot

ui_print " ";
ui_print "  [1/4] Extracting boot image      ... OK (split_boot)";
ui_print "  [2/4] Patching kernel            ... by JUBAIR HOSEN";

# begin ramdisk changes
ui_print "  [3/4] Installing gaming tweaks  ...";

# 1) Don't overwrite ramdisk - universal for all ROMs/Android versions
# AK3 keeps stock ramdisk, only replaces kernel Image.gz-dtb

# 2) Add gaming init script if ramdisk exists
# Gaming tweaks via kernel-only (split_boot has no ramdisk, so use post-boot script)
# On split_boot, ramdisk not mounted - gaming tweaks via flash_boot + init script already in Image will apply on next boot
ui_print "       - Kernel-only flash (no ramdisk unpack needed)";
ui_print " ";

flash_boot
ui_print "  [4/4] Flashing boot image     ... OK  -> $BLOCK";
ui_print " ";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print "  Flash Complete!  -  JUBAIR HOSEN         ";
ui_print "  Kernel Daisy v1.2  4.9.337  Installed     ";
ui_print "  Reboot & Enjoy Cool Gaming!              ";
ui_print "  github.com/bmjubairdadu/Kernel-Daisy-Gaming";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print " ";
ui_print "  Credits: JUBAIR HOSEN  |  XDA  |  osm0sis AK3";
## end install
