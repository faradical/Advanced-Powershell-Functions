#defines the path to the script's parent directory as a variable
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

<#
Get-JulianDate
	-Summary: Returns the date in Julian format, yyddd. Useful in mainframe automation scripts.
	-Usage: Get-JulianDate
#>
Function Get-JulianDate
{ 
	$yy = (get-date -Format yy)
	$date = Get-Date
	$offset = (Get-Date 1/1/$yy).AddDays(-1)
	$jdays = $date - $offset
	$jday = $jdays.days
	$length = ($jday).tostring().length

	switch ($length) {
		"1" {$jdate = "$yy" + "00" + "$jday"}
		"2" {$jdate = "$yy" + "0" + "$jday"}
		"3" {$jdate = "$yy" + "$jday"}
	}
	return $jdate
}

<#
Get-Clipboard
	-Summary: Returns whatever is currently saved to the clipboard.
	-Usage: Get-Clipboard
#>
function Get-Clipboard
{
	Add-Type -AssemblyName System.Windows.Forms
	$tb = New-Object System.Windows.Forms.TextBox
	$tb.Multiline = $true
	$tb.Paste()
	$tb.Text
}

function Start-Service
{
	Param
	(
		[parameter(ValueFromPipeline=$True)][string]$service,
		[string]$server = $env:ComputerName,
		[switch]$ifauto,
		[switch]$ifmanual,
		[switch]$help
	)
	
	BEGIN {}
	PROCESS
	{	
		$helpmessage = "
	NAME
		Start-Service
	
	SYNOPISIS
		Starts services as specified. Returns an object with the status information of the service.
	
	SYNTAX
		Start-Service [[-service] <string>] [[-server] <string>] [-ifauto] [-ifmanual]
			-[[-service] <string>]: Accepts the service Display Name as string as valid input.
			-[[-server] <string>]: Accept server name as string. If none is specified the function will default 
			 to the local machine.
			-[-ifauto]: specifies to only start a service if its start type is automatic.
			-[-ifmanual]: specifies to only start a service if its start type is manual.
			-If neither -ifauto or -ifmanual is specified, the function will start the service regardless of it's 
			 start type.
	
	RETURNS
		Object with the following parameters:
			-Message: <string> information on the function result
			-Server: <string>
			-Service: <string>
			-Status: <string>
			-DisplayName: <string>
			-StartType: <string>
	"
		if ($help)
		{
			Write-host $helpmessage
		}
		elseif ( -not $service)
		{
			Write-error “You must supply a value for -service”
		}
		else
		{
			$ErrorActionPreference = 'stop'

			$Status = (Get-Service -Computername $server -DisplayName $service).Status
			$servicename = (Get-Service -Computername $server -displayName $service).name
			$StartType = (Get-WmiObject -computername $server -Class Win32_Service -Filter "name='$servicename'").StartMode
			
			$ServObj = New-Object -TypeName psobject -Property @{
				Message = ''
				Server = $server
				Service = $service
				Status = $Status
				DisplayName = $servicename
				StartType = $StartType
			}

			if ($ifauto)
			{
				if ($Status -eq "Stopped" -and $StartType -eq "Auto")
				{
					if ($service -contains "Service")
					{
						Write-Host "Starting the $service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
					}
					else
					{
						Write-Host "Starting the $service service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
					}
					
					(Get-Service -Computername $server -DisplayName "$service").Start()
					$Status = (Get-Service -Computername $server -DisplayName "$service").Status
					
					while ($Status -eq "StartPending")
					{
						sleep -seconds 5
						$Status = (Get-Service -Computername $server -DisplayName "$service").Status
						
						$ServObj = New-Object -TypeName psobject -Property @{

							Message = ''
							Server = $server
							Service = $service
							Status = $Status
							DisplayName = $servicename
							StartType = $StartType

						}
						
						Write-Host $server $service $status $starttype -Foregroundcolor Yellow -BackgroundColor DarkCyan # REPLACE WITH OBJECT
					}
					
					if ($Status -eq "Running")
					{
						if ($service -contains "Service")
						{
							$servobj.Message = "Started the $service."
							Return $ServObj
						}
						else
						{
							$servobj.Message = "Started the $service service."
							Return $ServObj
						}
					}
					else
					{
						if ($service -contains "Service")
						{
							$servobj.Message = "Unable to start $service."
							Return $ServObj
						}
						else
						{
							$servobj.Message = "Unable to start $service service."
							Return $ServObj
						}
					}
				}
				elseif ($Status -eq "Stopped" -and $StartType -eq $null)
				{
					if ($service -contains "Service")
					{
						Write-error "$service was stopped but unable to determine start-type."
					}
					else
					{
						Write-error "$service service was stopped but unable to determine start-type."
					}
				}
				elseif ($StartType -eq "Manual")
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "The $service is a manual service."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "The $service service is a manual service."
						Return $ServObj
					}
				}
				elseif ($Status -eq "Running")
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "The $service was running."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "The $service service was running."
						Return $ServObj
					}
				}
				elseif ($Status -eq $null)
				{
					if ($service -contains "Service")
					{
						Write-error "Unable to get $service status from $server."
					}
					else
					{
						Write-error "Unable to get $service service status from $server."
					}
				}
			}
			elseif($ifmanual)
			{
				if ($Status -eq "Stopped" -and $StartType -eq "Manual")
				{
					if ($service -contains "Service")
					{
						Write-Host "Starting the $service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
					}
					else
					{
						Write-Host "Starting the $service service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
					}
					
					(Get-Service -Computername $server -DisplayName "$service").Start()
					$Status = (Get-Service -Computername $server -DisplayName "$service").Status
					
					while ($Status -eq "StartPending")
					{
						sleep -seconds 5
						$Status = (Get-Service -Computername $server -DisplayName "$service").Status
						
						$ServObj = New-Object -TypeName psobject -Property @{

							Message = ''
							Server = $server
							Service = $service
							Status = $Status
							DisplayName = $servicename
							StartType = $StartType

						}
						
						Write-Host $server $service $status $starttype -Foregroundcolor Yellow -BackgroundColor DarkCyan # REPLACE WITH OBJECT
					}
					
					if ($Status -eq "Running")
					{
						if ($service -contains "Service")
						{
							$servobj.Message = "Started the $service."
							Return $ServObj
						}
						else
						{
							$servobj.Message = "Started the $service service."
							Return $ServObj
						}
					}
					else
					{
						if ($service -contains "Service")
						{
							$servobj.Message = "Unable to start $service."
							Return $ServObj
						}
						else
						{
							$servobj.Message = "Unable to start $service service."
							return $ServObj
						}
					}
				}
				elseif ($Status -eq "Stopped" -and $StartType -eq $null)
				{
					if ($service -contains "Service")
					{
						Write-error "$service was stopped but unable to determine start-type."
					}
					else
					{
						Write-error "$service service was stopped but unable to determine start-type."
					}
				}
				elseif ($StartType -eq "Auto")
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "The $service is an automatic service."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "The $service service is an automatic service."
						Return $ServObj
					}
				}
				elseif ($Status -eq "Running")
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "The $service was running."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "The $service service was running."
						Return $ServObj
					}
				}
				elseif ($Status -eq $null)
				{
					if ($service -contains "Service")
					{
						Write-error "Unable to get $service status from $server."
					}
					else
					{
						Write-error "Unable to get $service service status from $server."
					}
				}
			}
			else
			{
				if ($service -contains "Service")
				{
					Write-Host "Starting the $service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
				}
				else
				{
					Write-Host "Starting the $service service." -Foregroundcolor Yellow -BackgroundColor DarkCyan
				}

				(Get-Service -Computername $server -DisplayName "$service").Start()
				$Status = (Get-Service -Computername $server -DisplayName "$service").Status
							
				while ($Status -eq "StartPending")
				{
					sleep -seconds 5
					$Status = (Get-Service -Computername $server -DisplayName "$service").Status
								
					$ServObj = New-Object -TypeName psobject -Property @{

						Message = ''
						Server = $server
						Service = $service
						Status = $Status
						DisplayName = $servicename
						StartType = $StartType

					}
								
					Write-Host $server $service $status $starttype -Foregroundcolor Yellow -BackgroundColor DarkCyan
				}

				if ($Status -eq "Running")
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "Started the $service."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "Started the $service service."
						Return $ServObj
					}
				}
				else
				{
					if ($service -contains "Service")
					{
						$servobj.Message = "Unable to start $service."
						Return $ServObj
					}
					else
					{
						$servobj.Message = "Unable to start $service service."
						Return $ServObj
					}
				}
			}
		}
	}
	END{}
}

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

function Clean-Disk
{
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
}

function Get-Memory
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
}

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

Function Top
{
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
}

