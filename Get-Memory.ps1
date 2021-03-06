param
(
	[parameter(ValueFromPipeline=$True)][string]$server = $env:ComputerName,
	[switch]$help
)

BEGIN {}
PROCESS
{
	$helpmessage = "
NAME
	Get-Memory

SYNOPSIS
	Retrieves Percent of used memory on target server rounded to 2 decimal places.

SYNTAX
	Get-Memory [[-server] <string>]
		-If no server is specified, function will default to the local machine.

RETURNS
	Object with the parameters:
		-ComputerName
		-MemoryUsed
	"
	
	if ($help)
	{
		Write-Host $helpmessage
	}
	else
	{
		$ComputerMemory =  Get-WmiObject -Class WIN32_OperatingSystem -computername $server
		
		if ($ComputerMemory -eq $null)
		{
			Write-error "Unable to get percent free memory for $server"
			exit
		}
		else
		{
			$percentMemory = [math]::Round(((($ComputerMemory.TotalVisibleMemorySize - $ComputerMemory.FreePhysicalMemory)*100) / $ComputerMemory.TotalVisibleMemorySize),2)
			
			$Obj = New-Object -TypeName psobject -Property @{
				ComputerName = $server
				MemoryUsed = $percentMemory
			}
			Return $Obj
		}
	}
}
END {}