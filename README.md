Octopus Deploy Powershell Scripts
=================================

Powershell deployment scripts for windows services, creating message queues and other common tasks for Octopus deployments.

Powershell scripts:

* Deploying and installing [NServiceBus](http://particular.net/) endpoints as windows services
* Deploying and installing [TopShelf](http://topshelf-project.com/) windows services
* Deploying and installing standard .exe executables as windows services
* Creating Microsoft Message Queues (MSMQ) 
* Deploying SQL Databases from Data-tier Application (DAC) files
* 


## NServiceBus Deploy

<code>nservicebus\Deploy.ps1</code>

Installs an NServiceBus endpoint as a windows service. If a service with the same name already exists, it will be stopped
and uninstalled fro the system BEFORE deploying the executable from the Octopus nuget package.

This script can also be used to provision a new system by installing the NServiceBus infrastructure, RavenDB, MSMQ, and 
DTC before installing the service (NServiceBus 3.x only!).


## TopShelf Deploy

<code>nservicebus\Deploy.ps1</code>

Installs a TopShelf service using the default HostFactory definition (generally in Program.cs).
the service with the same name already exists it will be stopped and reconfigured to use
the service executable from this deployed octopus package.


## MSMQ Pre-Deploy

<code>msmq\PreDeploy.ps1</code>

Pre deployment script that creates the required message queues (MSMQ). This script accepts
either a list of queue names, or the name of a file containing the queues to create.

The preferred mode of use is to define a <code>$MessageQueueNames</code> variable in the Octopus Web Portal. This allows
queues to be created on a per-machine & per-environment basis. Useful for provisioning private queues in test environments
and public TCP queues for production.


## SQL Database DAC Deploy

<code>mssql dac\Deploy.ps1</code>

Publishes a data-tier application (DAC) from a compiled DAC package to an existing 
SQL Database, Incrementally updating the database schema to match the source .dacpac
file. If the database does not exist on the server, the publish operation will deploy, 
otherwise an existing database will be updated.

This script is compatibile with Visual Studio 2012 SQL Server Database projects. 

DAC files can only be published to a machine that has the <code>SqlPackage.exe</code> command installed. This should be
part of your existing SQL Server 2012 installation and is also available by installing [SQL Server Database Tools](http://msdn.microsoft.com/en-us/data/tools.aspx) 
for Visual Studio. 




# License

Copyright (c) 2013 Brian Cowdery
Licensed under the MIT license.


