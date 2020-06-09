#Check if user's password is next to expiration and send the results by mail

$AcsExp = Get-ADUser -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name
$FechaHoy = Get-Date
#$FechaHoy = $FechaHoy.ToString("dd/MM/yyyy")

$Fromusr = "test@gmail.com" #set your mail account
$Destinatario = "test2@gmail.com" #set receiver mail account
$Sub = "Vencimiento de password"
$anonUser = "anonymous"
$anonPass = ConvertTo-SecureString "anonymous" -AsPlainText -Force
$anonCred = New-Object System.Management.Automation.PSCredential($anonUser, $anonPass)
$Smtpsvr = "192.1.1.2" #put smtp server
ExpirationDays = 120 #Set days for password expiration
AdvisorDate = -15 #Set days to validate before block

ForEach ($user in $AcsExp)
{
    $Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
    $PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
    $nroEmpleado = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber
  
    #Validating if user is enabled, password expiration is active and user has EmployeeNumber

    if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($nroEmpleado)))
    {
        $FechaPasswordLastSet = Get-ADUser -Filter "Name -like '$user'" -properties PasswordLastSet | select-object -ExpandProperty PasswordLastSet
        $FechaVencimiento = $FechaPasswordLastSet.AddDays(ExpirationDays) 
        $FechaVencimiento_Resta15 = $FechaVencimiento.AddDays(AdvisorDate) 
        #$FechaVencimiento_Resta12 = $FechaVencimiento_Resta12.ToString("dd/MM/yyyy")
        $FechaVencimientoToString = $FechaVencimiento.ToString("dd/MM/yyyy")
        $prop="Name","DisplayName","UserPrincipalName"

        #Validating dates
        if ($FechaHoy -ge $FechaVencimiento_Resta15 -and $FechaPasswordLastSet -like "*2020*")
            
            {
                $data = Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
                Select-Object -Property $prop | 
                ConvertTo-Csv -NoTypeInformation |     
                Select-Object -Skip 1
                $lista = $lista + $data + "," + $FechaVencimientoToString + "`n"
                
                Write-Output $User
                Write-Output $FechaHoy
                Write-Output $FechaVencimiento_Resta15
                Write-Output "`n"
            }
    }
}
write $lista | Out-File export1.txt
$export = 'export1.txt'
Send-MailMessage -to $Destinatario -from $fromusr -subject "$sub " -body "Lista de usuarios con vencimiento de pass <= a 15 dias`n`n Vencimiento 120 dias" -Attachments $export -SmtpServer $Smtpsvr -Credential $anonCred
