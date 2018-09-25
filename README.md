# CMMessaging

PowerShell module to expose functionality of the Messaging pieces of the SDK

This module relies on the [Microsoft Configuration Management Messaging SDK](https://www.nuget.org/packages/Microsoft.ConfigurationManagement.Messaging/). The license for this can be found [here.](https://aka.ms/configmgrsdklicense)

## Getting started

Please install the module from the gallery with this command:

``` PowerShell
Install-Module CMMessaging
```

All commands will require you to first set the Client. To just use local settings, you can run this command:

``` PowerShell
Set-CMMessagingClient
```

To set a "fake" client, you can use this command:

``` PowerShell
Set-CMMessagingClient -ClientName 'MyFakeComputer' -CertFilePath 'c:\MyCert.pfx' -CertificatePassword 'P@ssw0rd'
```

Once Set-CMMessagingClient is run, you can run any of the other commands! If you'd like to send a hardware inventory class as the current computer, use this:

``` PowerShell
Set-CMMessagingClient
Send-CMMessagingHardwareInventoryClass -Classes 'Win32_ComputerSystem'
```

The above command will immediately send a hardware inventory message as the current computer with Win32_ComputerSystem included. **Note** this will bypass the hardware inventory cycle, AND send the class even if it's not set to be collected on this computer. The site server will process whatever class you tell it to with these cmdlets even if it's not set in Client Settings.