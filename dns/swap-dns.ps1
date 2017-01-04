# swap-dns.ps1
# script to update all the servers in .\servers.txt file
# will swap the DNS server $DNSInitial if found on any server to $DNSFinal
# written by Hugh Patterson 19/02/2016
# last updated 19/02/2016


$DNSInitial = "1.2.3.4" 
$DNSFinal = "4.3.2.1"

$servers = get-content .\servers.txt

foreach($server in $servers) {
    Write-Host "Starting on" $server
    Write-Host "--------------------------"
    if (Test-Connection -Count 1 -Quiet -ComputerName $server) {
        $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $server | where {($_.IPEnabled -eq “FALSE") -and ($_.DHCPEnabled -eq $False)} 

        foreach($NIC in $NICs) {
            Write-Host "DNS servers before change:"
            $DNSServers = $NIC.DNSServerSearchOrder
            for ($i = 0; $i -lt 4; $i++) {
                Write-Host $DNSServers[$i]
                if ($DNSServers[$i] -contains $DNSInitial) {
                    $DNSServers[$i] = $DNSFinal
                }
            }

    
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