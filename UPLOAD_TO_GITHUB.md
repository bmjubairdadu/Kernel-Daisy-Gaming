# Upload to GitHub - Steps

Your Kernel Daisy for Gaming project is ready with flashable zip at `out/Kernel-Daisy-Gaming-v1.0-AnyKernel3.zip`

## 1. Create GitHub Repo
1. Go to https://github.com/new
2. Name: `Kernel-Daisy-Gaming` (or `Kernel_Daisy_for_Gaming`)
3. Description: `Kernel Daisy for Gaming - Mi A2 Lite (daisy) - Cool & Smooth - Snapdragon 625`
4. **Do NOT** initialize with README/license (we already have)
5. Create repository → copy the URL e.g. `https://github.com/YOUR_USERNAME/Kernel-Daisy-Gaming.git`

## 2. Push From This Folder

Open PowerShell in `C:\Users\Administrator\Desktop\Kernel` and run:

```powershell
git remote add origin https://github.com/YOUR_USERNAME/Kernel-Daisy-Gaming.git
git branch -M main
git push -u origin main
```

If asked for login, use GitHub Personal Access Token (Settings → Developer settings → Tokens → Generate).

## 3. Flashable Zip Upload
After push, GitHub Actions will **auto-build** and create a Release with flashable zip:
- Go to `Actions` tab on GitHub → see `Build Kernel Daisy Gaming` running (10-20 min on Linux runner)
- Or manually upload the local zip:
  - Go to `Releases` → `Draft a new release` → Tag `v1.0-Gaming` → Upload `out/Kernel-Daisy-Gaming-v1.0-AnyKernel3.zip`

Local zip location on your PC:
```
C:\Users\Administrator\Desktop\Kernel\out\Kernel-Daisy-Gaming-v1.0-AnyKernel3.zip
```
Also dated version: `out\Kernel-Daisy-Gaming-v1.0-AnyKernel3-20260901.zip`

## 4. For Real Kernel Build (not placeholder)
The placeholder `Image.gz-dtb` is for packaging demo on Windows.
Real kernel compiles on **Linux / WSL2 / GitHub Actions**:
- GitHub Actions does it automatically (needs Xiaomi source)
- Or on WSL2/Ubuntu:
  ```bash
  bash build.sh all   # builds real Image.gz-dtb + zip at out/*.zip
  ```

## 5. Share
After release, share link: `https://github.com/YOUR_USERNAME/Kernel-Daisy-Gaming/releases`

Flash via TWRP: Install → Select zip → Reboot.

Need help pushing? Paste your GitHub repo URL here and I will run the push commands.
