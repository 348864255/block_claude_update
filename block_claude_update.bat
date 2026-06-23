@echo off
@chcp 936 >nul 2>&1
echo ============================================
echo   禁止 Claude Store 自动更新 - 请以管理员运行
echo ============================================
echo.

echo [1/5] 关闭 ContentDeliveryManager 静默安装...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f
echo      OK
echo.

echo [2/5] 停用 Delivery Optimization (DoSvc) 服务...
sc stop DoSvc >nul 2>&1
timeout /t 3 /nobreak >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f
echo      OK
echo.

echo [3/5] 禁用安装更新扫描计划任务...
schtasks /Change /TN "\Microsoft\Windows\InstallService\ScanForUpdates" /Disable
schtasks /Change /TN "\Microsoft\Windows\InstallService\ScanForUpdatesAsUser" /Disable
schtasks /Change /TN "\Microsoft\Windows\InstallService\RestoreDevice" /Disable
echo      OK
echo.

echo [4/5] 禁用 Delivery Optimization 策略...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f
echo      OK
echo.

echo [5/5] 验证所有更改...
echo --- ContentDeliveryManager ---
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed
echo --- Delivery Optimization ---
sc query DoSvc | findstr STATE
reg query "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start
echo --- 计划任务 ---
schtasks /Query /TN "\Microsoft\Windows\InstallService\ScanForUpdates" /FO LIST | findstr Status
schtasks /Query /TN "\Microsoft\Windows\InstallService\ScanForUpdatesAsUser" /FO LIST | findstr Status

echo.
echo ============================================
echo   全部完成！
echo.
echo   请重启电脑使效果生效
echo   24小时后检查是否还有新版本目录出现
echo.
echo   恢复更新请运行 restore_claude_update.bat
echo ============================================
pause
