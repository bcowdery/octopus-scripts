# Pre deployment script that creates the required message queues (MSMQ). This script accepts
# either a list of queue names, or the name of a file containing the queues to create.
#
# These variables should be set via the Octopus web portal:
#
#	MessageQueueNames	- Comma separated list of queues to create.
#   MessageQueueFile    - Name of the file containing list of queue names (one per line) to create. Overrides $MesageQueueNames.
#	DeleteIfExists		- Delete queue if it already exists, defaults to False

# defaults
$ScriptPath = Split-Path -parent $MyInvocation.MyCommand.Definition
$DeleteIfExists = [System.Convert]::ToBoolean($DeleteIfExists)


# get queues names to create
$queues = @();
if ($MessageQueueFile -ne $NULL) {
    $fullPath = Join-Path $ScriptPath $MessageQueueFile
    $queues = Get-Content $fullPath

} elseif ($MessageQueueNames -ne $NULL) {
    $queues = $MessageQueueNames.Split(",");
}


# go go gadget msmq
Write-Host "Creating queues and setting permissions to Everyone/FullControl"

[Reflection.Assembly]::LoadWithPartialName("System.Messaging")
$msmq = [System.Messaging.MessageQueue]

foreach ($queue in $queues) {
	$queue = $queue.Trim()
	$create = $true

	if ($msmq::Exists($queue)) {
		if ($DeleteIfExists) {
			Write-Host " Queue '$queue' already exists and will be deleted"
			$msmq::Delete($queue)
		}
		else
		{
			Write-Host " Queue '$queue' already exists"
			$create = $false
		}
	}

	if ($create) {
		Write-Host " Creating queue '$queue'"
		$q = $msmq::Create($queue)
		$q.UseJournalQueue = $TRUE
		$q.MaximumJournalSize = 1024 #kilobytes
		$q.SetPermissions("Everyone", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
		$q.SetPermissions("ANONYMOUS LOGON", [System.Messaging.MessageQueueAccessRights]::FullControl, [System.Messaging.AccessControlEntryType]::Set)
	}
}
