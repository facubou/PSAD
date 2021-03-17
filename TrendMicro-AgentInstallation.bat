@echo off
setlocal enableextensions enabledelayedexpansion
for /F "tokens=*" %%a in ('type Servers.txt') do (
    set equipo=%%~a
    winrs -r:!equipo! if not exist c:\temp\ (mkdir c:\temp\ )
    xcopy /F C:\Users\fb\Documents\InstalacionAgenteDeepSecurity\Agent-Core-Windows-9.6.2-9361.x86_64_DeepSec.msi "\\!equipo!\c$\temp\AgenteDeepSec.msi"
    \r\n
    echo Installing Agent in !equipo!
    winrs -r:!equipo! msiexec /i C:\temp\AgenteDeepSec.msi
    \r\n
    echo Copying files in !equipo!
    winrs -r:!equipo! mkdir %temp%\DeepSec
    winrs -r:!equipo! xcopy /E /S /I "c:\Program Files\Trend Micro\Deep Security Agent\*.*" "%temp%\DeepSec\"
    \r\n
    echo Activating Agent in !equipo!
    \r\n
    winrs -r:!equipo! %temp%\DeepSec\dsa_control.cmd -r
    winrs -r:!equipo! %temp%\DeepSec\dsa_control.cmd -a dsm://DeepSec-srv:4120/ "policyid:23"
    winrs -r:!equipo! RD /S/Q %TEMP%\DeepSec\
    timeout 7
)
pause
