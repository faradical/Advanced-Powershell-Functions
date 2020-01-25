function Get-CPU
{
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
		Get-CPU
	
	SYNOPSIS
		Shows breakdown of CPU usage on a server
	
	SYNTAX
		Get-CPU [[-server] <string>]
			-If no server is specified, function will default to the local machine.
	
	RETURNS
		Object with the property PercentTotalUsage and an additional property showing 
		percent use for each individual CPU on target server.
	"

		if ($help)
		{
			Write-host $helpmessage
		}
		else
		{
			$CPUs = Get-WmiObject WIN32_PROCESSOR -ComputerName $server
			
			if ($CPUs -ne $null)
				{
				$obj = New-Object -TypeName PSObject -Property @{
					PercentTotalUsage = $PercentTotalUsage
				}
				
				$x = 0
				$totaluse = 0
				foreach ($cpu in $CPUs)
				{
					$cpuname = $cpu.DeviceID
					$cpuclean = $cpu.LoadPercentage
					$x += 1
					$totaluse += $cpuclean
					if ($CPUs.count -gt 1)
					{
						$obj | Add-Member -MemberType NoteProperty -Name "Percent$cpuname" -Value $cpuclean
					}
				}
				$obj.PercentTotalUsage = ($totaluse / $x)
				$obj
				}
			else
			{
				Write-error "Unable to get CPU usage for $server."
			}
		}
	}
	END {}
}