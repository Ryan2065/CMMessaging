Add-Type -Path "$PSScriptRoot\bin\Microsoft.ConfigurationManagement.Messaging.dll"

$Commands = Get-ChildItem "$PSScriptRoot\Commands" -Filter '*.ps1'

Foreach($Command in $Commands) {
    . $Command.FullName
}

Export-ModuleMember -Function $Commands.BaseName