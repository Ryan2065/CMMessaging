Function Register-CMMessagingClient {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AgentIdentity = 'CMMessagingCmdlet'
    )
    if($null -eq $Script:CMMessagingClient){
        throw 'Please first run Set-CMMessagingClient to set the client information!'
        return
    }
    $Sender = New-Object -TypeName Microsoft.ConfigurationManagement.Messaging.Sender.Http.HttpSender
    $Request = [Microsoft.ConfigurationManagement.Messaging.Messages.ConfigMgrRegistrationRequest]::new()
    [void]$Request.AddCertificateToMessage($Script:CMMessagingClient.SigningCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Signing)
    [void]$Request.AddCertificateToMessage($Script:CMMessagingClient.EncryptionCertificate, [Microsoft.ConfigurationManagement.Messaging.Framework.CertificatePurposes]::Encryption)
    $Request.Settings.HostName = $Script:CMMessagingClient.ManagementPoint
    [void]$Request.Discover()
    $Request.AgentIdentity = $AgentIdentity
    $Request.ClientFqdn = $Script:CMMessagingClient.ClientName + "." + $Script:CMMessagingClient.Domain
    $Request.NetBiosName = $Script:CMMessagingClient.ClientName
    $Request.Settings.Compression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
    $request.Settings.ReplyCompression = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCompression]::Zlib
    
    # After contacting the site server, they reply back with the GUID the site server is going to use. Set that for other modules to use.
    $Script:CMMessagingClient.ClientGUID = $request.RegisterClient($Sender, [TimeSpan]::FromMinutes(5))
}