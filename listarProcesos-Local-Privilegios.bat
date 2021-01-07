@echo off

echo Creando informe...

NETSTAT -A -B > output.txt

TASKLIST /FI "STATUS eq RUNNING" /V >> output.txt

type C:\WINDOWS\system32\drivers\etc\hosts >> output.txt

echo Se creo el archivo output.txt

pause
exit

