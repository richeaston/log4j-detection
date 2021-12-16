# log4j-detection
Log4j detection using powershell


Author : Richard Easton

Description: Searches ALL locations for .jar files

Usage: Run powershell or Powershell_ise as an account that has rights to read on the server.

output: will output results to a log file in logs folder


warning: this script does servers (from servers.csv) one at a time and takes a LONG time, this is so you don't overload a VMHost.

note: using CMtrace will highlight warnings in yellow in the log file making them easier to idenitify
