# get-dns.ps1
# script to list the DNS servers of the machines in .\servers.txt file
# if you'd like a spreadsheet, you can pipe output like so:
#         .\get-dns.ps1 > output.csv
# otherwise it will mix output in a human readable format to console.
#
# written by Hugh Patterson 19/02/2016
# last updated 19/02/2016

$servers = get-content .\servers.txt

foreach($server in $servers) {
    Write-Host "Starting on" $server
    Write-Host "--------------------------"
    if (Test-Connection -Count 1 -Quiet -ComputerName $server) {
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server | where {($_.IPEnabled -eq “FALSE") -and ($_.DHCPEnabled -eq $False)} 

        foreach($NIC in $NICs) {

            $DNSServers = $NIC.DNSServerSearchOrder
            $DNSServers = $DNSServers -join "`t"
            $output = -join ($server, "`t",$DNSServers)
            $output
        }
    }    
    else {
    Write-Host $server "is down" -ForegroundColor Red
    } 
    Write-Host
}
Write-Host "Finished getting DNS servers."