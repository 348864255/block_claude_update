# Claude Store 自动更新禁用工具

## 📦 文件说明

| 文件 | 用途 | 运行方式 |
|------|------|----------|
| `block_claude_update.bat` | 🔒 禁用 Claude Store 自动更新 | 右键 → **以管理员身份运行** |
| `restore_claude_update.bat` | 🔓 恢复 Claude Store 自动更新 | 右键 → **以管理员身份运行** |
| `排查报告.md` | 🔍 完整排查过程与技术分析 | 文档阅读 |

---

## ⚠️ 重要提示

- **所有脚本必须以管理员身份运行**（右键点击 → 以管理员身份运行）
- 执行禁用脚本后**必须重启电脑**才能生效
- 脚本适用于 Windows 10/11 系统
- 恢复脚本可将所有设置还原至系统默认状态

---

## 🎯 解决什么问题

Windows 会自动将 Claude Store 应用更新到最新版本，即使你已经通过以下方式尝试阻止：

- ❌ 防火墙封锁 Store 客户端进程 → **无效**
- ❌ 注册表 `AutoDownload=2` → **无效**

**根本原因**：Claude 更新走的是 Windows 系统级通道（ContentDeliveryManager + Delivery Optimization），**完全绕过了 Store 客户端**，因此常规方法无法拦截。

---

## 🛠️ 技术原理

本工具通过**三重防线**彻底阻止自动更新：

```
InstallService\ScanForUpdates（计划任务，每日触发）
  → ContentDeliveryManager 判断"静默安装"
    → Delivery Optimization 从微软 CDN 下载
      → 写入 WindowsApps 目录
```

### 三道防线

1. **关闭 ContentDeliveryManager**（根因）  
   禁用 `SilentInstalledAppsEnabled` 和 `ContentDeliveryAllowed`，阻止系统级静默安装

2. **禁用 Delivery Optimization 服务**  
   停止并禁用 DoSvc 服务，阻止下载执行

3. **禁用 InstallService 计划任务**  
   禁用 `ScanForUpdates` 等触发器，阻止定期扫描

> 📌 **AutoDownload=2 为什么没用？**  
> 该策略仅控制 Store **客户端**的下载行为，而更新走的是独立的系统通道，不受此控制。

---

## 🚀 使用方法

### 禁用自动更新
1. 右键点击 `block_claude_update.bat`
2. 选择 **"以管理员身份运行"**
3. 等待脚本执行完成
4. **重启电脑**

### 验证是否生效
重启后，在命令提示符中执行：
```cmd
dir "C:\Program Files\WindowsApps\Claude*"
```
24 小时后检查是否出现新的版本目录。

### 恢复自动更新
如需恢复系统默认设置：
1. 右键点击 `restore_claude_update.bat`
2. 选择 **"以管理员身份运行"**

---

## 📋 脚本执行内容

### `block_claude_update.bat` 操作清单

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1/5 | 关闭 ContentDeliveryManager | 禁止后台静默安装 |
| 2/5 | 停用 Delivery Optimization | 禁用下载服务 |
| 3/5 | 禁用安装更新扫描任务 | 禁用计划任务触发器 |
| 4/5 | 禁用 Delivery Optimization 策略 | 组策略级别禁用 |
| 5/5 | 验证所有更改 | 显示当前状态 |

### `restore_claude_update.bat` 操作清单

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1/3 | 恢复 ContentDeliveryManager | 还原为允许状态 |
| 2/3 | 恢复 Delivery Optimization | 启动并设为自动 |
| 3/3 | 恢复计划任务 | 启用所有更新扫描任务 |

---

## 📊 验证命令

```cmd
:: 1. 确认 CDM 已关闭
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed
:: 应显示 0x0

:: 2. 确认 DoSvc 已禁用
sc qc DoSvc
:: 应显示 START_TYPE : 4  DISABLED

:: 3. 确认计划任务已禁用
schtasks /Query /TN "\Microsoft\Windows\InstallService\ScanForUpdates" /FO LIST | findstr Status
:: 应显示 Disabled

:: 4. 检查 Claude 版本目录
dir "C:\Program Files\WindowsApps\Claude*"
```

---

## 📖 相关文档

- `排查报告.md` — 完整排查过程、技术原理与经验总结

---

## 📝 版本信息

- 适用系统：Windows 10 / 11（含 Home/Pro 版本）
- 测试环境：Windows 11 Home China (10.0.26200)
- 目标应用：Claude Store 版本

---
