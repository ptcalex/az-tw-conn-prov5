##### CONFIGURATION - MUST SETUP IN ADVANCE #####

# AZURE IOT HUB PARAMETERS #
$azStorageAccount = ""    # storage account name
$azIoTHub = ""            # IoT Hub name
$azConsumerGroup = ""     # consumer group name (see Azure Portal > IoT Hub > Built-in endpoints)

# THINGWORX PARAMETERS #
$twUrl = ""               # "https://hostname:port/Thingworx"
$twApplicationKey = ""    # your application key previously created in ThingWorx
$twProject = ""           # ThingWorx project to created for collecting provisioned entities
$twAzureBlobTemplate = "AzureBlobStorageTemplate"
$twAzureBlobThing = ""    # Azure Storage Container thing
$twAzureIotHubTemplate = "AzureIotHubTemplate"
$twAzureIoTHubThing = ""  # Azure IoT Hub thing



######## IMPLEMENTATION ########
################################
##### DO NOT CHANGE BELOW ######

Write-Output "1/7 - Getting Azure Blob Storage connection string..."
$connectionString = ((az storage account show-connection-string --name $azStorageAccount) | ConvertFrom-Json).connectionString

Write-Output "2/7 - Getting Azure IoT Hub iothubowner policy connection string..."
$iotHubOwnerPolicyConnectionString = ((az iot hub show-connection-string --hub-name $azIoTHub --policy-name iothubowner --key primary) | ConvertFrom-Json).connectionString

Write-Output "3/7 - Getting Azure IoT Hub service policy connection string..."
$consumerPolicyConnectionString = ((az iot hub show-connection-string --hub-name $azIoTHub --policy-name service --key primary) | ConvertFrom-Json).connectionString

Write-Output "4/7 - Getting Azure IoT Hub registryReadWrite policy connection string..."
$registryPolicyConnectionString = ((az iot hub show-connection-string --hub-name $azIoTHub --policy-name registryReadWrite --key primary) | ConvertFrom-Json).connectionString

Write-Output "5/7 - Getting Azure Event Hub compatible name..."
$eventHubName = (az iot hub show --name $azIoTHub | ConvertFrom-Json).properties.eventHubEndpoints.events.path

Write-Output "6/7 - Getting Azure Event Hub endpoint..."
$eventHubEndpoint = (az iot hub show --name $azIoTHub | ConvertFrom-Json).properties.eventHubEndpoints.events.endpoint
$sharedAccessKeyName = $iotHubOwnerPolicyConnectionString.split(";")[1]
$sharedAccessKey = $iotHubOwnerPolicyConnectionString.split(";")[2]
$eventHubCompatibleEndpoint = "Endpoint=$eventHubEndpoint;$sharedAccessKeyName;$sharedAccessKey;EntityPath=$eventHubName"

$consumerGroup = $azConsumerGroup

# ThingWorx Entities #
$twEntities = New-Object PSObject
$twEntities | Add-Member project $twProject
$twEntities | Add-Member blobThing $twAzureBlobThing
$twEntities | Add-Member iotHubThing $twAzureIoTHubThing

# Blob Storage Thing Configuration #
$azBlobConfig = New-Object PSObject
$azBlobConfig | Add-Member accountName $azStorageAccount
$azBlobConfig | Add-Member connectionString $connectionString

# IoT Hub Thing Configuration #
$azIoTHubConfig = New-Object PSObject
$azIoTHubConfig | Add-Member iotHubName $azIoTHub
$azIoTHubConfig | Add-Member eventHubName $eventHubName
$azIoTHubConfig | Add-Member eventHubEndpoint $eventHubCompatibleEndpoint
$azIoTHubConfig | Add-Member consumerPolicyConnectionString $consumerPolicyConnectionString
$azIoTHubConfig | Add-Member registryPolicyConnectionString $registryPolicyConnectionString
$azIoTHubConfig | Add-Member consumerGroup $consumerGroup

$config = New-Object PSObject
$config | Add-Member thingworx $twEntities
$config | Add-Member blob $azBlobConfig
$config | Add-Member iot $azIoTHubConfig

$json = New-Object PSObject
$json | Add-Member json $config

Write-Output "7/7 - Calling ThingWorx provisioning service..."
$Url = "$twUrl/Things/ALX.IoTHub.Helper/Services/ProvisionIoTHubConnectorEntities"
$Headers = @{
  'appkey' = $twApplicationKey
  'content-type' = 'application/json'
  'accept' = 'application/json'
}
$Body = ConvertTo-Json $json
Invoke-RestMethod -Method POST -Uri $Url -Body $Body -Headers $Headers | ConvertTo-Json
