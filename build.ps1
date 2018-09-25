#Import-Module "$PSScriptRoot\CMMessaging" -Force

Publish-Module -Path "$PSScriptRoot\CMMessaging" -NuGetApiKey $env:NuGetKey -Force

