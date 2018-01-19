@echo off
powershell.exe -command "& set-executionpolicy bypass -force; $secondsToWait=5; While (($secondsToWait -gt 0) -and (-not(test-NetConnection))) {$secondsToWait--;start-sleep 1}; if (get-module -ListAvailable -name ib1) {update-module ib1 -force} else {install-module ib1 -force}"

