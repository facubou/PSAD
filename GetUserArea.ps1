#Script get the middle of canonicalName for extract user's area
$Usuarios = get-content -path "C:\temp\users.txt.txt"

ForEach ($user in $usuarios)
{
    $unico = (((Get-ADUser -Filter "Name -like '$user'" -Properties CanonicalName | select-object -ExpandProperty CanonicalName) -split "/") | select -Skip 1) -join ','
    $parse = $unico.Substring(0, $unico.IndexOf(',')) -replace '_', ' '
    $salida = ( Get-Culture ).TextInfo.ToTitleCase( $parse.ToLower() )
    Write-Host "$user,$salida"
}
