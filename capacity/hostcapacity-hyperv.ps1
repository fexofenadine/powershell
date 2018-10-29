# Script for Host/Cluster output of Hyper-V SCVMM servers
# Written by Hugh Patterson
# Last updated 17/11/2015

Function Generate-Report ($filename) {
    ForEach-Object {Get-VMHost} | Select @{N="Cluster";E={(Invoke-Command -ComputerName $_.Name -ScriptBlock {Get-Cluster -WarningAction silentlyContinue}).Name}},
    @{N="Hostname";E={$_.Name}},
        @{N="Manufacturer";E={(gwmi -ComputerName $_.Name -Class Win32_ComputerSystem).Manufacturer}}, 
        @{N="Model";E={(gwmi -ComputerName $_.Name -Class Win32_ComputerSystem).Model}}, 
        @{N="ProcessorType";E={(gwmi -ComputerName $_.Name -Class Win32_Processor).Name[0]}}, 
        @{N="Number of CPUs";E={$_."LogicalProcessorCount"}}, 
        @{N="Number of VMs";E={(Get-SCVirtualMachine -VMHost $_.Name).Count}}, 
        @{N="Total Memory (MB)";E={($_.TotalMemory)/1MB}},
        @{N="Total GHz";E={($_."LogicalCPUCount" * $_."CPUSpeed")/1000}}, 
        @{N="Average CPU %";E={$_ | Get-AvgCPU $_}}, 
        @{N="Average Memory % ";E={$_ | Get-AvgMem $_}} | Sort Cluster, Hostname | Export-Csv -NoTypeInformation -Append $filename
}

Function Get-AvgMem ($hostname) {
    ForEach ($mem in (Get-SCPerformanceData -vmhost $hostname -PerformanceCounter MemoryUsage -timeframe Month).PerformanceHistory) {
        $runningtotal = $runningtotal + $mem
    }
    $totalmem = (gwmi -ComputerName $hostname -Class Win32_ComputerSystem).TotalPhysicalMemory/1MB
    $avgmem = $runningtotal/(Get-SCPerformanceData -vmhost $hostname -PerformanceCounter MemoryUsage -timeframe Month).PerformanceHistory.count
    Return ($avgmem/$totalmem*100)
}

Function Get-AvgCPU ($hostname) {
    ForEach ($cpu in (Get-SCPerformanceData -vmhost $hostname -PerformanceCounter CPUUsage -timeframe Month).PerformanceHistory) {
        $runningtotal = $runningtotal + $cpu
    }
    Return ($runningtotal/(Get-SCPerformanceData -vmhost $hostname -PerformanceCounter CPUUsage -timeframe Month).PerformanceHistory.count)
}



Import-Module VirtualMachineManager

$filename = -join(".\","$vmmserver","_Hyper-V_Capacity_Report_",(Get-Date).tostring("MMMM"),".csv")

If (Test-Path $filename){
	Remove-Item $filename
}

$vmmserver = Read-Host -Prompt "Enter VMM server to connect to"


echo "Connecting to $vmmserver"
Get-SCVMMServer -ComputerName $vmmserver | Out-Null
echo "Generating report..."
Generate-Report $filename
echo "Report from $vmmserver completed."



# Email the report home **not working yet**
$smtpServer = "XXXX"
$att = new-object Net.Mail.Attachment($filename)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "hugh.blah@XXXXXX"
$msg.To.Add("recipient@XXXXX")
$msg.Subject = -join("$env:USERDOMAIN"," Hyper-V Capacity Report ",(Get-Date).tostring("MMMM"))
$msg.Body = "This is a test"
$msg.Attachments.Add($att)
$smtp.Send($msg)
@$att.Dispose()

