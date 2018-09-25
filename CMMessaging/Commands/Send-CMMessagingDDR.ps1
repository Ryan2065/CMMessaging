Function Send-CMMessagingDDR {
    Param(
        [Parameter(Mandatory=$false)]
        [string]$ADSiteName = 'Default-First-Site-Name'
    )
    if($null -eq $Script:CMMessagingClient){
        throw 'Please first run Set-CMMessagingClient to set the client information!'
        return
    }
    $Sender = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender
    $DDRMessage = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrDataDiscoveryRecordMessage]::new()
    $DDRMessage.SmsId = $Script:CMMessagingClient.ClientGUID
    $DDRMessage.ADSiteName = $ADSiteName
    $DDRMessage.SiteCode = $Script:CMMessagingClient.SiteCode
    $DDRMessage.DomainName = $Script:CMMessagingClient.Domain
    $DDRMessage.NetBiosName = $Script:CMMessagingClient.ClientName
    [void]$DDRMessage.Discover()
    $DDRMessage.AddCertificateToMessage($Script:CMMessagingClient.SigningCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Signing)
    $DDRMessage.AddCertificateToMessage($Script:CMMessagingClient.EncryptionCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Encryption)
    $DDRMessage.Settings.HostName = $Script:CMMessagingClient.ManagementPoint
    $DDRMessage.Settings.Compression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
    $DDRMessage.Settings.ReplyCompression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
    [void]$DDRMessage.SendMessage($Sender)
}