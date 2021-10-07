@echo off

cd %~dp0
echo [-] Current Directory = %cd%

:check_os
IF "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set bit=x86
) else (
    set bit=x64
)

:check_sysmon
IF %bit% == "x86" (
    sc query "Sysmon" | Find "RUNNING" >nul
) else (
    sc query "Sysmon64" | Find "RUNNING" >nul
)
IF "%ERRORLEVEL%" EQU "0" (
    echo [+] Sysmon is running. Check version.
    goto check_sysmon_version
)
echo [!] Sysmon is not running. Trying to start sysmon...

:start_sysmon
IF %bit% == "x86" (
    net start Sysmon >nul 2>nul
) else (
    net start Sysmon64 >nul 2>nul
)
IF "%ERRORLEVEL%" NEQ "0" (
    echo [!] Unable to start service. Perform installation..
    goto install_sysmon
)

:check_sysmon_version
IF %bit% == "x86" (
    Sysmon | Find "13.24"
) else (
    Sysmon64 | Find "13.24"
)
IF "%ERRORLEVEL%" NEQ "0" (
    echo [-] Sysmon not up to date. Perform reinstallation..
    goto install_sysmon
)
echo [+] Sysmon is up to date

:update_config
echo [+] Reloading Sysmon Config...
IF %bit% == "x86" (
    sysmon.exe -c sysmonconfig-export.xml >nul 2>nul
) else (
    sysmon64.exe -c sysmonconfig-export.xml >nul 2>nul
)
goto exit

:install_sysmon
echo Installing Sysmon Config...
sysmon.exe -u >nul 2>nul
sysmon64.exe -u >nul 2>nul
IF %bit% == "x86" (
    sysmon.exe /accepteula -i sysmonconfig-export.xml
) else (
    sysmon64.exe /accepteula -i sysmonconfig-export.xml
)

:exit
echo [+] Completed!

