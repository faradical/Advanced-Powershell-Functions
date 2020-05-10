# Advanced-Powershell-Functions

A library of PowerShell functions I wrote to ease windows server administration tasks. Useful as stand-alone commands when added to an environmental path or as a module in writing PS scripts for enterprise scale automation.


## To Download

To use these functions, simply clone the repository:
```
git clone https://github.com/faradical/Advanced-Powershell-Functions
```
Add the functions to your path or venv, or call the PowerShellFunctionsLibrary.ps1 file as module in other scripts.

## Functions

### Clean-Disk

### Get-Clipboard
* Summary: Returns whatever is currently saved to the clipboard. I do not believe this is my original work, but I have no idea who I might have acquired this from to credit them, but it is very useful so I have included it anyway.
* Usage: Get-Clipboard

### Get-CPU

### Get-FreeDiskSpace

### Get-JulianDate
* Summary: Returns the date in Julian format, yyddd. Useful in mainframe automation scripts.
* Usage: Get-JulianDate

### Get-Memory

### Start-Service
* NAME
	* Start-Service

* SYNOPISIS
	* Starts services as specified. Returns an object with the status information of the service.

* SYNTAX
	* Start-Service [[-service] <string>] [[-server] <string>] [-ifauto] [-ifmanual]
		* [[-service] <string>]: Accepts the service Display Name as string as valid input.
		* [[-server] <string>]: Accept server name as string. If none is specified the function will default 
		 to the local machine.
		* [-ifauto]: specifies to only start a service if its start type is automatic.
		* [-ifmanual]: specifies to only start a service if its start type is manual.
		* If neither -ifauto or -ifmanual is specified, the function will start the service regardless of it's 
		 start type.

* RETURNS
	* Object with the following parameters:
		* Message: <string> information on the function result
		* Server: <string>
		* Service: <string>
		* Status: <string>
		* DisplayName: <string>
		* StartType: <string>

### Top


## PowerShellFunctionsLibrary

