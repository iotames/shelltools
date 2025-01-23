@echo off
setlocal enabledelayedexpansion

REM 本脚本为浏览器客户端，连接浏览器到代理服务器，并打开目标网址

REM 定义变量
set PROXY_SERVER_URL=http://192.168.2.107:8889
set TARGET_URL=https://www.google.com

REM 定义路径列表（使用 %USERPROFILE% 动态替换用户路径）
set paths[0]=C:\Program Files\Google\Chrome\Application\chrome.exe
set paths[1]=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
set paths[2]=%USERPROFILE%\AppData\Local\Google\Chrome\Application\chrome.exe
set paths[3]=%USERPROFILE%\AppData\Local\MyChrome\Chrome\Application\chrome.exe
set paths[4]=C:\Program Files\Microsoft\Edge\Application\msedge.exe
set paths[5]=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
set paths[6]=%USERPROFILE%\AppData\Local\Microsoft\Edge\Application\msedge.exe

REM 遍历路径列表
set count=0
:loop
if defined paths[%count%] (
    REM 检查文件是否存在
    if exist "!paths[%count%]!" (
        echo !paths[%count%]! ----------- path is exist

        REM 提取浏览器可执行文件名（去掉 .exe）
        for %%A in ("!paths[%count%]!") do set BROWSER_EXE=%%~nA

        REM 构建用户数据目录路径
        set USER_DATA_DIR=%USERPROFILE%\AppData\Local\Santic\Gomitm\runtime\!BROWSER_EXE!_user_data
        echo User Data Directory: !USER_DATA_DIR%!

        REM 启动浏览器并传递参数
        start "ProxyClientForMITM" "!paths[%count%]!" --log-level=1 --window-size="1366,768" --user-data-dir="!USER_DATA_DIR!" --proxy-server=%PROXY_SERVER_URL% --new-window %TARGET_URL%
        goto end
    ) else (
        echo !paths[%count%]! ------------ path is not exist
    )
    set /a count+=1
    goto loop
)

:end
endlocal
pause


@REM "C:\Program Files\Google\Chrome\Application\chromm.exe" --log-level=1 --window-size="1366,768" --user-data-dir="D:\chrome_user_data" --proxy-server=http://172.16.160.13:8889 --new-window https://www.wgsnchina.cn/fashion
