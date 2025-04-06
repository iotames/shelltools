@echo off & setlocal enabledelayedexpansion
REM -- 全自动DNS配置脚本（增强版）--
chcp 65001 >nul

REM -- 检查管理员权限 --
NET SESSION >nul 2>&1 || (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dpnx0' -Verb RunAs"
    exit /b
)

REM -- 确保命令行编码正确 -- [新增]
powershell -Command "& {$OutputEncoding = [System.Text.Encoding]::UTF8}"

:MAIN
cls
echo ===== Santic外网专线配置工具 =====
echo.
echo 1. 设置专线DNS (加速全球访问)
echo 2. 恢复自动获取DNS
echo 3. 退出
echo.
set /p choice=请选择操作 [1-3]: 

if "%choice%"=="1" goto SetDNS
if "%choice%"=="2" goto ResetDNS
if "%choice%"=="3" exit /b
goto MAIN

:SetDNS
cls
echo 正在配置专线DNS...

REM -- 预配置的DNS服务器 --
set PRIMARY_DNS=183.90.189.7
set SECONDARY_DNS=43.156.97.238

REM -- 使用接口索引检测方法 --
set "INTERFACE_IDX="
echo 正在扫描活动网络接口...

REM -- 使用PowerShell获取活动网络接口的索引 --
for /f "usebackq delims=" %%a in (`powershell -Command "& {Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 -ExpandProperty InterfaceIndex}"`) do (
    set "INTERFACE_IDX=%%a"
    echo 发现活动网络接口索引: !INTERFACE_IDX!
)

if "%INTERFACE_IDX%"=="" (
    echo 错误：未找到活动的网络接口！
    echo 请确认：
    echo 1. 网络线缆已正确连接
    echo 2. 无线网络已成功连接
    pause
    goto MAIN
)

echo 已检测到网络接口索引: [%INTERFACE_IDX%]

REM -- 执行DNS设置 --
echo 正在设置接口索引 [%INTERFACE_IDX%] 的DNS...
netsh interface ipv4 delete dns "%INTERFACE_IDX%" all >nul
netsh interface ipv4 add dns "%INTERFACE_IDX%" %PRIMARY_DNS% validate=no >nul
netsh interface ipv4 add dns "%INTERFACE_IDX%" %SECONDARY_DNS% index=2 validate=no >nul

REM -- 验证设置 --
echo 最终DNS配置：
netsh interface ipv4 show dnsservers "interface=%INTERFACE_IDX%"

REM -- 测试DNS连通性 --
echo.
echo 正在测试DNS连通性...
ping -n 1 -w 1000 www.google.com >nul
if %errorlevel% equ 0 (
    echo DNS测试成功: 可以访问国际网站
) else (
    echo DNS测试结果: 无法访问国际网站，请检查网络连接
)

echo.
echo 操作已完成，按任意键返回主菜单
pause >nul
goto MAIN

:ResetDNS
cls
echo 正在恢复自动获取DNS...

REM -- 检测活动网络接口索引 --
set "INTERFACE_IDX="
for /f "usebackq delims=" %%a in (`powershell -Command "& {Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -First 1 -ExpandProperty InterfaceIndex}"`) do (
    set "INTERFACE_IDX=%%a"
)

if "%INTERFACE_IDX%"=="" (
    echo 错误：未找到活动的网络接口！
    pause
    goto MAIN
)

echo 已检测到网络接口索引: [%INTERFACE_IDX%]

REM -- 恢复DHCP DNS设置 --
echo 正在恢复接口索引 [%INTERFACE_IDX%] 的DNS为自动获取...
netsh interface ipv4 set dnsservers "%INTERFACE_IDX%" dhcp >nul

REM -- 验证设置 --
echo 最终DNS配置：
netsh interface ipv4 show dnsservers "interface=%INTERFACE_IDX%"

echo.
echo 操作已完成，按任意键返回主菜单
pause >nul
goto MAIN

endlocal