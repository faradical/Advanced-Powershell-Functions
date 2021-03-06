# Advanced-Powershell-Functions

A library of PowerShell functions I wrote to ease windows server administration tasks. Useful as stand-alone commands when added to an environmental path or as a module in writing PS scripts for enterprise scale automation.


## Instructions

To use these functions, simply clone the repository:
```
git clone https://github.com/faradical/Advanced-Powershell-Functions
```
Add the functions to your path or venv, or call the PowerShellFunctionsLibrary.ps1 file as module in other scripts. Most of the complicated functions come with -help modifiers that print documnetion for assistance in use.

## Functions

### Clean-Disk
Cleans space from predefined file paths for removable content. Later updates may include parameter to force 
	script to instead pull file paths from a user specified object. Depends on `Get-FreeDiskSpace` to function.

* SYNTAX
	* `Clean-Disk [[-servers] <array>/<string>] [[-disk] <string>]`
		* [[-servers] `<array>`/`<string>`]: Accepts target servers in an array of strings or an individual server.
		 If none is specified, the function will default to the local machine.
		* [[-disk] `<string>`]: Specify a single disk to check. If none is specified, the function will return free
		 space free all drives with a valid size.

* RETURNS
	* Array of objects with parameters:
		* Server: `<string>`
		* Disk: `<string>`
		* PreviousFreeSpace: `<int>` as percent
		* PercentFreeSpace: `<int>` as percent
		* CleanedSpace: `<int>` as percent

### Get-Clipboard
Returns whatever is currently saved to the clipboard. I do not believe this is my original work, but I have no idea who I might have acquired this from to credit them, but it is very useful so I have included it anyway.
* Usage: `Get-Clipboard`

### Get-CPU
Shows breakdown of CPU usage on a server

* SYNTAX
	* `Get-CPU [[-server] <string>]`
		* If no server is specified, function will default to the local machine.

* RETURNS
	* Object with the property PercentTotalUsage and an additional property showing 
	percent use for each individual CPU on target server.

### Get-FreeDiskSpace
Checks percent free disk space available on target servers

* SYNTAX
	* `Get-FreeDiskSpace [[-servers] <array>/<string>] [[-disk] <string>]`
		* [[-servers] `<array>`/`<string>`]: Accepts target servers in an array of strings or an individual server.
		 If none is specified, the function will default to the local machine.
		* [[-disk] `<string>`]: Specify a single disk to check. If none is specified, the function will return free
		 space free all drives with a valid size.

* RETURNS
	* Array of objects with parameters:
		* Server: `<string>`
		* Disk: `<string>`
		* PercentFreeSpace: `<int>`
		* FreeSpaceGB: `<int>`
		* TotalSpaceGB: `<int>`

### Get-JulianDate
Returns the date in Julian format, yyddd. Useful in mainframe automation scripts.
* Usage: `Get-JulianDate`

### Get-Memory
Retrieves Percent of used memory on target server rounded to 2 decimal places.

* SYNTAX
	* `Get-Memory [[-server] <string>]`
		* If no server is specified, function will default to the local machine.

* RETURNS
	* Object with the parameters:
		* ComputerName
		* MemoryUsed

### Start-Service
Starts services as specified. Returns an object with the status information of the service.

* SYNTAX
	* `Start-Service [[-service] <string>] [[-server] <string>] [-ifauto] [-ifmanual]`
		* [[-service] `<string>`]: Accepts the service Display Name as string as valid input.
		* [[-server] `<string>`]: Accept server name as string. If none is specified the function will default 
		 to the local machine.
		* [-ifauto]: specifies to only start a service if its start type is automatic.
		* [-ifmanual]: specifies to only start a service if its start type is manual.
		* If neither -ifauto or -ifmanual is specified, the function will start the service regardless of it's start type.

* RETURNS
	* Object with the following parameters:
		* Message: `<string>` information on the function result
		* Server: `<string>`
		* Service: `<string>`
		* Status: `<string>`
		* DisplayName: `<string>`
		* StartType: `<string>`

### Top
Provides basic information on the system resource consumption of processes in a neat, simple to use command. Easily my favorite function I have written so far.

* SYNTAX:
	* `Top [[-server] <string>] [[-process] <string>] [-memory] [-cpu] [[show] <int>]`
		* [[-server] `<string>`]: Specify a target server by string. Will default to the local machine.
		* [[-process] `<string>`]: Specify a process by name to get info on. Partial names will still return hits.
		* [-memory]: Sort output by memory in descending order.
		* [-cpu]: Sort output by CPU in descending order.
		* [[show] `<int>`]: specify a certain certain number of rsults to limit the output to.

* RETURNS:
	* Object with parameters:
		* ProcessName
		* PercentCPU
		* MemoryInMB
		* PercentMemory

## Donate
Like what I do? Want me to do more? Send me dollar and say "faradical, go back to work." Or don't.
[paypal](https://paypal.me/feedseth?locale.x=en_US)
BTC Address: 3E1Hr3Q6imVgvX352QgEPLeXYkrKfgzkQf
ETH Address: 0x216ee6f11D7547bE201c4E2DAFf02D2C232574f3