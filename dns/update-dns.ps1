# update-dns.ps1
# script to update all the servers in .\servers.txt file
# written by Hugh Patterson 19/02/2016
# last updated 19/02/2016

$DNSServers = "1.2.3.4","5.6.7.8"

$servers = get-content .\servers.txt

foreach($server in $servers) {
    Write-Host "Starting on" $server
    Write-Host "--------------------------"
    if (Test-Connection -Count 1 -Quiet -ComputerName $server) {
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server | where {($_.IPEnabled -eq “FALSE") -and ($_.DHCPEnabled -eq $False)} 

        foreach($NIC in $NICs) {
            Write-Host "DNS servers before change:"
            $NIC.DNSServerSearchOrder
    
            $NIC.SetDNSServerSearchOrder($DNSServers)
            $NIC.SetDynamicDNSRegistration(“TRUE”)
        }
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server | where {($_.IPEnabled -eq “FALSE") -and ($_.DHCPEnabled -eq $False)} 
    
        Write-Host "DNS servers after change:"
        $NICs.DNSServerSearchOrder
    }    
    else {
    Write-Host $server "is down" -ForegroundColor Red
    } 
    Write-Host
}
Write-Host "Finished updating DNS servers."