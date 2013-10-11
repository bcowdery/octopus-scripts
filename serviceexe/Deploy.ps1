# Installs an executable as a windows service. If the service with the same name already exists
# it will be stopped and reconfigured to use the service executable from this deployed octopus package.
#
# see example http://octopusdeploy.com/documentation/features/powershell
#
# These variables can be set via the Octopus web portal:
#
#   ServiceName         - Name of the Windows service.
#   ServiceExecutable   - Path to the .exe file, typically will be located in the root of the NuGet package

# defaults
if (! $ServiceName) { $ServiceName = "My Service" }
if (! $ServiceExecutable) { $ServiceExecutable = "MyService.exe" }


# try and install / update the service by name
$service = Get-Service $ServiceName -ErrorAction SilentlyContinue

$fullPath = Resolve-Path $ServiceExecutable

if (! $service)
{
    Write-Host "The service will be installed"

	New-Service -Name $ServiceName -BinaryPathName $fullPath -StartupType Automatic
}
else
{
    Write-Host "The service will be stopped and reconfigured"

	Stop-Service $ServiceName -Force

    & "sc.exe" config $service.Name binPath= $fullPath start= auto | Write-Host
}


# rename the transformed "app.config" to "MyService.exe.config" as this is not handled automatically
# by octopus unless your transforms match the service exe config name ("MyService.<Environment>.exe.config")
Write-Host "Copying transformed $OctopusEnvironmentName configuration file"

Rename-Item "$ServiceExecutable.config" "$ServiceExecutable.config.original"
Copy-Item "app.config" -Destination "$ServiceExecutable.config"


# start !
Write-Host "Starting the service"
Start-Service $ServiceName
