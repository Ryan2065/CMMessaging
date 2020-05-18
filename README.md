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
Set-CMMessagingClient -ClientName 'MyFakeComputer'
```

Once Set-CMMessagingClient is run, you can run any of the other commands! If you'd like to send a hardware inventory class as the current computer, use this:

``` PowerShell
Set-CMMessagingClient
Send-CMMessagingHardwareInventoryClass -Classes 'Win32_ComputerSystem'
```

The above command will immediately send a hardware inventory message as the current computer with Win32_ComputerSystem included. **Note** this will bypass the hardware inventory cycle, AND send the class even if it's not set to be collected on this computer. The site server will process whatever class you tell it to with these cmdlets even if it's not set in Client Settings. I think that's cool but am not sure what to do with it. Feel free to come up with something!

Quickest way to fill your environment with a ton of fake data?

``` PowerShell
Install-Module CMMessaging -Scope CurrentUser
Import-Module CMMessaging
$WMIClasses=@("Win32_ComputerSystem","Win32_OperatingSystem","Win32_BIOS","Win32_SystemEnclosure","Win32_NetworkAdapter","Win32_NetworkAdapterConfiguration","Win32_DiskDrive","Win32_DiskPartition","Win32_Service","Win32Reg_AddRemovePrograms","CCM_LogicalMemoryConfiguration","Win32_POTSModem","Win32_DesktopMonitor","Win32_PhysicalMemory","Win32_ServerFeature","Win32_ParallelPort","Win32Reg_SMSGuestVirtualMachine64","Win32_USBController","Office365ProPlusConfigurations","Win32_NetworkClient","Win32Reg_SMSWindowsUpdate","Win32_MotherboardDevice","Win32_SoundDevice","Win32Reg_SMSGuestVirtualMachine","Win32Reg_SMSAdvancedClientSSLConfiguration","Win32_IDEController","Win32_VideoController","Win32_SCSIController","Win32_TapeDrive")
1..1000 | foreach-object {
    Set-CMMessagingClient -ClientName "FakeComp-$($_)"
    Register-CMMessagingClient
    Send-CMMessagingHardwareInventoryClass -Classes $WMIClasses
}
```
