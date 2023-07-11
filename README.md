# DCWindowsServerBackup
Configures Windows Server Backup for DCs 

The goal of this procedure is to configure Bare Metal Backups on the PDC Emulator of every forest in the domain.

This process requires a network storage location with sufficient storage to sustain all the backups and the computers themselves who will be performing the backups need modify permissions to the share created. 

## PROCESS
1. Copy the DCBackupSettings.ps1 file to C:\scripts\Backups on the target DCs. (This is automated already via Copy-DCWSBSettingsFile.ps1). 
2. Install Windows Server Backup on the target systems (This can be automated via WSBDCInstall.ps1).
3. Configure and test Windows Server Backup by running DCBackupSettings.ps1.
- In this file the BackupLocation network path needs to be changed from "\\TESTMGMT01.test.contoso.com\DCBACKUPS"
- This defaults to the local machine's credentials (when run automated, Local User if run interactively). 
4. Configure the Secheduled Task by running DCWSBWeeklyScheduledTask.ps1.
- This script targets the DCBackupSettings.ps1 file and uses it to define the steps done in the scheduled task.
- This backs up on Sunday at 7pm every week.
- Task is run as a SYSTEM meaning it uses the local system's credentials to access the share.
- This is limited to only take up to 2 hours. Any more and it will time out.
- It is named "Weekly Server Backup - BMR".
