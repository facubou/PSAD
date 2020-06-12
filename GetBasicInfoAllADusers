$AcsExp = Get-ADUser -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name

 ForEach ($user in $AcsExp)
 {
	$Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
	$PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
  $prop="Name","DisplayName","UserPrincipalName","Title","Department"
  $dep = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber

	if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($dep)))
		{
            Write-Output (Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
            Select-Object -Property $prop | 
            ConvertTo-Csv -NoTypeInformation |     
            Select-Object -Skip 1)
			#Write-Output (Get-ADUser -Filter "Name -like '$user'" -properties $prop | ConvertTo-Csv -NoTypeInformation)

        }

 }#For
