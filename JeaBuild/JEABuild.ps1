<#
Disclaimer

This example code is provided without copyright and “AS IS”.  It is free for you to use and modify.
Note: These demos should not be run as a script. These are the commands that I use in the 
demonstrations and would need to be modified for your environment.

#>

Param (
[String]$JEADevPath = 'c:\JeaDev',
[String]$JEAModuleName = 'JEAPrint',
[String]$JEARoleName = 'JEAPrintRole', # .psrc will be added later
[String]$JEASessionConfigName = 'JEAPrintConfig', # .pssc will be added later
[String]$JEAEndpointName = 'JEAPrintOperators',
[String]$ADGroupName = 'Company\JEA Print Operators'
)

#region Folder AND Module and EndPoint Config

$JEAProjectPath = "$JEADevPath\$JEAModuleName"

If ((Test-Path -path "$JEAProjectPath\RoleCapabilities") -eq $False) {
    Write-Output "Creating directory and module $JEAProjectPath"
    New-Item -Path "$JEAProjectPath" -ItemType Directory -Force
    New-Item -Path "$JEAProjectPath\RoleCapabilities" -ItemType Directory 
    New-Item -Path "$JEAProjectPath\$JEAModuleName.psm1" -ItemType File 
    New-ModuleManifest -Path "$JEAProjectPath\$JEAModuleName.psd1" -RootModule "$JEAModuleName.psm1" `
    -Guid ([GUID]::NewGuid()) -ModuleVersion 1.0 -Author Jason `
    -Description "JEA Endpoint: $JEAEndpointName"  
}
#endregion

#region Create Role Capability module

$RolePath = "$JEAProjectPath\RoleCapabilities\$JEARoleName.psrc"

$RoleCapability = @{
    Path = "$RolePAth"
    Author = 'Company Admin'
    CompanyName = 'Company'
    VisibleCmdlets = 'Restart-Service'
    FunctionDefinitions = @{ Name = 'Get-UserInfo'; ScriptBlock = { $PSSenderInfo } }
#   $PSSenderInfo is not exposed by default - so we make a function to display that is
}

New-PSRoleCapabilityFile @RoleCapability 

#endregion 

#region Session Configuration file (constrained Endpoint)

# Warning - must delete old file of you run this multiple times.
$SessionConfig = @{
    SessionType = 'RestrictedRemoteServer'
    RunAsVirtualAccount = $true
    TranscriptDirectory = "c:\ProgramData\JEAConfiguration\Transcripts\$JEAEndpointName"
    RoleDefinitions = @{"$ADGroupName" = @{ RoleCapabilities = "$JEARoleName" }}
}

New-PSSessionConfigurationFile -Path "$JEAProjectPath\$JEASessionConfigName.pssc" @SessionConfig


#endregion

BREAK



##region Deploy to S1 or client

Copy-Item C:\GitHub\JEA\DSCCamp\JeaBuild\JeaDeploy.ps1 -Destination $JEAProjectPath

# Deploy S1
Copy-Item "$JEAProjectPath" -Recurse -Destination "\\s1\c$\JeaDev\$JEAModuleName" -Force
Invoke-Command -ComputerName s1 {& "$Using:JEAProjectPath\JeaDeploy.ps1"}
##Explain error messege -- do to Restart of WinRM

# Deploy Client
& C:\JeaDev\JEAPrint\JeaDeploy.ps1
##endregion
#

