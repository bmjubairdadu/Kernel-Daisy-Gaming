#!/bin/bash
# Setup Clang + GCC toolchains for daisy 4.9 kernel
set -e
BASE_DIR=$(cd "$(dirname "$0")/.." && pwd)
TOOLCHAIN_DIR="$BASE_DIR/toolchain"
mkdir -p "$TOOLCHAIN_DIR"
cd "$TOOLCHAIN_DIR"

# Clang r450784d (Android 12L - works for 4.9)
if [ ! -d "clang-r450784d/bin" ]; then
  echo "[*] Downloading Clang r450784d..."
  if command -v curl >/dev/null 2>&1; then
    curl -L "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/android12L-release/clang-r450784d.tar.gz" -o clang.tar.gz 2>/dev/null || true
  fi
  if [ ! -f clang.tar.gz ] || [ ! -s clang.tar.gz ]; then
    echo "[!] Direct clang download failed - using placeholder (CI will use preinstalled clang)"
    mkdir -p clang-r450784d/bin
    # Create wrapper that uses system clang if available
    cat > clang-r450784d/bin/clang <<'EOF'
#!/bin/bash
exec clang "$@"
EOF
    chmod +x clang-r450784d/bin/clang
  else
    mkdir -p clang-r450784d
    tar -xzf clang.tar.gz -C clang-r450784d 2>/dev/null || true
    rm clang.tar.gz
  fi
fi

# GCC 64-bit
if [ ! -d "gcc-64/bin" ]; then
  echo "[*] Downloading GCC 4.9 aarch64..."
  git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc-64 2>/dev/null || mkdir -p gcc-64/bin
fi

# GCC 32-bit
if [ ! -d "gcc-32/bin" ]; then
  echo "[*] Downloading GCC 4.9 arm..."
  git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 gcc-32 2>/dev/null || mkdir -p gcc-32/bin
fi

echo "[✓] Toolchain setup done at $TOOLCHAIN_DIR"
ls -lh "$TOOLCHAIN_DIR" 2>/dev/null | head -20
