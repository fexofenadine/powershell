# maps a disk on startup of calibre and unmounts it when the the calibre.exe process/app is closed
# could easily be modified to work for iTunes or any other disks that need to be mounted on demand for a single app
# you can create a shortcut to run this like this: 
# "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -file "c:\path\to\Start-Calibre.ps1" -WindowStyle hidden 
# or just edit your existing calibre shortcut if you want to keep the pretty icon
# you may need to enable the execution of unsigned scripts to get this to run on win10

New-PSDrive -Name "E" -PSProvider FileSystem -Root "[\\path\to\ebooks]" -Persist
& "C:\Program Files\Calibre2\calibre.exe"
Wait-Process -Name "calibre"
Remove-PSDrive -Name "E"
