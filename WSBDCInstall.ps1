<# 
    .SYNOPSIS 
    WSBDCInstall.ps1: Installs Windows Server Backup on the PDCs in all the child domains.
    
    .DESCRIPTION 
    Installs the Windows Server Backup feature on all PDCs in all the child domains. 
    Does not exclude the root domain.  Part 1 of the Install and Configure Windows Server Backup Services Workplan.

    .NOTES
    Created By: Tyler Jacobs
    Created On: 07/11/2023
    Version: 1.0
#>

$ExcludedDomains = ""
$Domains = (Get-ADForest).Domains.Where({ $ExcludedDomains -notcontains $Domain })
$BatchSize = 50 # Determines how many DCs we install on at a given time.
$DomainPDCList = [System.Collections.Generic.List[string]]::new()

# Loop through the domains add the DCs we find to the $DomainPDCList
foreach( $Domain in $Domains )
{
    Try
    {
        $DomainPDCList.Add( (Get-ADDomainController -DomainName $Domain -Discover -Service PrimaryDC -ErrorAction Stop).Hostname )
    }
    Catch
    {
        Write-Error "Unable to locate PDC Emulator DC in domain '$Domain'"
    }
}

# Clone the list. 
$CloneDomainPDCList = [System.Collections.Generic.List[String]]::new($DomainPDCList)

$BatchCount = 1

# Loop through the Cloned List
while( $CloneDomainPDCList.Count -gt 0 )
{
    # Grab $BatchSize Dcs, we'll target them first.
    $BatchPDCs = $CloneDomainPDCList | Select-Object -First $BatchSize

    Write-Host "Starting Batch $BatchCount..."
    Invoke-Command -ComputerName $BatchPDCs -ScriptBlock { Install-WindowsFeature -Name "Windows-Server-Backup" }
    $CloneDomainPDCList.RemoveRange(0,$BatchPDCs.Count) # Remove the ones we've done
    $BatchCount++
    Write-Output "`tWaiting for 15 minutes between batches"
    Start-Sleep -Seconds 900 # 15 minutes
}