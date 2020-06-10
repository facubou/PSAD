Function Get-LocalAdmins {
    <#
    .SYNOPSIS
    Gets the members of the local administrators of the computer 
    and outputs the result to a CSV file.
    .PARAMETER Computers
    Specifies the Computer names of devices to query
    .INPUTS
    System.String. Get-LocalAdmins can accept a string value to
    determine the Computers parameter.
    .EXAMPLE
    Para buscar un único equipo: Get-LocalAdmins -Equipos Equipo1, Equipo2
    .EXAMPLE
    Para buscar por listado de equipos: Get-LocalAdmins -Computers (Get-Content -Path "$env:HOMEPATH\Desktop\computers.txt")
    .EXAMPLE
    Para darle formato a la salida: Get-LocalAdmins -Computers DC,SVR8 | Format-Table -AutoSize -Wrap
    .EXAMPLE
    Para exportarlo a un CSV: utilGet-LocalAdmins -Computers DC,SVR8 | Export-Csv -Path "$env:HOMEPATH\Desktop\LocalAdmin.csv" -NoTypeInformation
    #>
        
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
                Where-Object {$_.groupcomponent -like '*"Administradores"'} #set Administrators if you have English Configuration on Domain
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
