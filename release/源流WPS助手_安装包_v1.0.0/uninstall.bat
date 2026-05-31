@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo   源流WPS助手 卸载程序 v1.0.0
echo ========================================
echo.

echo.
echo 卸载前请先保存 WPS 中正在编辑的文档。
echo 卸载过程将自动关闭 WPS、表格、演示相关进程。
echo.
choice /C YN /M "是否继续卸载？"
if errorlevel 2 (
    echo.
    echo 已取消卸载。
    echo.
    pause
    exit /b 0
)

echo.
echo [1/5] 正在关闭 WPS 相关进程...
taskkill /F /IM wps.exe >nul 2>&1
taskkill /F /IM et.exe >nul 2>&1
taskkill /F /IM wpp.exe >nul 2>&1
for %%P in (wpscloudsvr wpscenter wpsnotify ksolaunch) do (
    taskkill /F /IM %%P.exe >nul 2>&1
)
timeout /t 2 /nobreak >nul

set "JSA=%APPDATA%\kingsoft\wps\jsaddons"
set "ADDON_DIR=%JSA%\SourceflowdigitalAssistant_1.0.0"

echo [2/5] 备份现有配置...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set "DATETIME=%%I"
if not defined DATETIME set "DATETIME=00000000_000000"
set "TS=!DATETIME:~0,8!_!DATETIME:~8,6!"
set "BACKUP=%JSA%\backup_uninstall_!TS!"
mkdir "!BACKUP!" 2>nul

if exist "%JSA%\publish.xml" copy /Y "%JSA%\publish.xml" "!BACKUP!\publish.xml.bak" >nul
if exist "%JSA%\authaddin.json" copy /Y "%JSA%\authaddin.json" "!BACKUP!\authaddin.json.bak" >nul
if exist "%JSA%\authwebsite.xml" copy /Y "%JSA%\authwebsite.xml" "!BACKUP!\authwebsite.xml.bak" >nul
if exist "%JSA%\jsaddinblockhost.ini" copy /Y "%JSA%\jsaddinblockhost.ini" "!BACKUP!\jsaddinblockhost.ini.bak" >nul
echo 已备份到 backup_uninstall_!TS!

echo [3/5] 删除插件目录...
if exist "%ADDON_DIR%" (
    rmdir /S /Q "%ADDON_DIR%"
)
if exist "%ADDON_DIR%" (
    echo.
    echo [错误] 插件目录未能完全删除。
    echo 请尝试右键 uninstall.bat，以管理员身份运行。
    echo.
    pause
    exit /b 1
) else (
    echo 已删除 SourceflowdigitalAssistant_1.0.0
)

echo [4/5] 删除 authaddin.json 并清空 publish.xml...
if exist "%JSA%\authaddin.json" (
    del /F /Q "%JSA%\authaddin.json"
)
if exist "%JSA%\authaddin.json" (
    echo.
    echo [错误] authaddin.json 未能删除。
    echo 请尝试右键 uninstall.bat，以管理员身份运行。
    echo.
    pause
    exit /b 1
) else (
    echo 已删除 authaddin.json（或原本不存在）。
)

(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<jsplugins^>
echo ^</jsplugins^>
) > "%JSA%\publish.xml"

echo [5/5] 卸载结果验证...
echo.
if exist "%ADDON_DIR%" (
    echo [X] 插件目录仍存在: %ADDON_DIR%
) else (
    echo [OK] 插件目录已删除
)

if exist "%JSA%\authaddin.json" (
    echo [X] authaddin.json 仍存在
) else (
    echo [OK] authaddin.json 已删除
)

echo.
echo --- publish.xml 当前内容 ---
if exist "%JSA%\publish.xml" (
    type "%JSA%\publish.xml"
) else (
    echo publish.xml 不存在
)
echo --- 验证结束 ---

echo.
echo [完成] 源流WPS助手卸载完成。
echo 请重新打开 WPS，确认顶部「源流WPS助手」选项卡已消失。
echo.
pause
exit /b 0
