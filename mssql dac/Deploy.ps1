# Publishes a data-tier application (DAC) from a compiled DAC package to an existing 
# SQL Database, Incrementally updating the database schema to match the source .dacpac
# file. If the database does not exist on the server, the publish operation will deploy,
# otherwise an existing database will be updated.
#
# see http://msdn.microsoft.com/en-us/library/hh550080(v=vs.103).aspx
#
# These variables can be set via the Octopus web portal:
#
#    $SqlPackageFile 		- Name of the included SQL data-tier application .dacpac file
#    $ConnectionString		- Target connection string of the database to deploy to
#    $SqlPackageExecutable	- Path to the command line SqlPackage.exe deployment utility
#
# SQLCMD Varaibles that can be set via the Octopus web portal:
#    $MyCmdVar 	- Sets the $(MyCmdVar) SQLCMD var


$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path 

# defaults
if (! $SqlPackageFile) { $SqlPackageFile = "MyDatabase.dacpac" }
if (! $ConnectionString) { $ConnectionString = "Server=(local);Database=MyDatabase;Trusted_Connection=True" }
if (! $SqlPackageExecutable) { $SqlPackageExecutable = "C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\SqlPackage.exe" }


# SQLCMD Variables
if (! $MyCmdVar) { $MyCmdVar = "Runtime value of a SQLCMD variable." }

# Publish to target database
$dacPath = Join-Path $ScriptPath $SqlPackageFile
& "$SqlPackageExecutable" /SourceFile:"$dacPath" /Action:Publish /TargetConnectionString:$ConnectionString /Variables:MyCmdVar=$MyCmdVar | Write-Host
