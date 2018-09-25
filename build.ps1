Import-Module .\CMMessaging -Force

Publish-Module -Name 'CMMessaging' -NuGetApiKey $env:NuGetKey

