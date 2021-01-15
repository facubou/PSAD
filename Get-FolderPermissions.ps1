$AllFolders = Get-ChildItem -Directory -Path "\\folder\" -Recurse -Force
$Results = @()
Foreach ($Folder in $AllFolders) {
    $Acl = Get-Acl -Path $Folder.FullName
    foreach ($Acceso in $acl.Access) {
        if ($Acceso.IdentityReference -notlike "BUILTIN\Administrators" -and $Acceso.IdentityReference -notlike "DOMAIN\Domain Admins" -and $Acceso.IdentityReference -notlike "CREATOR OWNER" -and $Acceso.IdentityReference -notlike "NT AUTHORITY\SYSTEM") {
            $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD Group'=$Acceso.IdentityReference;'Permisos'=$Acceso.FileSystemRights;'Inherited'=$Acceso.IsInherited}
            $Results += New-Object -TypeName PSObject -Property $Properties
        }
    }
}

$Results | Export-Csv -path "C:\temp\UsuariosConPermisos - $(Get-Date -Format HH_mm).csv"
