Clear-host
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

$servers = get-content -Path "$dir\Servers.csv"
Add-LogEntry -Value "Server list ingested"
Add-LogEntry -value ""

foreach ($server in $servers) {
    $s = $server.split(".")
    Write-host "Connecting to $($S[0])" -foregroundcolor Yellow
    Add-LogEntry -Value "Connecting to $($S[0])"
    #test connection to server
    if (Test-Connection -ComputerName $server -BufferSize 1 -Count 1) {
        try {
            Write-host "`t└ $($S[0]) is online" -foregroundcolor Cyan  
            Add-LogEntry -Value `t"$($S[0]) is online"
            Write-host "`t└ Checking for .jar files, this may take some time." -foregroundcolor Yellow
            $results = Invoke-Command -ComputerName $($S[0]) -ScriptBlock { gwmi win32_logicaldisk -filter "DriveType = 3" | select-object DeviceID | Foreach-object { Get-ChildItem ($_.DeviceID + "\") -Recurse -force -include *.jar -ErrorAction ignore | foreach {select-string "JndiLookup.class" $_} | select FileName, Path, Pattern -verbose }}
            
            foreach ($result in $results) {
                Write-host "`t`t└ $($result.filename) found on $($S[0])" -foregroundcolor Magenta
                Write-host "`t`t└ $($result.Path)"-ForegroundColor Gray
                add-logentry -value "$($result.filename) found on $($S[0]) with $($result.Pattern) on path $($result.Path)"
            }
       }
       Catch {
            Write-host "`t└ an error occurred! on $($S[0])" -foregroundcolor Red
            Add-Logentry -value "An error occured on $($S[0])"
       }
    Write-host "`t└ $($S[0]) search completed" -foregroundcolor Green
    Add-LogEntry "$($S[0]) search completed"
    Add-LogEntry -value ""
           
    }
}
