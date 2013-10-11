# Installs an NServiceBus endpoint as a windows service. If the service with
# the same name already exists it will be stopped and uninstalled from the
# system before deploying the executable from this octopus package.
#
# see http://particular.net/articles/the-nservicebus-host
#	  http://particular.net/articles/profiles-for-nservicebus-host
#
# These variables can be set via the Octopus web portal:
#
#   ServiceName         - Name of the installed NServiceBus host windows service.
#	ServiceBusProfile	- Name of the NServicBus host profile to use when running the service.
#                         If left blank, NServiceBus defaults to "NServiceBus.Production"

# defaults
if (! $ServiceName) { $ServiceName = "My Endpoint Service" }


# try and install / update the service by name
$service = Get-Service $ServiceName -ErrorAction SilentlyContinue

$fullPath = Resolve-Path "NServiceBus.Host.exe"

if ($service)
{
	Write-Host "The existing service will be stopped and removed"

	Stop-Service $ServiceName -Force
	& "$fullPath" /uninstall /serviceName:"$ServiceName" | Write-Host
}


# rename the transformed "app.config" to "MyService.exe.config" as this is not handled automatically
# by octopus unless your transforms match the service exe config name ("MyService.<Environment>.exe.config")
Write-Host "Copying transformed $OctopusEnvironmentName configuration file"

Rename-Item "$ServiceExecutable.config" "$ServiceExecutable.config.original"
Copy-Item "app.config" -Destination "$ServiceExecutable.config"


# start !
Write-Host "Starting the service"
Start-Service $ServiceName
