<# 
    .SYNOPSIS 
    DCBackupSettings.ps1: Windows Server Backup Backup Settings
    
    .DESCRIPTION 
    This defines the backup settings needed to do a weekly backup. This script is simply the Windows Backup components. 
    The scheduled task "Weekly Server Backup" defines the period of backup. 

    .NOTES
    Created By: Tyler Jacobs
    Created On: 07/11/2023
    Version: 1.0
#>
# Do not change anything past this point.
$BackupPolicy = New-WBPolicy 
$BackupLocation = New-WBBackupTarget -NetworkPath "\\TESTMGMT01.test.contoso.com\DCBACKUPS"
Add-WBBackupTarget -Policy $BackupPolicy -Target $BackupLocation
Add-WBBareMetalRecovery -Policy $BackupPolicy
Add-WBSystemState -Policy $BackupPolicy
Start-WBBackup -Policy $BackupPolicy


Start-ScheduledTask -TaskName "Weekly Server Backup - BMR"