# Claude Store Auto-Update Blocker

## 📦 Files

| File | Purpose | How to Run |
|------|---------|------------|
| `block_claude_update.bat` | 🔒 Disable Claude Store auto-update | Right-click → **Run as administrator** |
| `restore_claude_update.bat` | 🔓 Restore Claude Store auto-update | Right-click → **Run as administrator** |
| `排查报告.md` | 🔍 Complete investigation report & technical analysis | Read as document |

---

## ⚠️ Important

- **All scripts must be run as administrator** (right-click → Run as administrator)
- **Restart your computer** after running the block script for changes to take effect
- Works on Windows 10/11
- The restore script reverts all settings to system defaults

---

## 🎯 What Problem Does This Solve

Windows automatically updates the Claude Store app to the latest version, even after you've tried:

- ❌ Firewall blocking Store client processes → **Ineffective**
- ❌ Registry `AutoDownload=2` → **Ineffective**

**Root Cause**: Claude updates go through Windows system-level channels (ContentDeliveryManager + Delivery Optimization), **completely bypassing the Store client**. Conventional methods cannot intercept this.

---

## 🛠️ Technical Principle

This tool uses a **three-layer defense** to completely block automatic updates:

```
InstallService\ScanForUpdates (scheduled task, triggered daily)
  → ContentDeliveryManager determines "silent installation"
    → Delivery Optimization downloads from Microsoft CDN
      → Writes to WindowsApps directory
```

### Three Layers of Defense

1. **Disable ContentDeliveryManager** (root cause)  
   Disable `SilentInstalledAppsEnabled` and `ContentDeliveryAllowed` to block system-level silent installation

2. **Disable Delivery Optimization Service**  
   Stop and disable DoSvc service to prevent downloads

3. **Disable InstallService Scheduled Tasks**  
   Disable `ScanForUpdates` and other triggers to stop periodic scanning

> 📌 **Why AutoDownload=2 doesn't work?**  
> This policy only controls the Store **client's** download behavior. Updates use an independent system channel and are not affected by this setting.

---

## 🚀 How to Use

### Disable Auto-Update
1. Right-click `block_claude_update.bat`
2. Select **"Run as administrator"**
3. Wait for the script to complete
4. **Restart your computer**

### Verify It Worked
After restart, run in Command Prompt:
```cmd
dir "C:\Program Files\WindowsApps\Claude*"
```
Check again after 24 hours to see if any new version directory appears.

### Restore Auto-Update
To revert to system defaults:
1. Right-click `restore_claude_update.bat`
2. Select **"Run as administrator"**

---

## 📋 Script Operations

### `block_claude_update.bat` Actions

| Step | Action | Description |
|------|--------|-------------|
| 1/5 | Disable ContentDeliveryManager | Block background silent installation |
| 2/5 | Stop Delivery Optimization | Disable download service |
| 3/5 | Disable update scan tasks | Disable scheduled task triggers |
| 4/5 | Disable Delivery Optimization policy | Group policy level disable |
| 5/5 | Verify all changes | Display current status |

### `restore_claude_update.bat` Actions

| Step | Action | Description |
|------|--------|-------------|
| 1/3 | Restore ContentDeliveryManager | Revert to allowed state |
| 2/3 | Restore Delivery Optimization | Start and set to automatic |
| 3/3 | Restore scheduled tasks | Enable all update scan tasks |

---

## 📊 Verification Commands

```cmd
:: 1. Verify CDM is disabled
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed
:: Should show 0x0

:: 2. Verify DoSvc is disabled
sc qc DoSvc
:: Should show START_TYPE : 4  DISABLED

:: 3. Verify scheduled task is disabled
schtasks /Query /TN "\Microsoft\Windows\InstallService\ScanForUpdates" /FO LIST | findstr Status
:: Should show Disabled

:: 4. Check Claude version directories
dir "C:\Program Files\WindowsApps\Claude*"
```

---

## 📖 Documentation

- `排查报告.md` — Complete investigation report, technical principles, and lessons learned (Chinese only)

---

## 💡 Additional Tip

Setting your network connection as **"Metered"** provides an extra layer of protection against Windows background downloads.

---

## 📝 Version Information

- Supported OS: Windows 10 / 11 (including Home/Pro editions)
- Tested on: Windows 11 Home China (10.0.26200)
- Target app: Claude Store version

---

## 🌐 Language

- [中文版](./README_zh.md) — Chinese version of this document

---

*If you encounter any issues, re-run the script as administrator or refer to `排查报告.md` for detailed technical background.*
