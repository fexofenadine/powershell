# Script for Host/Cluster Capacity output of VMWare VCenters
# ****Should be run from PowerCLI****
# Written by Hugh Patterson
# Last updated 07/04/2016

Function Get-AvgCpu ($hostname, $months)
{
	$days = ($months * (-30))
	$avgcpu = @()
	$avgcpu = (Get-VMHost $hostname | Get-Stat -Stat "cpu.usage.average" -Start (Get-Date).adddays($days-30) -finish (Get-Date).adddays($days) -maxsamples 1) # | Select-Object -Property Value)

	if ($avgcpu.count -like "") {
		Return $avgcpu.Value
		}
	else
		{
		Return $avgcpu[0].Value
		}
}

Function Get-AvgMem ($hostname, $months)
{
	$days = ($months * (-30))
	$avgmem = @()
	$avgmem = (Get-VMHost $hostname | Get-Stat -Stat "mem.usage.average" -Start (Get-Date).adddays($days-30) -finish (Get-Date).adddays($days) -maxsamples 1) # | Select-Object -Property Value)

	if ($avgmem.count -like "") {
		Return $avgmem.Value
		}
	else
		{
		Return $avgmem[0].Value
		}

}

$viserver = Read-Host -Prompt "Enter VCenter server to connect to"

Connect-VIServer $viserver

$filename = -join(".\", $viserver, "_VMWare_Capacity_Report_", (Get-Date).tostring("MMMM"), ".csv")
$month = , (Get-Date).tostring("MMMM")

echo "Starting $month report"
Get-VMHost | Select @{N="Cluster";E={Get-Cluster -VMHost $_}}, 
    @{N="Hostname";E={$_."Name"}}, 
    Manufacturer, 
    Model, 
    ProcessorType, 
    @{N="Number of CPUs";E={$_."NumCpu"}}, 
    @{N="Number of VMs";E={($_ | Get-VM).Count}}, 
#   @{N="DatastoreName (Capacity in GB)";E={[string]::Join(",",( $_ | Get-Datastore | %{$_.Name + "(" + ("{0:f1}" -f ($_.CapacityMB/1KB)) + ")"}))}},  
    @{N="Total Memory (MB)";E={$_.MemoryTotalMB}}, 
    @{N="Total GHz";E={$_.CpuTotalMhz/1000}}, 
    @{N="Average CPU %";E={$_ | Get-AvgCpu $_ 0}}, 
    @{N="Average Memory %";E={$_ | Get-AvgMem $_ 0}} | Sort Cluster, Name | Export-Csv -NoTypeInformation $filename
echo "Complete"
