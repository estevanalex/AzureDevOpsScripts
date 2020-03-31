# Get the latest scan from TF Remote Provider 
# To use this script your must configure Threadfix Remote Provider with your Fortify On Demand instance
# You can use Azure DevOps Build Protected Variables for TF_APIKey and Build Variables for TF_APPID, TF_URL, TF_RPID. 
# To do list: 
#  (no file, upload error, upload status)
# - multiple files (a for loop in the #Body part)

# Same AppID from TF
$TF_APPID = "999"

# Remote Provider ID for Foritfy On Demand
$TF_RPID = "1"

# URL and API Key
# ThreadFix URL for Remote Prodiver - please change to your TF URL. 
$TF_URL = "https://yourthreadfixURL.com" + "/rest/latest/remoteprovider/" + $TF_RPID + "/importAllForApplication/" + $TF_APPID
# TF API Key - Use your API Key for Threadfix.
$TF_APIKey = "<YOURAPIKEY>"

# Header
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "APIKEY " + $TF_APIKey)
$headers.Add("Accept", "application/json")

# Sync
$_results = Invoke-RestMethod -Uri $TF_URL -Headers $headers -Method Post 
