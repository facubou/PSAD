Function Get-LocalAdmins {
        
        Param(
            [Parameter(Mandatory)]
            [string[]]$Equipos
            )
        # testing the connection to each computer via ping before
        # executing the script
        foreach ($equipo in $Equipos) {
            if (Test-Connection -ComputerName $equipo -Quiet -count 1) {
                Add-Content -value $equipo -path $env:USERPROFILE\AppData\Local\Temp\EquiposUp.txt -Force
            } else {
                Write-Verbose -Message ('{0} equipo unreachable' -f $equipo) -Verbose
            }
        }
    
        #Cargar equipos en archivo temporal
        $EquiposUp = Get-Content -path $env:USERPROFILE\AppData\Local\Temp\EquiposUp.txt

        $list = new-object -TypeName System.Collections.ArrayList
        foreach ($equipo in $EquiposUp) {
            $admins = Get-WmiObject -Class win32_groupuser -ComputerName $equipo | 
                Where-Object {$_.groupcomponent -like '*"Administradores"'} 
            $obj = New-Object -TypeName PSObject -Property @{
                ComputerName = $equipo
                LocalAdmins = $null
            }
            foreach ($admin in $admins) {
                $admin.partcomponent -match '.+Domain\=(.+)\,Name\=(.+)$' | Out-Null
                $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n" | Out-Null
                $obj.Localadmins += $matches[1].trim('"') + '\' + $matches[2].trim('"') + "`n"
            }
            $list.add($obj) | Out-Null
            
        }
        $list
        
        #Limpiando Archivo Temporal
        if(Test-Path -Path $env:USERPROFILE\AppData\Local\Temp\EquiposUp.txt){
            Remove-Item -Path $env:USERPROFILE\AppData\Local\Temp\EquiposUp.txt -Force
        }

    }
