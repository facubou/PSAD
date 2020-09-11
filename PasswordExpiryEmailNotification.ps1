#-----Input Dataset-----
#Get all AD users
$AcsExp = Get-ADUser -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name
#Get all users of another AD
$AcsExpLeasing = Get-ADUser -Server "dc.domain.local" -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name

$FechaHoy = Get-Date
#Get Users in a text file
$AcsTxt = get-content "C:\users\ff\Desktop\usuariosSinLegajo.txt"
#Define propierties for export (if are needed)
$prop="Name","DisplayName","UserPrincipalName","PasswordLastSet"

#SMTP Server data
$Fromusr = "emailsecurity@domain.com"
$anonUser = "anonymous"
$anonPass = ConvertTo-SecureString "anonymous" -AsPlainText -Force
$anonCred = New-Object System.Management.Automation.PSCredential($anonUser, $anonPass)
$Smtpsvr = "192.168.1.2"
$body = get-content "C:\users\ff\Desktop\body.txt" -Encoding UTF8 | Out-String #Set with a simple string if enconding is not needed
$sub = "Su clave de Windows se encuentra proxima a vencer"
$encoding = "UTF8"

Write-Output ("[#] ------------------Usuarios Domain------------------")
ForEach ($user in $AcsExp)
{
    #Check if user exist and is nominal
    $Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
    $PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
    $nroEmpleado = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber
    $mail = Get-ADUser -Filter "Name -like '$user'" -properties mail | select-object -ExpandProperty mail

    if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($nroEmpleado)) -and -not ([string]::IsNullOrEmpty($mail)))
    {
        $FechaPasswordLastSet = Get-ADUser -Filter "Name -like '$user'" -properties PasswordLastSet | select-object -ExpandProperty PasswordLastSet
        $FechaVencimiento = $FechaPasswordLastSet.AddDays(30)
        $FechaVencimiento = $FechaVencimiento.ToString("dd/MM/yyyy")
        $FechaHoy_Resta30 = $FechaHoy.AddDays(-23) #Set for 7 days before block

        if ($FechaHoy_Resta30 -ge $FechaPasswordLastSet -and $FechaPasswordLastSet -like "*2020*")
            
            {
                $data = Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
                Select-Object -Property $prop | 
                ConvertTo-Csv -NoTypeInformation |     
                Select-Object -Skip 1
                $lista = $lista + $data + "," + $FechaVencimiento + "`n"
                $destinatario = $mail
                
                $Contador = $Contador +1

                Write-Output ("[#] Usuario "+$User)
                Write-Output ("[#] Ultimo Cambio de Pass "+$FechaPasswordLastSet)
                Send-MailMessage -to $Destinatario -from $fromusr -subject $sub -body $body -bodyashtml -SmtpServer $Smtpsvr -Credential $anonCred -Encoding $encoding             
                Write-Output ("[#] Correo enviado a "+$mail)
                Write-Output "`n"
            }
    }
}

#Another loop for another data input (txt)
Write-Output ("[#] ------------------Usuarios Domain Sin Legajo------------------`n")
foreach($user in $AcsTxt) {

    $Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
    $PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
    $nroEmpleado = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber
    $mail = Get-ADUser -Filter "Name -like '$user'" -properties mail | select-object -ExpandProperty mail

    if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($mail)))
    {
            
        $FechaPasswordLastSet = Get-ADUser -Filter "Name -like '$user'" -properties PasswordLastSet | select-object -ExpandProperty PasswordLastSet
        $FechaVencimiento = $FechaPasswordLastSet.AddDays(30)
        $FechaVencimiento = $FechaVencimiento.ToString("dd/MM/yyyy")
        $FechaHoy_Resta30 = $FechaHoy.AddDays(-23)
                
        if ($FechaHoy_Resta30 -ge $FechaPasswordLastSet -and $FechaPasswordLastSet -like "*2020*")
            
        {
        $data = Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
        Select-Object -Property $prop |
        ConvertTo-Csv -NoTypeInformation |     
        Select-Object -Skip 1
        $lista = $lista + $data + "," + $FechaVencimiento + "`n"
                
        $Contador = $Contador +1

        Write-Output ("[#] Usuario "+$User)
        Write-Output ("[#] Ultimo Cambio de Pass "+$FechaPasswordLastSet)
        Send-MailMessage -to $mail -from $fromusr -subject $sub -body $body -bodyashtml -SmtpServer $Smtpsvr -Credential $anonCred -Encoding $encoding                
        Write-Output ("[#] Correo enviado a "+$mail)
        Write-Output "`n"
            }
        }
    }
Write-Output ("Cantidad de correos enviados sin Legajo: $Contador")

#Another loop for other AD
Write-Output ("[#] `n----------------------Usuarios Active Directory nro 2---------------------:`n")
ForEach ($user in $AcsExpLeasing)
{
    $Enabled = Get-ADUser -Server "dc.domain.local" -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
    $PassExpira = Get-ADUser -Server "dc.domain.local" -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
    $nroEmpleado = Get-ADUser -Server dc.domain.local" -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber
    $mail = Get-ADUser -Server "dc.domain.local" -Filter "Name -like '$user'" -properties mail | select-object -ExpandProperty mail

    if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($nroEmpleado)) -and -not ([string]::IsNullOrEmpty($mail)))
    {
        $FechaPasswordLastSet = Get-ADUser -Server "dc.domain.local" -Filter "Name -like '$user'" -properties PasswordLastSet | select-object -ExpandProperty PasswordLastSet
        $FechaVencimiento = $FechaPasswordLastSet.AddDays(30)
        $FechaVencimiento = $FechaVencimiento.ToString("dd/MM/yyyy")
        $FechaHoy_Resta30 = $FechaHoy.AddDays(-23)
        $prop="Name","DisplayName","UserPrincipalName","PasswordLastSet"

        if ($FechaHoy_Resta30 -ge $FechaPasswordLastSet -and $FechaPasswordLastSet -like "*2020*")
            
            {
                #$Destinatario = 
                $Contador = $Contador +1
                $data = Get-ADUser -Server "dc.domain.local" -Filter "Name -like '$user'" -properties $prop | 
                Select-Object -Property $prop | 
                ConvertTo-Csv -NoTypeInformation |     
                Select-Object -Skip 1
                $lista = $lista + $data + "," + $FechaVencimiento + "`n"
                Write-Output ("[#] Usuario "+$User)
                Write-Output ("[#] Ultimo Cambio de Pass "+$FechaPasswordLastSet)
                Send-MailMessage -to $mail -from $fromusr -subject $sub -body $body -bodyashtml -SmtpServer $Smtpsvr -Credential $anonCred -Encoding $encoding
                Write-Output ("[#] Correo enviado a "+$mail)
                Write-Output "`n"
            }
    }
}
Write-Output ("Cantidad de correos enviados en AD nro 2: $Contador")

write $lista | Out-File export1.txt
$export = 'export1.txt'
Send-MailMessage -to $Destinatario -from $fromusr -subject $sub -body $body -Attachments $export -SmtpServer $Smtpsvr -Credential $anonCred -Encoding $encoding
