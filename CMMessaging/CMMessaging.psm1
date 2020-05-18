Add-Type -Path "$PSScriptRoot\bin\Microsoft.ConfigurationManagement.Messaging.dll"

Add-Type -Path "$PSScriptRoot\bin\Microsoft.ConfigurationManagement.Security.Cryptography.dll"

$Commands = Get-ChildItem "$PSScriptRoot\Commands" -Filter '*.ps1'

Foreach($Command in $Commands) {
    . $Command.FullName
}

Export-ModuleMember -Function $Commands.BaseName