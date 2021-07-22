# Azure ThingWorx IoT Hub Connector Provisioning - Step 5

The ThingWorx Azure IoT Hub Connector integrates edge devices that are running applications developed using a Microsoft Azure IoT SDK with the ThingWorx Platform.

Getting an Azure IoT Hub Connector up and running requires performing several installation and configuration steps, described [here](http://support.ptc.com/help/thingworx/azure_connector_scm/en/#page/thingworx_scm_azure%2Fazure_connector%2Fc_azure_connector_up_and_running.html%23 "Getting an Azure IoT Hub Connector Up and Running").

Of those steps, [Step 5](http://support.ptc.com/help/thingworx/azure_connector_scm/en/#page/thingworx_scm_azure%2Fazure_connector%2Fc_azure_connector_create_azure_entities_in_thingworx.html%23 "Step 5. Create Azure IoT Entities in ThingWorx Composer") could be automated with a script.

This repository contains such a script, implemented with Windows PowerShell commands which eventually call ThingWorx services via REST.

In order to benefit from this script you need first to:
1. Load entities in ThingWorx (file Entities.twx is included here) 
2. Install Azure PowerShell
3. Execute the `az login` command
4. Execute the PowerShell script (file `iot-hub-connector-provisioning.ps1` is included in this repository)
