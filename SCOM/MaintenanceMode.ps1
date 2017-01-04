# MaintenanceMode.ps1
# script to help put stuff into and out of Maintenance Mode in SCOM
# REQUIRES ShowUI MODULE!
# written by Hugh Patterson 01/07/2016
# last updated 09/07/2016

function Start_MM ($servers, $endtime, $reason, $comment) {
    Write-Host "starting maintenance mode, wait for it.."
    (Get-SCOMClassInstance -Name $servers).ScheduleMaintenanceMode(`
        (get-date).ToUniversalTime(),
        ((get-date).AddMinutes($endtime)).ToUniversalTime(),
        $reason,
        $comment,
        "OneLevel")
}

function Stop_MM ($servers, $endtime) {
    Write-Host "stopping maintenance mode, wait for it.."
    (Get-SCOMClassInstance -Name $servers).StopMaintenanceMode((get-date).ToUniversalTime())
}

function Check_MM ($servers) {
    Write-Host "checking maintenance mode status, wait for it.."
    $output = foreach($server in $servers) {
        $tempobject = Get-SCOMClassInstance -Name $server
        New-Object psobject -property @{
            ComputerName=$server
            MaintenanceModeLastModified=$tempobject.MaintenanceModeLastModified[2].tolocaltime()
            InMaintenanceMode=$tempobject.InMaintenanceMode[0]
        }
    }
    return $output
}

function SplitAppendDNS ($blah) {
    $blah = -split $blah
    $i=0
    foreach ($bla in $blah){
        $blah[$i] = -join($bla, ".", $env:USERDNSDOMAIN).toUpper()
        $i++
    }
    return $blah
}

Import-Module OperationsManager
Import-Module ShowUI
New-SCOMManagementGroupConnection -ComputerName yourSCOMservergoeshere    # Add your SCOM server name here
$global:checkmm = $false
$global:startmm = $false
#$traversal = [EnterpriseManagement.Common.TraversalDepth]::OneLevel

$mmcodes = "ApplicationInstallation","ApplicationUnresponsive","ApplicationUnstable","LossOfNetworkConnectivity","PlannedApplicationMaintenance","PlannedHardwareInstallation","PlannedHardwareMaintenance","PlannedOperatingSystemReconfiguration","PlannedOther","SecurityIssue","UnplannedApplicationMaintenance","UnplannedHardwareInstallation","UnplannedHardwareMaintenance","UnplannedOperatingSystemReconfiguration","UnplannedOther"

$input = Grid -ControlName 'SCOM Maintenance Mode Helper' -Columns 2 {
    New-Grid -columns 1 -column 0 -Rows (            
    'Auto', # Automatically sized header row                     
    'Auto' # Server list at the bottom            
    ) {
        New-Label "Server List" -row 0
        TextBox -Name "Servers" -FontFamily "Consolas, Global Monospace" -Width 250 -Height 300 -AcceptsReturn -AcceptsTab -VerticalScrollBarVisibility Visible -BorderThickness 2 -row 1
    }
    New-UniformGrid -columns 1 -Column 1 {
        New-Label "Number of Minutes"
        TextBox -Name "Hours" -Height 25 -Width 250 -BorderThickness 2 -Text "60"
        New-Label " "
        New-Label "Reason Code"
        New-ComboBox -SelectedIndex 8 -Height 25 -Width 250 -IsTextSearchEnabled:$true -IsSynchronizedWithCurrentItem:$true -Items $mmcodes -On_SelectionChanged {$global:reasoncode = $this.SelectedValue} -On_Loaded {$global:reasoncode = "PlannedOther"}
        New-Label " "
        New-Label "Comments"
        TextBox -Name "Comments" -FontFamily "Consolas, Global Monospace" -Width 250 -Height 25 -AcceptsReturn -AcceptsTab -BorderThickness 2
        New-Label " "
        New-Button "Check MM Status" -Height 25 -Width 200 -On_Click {
            $global:checkmm = $true           
            Get-ParentControl |            
            Set-UIValue -passThru|
            Close-Control
        }
        New-Button "Put Machines Into MM" -Height 25 -Width 200 -On_Click {
            $global:startmm = $true   
            Get-ParentControl |            
            Set-UIValue -passThru |
            Close-Control
        }
        New-Button "Stop MM" -Height 25 -Width 200 -On_Click {
            $global:stopmm = $true   
            Get-ParentControl |            
            Set-UIValue -passThru |
            Close-Control
        }
    }        
       
} -Show

$servers = SplitAppendDNS $input.Servers

if ($global:startmm) {Start_MM $servers $input.Hours $global:reasoncode $input.Comments}
if ($global:stopmm) {Stop_MM $servers $input.Hours}
Check_MM $servers | Tee-Object -variable status | Out-GridView
$status

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")