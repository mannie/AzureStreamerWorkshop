# Capturing Events In Cosmos DB
Return to [Ingesting events into Event Hubs](EventHubs.md).



---



In this section, we will create a Logic App to respond to each event being streamed through our Event Hub. We'll take the payload...
```json
{
    "name": "deposit",
    "current": 999,
    "timestamp": 1551465599,
    "previous": 1000,
    "initial": 1000
}
```
...and enrich it...
```json
{
    "event": {
        "name": "deposit",
        "current": 999,
        "timestamp": 1551465599,
        "previous": 1000,
        "initial": 1000
    },
    "id": "34634-5535768",
    "properties": {
        "x-opt-sequence-number": 34634,
        "x-opt-offset": "5535768",
        "x-opt-enqueued-time": "2019-03-01T18:39:59.942Z"
    }
}
```
...before persisting it in our Cosmos DB instance.

**Section Outline**
1. [Creating the Cosmos DB Store](#creating-the-cosmos-db-store)
1. [Creating the Logic App](#creating-the-logic-app)
1. [Enriching the Event Payload](#enriching-the-event-payload)



---



## Creating the Cosmos DB Store

1. x
    ```sh
    # __LocalHost__
    cosmos=__globally_unique_name__ # example cosmosdb=streamercli
    az cosmosdb create \
        --name $cosmos \
        --resource-group $group \
        --locations $location=0 \
        --enable-multiple-write-locations true \
        --kind GlobalDocumentDB
    ```
    ```json
    {
      "capabilities": [],
      "consistencyPolicy": {
        "defaultConsistencyLevel": "Session",
        "maxIntervalInSeconds": 5,
        "maxStalenessPrefix": 100
      },
      "databaseAccountOfferType": "Standard",
      "documentEndpoint": "https://streamercli.documents.azure.com:443/",
      "enableAutomaticFailover": false,
      "enableMultipleWriteLocations": true,
      "failoverPolicies": [ ... ],
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.DocumentDB/databaseAccounts/streamercli",
      "ipRangeFilter": "",
      "isVirtualNetworkFilterEnabled": false,
      "kind": "GlobalDocumentDB",
      "location": "East US 2",
      "name": "streamercli",
      "provisioningState": "Succeeded",
      "readLocations": [ ... ],
      "resourceGroup": "StreamerCLI",
      "tags": {},
      "type": "Microsoft.DocumentDB/databaseAccounts",
      "virtualNetworkRules": [],
      "writeLocations": [ ... ]
    }
    ```

1. x
    ```sh
    # __LocalHost__
    db=events
    az cosmosdb database create \
        --db-name $db \
        --name $cosmos \
        --resource-group $group
    ```

    ```json
    {
      "_colls": "colls/",
      "_etag": "\"00002100-0000-0200-0000-5cd0451b0000\"",
      "_rid": "f8k-AA==",
      "_self": "dbs/f8k-AA==/",
      "_ts": 1557153051,
      "_users": "users/",
      "id": "events"
    }
    ```

1. x
    ```sh
    collection=captured
    az cosmosdb collection create \
        --collection-name $collection \
        --db-name $db \
        --name $cosmos \
        --partition-key-path /event/name \
        --resource-group $group \
        --throughput 400
    ```

    ```json
    {
      "collection": {
        "_conflicts": "conflicts/",
        "_docs": "docs/",
        "_etag": "\"00002300-0000-0200-0000-5cd046ba0000\"",
        "_rid": "f8k-AKWdebQ=",
        "_self": "dbs/f8k-AA==/colls/f8k-AKWdebQ=/",
        "_sprocs": "sprocs/",
        "_triggers": "triggers/",
        "_ts": 1557153466,
        "_udfs": "udfs/",
        "conflictResolutionPolicy": { ... },
        "geospatialConfig": {
          "type": "Geography"
        },
        "id": "captured",
        "indexingPolicy": { ... },
        "partitionKey": {
          "kind": "Hash",
          "paths": [
            "/event/name"
          ],
          "systemKey": false
        }
      },
      "offer": { ... }
    }
    ```

1. x



---



## Creating the Logic App

1. x
    ```sh
    # __LocalHost__
    az group deployment create \
        --resource-group $group \
        --template-uri https://raw.githubusercontent.com/mannie/AzureStreamerWorkshop/cli/CLI/LogicApps/CaptureEvents.0.arm.json
    ```
    ```json
    {
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.Resources/deployments/CaptureEvents.0.arm",
      "location": null,
      "name": "CaptureEvents.0.arm",
      "properties": {
        "correlationId": "81c04a57-ec47-4227-ab5d-5aef1b8f548b",
        "debugSetting": null,
        "dependencies": [],
        "duration": "PT6.7523756S",
        "mode": "Incremental",
        "onErrorDeployment": null,
        "outputResources": [ ... ],
        "outputs": null,
        "parameters": {
          "workflows_parent_name": {
            "type": "String",
            "value": "CaptureEvents"
          }
        },
        "parametersLink": null,
        "providers": [ ... ],
        "provisioningState": "Succeeded",
        "template": null,
        "templateHash": "1440037073524055121",
        "templateLink": null,
        "timestamp": "2019-05-10T22:25:35.446673+00:00"
      },
      "resourceGroup": "StreamerCLI",
      "type": null
    }
    ```

1. x
    ```sh
    # __LocalHost__
    az group deployment create \
        --resource-group $group \
        --template-uri https://raw.githubusercontent.com/mannie/AzureStreamerWorkshop/cli/CLI/LogicApps/CaptureEvents.1.arm.json \
        --parameters "{ \
                'eventhubs_hub_name' : { 'value' : '$eventhub' } \
            }"
    ```
    ```json
    {
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.Resources/deployments/CaptureEvents.1.arm",
      "location": null,
      "name": "CaptureEvents.1.arm",
      "properties": {
        "correlationId": "0ca5969a-0012-4fd8-bbf7-5bfaacbab4a0",
        "debugSetting": null,
        "dependencies": [],
        "duration": "PT4.0172356S",
        "mode": "Incremental",
        "onErrorDeployment": null,
        "outputResources": [ ... ],
        "outputs": null,
        "parameters": {
          "connections_eventhubs_externalid": {
            "type": "String",
            "value": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.Web/connections/eventhubs"
          },
          "eventhubs_hub_name": {
            "type": "String",
            "value": "cli"
          },
          "workflows_parent_name": {
            "type": "String",
            "value": "CaptureEvents"
          }
        },
        "parametersLink": null,
        "providers": [ ... ],
        "provisioningState": "Succeeded",
        "template": null,
        "templateHash": "9351925465353901771",
        "templateLink": null,
        "timestamp": "2019-05-10T22:29:06.345254+00:00"
      },
      "resourceGroup": "StreamerCLI",
      "type": null
    }
    ```

1. The `Overview` section of the Logic App should indicate that the Logic App has received and processed events (see the `Runs history` panel). If the `Runs history` isn't showing any activity, click the `Refresh` button located above the `Runs history` section.
  ![Runs history](LogicApps/Logic/10.png)

1. Clicking on an execution in the `Runs history` allows you to view more information about that run. All the actions in the Logic App will appear in a collapsed state with an icon indicating their success/failure; to expand an action to view more information, simply click on it. You should find that the `Content` of the Logic App trigger looks very similar to:
    ```json
    {
        "name": "deposit",
        "current": 999,
        "timestamp": 1551465599,
        "previous": 1000,
        "initial": 1000
    }
    ```
    ![Examine previous run](LogicApps/Logic/11.png)



---



## Enriching the Event Payload

1. x
    ```sh
    # __LocalHost__
    az group deployment create \
        --resource-group $group \
        --template-uri https://raw.githubusercontent.com/mannie/AzureStreamerWorkshop/cli/CLI/LogicApps/CaptureEvents.2.arm.json \
        --parameters "{ \
                'eventhubs_hub_name' : { 'value' : '$eventhub' }, \
                'cosmosdb_database_name' : { 'value' : '$db' }, \
                'cosmosdb_collection_name' : { 'value' : '$collection' } \
            }"
    ```
    ```json
    {
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.Resources/deployments/CaptureEvents.2.arm",
      "location": null,
      "name": "CaptureEvents.2.arm",
      "properties": {
        "correlationId": "fc58b1e2-9cb9-4b7c-8c3a-a9439cdc0d52",
        "debugSetting": null,
        "dependencies": [],
        "duration": "PT4.6728183S",
        "mode": "Incremental",
        "onErrorDeployment": null,
        "outputResources": [ ... ],
        "outputs": null,
        "parameters": { ... },
        "parametersLink": null,
        "providers": [ ... ],
        "provisioningState": "Succeeded",
        "template": null,
        "templateHash": "9644914800481869788",
        "templateLink": null,
        "timestamp": "2019-05-10T22:33:21.100645+00:00"
      },
      "resourceGroup": "StreamerCLI",
      "type": null
    }
    ```


1. Feel free to inspect the recent execution via the `Runs history` section of the `Overview` blade. Remember, if the `Runs history` isn't showing any activity, click the `Refresh` button located above the `Runs history` section.
  ![Runs history](LogicApps/Enrich/17.png)

1. To inspect the save documents in Cosmos DB, head on over to the `Data Explorer` on your Cosmos DB resource. Select the database, the collection, then the `Documents` option. You will find a list of the persisted documents; click to view any of the documents to inspect. The document should look like this (with a few additional properties prefixed by an underscore):
    ```json
    {
        "event": {
            "name": "deposit",
            "current": 999,
            "timestamp": 1551465599,
            "previous": 1000,
            "initial": 1000
        },
        "id": "34634-5535768",
        "properties": {
            "x-opt-sequence-number": 34634,
            "x-opt-offset": "5535768",
            "x-opt-enqueued-time": "2019-03-01T18:39:59.942Z"
        }
    }
    ```
    ![Cosmos DB Data Explorer](LogicApps/Enrich/18.png)



---



Move on to [Enriching the event's payload](Functions.md).
