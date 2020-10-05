[Reflection.Assembly]::LoadFile('.\taglib-sharp.dll')
$folder = "C:\Users\[username]\music\"
$files = Get-ChildItem -recurse $folder -include ('*.mp3', '*.flac')
#$file=$files[0]
$i=0
$logfile = "./remove-dupeimageslog.csv"
$workdone =@()

foreach ($file in $files) {
    $tag = [TagLib.File]::Create($file.FullName)
    $length = $tag.tag.Pictures.length
    if ($tag.tag.Pictures.length -gt 1) { #more than one picture
        $file.FullName # show filename
        $length # show how many pictures were embedded
        $primarypicture = $tag.tag.pictures[0]
        $ErrorActionPreference = 'SilentlyContinue'
        $tag.tag.pictures = $primarypicture
        $ErrorActionPreference = 'Continue'
        $object = New-Object -TypeName PSObject
        $object | Add-Member -Name 'FIleName' -MemberType Noteproperty -Value $file.FullName
        $object | Add-Member -Name 'NumberofPics' -MemberType Noteproperty -Value ($length)
        $workdone += $object
        #$tag.Save() # uncomment to enable writing modified tag
        $i++
    } 
}
$workdone | export-csv $logfile
$workdone | ogv
