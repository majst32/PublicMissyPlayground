param()

$ProgressPreference = 'SilentlyContinue'
$params = @{
    ComputerName = "servername.contoso.com"
    Port = 5985
}

Test-NetConnection @params