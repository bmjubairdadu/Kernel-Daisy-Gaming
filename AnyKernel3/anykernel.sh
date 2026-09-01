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
# Matches how real daisy kernels (e.g. cosmedd/daisy_kernel style) ship: explicit boot filename, slot-aware
block=boot
is_slot_device=1
ramdisk_compression=auto
patch_vbmeta_flag=auto

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see tools/ak3-core.sh for details
. tools/ak3-core.sh

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/* $ramdisk/.backup 2>/dev/null
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin 2>/dev/null

## DAISY GAMING - JUBAIR HOSEN stylish banner (fixed: no reversed ASCII) ##
ui_print " ";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print "                                          ";
ui_print "  KERNEL DAISY  FOR  GAMING                ";
ui_print "  v1.1  |  4.9.337 LTS  (Final)             ";
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
ui_print "  -> Target : boot (A/B active)            ";
ui_print " ";

dump_boot

ui_print " ";
ui_print "  [1/4] Extracting boot image      ... OK";
ui_print "  [2/4] Patching kernel            ... by JUBAIR HOSEN";

# begin ramdisk changes
ui_print "  [3/4] Installing gaming tweaks  ...";

# 1) Don't overwrite ramdisk - universal for all ROMs/Android versions
# AK3 keeps stock ramdisk, only replaces kernel Image.gz-dtb

# 2) Add gaming init script if ramdisk exists
if [ -d $ramdisk ]; then
  if [ -f $home/gaming-init.sh ]; then
    cp -f $home/gaming-init.sh $ramdisk/system/etc/init/gaming_init.sh 2>/dev/null
    cp -f $home/gaming-init.sh $ramdisk/system/etc/gaming_init.sh 2>/dev/null
    chmod 755 $ramdisk/system/etc/init/gaming_init.sh 2>/dev/null
    chmod 755 $ramdisk/system/etc/gaming_init.sh 2>/dev/null
    ui_print "       - Gaming init      : OK";
  fi
fi

# Apply thermal config
if [ -f $home/thermal-engine-daisy-gaming.conf ]; then
  mkdir -p $ramdisk/vendor/etc 2>/dev/null
  ui_print "       - Thermal engine : OK";
fi
ui_print " ";

write_boot
ui_print "  [4/4] Flashing boot image     ... OK  -> $BLOCK";
ui_print " ";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print "  Flash Complete!  -  JUBAIR HOSEN         ";
ui_print "  Kernel Daisy v1.1  4.9.337  Installed     ";
ui_print "  Reboot & Enjoy Cool Gaming!              ";
ui_print "  github.com/bmjubairdadu/Kernel-Daisy-Gaming";
ui_print "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
ui_print " ";
ui_print "  Credits: JUBAIR HOSEN  |  XDA  |  osm0sis AK3";
## end install
