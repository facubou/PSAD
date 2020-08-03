$computers = 'PC0765342'
$sourcefile = "\\ServerName\Desktop\agent_cloud_x64.msi"

$jobscript = {
	Param($computer)
	$destinationFolder = "\\$computer\C$\Temp"
	if (!(Test-Path -path $destinationFolder)) {
		New-Item $destinationFolder -Type Directory
	}
	Copy-Item -Path $sourcefile -Destination $destinationFolder
	Invoke-Command -ComputerName $computer -ScriptBlock { Msiexec c:\temp\agent_cloud_x64.msi /i  /log C:\MSIInstall.log }
}

$computer | 
	ForEach-Object{
		Start-Job -ScriptBlock $jobscript -ArgumentList $_ -Credential $domaincredentail
	}
