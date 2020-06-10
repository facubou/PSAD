Para utilizar el script primero hay que cargarlo como una función en PS: 
. .\Get-LocalAdmins.ps1

Luego se puede utilizar simplemente escribiendo: 
Get-LocalAdmins -Equipos WKSxxxx | Format-Table -AutoSize -Wrap
Get-LocalAdmins -Equipos (Get-Content -Path C:\Users\user1\Desktop\archivo.txt) | Format-Table -AutoSize -Wrap

