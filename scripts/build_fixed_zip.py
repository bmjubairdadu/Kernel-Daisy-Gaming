#!/usr/bin/env python3
"""Build proper AnyKernel3 flashable zip with STORE (no compression) and unix perms - TWRP compliant"""
import zipfile
import os
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
AK3 = BASE / "AnyKernel3"
OUT = BASE / "out"

# Ensure LF and executable bits sources are correct
# Choose latest version name
zip_name = "Kernel-Daisy-Gaming-v1.1-4.9.337-AnyKernel3.zip"
zip_path = OUT / zip_name
zip_path_dated = OUT / f"Kernel-Daisy-Gaming-v1.1-4.9.337-AnyKernel3-{__import__('datetime').date.today().strftime('%Y%m%d')}.zip"

OUT.mkdir(parents=True, exist_ok=True)

def should_store(name):
    # TWRP requires these stored (no compress) and specific perms
    # Compress kernel image would break, but store keeps it TWRP-safe
    # Use ZIP_STORED for everything to maximize compatibility (original AK3 uses stored)
    return True

def get_perms(path):
    # Mimic AK3 perms
    name = path.name
    if name in ("update-binary", "updater-script"):
        return 0o755
    if path.suffix == ".sh" or "tools" in str(path):
        return 0o755 if path.suffix not in (".conf",) else 0o644
    if name in ("anykernel.sh", "gaming-init.sh"):
        return 0o755
    if "META-INF" in str(path):
        return 0o755
    return 0o644

# Collect files in deterministic order matching AK3 convention
files = []
for root, dirs, filenames in os.walk(AK3):
    # Skip .git and exclude placeholder files (AK3 spec deletes them before repack)
    dirs[:] = [d for d in dirs if d != ".git"]
    for fn in filenames:
        if fn == "placeholder":
            continue
        fp = Path(root) / fn
        arc = fp.relative_to(AK3).as_posix()  # Always unix slashes - CRITICAL for recovery!
        files.append((fp, arc))

# Also need empty dirs as entries for ramdisk/patch etc if they are empty placeholders
for root, dirs, filenames in os.walk(AK3):
    for d in dirs:
        dp = Path(root) / d
        arc = dp.relative_to(AK3).as_posix() + "/"
        # Add directory entry if not already covered
        files.append((dp, arc, True))

# Dedupe and sort - META-INF first (required by recovery)
files_unique = {}
for item in files:
    if len(item)==3:
        fp, arc, is_dir = item
        if arc not in files_unique:
            files_unique[arc] = (fp, is_dir)
    else:
        fp, arc = item
        files_unique[arc] = (fp, False)

# Sort: META-INF first, then tools, then rest
def sort_key(k):
    if k.startswith("META-INF"): return (0, k)
    if k.startswith("tools/"): return (1, k)
    if k in ("anykernel.sh", "Image.gz-dtb", "version"): return (2, k)
    return (3, k)

sorted_arcs = sorted(files_unique.keys(), key=sort_key)

# Build zip with STORE and correct external_attr (unix perms)
for dest in [zip_path, zip_path_dated]:
    with zipfile.ZipFile(dest, 'w', compression=zipfile.ZIP_STORED, allowZip64=False) as z:
        for arc in sorted_arcs:
            fp, is_dir = files_unique[arc]
            if is_dir:
                # Directory entry
                zi = zipfile.ZipInfo(arc)
                zi.external_attr = (0o755 << 16) | 0x10  # directory flag
                zi.compress_type = zipfile.ZIP_STORED
                # Set date to now
                z.writestr(zi, b'')
                continue
            # File entry
            data = fp.read_bytes()
            # Fix CRLF -> LF for shell scripts on the fly
            if fp.suffix == ".sh" or arc == "META-INF/com/google/android/update-binary" or arc == "META-INF/com/google/android/updater-script":
                data = data.replace(b"\r\n", b"\n")
            zi = zipfile.ZipInfo(arc)
            perms = 0o755 if (arc.endswith(".sh") or "tools/" in arc or arc.startswith("META-INF/")) else get_perms(fp)
            # Preserve Image perms 644 but exec for scripts
            if arc == "Image.gz-dtb":
                perms = 0o644
            if arc.endswith("ak3-core.sh"):
                perms = 0o755
            zi.external_attr = (perms & 0xFFFF) << 16
            zi.compress_type = zipfile.ZIP_STORED
            z.writestr(zi, data)
    print(f"Created {dest} ({dest.stat().st_size} bytes)")

# Verify zip
for dest in [zip_path, zip_path_dated]:
    with zipfile.ZipFile(dest, 'r') as z:
        print(f"\n=== {dest.name} entries ===")
        for info in z.infolist():
            perms = (info.external_attr >> 16) & 0xFFF
            print(f"  {oct(perms):>6} {info.filename:<50} {info.file_size:>8} -> {info.compress_size:>8} {'STORE' if info.compress_type==0 else 'DEFLATE'}")
        # Test integrity
        bad = z.testzip()
        print(f"testzip: {bad if bad else 'OK'}")

print("\nDone - flashable zips are recovery-compliant (STORE, LF, unix perms).")
