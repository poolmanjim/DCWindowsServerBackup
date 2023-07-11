
<# 
    .SYNOPSIS 
    DCWeeklyBackup.ps1: Configures a Weely Bare Metal Backup Scheduled Task
    
    .DESCRIPTION 
    DCWSBWeeklyScheduledTask.ps1: Configures a Weely Bare Metal Backup Scheduled Task to the R drive of the DC by default. 
    Reads off the "DCBackupSettings.ps1" file to peform the backup. 

    .NOTES
    Created By: Tyler Jacobs
    Created On: 07/11/2023
    Version: 1.0
#>

$ExcludedDomains = ""
$Domains = (Get-ADForest).Domains.Where({ $ExcludedDomains -notcontains $Domain })
$DomainPDCList = [System.Collections.Generic.List[string]]::new()

$WeeklyBackupSB = {
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument '-NoProfile -File C:\Scripts\Backups\DCBackupSettings.ps1' 
    $Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Sunday -At 19:00
    $Principal = New-ScheduledTaskPrincipal -UserID "SYSTEM" -LogonType ServiceAccount -RunLevel Highest 
    $Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 02:00:00
    $Task = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigger -Settings $Settings
    Register-ScheduledTask -TaskName "Weekly Server Backup - BMR" -InputObject $Task
}

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

$null = Invoke-Command -ComputerName $DomainPDCList -ScriptBlock $WeeklyBackupSB