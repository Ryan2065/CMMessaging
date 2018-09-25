Import-Module "$PSScriptRoot\CMMessaging" -Force

Publish-Module -Name 'CMMessaging' -NuGetApiKey $env:NuGetKey -Force

