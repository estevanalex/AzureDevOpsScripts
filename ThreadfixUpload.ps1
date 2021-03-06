# This script works for one file only, for multple files chenges on Body part (a for instruction) and on the Threadfix URL are required.
# How to use:
# Copy and Paste into the Powershell Script Task (inline).
#
# You can use Azure DevOps Build Protected Variables for TF_APIKey and Build Variables for TF_APPID, TF_URL, FileUp.
# To do list: 
# - multiple files (a for loop in the #Body part)

# Enable PS to work with TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ThreadFix Application ID - please change to your APP ID.
$TF_APPID = "1000"
# ThreadFix URL - please change to your TF URL. 
$TF_URL = "https://yourthreadfixURL.com" + "/rest/latest/applications/" + $TF_APPID + "/upload"
# TF API Key - Use your API Key for Threadfix.
$TF_APIKey = "<YOURAPIKEY>"
   
# Header
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "APIKEY " + $TF_APIKey)
$headers.Add("Accept", "application/json")
   
# File Section
# Scan result full file path for uploading - you can use a combination of Azure DevOps Standard Build Variables and previous task variables
# On the example we are collecting the OWASP Dependency Check Task result, but works for any scan result file supported by Threadfix
$FileUp = "$(Agent.BuildDirectory)\TestResults\dependency-check\dependency-check-report.xml"

$FileName = Split-path $FileUp -Leaf
$FileBytes = [System.IO.File]::ReadAllBytes($FileUp)
$FileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($FileBytes)
   
# Body
$Boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"
$Body = @(
  "--$Boundary",
  "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"",
  "Content-Type: application/octet-stream$LF",
  $FileEnc,
  "--$Boundary--$LF" 
) -join $LF
   
# Upload Files in four attempts
$_attempts = 1
$_looperror = 0
do 
{ 
    $_results = try { Invoke-RestMethod -Uri $TF_URL -Headers $headers -Method Post -ContentType "multipart/form-data; boundary=`"$Boundary`"" -Body $Body } catch { $_.Exception.Response }
    $_httpcode = $_results.StatusCode
    if (!$_httpcode)
    {
        $_looperror = 0
        $_attempts = 5
    } else {
        Write-Host "##vso[task.LogIssue type=warning;]Attempt $_attempts failed due" $_results.StatusCode
        $_attempts++
        $_looperror = 1
        Start-Sleep 4
    } 
} while ( $_attempts -le 4 )

if ( $_looperror -eq 1 )
{
   Write-Host "##vso[task.LogIssue type=error;]Uploading the Scan to Threafix is not working!!! Do it manually via Threadfix Application page!!!!"
   Write-Host "##vso[task.complete result=SucceededWithIssues;]"
} else {
   Write-Host "Threadfix Scan Upload for Application $TF_APPID has been done!"
}
