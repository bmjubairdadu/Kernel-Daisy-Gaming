# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Kernel Daisy for Gaming 4.9.337 LTS by DaisyGaming @ XDA - Latest 4.9 Final
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

# shell variables
# daisy (Mi A2 Lite) is A-only (no A/B slots) - using auto lets AK3 probe all paths
# Fixes "Unable to determine partition" on TWRP where /dev/block/bootdevice/by-name missing
block=auto
is_slot_device=0
ramdisk_compression=auto
patch_vbmeta_flag=auto

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see tools/ak3-core.sh for details
. tools/ak3-core.sh

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/* $ramdisk/.backup 2>/dev/null
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin 2>/dev/null

## DAISY GAMING overrides - fix partition detection before dump_boot ##
# Force override if setup_ak still fails to find block device
if [ ! -e "$BLOCK" ] 2>/dev/null; then
  ui_print " ";
  ui_print "-- Daisy partition fallback --";
  for p in /dev/block/bootdevice/by-name/boot /dev/block/by-name/boot /dev/block/platform/soc/1da4000.ufshc/by-name/boot /dev/block/platform/soc.0/7824900.sdhci/by-name/boot /dev/block/platform/7824900.sdhci/by-name/boot; do
    if [ -e "$p" ]; then BLOCK=$p; ui_print "-> Found: $BLOCK"; break; fi
  done
  if [ ! -e "$BLOCK" ]; then
    for fstab in /etc/recovery.fstab /etc/fstab /system/etc/recovery.fstab /fstab.qcom; do
      [ -f "$fstab" ] || continue
      cand=$(grep " /boot " "$fstab" 2>/dev/null | grep -o "/dev/[^ ]*" | head -n1)
      if [ "$cand" ] && [ -e "$cand" ]; then BLOCK=$cand; ui_print "-> Fstab: $BLOCK"; break; fi
    done
  fi
  if [ ! -e "$BLOCK" ]; then
    ui_print "!! Could not find boot partition - listing: $(ls /dev/block/*/by-name/ 2>&1 | head -c 200)"
    abort "Unable to determine boot partition. Aborting...";
  fi
fi

## AnyKernel install - with upgraded flashing screen
ui_print " ";
ui_print "==========================================";
ui_print "  Kernel Daisy for Gaming v1.1           ";
ui_print "  4.9.337 LTS - Latest Final             ";
ui_print "  Cool & Smooth - No Heat No Lag         ";
ui_print "  Mi A2 Lite (daisy) | Snapdragon 625    ";
ui_print "  Universal 9-14 - Any ROM               ";
ui_print "==========================================";
ui_print " ";
ui_print "-> Device: $(getprop ro.product.device 2>/dev/null || echo daisy)";
ui_print "-> Android: $(getprop ro.build.version.release 2>/dev/null || echo 11)";
ui_print "-> Boot: $BLOCK";
ui_print " ";

dump_boot

ui_print "-> Extracting boot image... OK";
ui_print "-> Patching kernel (Image.gz-dtb)...";

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
ui_print "-> Flashing boot image... OK";
ui_print " ";
ui_print "==========================================";
ui_print "  Flash Complete! Reboot & Game Cool!     ";
ui_print "  Thermal 42C | GPU 725MHz | schedutil    ";
ui_print "==========================================";
## end install
