@echo off
chcp 65001 >nul 2>&1
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo   源流WPS助手 安装程序 v1.0.6
echo ========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "PKG=%SCRIPT_DIR%SourceflowdigitalAssistant.7z"
set "SEVENZIP=%SCRIPT_DIR%tools\7za.exe"
set "JSADDONS=%APPDATA%\kingsoft\wps\jsaddons"
set "PLUGIN_DIR=%JSADDONS%\SourceflowdigitalAssistant_1.0.0"

if not exist "%PKG%" (
    echo.
    echo [错误] 未找到 SourceflowdigitalAssistant.7z。
    echo 请确认安装包文件完整后重新运行 install.bat。
    echo.
    pause
    exit /b 1
)

if not exist "%SEVENZIP%" (
    echo.
    echo [错误] 未找到 tools\7za.exe。
    echo 请确认安装包文件完整后重新运行 install.bat。
    echo.
    pause
    exit /b 1
)

echo.
echo 安装前请先保存 WPS 中正在编辑的文档。
echo 安装过程将自动关闭 WPS、表格、演示相关进程。
echo.

:confirm_install
echo.
echo 是否确认安装？请输入 Y 后按回车继续，输入 N 后按回车退出：
set /p "CONFIRM="
if /i "!CONFIRM!"=="Y" goto do_install
if /i "!CONFIRM!"=="N" (
    echo.
    echo 已取消安装。
    echo.
    pause
    exit /b 0
)
echo 输入无效，请重新输入 Y 或 N。
goto confirm_install

:do_install

echo.
echo [1/7] 正在关闭 WPS 相关进程...
taskkill /F /IM wps.exe >nul 2>&1
taskkill /F /IM et.exe >nul 2>&1
taskkill /F /IM wpp.exe >nul 2>&1
for %%P in (wpscloudsvr wpscenter wpsnotify ksolaunch) do (
    taskkill /F /IM %%P.exe >nul 2>&1
)
timeout /t 2 /nobreak >nul

echo [2/7] 准备安装目录...
if not exist "%JSADDONS%" mkdir "%JSADDONS%"

echo [3/7] 备份现有配置...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set "DATETIME=%%I"
if not defined DATETIME set "DATETIME=00000000_000000"
set "TS=!DATETIME:~0,8!_!DATETIME:~8,6!"
set "BACKUP=%JSADDONS%\backup_install_!TS!"
mkdir "!BACKUP!" 2>nul
if exist "%JSADDONS%\publish.xml" (
    copy /Y "%JSADDONS%\publish.xml" "!BACKUP!\publish.xml.bak" >nul
    echo 已备份 publish.xml 到 backup_install_!TS!
)

echo [4/7] 解压插件文件...
if exist "%PLUGIN_DIR%" rmdir /S /Q "%PLUGIN_DIR%"

"%SEVENZIP%" x "%PKG%" "-o%JSADDONS%" -y
if errorlevel 1 (
    echo.
    echo [错误] 解压失败。
    echo 请尝试右键 install.bat，以管理员身份运行。
    echo.
    pause
    exit /b 1
)

echo [5/7] 写入安装标识 install-state.js...
set "INSTALL_ID=%DATE%_%TIME%_%RANDOM%"
set "INSTALL_ID=!INSTALL_ID:/=-!"
set "INSTALL_ID=!INSTALL_ID::=-!"
set "INSTALL_ID=!INSTALL_ID:.=-!"
set "INSTALL_ID=!INSTALL_ID: =_!"
set "INSTALL_STATE=%PLUGIN_DIR%\js\install-state.js"
if not exist "%PLUGIN_DIR%\js" mkdir "%PLUGIN_DIR%\js"
(
echo window.SOURCEFLOW_INSTALL_ID = "!INSTALL_ID!";
) > "%INSTALL_STATE%"

echo [6/7] 写入 publish.xml...
(
echo ^<?xml version="1.0" encoding="UTF-8"?^>
echo ^<jsplugins^>
echo     ^<jsplugin name="SourceflowdigitalAssistant" type="wps"
echo         url="SourceflowdigitalAssistant_1.0.0"
echo         version="1.0.0"
echo         enable="enable_dev"
echo         install="null"
echo         customDomain=""/^>
echo ^</jsplugins^>
) > "%JSADDONS%\publish.xml"

if not exist "%PLUGIN_DIR%\manifest.xml" (
    echo.
    echo [错误] 解压后未找到 manifest.xml，安装不完整。
    echo.
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\ribbon.xml" (
    echo.
    echo [错误] 解压后未找到 ribbon.xml，安装不完整。
    echo.
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\index.html" (
    echo.
    echo [错误] 解压后未找到 index.html，安装不完整。
    echo.
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\main.js" (
    echo.
    echo [错误] 解压后未找到 main.js，安装不完整。
    echo.
    pause
    exit /b 1
)
if not exist "%INSTALL_STATE%" (
    echo.
    echo [错误] 未写入 install-state.js，安装不完整。
    echo.
    pause
    exit /b 1
)

echo [7/7] 安装完成！
echo.
echo [完成] 源流WPS助手安装完成。
echo 请重新打开 WPS，在顶部菜单查看「源流WPS助手」。
echo 本次安装标识: !INSTALL_ID!
echo.
pause
exit /b 0
