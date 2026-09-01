# Installation Guide - Kernel Daisy for Gaming

## Prerequisites
- **Device:** Xiaomi Mi A2 Lite (`daisy`) ONLY - check with: `getprop ro.product.device` should be `daisy`
- **Bootloader:** Unlocked ( `fastboot oem unlock` )
- **Recovery:** TWRP 3.5+ or OrangeFox for daisy
- **ROM:** Any Android 9 / 10 / 11 / 12 / 13 / 14 - Stock or Custom (AOSP/Lineage/PE/EvoX etc.)
- **Android version:** Android 11 primary, but AnyKernel3 makes it universal

> ⚠️ **DO NOT FLASH ON Mi A2 (jasmine_sprout)** - different device, will brick!

---

## Method 1: Flash via Recovery (Recommended)

1. **Download** `Kernel-Daisy-Gaming-v1.0-AnyKernel3.zip` from Releases

2. **Backup** (very important):
   - Reboot to Recovery (Power + Vol Up)
   - TWRP → Backup → Select `Boot` → Swipe
   - Copy backup to PC

3. **Flash**:
   - TWRP → Install → Select zip → Swipe to confirm
   - Wipe Cache/Dalvik (optional but recommended)
   - Reboot System

4. **Verify**:
   - Settings → System → About phone → Kernel version should show `daisy-gaming` and `4.9.xxx-gaming`
   - Or via terminal: `uname -r`

---

## Method 2: Flash via Fastboot (if you have boot.img)

```bash
# Extract boot.img from zip (if provided) or use AK3's Image.gz-dtb
fastboot flash boot boot.img
fastboot reboot
```

But using recovery zip is safer (AK3 patches existing boot, keeps your ROM's ramdisk).

---

## Post-Install Tuning (Get Max Cool & Performance)

### Recommended App: Franco Kernel Manager / SmartPack / EXKM

| Setting | Gaming (Performance) | Cool (Battery) |
|---------|---------------------|----------------|
| CPU Governor | `schedutil` | `schedutil` |
| CPU Max | 1.8 GHz (all 8 cores) | 1.6 GHz |
| Input Boost | 1400 MHz / 2000ms | 1200 MHz / 1500ms |
| GPU Max | 725 MHz (OC) | 650 MHz (stock) |
| GPU Governor | performance | msm-adreno-tz |
| I/O Scheduler | maple | maple |
| Read Ahead | 1024 KB | 512 KB |
| Thermal | Use included config | Use included config |

### In Game:
- Close background apps, enable Game Mode if ROM has it
- Our kernel auto-applies: `thermal-engine-daisy-gaming.conf` → 42°C limit

---

## Restore Stock Kernel

If you face any issue:

1. Restore TWRP Backup: TWRP → Restore → Boot
2. Or dirty flash your ROM zip (without wipe) - restores stock boot
3. Or fastboot flash stock boot.img:
   ```bash
   fastboot flash boot stock_boot_daisy.img
   ```

---

## FAQ

**Q: Works on Android 11?**
A: Yes, primary target is Android 11, but AnyKernel3 = universal Android 9-14.

**Q: Works on Stock ROM?**
A: Yes, all stock Android One and all custom ROMs.

**Q: Will it work after ROM update?**
A: Reflash kernel after ROM update (ROM overwrites boot).

**Q: Getting bootloop?**
A: Restore boot backup. Ensure you flashed `daisy` build not `jasmine`.

**Q: Phone still hot?**
A: Check ambient temp, use Cool preset (650MHz GPU), ensure thermal-engine is running: `ps | grep thermal`

---

## Thermal Results

Expected after install:
- Idle: 32-34°C
- PUBG 30min: 38-40°C (stock 43-45°C)
- Charging: 35-38°C

Monitor with `CPU Temp` app or `cat /sys/class/thermal/thermal_zone*/temp`

Enjoy! 🎮❄️
