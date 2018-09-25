Function Set-CMMessagingClient {
    <#
        .SYNOPSIS
        Will set interal settings for the messaging client

        .DESCRIPTION
        The messaging client needs some information before it can send a message. This sets the client setttings so
        we know the computer name, SCCM server information, and client certificate. If this is run with no parameters
        it is in "local client" mode and will just use the settings of the current computer. This may need to be run
        from an elevated session depending on what settings it needs to get.

        .PARAMETER ManagementPoint
        The management point server name. If not supplied, will be detected from WMI

        .PARAMETER ClientName
        Name of the computer we are sending information on. If not supplied, it will use $env:ComputerName

        .PARAMETER Domain
        Domain name of the Client. If not supplied, will use [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName

        .PARAMETER SiteCode
        Site code of the client. If not supplied, will get it from WMI. 

        .PARAMETER CertFilePath
        File path of the certificate. If not supplied and ClientName = Current computer name, will use current computers certificate. If not, will generate one.

        .PARAMETER CertificatePassword
        Password of certificate file

        .PARAMETER ClientGUID
        GUID of the client.

        .EXAMPLE
        Set-CMMessagingClient
        Will set up module to send messages as the current computer. *Note, this may need admin rights as it needs to read from root\ccm WMI*

        .EXAMPLE
        Set-CMMessagingClient -ClientName 'UniqueComputerName'
        Will set up the module to send messages as a "fake" computer. Certificate information will be generated on the fly.

        .EXAMPLE
        Set-CMMessagingClient -ClientName 'UniqueComputerName' -CertFilePath 'C:\MyCert.pfx' -CertificatePassword (ConvertTo-SecureString 'P@ssw0rd')
        Will send messages as a "fake" computer using the specified certificate.

        .NOTES
        General notes
    #>    
    [CmdletBinding(DefaultParameterSetName='DefaultSet')]
    
    Param (
        [Parameter(Mandatory=$false, ParameterSetName='DefaultSet')]
        [Parameter(Mandatory=$false, ParameterSetName='CertFilePath')]
        [string]$ManagementPoint,
        [Parameter(Mandatory=$false, ParameterSetName='DefaultSet')]
        [Parameter(Mandatory=$false, ParameterSetName='CertFilePath')]
        [string]$ClientName,
        [Parameter(Mandatory=$false, ParameterSetName='DefaultSet')]
        [Parameter(Mandatory=$false, ParameterSetName='CertFilePath')]
        [string]$Domain,
        [Parameter(Mandatory=$false, ParameterSetName='DefaultSet')]
        [Parameter(Mandatory=$false, ParameterSetName='CertFilePath')]
        [string]$SiteCode,
        [Parameter(Mandatory=$false, ParameterSetName='DefaultSet')]
        [Parameter(Mandatory=$false, ParameterSetName='CertFilePath')]
        [guid]$ClientGUID,
        [Parameter(Mandatory=$true, ParameterSetName='CertFilePath')]
        [string]$CertFilePath,
        [Parameter(Mandatory=$true, ParameterSetName='CertFilePath')]
        [SecureString]$CertificatePassword
    )
    $Script:CMMessagingClient = @{}
    
    #region Management Point Lookup
    if([String]::IsNullOrEmpty($ManagementPoint)){
        $ManagementPoint = (Get-CimInstance -ClassName SMS_Authority -Namespace 'root\ccm').CurrentManagementPoint
    }
    $Script:CMMessagingClient.ManagementPoint = $ManagementPoint
    #endregion

    #region Client Name
    if([string]::IsNullOrEmpty($ClientName)){
        $ClientName = $env:COMPUTERNAME
    }
    $Script:CMMessagingClient.ClientName = $ClientName
    #endregion

    #region Domain
    if([string]::IsNullOrEmpty($Domain)){
        $Domain = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName
    }
    $Script:CMMessagingClient.Domain = $Domain
    #endregion

    #region SiteCode
    if([string]::IsNullOrEmpty($SiteCode)){
        $SiteCode = (Invoke-CimMethod -ClassName 'SMS_Client' -Namespace 'root\ccm' -MethodName 'GetAssignedSite').sSiteCode
    }
    $Script:CMMessagingClient.SiteCode = $SiteCode
    #endregion

    #region Client GUID
    if($ClientGUID) {
        # Constructor takes type GUID
        $Script:CMMessagingClient.ClientGUID = [Microsoft.ConfigurationManagement.Messaging.Framework.SmsClientId]::new($ClientGUID)
    }
    else {
        if($env:COMPUTERNAME -eq $ClientName) {
            $strClientGUID = (Get-CimInstance -ClassName CCM_Client -Namespace 'root\ccm').ClientId
            #Constructor takes well formatted string type of GUID or GUID:<GUID> (like CM stores it)
            $Script:CMMessagingClient.ClientGUID = [Microsoft.ConfigurationManagement.Messaging.Framework.SmsClientId]::new($strClientGUID)
        }
        else {
            #Generate new GUID
            $Script:CMMessagingClient.ClientGUID = [Microsoft.ConfigurationManagement.Messaging.Framework.SmsClientId]::new()
        }
    }
    #endregion

    #region CertFilePath
    if([string]::IsNullOrEmpty($CertFilePath)){
        if($env:COMPUTERNAME -eq $ClientName) {
            Write-Verbose -Message 'Current computer mode - Getting client certificate from LocalMachine\SMS certificate store'
            $Cert = (@(Get-ChildItem -Path 'Cert:\LocalMachine\SMS' | Where-Object { $_.FriendlyName -eq 'SMS Signing Certificate' }) | Sort-Object -Property NotBefore -Descending)[0]
            $Script:CMMessagingClient.SigningCertificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]::new('SMS', $Cert.Thumbprint)
            $Cert = (@(Get-ChildItem -Path 'Cert:\LocalMachine\SMS' | Where-Object { $_.FriendlyName -eq 'SMS Encryption Certificate' }) | Sort-Object -Property NotBefore -Descending)[0]
            $Script:CMMessagingClient.EncryptionCertificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509File]::new('SMS', $Cert.Thumbprint)
        }
        else {
            Write-Verbose -Message 'Fake computer mode - Setting client certificate to generated certificate'
            $Script:CMMessagingClient.SigningCertificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509]::CreateSelfSignedCertificate(
                'SCCM Test Certificate',
                'SCCM Signing Certificate',
                @('2.5.29.37'),
                (Get-Date).AddMinutes(-5),
                (Get-Date).AddYears(5)
            )
            $Script:CMMessagingClient.EncryptionCertificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509]::CreateSelfSignedCertificate(
                'SCCM Test Certificate',              #Subject Name
                'SCCM Encryption Certificate',        #Friendly Name
                @('2.5.29.37'),                       #oid purposes
                (Get-Date).AddMinutes(-5),            #Issue by date
                (Get-Date).AddYears(5)                #Expiration Date
            )
        }
    }
    else {
        Write-Verbose -Message ('Certificate file mode - Setting client certificate to file {0}' -f $CertFilePath)
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($CertificatePassword)
        $StringPW = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        $Script:CMMessagingClient.SigningCertificate = [Microsoft.ConfigurationManagement.Messaging.Framework.MessageCertificateX509Volatile]::new(
            $CertFilePath,
            $StringPW
        )
        $Script:CMMessagingClient.EncryptionCertificate = $Script:CMMessagingClient.SigningCertificate
    }
    #endregion

}