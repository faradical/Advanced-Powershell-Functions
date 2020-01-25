function Get-FreeDiskSpace
{
	Param
	(
		[parameter(ValueFromPipeline=$True)][array]$servers = @($env:ComputerName),
		[string]$disk,
		[switch]$help
	)
	
	BEGIN {}
	PROCESS
	{
		$helpmessage = "
	NAME
		Get-FreeDiskSpace
	
	SYNOPSIS
		Checks percent free disk space available on target servers
	
	SYNTAX
		Get-FreeDiskSpace [[-servers] <array>/<string>] [[-disk] <string>]
			-[[-servers] <array>/<string>]: Accepts target servers in an array of strings or an individual server.
			 If none is specified, the function will default to the local machine.
			-[[-disk] <string>]: Specify a single disk to check. If none is specified, the function will return free
			 space free all drives with a valid size.
	
	RETURNS
		Array of objects with parameters:
			-Server: <string>
			-Disk: <string>
			-PercentFreeSpace: <int>
			-FreeSpaceGB: <int>
			-TotalSpaceGB: <int>
	"
		if ($help)
		{
			Write-host $helpmessage
		}
		else
		{
			Foreach ($server in $servers)
			{	
				$drives = Get-WmiObject Win32_LogicalDisk -ComputerName $server | where-object{$_.size -ne $null}
				$percent = $null
				
				if($drives -eq $null)
				{
					Write-error "Unable to get disk space on $server"
					Return $null
					exit
				}
				
				if ($disk)
				{
					foreach ($d in $drives)
					{
						$drivenames += $d.DeviceID
					}

					if ($drivenames.contains($disk))
					{
						foreach ($d in $drives)
						{
							$DiskID = $d.DeviceID
							
							if ($DiskID -match $disk)
							{
                                $freespace = [math]::Round($d.FreeSpace / 1gb,2)
						        $size = [math]::Round($d.Size / 1gb,2)
								$percent = [math]::Round(($d.FreeSpace * 100 / $d.Size),2)
								$obj = New-Object -TypeName PSObject -property @{
									Server = $server
							        Disk = $DiskID
							        PercentFreeSpace = $percent
							        TotalSpaceGB = $size
							        FreeSpaceGB = $freespace
								}
								$obj
							}
						}
					}
					else
					{
						Write-error "No valid disks matching $disk found on $server."
					}
				}
				else
				{
					foreach ($d in $drives)
					{
						$DiskID = $d.DeviceID
						$freespace = [math]::Round($d.FreeSpace / 1gb,2)
						$size = [math]::Round($d.Size / 1gb,2)
						$percent = [math]::Round(($freespace * 100 / $size),2)
						$obj = New-Object -TypeName PSObject -property @{
							Server = $server
							Disk = $DiskID
							PercentFreeSpace = $percent
							TotalSpaceGB = $size
							FreeSpaceGB = $freespace
						}
						$obj
					}
				}
			}
		}
	}
	END{}
}