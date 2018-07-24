# maps a disk on startup of calibre and unmounts it when the the calibre.exe process/app is closed
# could easily be modified to work for iTunes or any other disks that need to be mounted on demand for a single app

New-PSDrive -Name "E" -PSProvider FileSystem -Root "[\\path\to\ebooks]" -Persist
& "C:\Program Files\Calibre2\calibre.exe"
Wait-Process -Name "calibre"
Remove-PSDrive -Name "E"
