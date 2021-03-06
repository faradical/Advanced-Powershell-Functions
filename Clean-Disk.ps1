Param
(
	[parameter(ValueFromPipeline=$True)][array]$servers = @($env:ComputerName),
	[parameter(ValueFromPipeline=$True)][string]$disk,
	[switch]$help
)

BEGIN {}
PROCESS
{
	$cfolders = @("") #places where we can always delete all the content on C:
	$ctimesensitive = @("") #places where we can only delete things older than 30 days on C:

	$dfolders = @() #places where we can always delete all the content on D:
	$dtimesensitive = @() #places where we can only delete things older than 30 days on D:

	$helpmessage = "
NAME
	Clean-Disk

SYNOPSIS
	Cleans space from predefined file paths for removable content. Later updates may include parameter to force 
	script to instead pull file paths from a user specified object.

SYNTAX
	Clean-Disk [[-servers] <array>/<string>] [[-disk] <string>]
		-[[-servers] <array>/<string>]: Accepts target servers in an array of strings or an individual server.
			If none is specified, the function will default to the local machine.
		-[[-disk] <string>]: Specify a single disk to check. If none is specified, the function will return free
			space free all drives with a valid size.

RETURNS
	Array of objects with parameters:
		-Server: <string>
		-Disk: <string>
		-PreviousFreeSpace: <int> as percent
		-PercentFreeSpace: <int> as percent
		-CleanedSpace: <int> as percent
	"
	if ($help)
	{
		Write-host $helpmessage
	}
	else
	{
		Foreach ($server in $servers)
		{
			if ($disk)
			{
				$getspace = Get-FreeDiskSpace $server $disk
				
				if($getspace -eq $null)
				{
					Write-error "Unable to access $disk on $server"
					exit
				}
				else
				{
					$freespace = $getspace.PercentFreeSpace
					Write-Host "$disk at $freespace% free space on $server. Initiating clean up." -Foregroundcolor Yellow -BackgroundColor DarkCyan
					
					if ($disk -match "C")
					{
						$x = 0
						foreach ($folder in $cfolders) #removes non-time sensitive data
						{
							$pathtest = test-path \\$server\$folder\ -ErrorAction 'SilentlyContinue'
							
							if ($pathtest -eq $true)
							{
								$x += 1
								$percent = ($x * 100 / $cfolders.count)
								Write-Progress -Id 0 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $folder"
								$garbage = Get-ChildItem \\$server\$folder\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
								
								if ($garbage.count -ne $null)
								{
									$i = 0
									
									foreach ($file in $garbage)
									{
										$i += 1
										$ipercent = ($i * 100 / $garbage.count)
										Write-Progress -Id 1 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
										Remove-Item $file -recurse -force
										$file = $null
									}
								}
							}
						}

						$x = 0
						foreach ($tslog in $ctimesensitive) #removes time sensitive data
						{	 
							$pathtest = test-path \\$server\$tslog\ -ErrorAction 'SilentlyContinue'
							
							if ($pathtest -eq $true)
							{
								$CurrentDate = Get-Date
								$DatetoDelete = $CurrentDate.AddDays(-30)
								$x += 1
								$percent = ($x * 100 / $ctimesensitive.count)
								Write-Progress -Id 0 -Activity "Removing files that can be deleted after 30 days" -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $tslog"
								$garbage = Get-ChildItem \\$server\$tslog\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
								
								if ($garbage.count -ne $null)
								{
									$i = 0
									
									foreach ($file in $garbage)
									{
										$i += 1
										$ipercent = ($i * 100 / $garbage.count)
										Write-Progress -Id 1 -Activity "Removing files older than 30 days" -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
										Remove-Item $file -recurse -force
										$file = $null
									}
								}
							}
						}
					}
					elseif ($disk -match "D")
					{
						$x = 0
						foreach ($folder in $dfolders) #removes non-time sensitive data
						{
							$pathtest = test-path \\$server\$folder\ -ErrorAction 'SilentlyContinue'
							
							if ($pathtest -eq $true)
							{
								$x += 1
								$percent = ($x * 100 / $cfolders.count)
								Write-Progress -Id 0 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $folder"
								$garbage = Get-ChildItem \\$server\$folder\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
								
								if ($garbage.count -ne $null)
								{
									$i = 0
									
									foreach ($file in $garbage)
									{
										$i += 1
										$ipercent = ($i * 100 / $garbage.count)
										Write-Progress -Id 1 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
										Remove-Item $file -recurse -force
										$file = $null
									}
								}
							}
						}

						$x = 0
						foreach ($tslog in $dtimesensitive) #removes time sensitive data
						{	 
							$pathtest = test-path \\$server\$tslog\ -ErrorAction 'SilentlyContinue'
							
							if ($pathtest -eq $true)
							{
								$CurrentDate = Get-Date
								$DatetoDelete = $CurrentDate.AddDays(-30)
								$x += 1
								$percent = ($x * 100 / $ctimesensitive.count)
								Write-Progress -Id 0 -Activity "Removing files that can be deleted after 30 days" -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $tslog"
								$garbage = Get-ChildItem \\$server\$tslog\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
								
								if ($garbage.count -ne $null)
								{
									$i = 0
									
									foreach ($file in $garbage)
									{
										$i += 1
										$ipercent = ($i * 100 / $garbage.count)
										Write-Progress -Id 1 -Activity "Removing files older than 30 days" -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
										Remove-Item $file -recurse -force
										$file = $null
									}
								}
							}
						}
					}

					$getspace = Get-FreeDiskSpace $server $disk

					if($getspace -eq $null)
					{
						Write-error "Unable to access $disk on $server"
						exit
					}
					else
					{
						$newfreespace = $getspace.PercentFreeSpace
						$obj = New-object -TypeName psobject -Property @{
							Server = $server
							Disk = $disk
							PreviousFreeSpace = $freespace
							PercentFreeSpace = $newfreespace
							CleanedSpace = $newfreespace - $freespace
						}
					}
				}
				$obj
			}
			else
			{
				$disks = Get-FreeDiskSpace $server
					
				foreach ($disk in $disks)
				{
					$disk = $disk.disk
					$getspace = Get-FreeDiskSpace $server $disk
					
					if($getspace -eq $null)
					{
						Write-error "Unable to access $disk on $server"
					}
					else
					{
						$freespace = $getspace.PercentFreeSpace
						Write-Host "$disk at $freespace% free space on $server. Initiating clean up." -Foregroundcolor Yellow -BackgroundColor DarkCyan
						
						if ($disk -match "C")
						{
							$x = 0
							foreach ($folder in $cfolders) #removes non-time sensitive data
							{
								$pathtest = test-path \\$server\$folder\ -ErrorAction 'SilentlyContinue'
								
								if ($pathtest -eq $true)
								{
									$x += 1
									$percent = ($x * 100 / $cfolders.count)
									Write-Progress -Id 0 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $folder"
									$garbage = Get-ChildItem \\$server\$folder\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
									
									if ($garbage.count -ne $null)
									{
										$i = 0
										
										foreach ($file in $garbage)
										{
											$i += 1
											$ipercent = ($i * 100 / $garbage.count)
											Write-Progress -Id 1 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
											Remove-Item $file -recurse -force
											$file = $null
										}
									}
								}
							}

							$x = 0
							foreach ($tslog in $ctimesensitive) #removes time sensitive data
							{	 
								$pathtest = test-path \\$server\$tslog\ -ErrorAction 'SilentlyContinue'
								
								if ($pathtest -eq $true)
								{
									$CurrentDate = Get-Date
									$DatetoDelete = $CurrentDate.AddDays(-30)
									$x += 1
									$percent = ($x * 100 / $ctimesensitive.count)
									Write-Progress -Id 0 -Activity "Removing files that can be deleted after 30 days" -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $tslog"
									$garbage = Get-ChildItem \\$server\$tslog\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
									
									if ($garbage.count -ne $null)
									{
										$i = 0
										
										foreach ($file in $garbage)
										{
											$i += 1
											$ipercent = ($i * 100 / $garbage.count)
											Write-Progress -Id 1 -Activity "Removing files older than 30 days" -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
											Remove-Item $file -recurse -force
											$file = $null
										}
									}
								}
							}
						}
						elseif ($disk -match "D")
						{
							$x = 0
							foreach ($folder in $dfolders) #removes non-time sensitive data
							{
								$pathtest = test-path \\$server\$folder\ -ErrorAction 'SilentlyContinue'
								
								if ($pathtest -eq $true)
								{
									$x += 1
									$percent = ($x * 100 / $cfolders.count)
									Write-Progress -Id 0 -Activity "Removing non-essential files." -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $folder"
									$garbage = Get-ChildItem \\$server\$folder\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
									
									if ($garbage.count -ne $null)
									{
										$i = 0
										
										foreach ($path in $garbage)
										{
											$i += 1
											$ipercent = ($i * 100 / $garbage.count)
											Write-Progress -Id 1 -Activity "Removing files older than 30 days" -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
											Remove-Item $file -recurse -force
											$file = $null
										}
									}
								}
							}

							$x = 0
							foreach ($tslog in $dtimesensitive) #removes time sensitive data
							{	 
								$pathtest = test-path \\$server\$tslog\ -ErrorAction 'SilentlyContinue'
								
								if ($pathtest -eq $true)
								{
									$CurrentDate = Get-Date
									$DatetoDelete = $CurrentDate.AddDays(-30)
									$x += 1
									$percent = ($x * 100 / $ctimesensitive.count)
									Write-Progress -Id 0 -Activity "Removing files that can be deleted after 30 days" -Status 'Status' -PercentComplete $percent -CurrentOperation "Cleaning $tslog"
									$garbage = Get-ChildItem \\$server\$tslog\* | Where-Object {$_.LastWriteTime -lt $DatetoDelete}
									
									if ($garbage.count -ne $null)
									{
										$i = 0
										
										foreach ($path in $garbage)
										{
											$i += 1
											$ipercent = ($i * 100 / $garbage.count)
											Write-Progress -Id 1 -Activity "Removing files older than 30 days" -Status 'Status' -PercentComplete $ipercent -CurrentOperation "Removing $file"
											Remove-Item $file -recurse -force
											$file = $null
										}
									}
								}
							}
						}
						else
						{
							Write-Error "This script is only designed to clear space on drives C: and D:"
						}
						
						$getspace = Get-FreeDiskSpace $server $disk
					
						if($getspace -eq $null)
						{
							Write-error "Unable to access $disk on $server"
							exit
						}
						else
						{
							$newfreespace = $getspace.PercentFreeSpace
							$obj = New-object -TypeName psobject -Property @{
								Server = $server
								Disk = $disk
								PreviousFreeSpace = $freespace
								PercentFreeSpace = $newfreespace
								CleanedSpace = $newfreespace - $freespace
							}
						}
					}
					$obj
				}
			}
		}
	}
}
END{}