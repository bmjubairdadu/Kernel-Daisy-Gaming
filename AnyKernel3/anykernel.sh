# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Kernel Daisy for Gaming by DaisyGaming @ XDA
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
supported.patchlevels=2019-09-01 - 2099-12-31
supported.vendorpatchlevels=2019-09-01 - 2099-12-31
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot
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

## AnyKernel install
dump_boot

# begin ramdisk changes

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
  fi
fi

# Apply thermal config to vendor if exists (systemless)
if [ -f $home/thermal-engine-daisy-gaming.conf ]; then
  # patch vendor thermal - will be installed via module/post-fs
  mkdir -p $ramdisk/vendor/etc 2>/dev/null
fi

write_boot
## end install
