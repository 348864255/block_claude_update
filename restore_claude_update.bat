@echo off
@chcp 936 >nul 2>&1
echo ============================================
echo   恢复 Claude Store 自动更新 - 请以管理员运行
echo ============================================
echo.

echo [1/3] 恢复 ContentDeliveryManager...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 1 /f
echo      OK
echo.

echo [2/3] 恢复 Delivery Optimization (DoSvc)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 2 /f
sc start DoSvc >nul 2>&1
echo      OK
echo.

echo [3/3] 恢复计划任务...
schtasks /Change /TN "\Microsoft\Windows\InstallService\ScanForUpdates" /Enable
schtasks /Change /TN "\Microsoft\Windows\InstallService\ScanForUpdatesAsUser" /Enable
schtasks /Change /TN "\Microsoft\Windows\InstallService\RestoreDevice" /Enable
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f
echo      OK
echo.

echo ============================================
echo   全部恢复完成！
echo ============================================
pause
