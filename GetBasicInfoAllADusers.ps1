$AcsExp = Get-ADUser -Filter {Name -like "*"} -properties Name | select-object -ExpandProperty Name

 ForEach ($user in $AcsExp)
 {
	$Enabled = Get-ADUser -Filter "Name -like '$user'" -properties Enabled | select-object -ExpandProperty Enabled
	$PassExpira = Get-ADUser -Filter "Name -like '$user'" -properties PasswordNeverExpires | select-object -ExpandProperty PasswordNeverExpires
  	
	#Creating variable to export info
	$prop="Name","DisplayName","UserPrincipalName","Title","Department"
  	
	#Get Employee Number
	$dep = Get-ADUser -Filter "Name -like '$user'" -properties EmployeeNumber | select-object -ExpandProperty EmployeeNumber

	#Chicking if user has employee number and the pass not expires
	if ($Enabled -eq $true -and $PassExpira -eq $false -and -not ([string]::IsNullOrEmpty($dep)))
		{
            Write-Output (Get-ADUser -Filter "Name -like '$user'" -properties $prop | 
            Select-Object -Property $prop | 
            ConvertTo-Csv -NoTypeInformation |     
            Select-Object -Skip 1)
	    
        }

 }
