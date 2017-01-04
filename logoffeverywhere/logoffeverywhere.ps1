# Script to list every server a user is logged onto and optionally log the user off everywhere.
#
# Written by Hugh Patterson 2015.08.11
#
# Edit the target username in '$username = "target"'
# Make sure a servers.txt list file exists.  This can be produced with the script listservers.ps1

$username = "hugh.patterson"

Function LogoffAll ($server, $username)
{
	$script:count++
	$session = ((quser /server:$server | ? { $_ -match $username }) -split ' +')[2]
	if ($session -notlike "") {
		Write-Output "$($count) $($server) $($session)" | Out-File $($username + ".log") -Append
        
# uncomment the following line if you want the user to be logged off everywhere they are found
        #logoff $session /server:$server
	}
}

$script:count = 0
$serverlist = Get-Content servers.txt
Write-Output $("Logged in sessions found for " + $username + "`r`n------------------------------------------------") | Out-File $($username + ".log")
ForEach ($server in $serverlist) { 
    LogoffAll $server $username
    Write-Progress -Activity $("Checking for logins for " + $username) -Status $("Server " + $script:count + " of " + $serverlist.count + ": " + $server) -PercentComplete (($script:count/$serverlist.count)*100)
}