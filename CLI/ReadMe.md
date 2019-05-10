# Getting Started with Azure CLI
Return to [Introduction](../ReadMe.md).



---


Due to the nature of working via CLI, you will need to be comfortable working across multiple different sessions and managing the state across those sessions. It is recommended to have 2 active sessions to complete the workshop: one on your **local machine** (local host), and another on the **Azure VM** (remote host, which will be created as part of the lab).

Decorations will be added preceding any commands to provide context for the execution environment. Commands preceded by `__LocalHost__` are to be run locally, while those preceded by `__RemoteHost__` are to be executed in the Azure VM. Commands without any decorations can be executed from a host of your choosing. Below are some examples to help familiarize yourself with this convention:
```sh
# __LocalHost__
echo "You should enter this command in your local machine's environment."
```
```sh
# __RemoteHost__
echo "However, you should switch to the session in your Azure VM and execute this command there!"

echo "This command is also meant to be executed remotely."
```
```sh
echo "Feel free to execute this locally or in your Azure VM."
echo "It may make sense to run the commands in whatever context you're currently in..."
echo "...I mean... it's easier!"

echo "¯\_(ツ)_/¯. "
```



1. x
    ```sh
    # __LocalHost__
    az login
    ```

    ```json
    Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
    You have logged in. Now let us find all the subscriptions to which you have access...
    [
    	{
    		"cloudName": "AzureCloud",
    		"id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    		"isDefault": true,
    		"name": "AIRS",
    		"state": "Enabled",
    		"tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    		"user": {
    			"name": "manniet@microsoft.com",
    			"type": "user"
    		}
    	}
    ]  
    ```

1. x
    ```sh
    # __LocalHost__
    az account set --subscription __subscription_name__ # example: az account set --subscription "AIRS"
    ```

1. x
    ```sh
    # __LocalHost__
    group=__resource_group_name__ # example: group=StreamerCLI
    location=__location_for_your_azure_resources__ # example: location=eastus2
    ```

    https://azure.microsoft.com/en-us/global-infrastructure/services/?products=all

1. x.
    ```sh
    # __LocalHost__
    az group create --name $group --location $location
    ```

    ```json
    {
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI",
      "location": "eastus2",
      "managedBy": null,
      "name": "StreamerCLI",
      "properties": {
        "provisioningState": "Succeeded"
      },
      "tags": null,
      "type": null
    }
    ```



---



Move on to [Deploying the streaming app into Azure](ACI.md).
