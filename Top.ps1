param
(
	[string]$server = $env:ComputerName,
	[parameter(ValueFromPipeline=$True)][string]$process,
	[switch]$memory,
	[switch]$CPU,
	[int]$show,
	[switch]$help
)

BEGIN {}

PROCESS
{
	$helpmessage = "
NAME:
	Top

SYNOPSIS:
	Provides basic information on the system resource consumption of processes in a neat, simple to use command.

SYNTAX:
	Top [[-server] <string>] [[-process] <string>] [-memory] [-cpu] [[show] <int>]
		-[[-server] <string>]: Specify a target server by string. Will default to the local machine.
		-[[-process] <string>]: Specify a process by name to get info on. Partial names will still return hits.
		-[-memory]: Sort output by memory in descending order.
		-[-cpu]: Sort output by CPU in descending order.
		-[[show] <int>]: specify a certain certain number of rsults to limit the output to.

RETURNS:
	Object with parameters:
		-ProcessName
		-PercentCPU
		-MemoryInMB
		-PercentMemory
	"
	$ComputerMemory =  Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | ?{$_.Name -match "_total"}
	
	$properties = @(
		@{Name="ProcessName"; Expression = {$_.name}},
		@{Name="PercentCPU"; Expression = {$_.PercentProcessorTime}},	
		@{Name="MemoryInMB"; Expression = {[math]::Round(($_.workingSetPrivate / 1mb),2)}}
		@{Name="PercentMemory"; Expression = {[math]::Round(($_.workingSetPrivate * 100 / $ComputerMemory.workingSetPrivate),2)}}
	)
	
	if ($memory -and $CPU)
	{
		Write-error "You cannot specify to sort by both memory and CPU parameters."
	}
	elseif ($process)
	{
		if ($memory)
		{
			if ($show)
			{
				$obj = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Sort-Object -Property workingSetPrivate -Descending | Select-Object $properties | ?{$_.ProcessName -match $process} | Select-Object -first $show 
				if ($obj)
				{
					Return $obj
				}
				else
				{
					Write-error "Unable to find $process on $server."
				}
			}
			else
			{
				$obj = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Sort-Object -Property workingSetPrivate -Descending | Select-Object $properties | ?{$_.ProcessName -match $process}
				if ($obj)
				{
					Return $obj
				}
				else
				{
					Write-error "Unable to find $process on $server."
				}
			}
		}
		elseif ($CPU)
		{
			if ($show)
			{
				$obj = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Sort-Object -Property PercentProcessorTime -Descending | Select-Object $properties| ?{$_.ProcessName -match $process} | Select-Object -first $show 
				if ($obj)
				{
					Return $obj
				}
				else
				{
					Write-error "Unable to find $process on $server."
				}
			}
			else
			{
				$obj = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Sort-Object -Property PercentProcessorTime -Descending | Select-Object $properties | ?{$_.ProcessName -match $process}
				if ($obj)
				{
					Return $obj
				}
				else
				{
					Write-error "Unable to find $process on $server."
				}
			}
		}
		else
		{
			if ($show)
			{
				Write-error "You must specify whether to sort by CPU or Memory when using the show parameter."
			}
			else
			{
				$obj = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Select-Object $properties | ?{$_.ProcessName -match $process}
				if ($obj)
				{
					Return $obj
				}
				else
				{
					Write-error "Unable to find $process on $server."
				}
			}
		}
	}
	elseif ($memory)
	{
		if ($show)
		{
			Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | ? {$_.Name -notmatch "^(idle|_total|system)$"} | Sort-Object -Property workingSetPrivate -Descending | Select-Object $properties -first $show
		}
		else
		{
			Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | ? {$_.Name -notmatch "^(idle|_total|system)$"} | Sort-Object -Property workingSetPrivate -Descending | Select-Object $properties
		}
	}
	elseif ($CPU)
	{
		if ($show)
		{
			Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | ? {$_.Name -notmatch "^(idle|_total|system)$"} | Sort-Object -Property PercentProcessorTime -Descending | Select-Object $properties -first $show
		}
		else
		{
			Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | ? {$_.Name -notmatch "^(idle|_total|system)$"} | Sort-Object -Property PercentProcessorTime -Descending | Select-Object $properties
		}
	}
	elseif ($show)
	{
		Write-error "You must specify whether to sort by CPU or Memory when using the show parameter."
	}
	elseif ($help)
	{
		Write-host $helpmessage
	}
	else
	{
		Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process -computername $server | Select-Object $properties
	}
}
END{}