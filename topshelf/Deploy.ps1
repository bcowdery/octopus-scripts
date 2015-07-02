# Installs a TopShelf service using the default HostFactory definition (generally in Program.cs).
# If the service with the same name already exists it will be stopped and reconfigured to use
# the service executable from this deployed octopus package.
#
# see http://docs.topshelf-project.com/en/latest/overview/commandline.html
#
# These variables should be set via the Octopus web portal:
#
#   ServiceName         - Name of the Windows service
#   ServiceExecutable   - Path to the .exe containing the TopShelf service

# defaults
if (! $ServiceName) { $ServiceName = "My Service" }
if (! $ServiceExecutable) { $ServiceExecutable = "MyService.exe" }


# try and install / update the service by name
$service = Get-Service $ServiceName -ErrorAction SilentlyContinue

$fullPath = Resolve-Path $ServiceExecutable

if (! $service)
{
    Write-Host "The service will be installed"

	& "$fullPath" install --servicename:$ServiceName | Write-Host
}
else
{
    Write-Host "The service will be stopped and reconfigured"

	Stop-Service $ServiceName
    & "sc.exe" config $service.Name binPath= $fullPath start= auto | Write-Host
}

if(Test-Path "app.config")
{
	# rename the transformed "app.config" to "MyService.exe.config" as this is not handled automatically
	# by octopus unless your transforms match the service exe config name ("MyService.<Environment>.exe.config")
	Write-Host "Copying transformed $OctopusEnvironmentName configuration file"

	Rename-Item "$ServiceExecutable.config" "$ServiceExecutable.config.original"
	Copy-Item "app.config" -Destination "$ServiceExecutable.config"
}

Write-Host "Starting the service"
Start-Service $ServiceName
