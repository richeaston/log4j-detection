
Function Add-LogEntry ($Value) {
    $datetime = get-date -format "dd-MM-yyyy HH:mm:ss"
    add-content -Path $log -Value "$($datetime): $value"
}

#end of functions

#create a logfile snippet
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

#get date and check if logfile for the day exists, if not, create it.
$date = get-date -Format "dd-MM-yyyy"
$log = "$dir\logs\Log-$date.log"
if ((test-path $log) -eq $false) {
    if ((test-path "$dir\logs") -eq $false) { new-item -Path $dir -name "Logs" -ItemType Directory -ErrorAction SilentlyContinue -Force -Verbose}
    new-item -Path "$dir\logs" -Name "Log-$date.log" -force -verbose
    Add-LogEntry -Value "Log file created"
}

$servers = get-content -Path "$dir\gag-citrix-Servers-1.csv"
$datetime = get-date -format "dd-MM-yyyy HH:mm:ss"
Add-LogEntry -Value "Server list ingested"
$log4jfile = "$dir\log4j-detection.ps1"

foreach ($server in $servers) {
    $s = $server.split(".")
    Write-host "Connecting to $($S[0])"
    Add-LogEntry -value ""
    Add-LogEntry -Value "Connecting to $($S[0])"
    #test connection to server
    if (Test-Connection -ComputerName $server -BufferSize 1 -Count 1) {
        try {
            Write-host "`t$($S[0]) is online"   
            Add-LogEntry -Value "$($S[0]) is online"
        
            $results = Invoke-Command -ComputerName $server -ScriptBlock { gwmi win32_logicaldisk -filter "DriveType = 3" | select-object DeviceID | Foreach-object { Get-ChildItem ($_.DeviceID + "\") -Recurse -force -include *.jar -ErrorAction ignore | foreach {select-string "JndiLookup.class" $_} | select FileName, Path, Pattern -verbose }}
            foreach ($result in $results) {
                Write-output "adding $($result.filename) found on $($S[0])"
                Add-LogEntry -value ""
                add-logentry -value $result.filename" found on $($S[0])"
                Add-Logentry -value $result.Path
                Add-Logentry -value $result.Pattern
                Add-LogEntry -value ""
            }
       }
       Catch {
            Write-host "an error occurred!"
            Add-Logentry -value "An error occured on $($S[0])"
            Add-LogEntry -value ""
       }
    Add-LogEntry "`t$($S[0]) search completed"
    Add-LogEntry -value ""
           
    }
}
