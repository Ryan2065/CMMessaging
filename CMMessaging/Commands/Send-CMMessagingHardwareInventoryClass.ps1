Function Send-CMMessagingHardwareInventoryClass{
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Classes,
        [string]$Namespace = 'root\cimv2'
    )
    if($null -eq $Script:CMMessagingClient){
        throw 'Please first run Set-CMMessagingClient to set the client information!'
        return
    }
    $Sender = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender
    $HwInvMessage = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrHardwareInventoryMessage]::new()
    $HwInvMessage.Settings.HostName = $Script:CMMessagingClient.ManagementPoint
    $HwInvMessage.SmsId = $Script:CMMessagingClient.ClientGUID
    [void]$HwInvMessage.Discover()
    foreach($class in $Classes){
        [void]$HwInvMessage.AddInstancesToInventory( [Microsoft.ConfigurationManagement.Messaging.Messages.WmiClassToInventoryReportInstance]::WmiClassToInventoryInstances($Namespace, $class) )
    }
    $HwInvMessage.AddCertificateToMessage($Script:CMMessagingClient.SigningCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Signing)
    $HwInvMessage.AddCertificateToMessage($Script:CMMessagingClient.EncryptionCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Encryption)
    [void]$HwInvMessage.Validate($Sender)
    [void]$HwInvMessage.SendMessage($Sender)
}