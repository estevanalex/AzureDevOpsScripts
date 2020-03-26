# This script works for one file only, for multple files chenges on Body part (a for instruction) and on the Threadfix URL are required.
# You can use Azure DevOps Build Protected Variables for API Key and Build Variables for APPID, URL, FileUp. 

# Enable PS to work with TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ThreadFix Application ID - please change to your APP ID.
$TF_APPID = "1000"
# ThreadFix URL - please change to your TF URL. 
$TF_URL = "https://yourthreadfixURL.com" + "/rest/latest/applications/" + $TF_APPID + "/upload"
# TF API Key - Use your API Key for Threadfix.
$TF_APIKey = "4rjejed8dedyeddjn9ef3rhf9rfhrnc9h3dhe37d"
   
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
   
# Upload Files
$_results = Invoke-RestMethod -Uri $TF_URL -Headers $headers -Method Post -ContentType "multipart/form-data; boundary=`"$Boundary`"" -Body $Body
