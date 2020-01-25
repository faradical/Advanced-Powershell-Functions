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