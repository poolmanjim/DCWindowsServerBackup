<# 
    .SYNOPSIS 
    Copy-DCWSBSettingsFile.ps1: SSE-CIS Copies the DCBackupSettings.ps1 file to each PDC.
    
    .DESCRIPTION 
    Copy-DCWSBSettingsFile.ps1: SSE-CIS Copies the DCBackupSettings.ps1 file to each PDC.
    This file is used by the scheduled task to determine which backup settings to use. 

    .NOTES
    Created By: Tyler Jacobs
    Created On: 07/11/2023
    Version: 1.0
#>

$ExcludedDomains = ""
$Domains = (Get-ADForest).Domains.Where({ $ExcludedDomains -notcontains $Domain })
$DomainPDCList = [System.Collections.Generic.List[string]]::new()

# Loop through the domains add the DCs we find to the $DomainPDCList
foreach( $Domain in $Domains )
{
    $WSBConfigFilePath = "\\{0}\c$\Scripts\Backups"
    # Find PDC
    Try
    {
        $DomainPDC = (Get-ADDomainController -DomainName $Domain -Discover -Service PrimaryDC -ErrorAction Stop).Hostname

        # Get-ADDOmainController returns the name as a collection, let's make it a single item
        if( $DomainPDC -is [System.Collections.ICollection] )
        {
            $DomainPDC = $DomainPDC[0]
        }

        $WSBConfigFilePath = [string]::Format($WSBConfigFilePath,$DomainPDC)
    }
    Catch
    {
        Write-Error "Unable to locate PDC Emulator DC in domain '$Domain'"
        throw $PSItem
    }

    # Settings Directory Creation
    if( !(Test-Path -Path $WSBConfigFilePath) )
    {
        Try
        {
            $null = New-Item -Path $WSBConfigFilePath -ItemType Directory -ErrorAction Stop -Verbose:$VerbosePreference -WhatIf:$WhatIfPreference
            Write-Output "$DomainPDC`: Created $WSBConfigFilePath"

            if( $WhatIfPreference )
            {
                Write-Information "Cannot continue Whatif testing without the acutal path created"
                break
            }
        }
        Catch
        {
            Write-Error "Unable to create path '$WSBConfigFilePath' on $DomainPDC"
            throw $PSItem
        }
    }

    # Copy Settings File
    Try
    {
        $null = Copy-Item -Path "C:\Scripts\DCBackupsSettings\DCBackupSettings.ps1" -Destination $WSBConfigFilePath -ErrorAction Stop -Verbose:$VerbosePreference -WhatIf:$WhatIfPreference
        Write-Output "$DomainPDC`: Copied 'DCBackupSettings.ps1' to DC"
    }
    Catch
    {
        Write-Error "Unable to copy 'DCBackupSettings.ps1' to '$WSBConfigFilePath' on $DomainPDC"
        throw $PSItem
    }
}