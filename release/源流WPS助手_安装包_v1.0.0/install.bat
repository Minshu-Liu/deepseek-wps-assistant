@echo off
chcp 65001 >nul
cd /d "%~dp0"
setlocal EnableDelayedExpansion

echo ========================================
echo   源流WPS助手 安装程序 v1.0.0
echo ========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "PKG=%SCRIPT_DIR%SourceflowdigitalAssistant.7z"
set "SEVENZIP=%SCRIPT_DIR%tools\7za.exe"
set "JSADDONS=%APPDATA%\kingsoft\wps\jsaddons"
set "PLUGIN_DIR=%JSADDONS%\SourceflowdigitalAssistant_1.0.0"

if not exist "%PKG%" (
    echo [错误] 未找到 SourceflowdigitalAssistant.7z
    echo 请确认 install.bat 与安装包在同一目录。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)

if not exist "%SEVENZIP%" (
    echo [错误] 未找到 tools\7za.exe
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)

echo.
echo 安装源流WPS助手前，请先保存并关闭所有 WPS 文档。
echo 继续安装将自动关闭所有 WPS 进程。
echo.
choice /C YN /M "是否继续安装"
if errorlevel 2 (
    echo 已取消安装。
    pause
    exit /b 0
)

echo.
echo [1/7] 正在关闭 WPS 相关进程...
for %%P in (wps wpp et wpscloudsvr wpscenter wpsnotify ksolaunch) do (
    taskkill /F /IM %%P.exe >nul 2>&1
)
timeout /t 2 /nobreak >nul

echo [2/7] 准备安装目录...
if not exist "%JSADDONS%" mkdir "%JSADDONS%"

echo [3/7] 备份现有配置...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
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
    echo [错误] 解压失败，请尝试右键 install.bat 以管理员身份运行。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)

echo [5/7] 写入安装标识 install-state.js...
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "INSTALL_ID=%%I"
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
    echo [错误] 解压后未找到 manifest.xml，安装不完整。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\ribbon.xml" (
    echo [错误] 解压后未找到 ribbon.xml，安装不完整。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\index.html" (
    echo [错误] 解压后未找到 index.html，安装不完整。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)
if not exist "%PLUGIN_DIR%\main.js" (
    echo [错误] 解压后未找到 main.js，安装不完整。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)
if not exist "%INSTALL_STATE%" (
    echo [错误] 未写入 install-state.js，安装不完整。
    mshta "javascript:alert('源流WPS助手安装失败，请联系技术支持。');close();"
    pause
    exit /b 1
)

echo [7/7] 安装完成！
echo.
echo 安装完成，请重新打开 WPS 文字，查看顶部「源流WPS助手」选项卡。
echo 点击「打开助手」即可使用。
echo 本次安装标识: !INSTALL_ID!
echo.
mshta "javascript:alert('源流WPS助手已安装成功，请重新打开 WPS 文字，查看顶部【源流WPS助手】选项卡。');close();"
pause
exit /b 0