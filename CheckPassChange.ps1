
#Check if password was changed in last 30 days and send mail with users out of compliance

$AcsExp = Get-ADUser -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name
$FechaHoy = Get-Date

$Fromusr = "yourmailaccoint@domain.com"
$Destinatario = "destinationmailaccount@domain.com"
$Sub = "Seteo de password"
$anonUser = "anonymous"
$anonPass = ConvertTo-SecureString "anonymous" -AsPlainText -Force
$anonCred = New-Object System.Management.Automation.PSCredential($anonUser, $anonPass)
$Smtpsvr = "192.168.1.40" #your smtp server

ForEach ($user in $AcsExp)
{
    $Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
    $PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
    $nroEmpleado = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber

    if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($nroEmpleado)))
    {
        $FechaPasswordLastSet = Get-ADUser -Filter "Name -like '$user'" -properties PasswordLastSet | select-object -ExpandProperty PasswordLastSet
        $FechaHoy_Resta30 = $FechaHoy.AddDays(-30)
        
        $prop="Name","DisplayName","UserPrincipalName"

        if ($FechaHoy_Resta30 -ge $FechaPasswordLastSet -and $FechaPasswordLastSet -like "*2020*")
            
            {
                $data = Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
                Select-Object -Property $prop | 
                ConvertTo-Csv -NoTypeInformation |     
                Select-Object -Skip 1
                $lista = $lista + $data + "," + $FechaVencimientoToString + "`n"
                $Contador = $Contador +1

                Write-Output ("[#] User "+$User)
                Write-Output ("[#] Last Pass Change "+$FechaPasswordLastSet)
                Write-Output "`n"
            }
    }
}
Write-Output $Contador
write $lista | Out-File export1.txt
$export = 'export1.txt'
Send-MailMessage -to $Destinatario -from $fromusr -subject "$sub " -body "Lista de usuarios con seteo de pass >= 30 dias" -Attachments $export -SmtpServer $Smtpsvr -Credential $anonCred
