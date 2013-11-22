# Installs an NServiceBus endpoint as a windows service. If the service with
# the same name already exists it will be stopped and uninstalled from the
# system before deploying the executable from this octopus package.
#
# see http://particular.net/articles/the-nservicebus-host
#	  http://particular.net/articles/profiles-for-nservicebus-host
#
# These variables can be set via the Octopus web portal:
#
#   ServiceName         	- Name of the installed NServiceBus host windows service.
#	ServiceEndpointDll		- Name of the DLL that configures this endpoint, used to apply app.config after transforms.
#	ServiceBusProfile		- Name of the NServicBus host profile to use when running the service. If left blank, NServiceBus defaults to "NServiceBus.Production"
#	InstallInfrastructure	- If True, runs the NServiceBus infrastructure installers before deployment (defaults to False)

# defaults
if (! $ServiceName) { $ServiceName = "My Endpoint Service" }
if (! $ServiceEndpointDll) { $ServiceEndpointDll = "My.Endpoint.Service.dll" }
$InstallInfrastructure = [System.Convert]::ToBoolean($InstallInfrastructure);


# install / update by service name
$fullPath = Resolve-Path "NServiceBus.Host.exe"

$service = Get-Service $ServiceName -ErrorAction SilentlyContinue

if ($service) 
{
	Write-Host "The existing service will be stopped and removed"
	
	Stop-Service $ServiceName -Force
	& "$fullPath" /uninstall /serviceName:"$ServiceName" | Write-Host
}

if ($InstallInfrastructure) 
{
	Write-Host "Installing NServiceBus infrastructure (RavenDB, MSMQ etc.)"
	& "$fullPath" /installInfrastructure $ServiceBusProfile | Write-Host	
}

Write-Host "The service will be installed"       	
& "$fullPath" /install /serviceName:"$ServiceName" $ServiceBusProfile | Write-Host

Write-Host "Copying transformed $OctopusEnvironmentName configuration file"
Rename-Item "$ServiceEndpointDll.config" "$ServiceEndpointDll.config.original"
Copy-Item "app.config" -Destination "$ServiceEndpointDll.config"


# Try and start the service by name
# Fail the deployment if ther are any errors

$ErrorActionPreference = "Stop"
try 
{
    Write-Host "Starting the service"
    Start-Service $ServiceName
}
catch 
{
    Write-Host "$($_.Exception.Message)"  -ForegroundColor Red
    Write-Host "$($_.InvocationInfo.PositionMessage)" -ForegroundColor Red
    exit 1
}
