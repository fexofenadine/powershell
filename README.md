# powershell
My Windows Powershell scripts repository

/capacity
  - contains scripts for determining host capacity levels for both vCenter/VMWare and SCVMM/Hyper-V servers.
  
/dns
  - contains scripts for exporting and modifying the DNS servers of a server list.
  
/filesystem
  - Start-Calibre.ps1: maps a disk on startup of calibre and unmounts it when the the calibre.exe process/app is closed

/id3tag
  - remove-dupeimages.ps1: finds mp3 and flac files within the specified directory that have more than one embedded image and removes all but the first image. (requires taglib, taglib-sharp.dll)
  
/listservers
  - contains a script for listing every Windows server in your domain.
 
/logoffeverywhere
  - contains a script for checking to see if a user is logged into any server in a server list, and optionally log them off (good for account lockouts).
 
/SCOM
  - contains a script for checking the SCOM maintenance mode status of machines, and modifying the state.  GUI enabled.
