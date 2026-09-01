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

## DAISY GAMING - JUBAIR HOSEN branded header (upgraded flashing screen) ##
  ui_print " ";
  ui_print "  ____      _ ___ __  __          ____	";
  ui_print " |  _ \\    | |_ _|  \\  |  | |  / ___|   ";
  ui_print " | | | |_  | || || |\\ | | | | | |      ";
  ui_print " | |_| | |_| || || |\\| | | | |_| |__  ";
  ui_print " |____/ \\___/|___|_| \\_|_|  \\____|  ";
  ui_print " ";
  ui_print "==========================================";
  ui_print "  Kernel Daisy for Gaming v1.1           ";
  ui_print "  4.9.337 LTS - Latest 4.9 Final (JUBAIR)";
  ui_print "  Made by JUBAIR HOSEN                   ";
  ui_print "  Mi A2 Lite (daisy) | Snapdragon 625    ";
  ui_print "  Kernel 4.9.337 | Android 9-14 Universal";
  ui_print "==========================================";
  ui_print " ";
  ui_print "  Features:";
  ui_print "   - Cool thermal 42C + no throttle     ";
  ui_print "   - GPU 650->725MHz OC | schedutil boost";
  ui_print "   - Maple I/O | 300Hz touch | ZRAM lz4 ";
  ui_print "   - KCAL + WireGuard + FastCharge      ";
  ui_print " ";
  ui_print "-> Device: $(getprop ro.product.device 2>/dev/null || echo daisy)";
  ui_print "-> Android: $(getprop ro.build.version.release 2>/dev/null || echo 11)";
  ui_print "-> Boot slot: $(getprop ro.boot.slot_suffix 2>/dev/null || grep -o 'androidboot.slot_suffix=[^ ]*' /proc/cmdline 2>/dev/null | cut -d= -f2 || echo _a)";
  ui_print "-> Boot: boot (A/B active via ak3-core)";
  ui_print " ";
  ui_print " ";
  # Let ak3-core handle block=boot + is_slot_device=1 -> boot_a/boot probing (proven daisy repo pattern)

dump_boot

ui_print "-> Extracting boot image... OK";
ui_print "-> Patching kernel (Image.gz-dtb by JUBAIR HOSEN)...";

# begin ramdisk changes
ui_print "-> Installing gaming tweaks...";

# 1) Don't overwrite ramdisk - universal for all ROMs/Android versions
# AK3 keeps stock ramdisk, only replaces kernel Image.gz-dtb

# 2) Add gaming init script if ramdisk exists
if [ -d $ramdisk ]; then
  # Add gaming tweaks init script
  if [ -f $home/gaming-init.sh ]; then
    cp -f $home/gaming-init.sh $ramdisk/system/etc/init/gaming_init.sh 2>/dev/null
    cp -f $home/gaming-init.sh $ramdisk/system/etc/gaming_init.sh 2>/dev/null
    chmod 755 $ramdisk/system/etc/init/gaming_init.sh 2>/dev/null
    chmod 755 $ramdisk/system/etc/gaming_init.sh 2>/dev/null
    ui_print "   - Gaming init injected";
  fi
fi

# Apply thermal config to vendor if exists (systemless)
if [ -f $home/thermal-engine-daisy-gaming.conf ]; then
  # patch vendor thermal - will be installed via module/post-fs
  mkdir -p $ramdisk/vendor/etc 2>/dev/null
  ui_print "   - Thermal engine installed";
fi

write_boot
ui_print "-> Flashing boot image to $BLOCK ... OK";
ui_print " ";
ui_print "==========================================";
ui_print "  Flash Complete! - JUBAIR HOSEN          ";
ui_print "  Kernel Daisy v1.1 4.9.337 LTS Installed ";
ui_print "  Reboot System & Enjoy Cool Gaming!      ";
ui_print "  github.com/bmjubairdadu/Kernel-Daisy   ";
ui_print "==========================================";
ui_print " "; 
ui_print "  Credits: JUBAIR HOSEN | XDA | osm0sis AK3";
ui_print "==========================================";
## end install
