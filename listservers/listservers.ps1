# Script to list every Windows server in the domain.
#
# Written by Hugh Patterson 2015.08.11

Function Get-Servers {
$strCategory = "computer"
$strOS = "Windows*Server*"
$name = "*" #string to search for in name
$strLongAgo = (get-date).adddays(-90).ToString("yyyyMMddHHmmss.0Z") # produces date of 90 days ago for AD activity comparison

$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.sizelimit = 100000 # prevent 1000 result limit
$objSearcher.pagesize = 1000 
$objSearcher.SearchRoot = $objDomain
$objSearcher.Filter = ("(&(Name=$name)(objectCategory=$strCategory)(OperatingSystem=$strOS)(whenChanged>=$strLongAgo))")

$colProplist = "name"#,"description"                                         uncomment to include description
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i) | Out-Null}

$colResults = $objSearcher.FindAll()
$report = @()
foreach ($objResult in $colResults) {
  $objComputer = $objResult.Properties
  $temp = New-Object PSObject
  $temp | Add-Member NoteProperty Server $($objcomputer.name) 
  # $temp | Add-Member NoteProperty Description $($objcomputer.description)   uncomment to include description
  $report += $temp
  }
Return $report  
}
Get-Servers | Export-Csv -notypeinformation 'servers.csv'