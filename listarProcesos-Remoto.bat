@echo off

echo Programa para listar procesos

set /p IP=Ingresar IP de equipo remoto: 

wmic /node:%IP% process call create "cmd /C > C:\testN.txt 2>&1 netstat.exe -A -B"

type \\%IP%\C$\testN.txt > output.txt

TASKLIST /FI "STATUS eq RUNNING" /V /S %IP% >> output.txt

type \\%IP%\C$\WINDOWS\system32\drivers\etc\hosts >> output.txt

echo Se creo el archivo output.txt

pause

