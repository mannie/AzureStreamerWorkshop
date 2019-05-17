# Ingesting Events Into Event Hubs
Return to [Deploying the streaming app into Azure](ACI.md).



---



In this section, we will create and configure our Event Hub to ingest data from our streamer app and publish it to subscribers. Configuring subscribers is the topic of the next section: [Capturing events in Cosmos DB](LogicApps.md).

**Section Outline**
1. [Creating an Event Hub](#creating-an-event-hub)
1. [Updating the Streamer App](#updating-the-streamer-app)



---



## Creating an Event Hub

1. x
    ```sh
    # __LocalHost__
    namespace=__globally_unique_name__ # example: namespace=streamercli
    az eventhubs namespace create \
        --name $namespace \
        --resource-group $group \
        --location $location \
        --sku Basic
    ```
    ```json
    {
      "createdAt": "2019-05-03T20:45:49.190000+00:00",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.EventHub/namespaces/streamercli",
      "isAutoInflateEnabled": false,
      "kafkaEnabled": false,
      "location": "East US 2",
      "maximumThroughputUnits": 0,
      "metricId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:streamercli",
      "name": "streamercli",
      "provisioningState": "Succeeded",
      "resourceGroup": "StreamerCLI",
      "serviceBusEndpoint": "https://streamercli.servicebus.windows.net:443/",
      "sku": {
        "capacity": 1,
        "name": "Basic",
        "tier": "Basic"
      },
      "tags": {},
      "type": "Microsoft.EventHub/Namespaces",
      "updatedAt": "2019-05-03T20:46:16.210000+00:00"
    }
    ```

1. x
    ```sh
    # __LocalHost__
    eventhub=__name__ # example: eventhub=cli
    az eventhubs eventhub create \
        --resource-group $group \
        --namespace-name $namespace \
        --name $eventhub \
        --message-retention 1
    ```
    ```json
    {
      "captureDescription": null,
      "createdAt": "2019-05-03T20:48:01.317000+00:00",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.EventHub/namespaces/streamercli/eventhubs/cli",
      "location": "East US 2",
      "messageRetentionInDays": 1,
      "name": "cli",
      "partitionCount": 4,
      "partitionIds": [
        "0",
        "1",
        "2",
        "3"
      ],
      "resourceGroup": "StreamerCLI",
      "status": "Active",
      "type": "Microsoft.EventHub/Namespaces/EventHubs",
      "updatedAt": "2019-05-03T20:48:01.673000+00:00"
    }
    ```



---



## Updating the Streamer App

1. Update your `Dockerfile` with the info for your Event Hub. `SASPolicyName` is the name of the SAS Policy whose value we copied (`RootManageSharedAccessKey`), while `SASPolicyKey` is the value we copied. `EventHubNamespace` and `EventHubPath` are the globally unique name of the Event Hub Namespace and that of the Event Hub, respectively. Your `Dockerfile` should look something like this; only the lines beginning with `ENV` should have changed.
    ```
    FROM swift
    ENV SASPolicyName="RootManageSharedAccessKey"
    ENV SASPolicyKey="9gk50LPNstmrs1DKIVdASdkKgxZZSIp4olPRnXZmhDQ="
    ENV EventHubNamespace="streamercli"
    ENV EventHubPath="cli"
    WORKDIR /temp
    COPY . ./
    CMD swift package clean
    CMD swift run
    ```
    ```sh
    # __RemoteHost__
    namespace=__eventhub_namespace__ # example: namespace=streamercli
    eventhub=__path_to_eventhub__ # example: eventhub=cli

    printf -v __getSharedPolicy '%q ' \
        az eventhubs namespace authorization-rule list \
            --namespace-name $namespace \
            --resource-group $group \
            --query "[?contains(rights, 'Send')].name" \
            --output tsv

    printf -v __getAccessKey '%q ' \
        az eventhubs namespace authorization-rule keys list \
            --name `eval $__getSharedPolicy` \
            --namespace-name $namespace \
            --resource-group $group \
            --query primaryKey \
            --output tsv

    function __env { echo "s ($1=.*\")(.*)(\") \1$2\3 "; } # Using [space] as the sed regex delimiter.

    cat Dockerfile | \
        sed -E "$(__env SASPolicyName `eval $__getSharedPolicy`)" | \
        sed -E "$(__env SASPolicyKey `eval $__getAccessKey`)" | \
        sed -E "$(__env EventHubNamespace $namespace)" | \
        sed -E "$(__env EventHubPath $eventhub)" > \
            Dockerfile
    ```

1. x
    ```sh
    # __RemoteHost__
    cat Dockerfile
    ```

1. Rebuild the streamer app and run it.
    ```sh
    # __RemoteHost__
    sudo docker build --tag $app .
    sudo docker run --interactive --tty --rm $app
    ```
    Once the app starts running, you should see something like this before your events start streaming:
    ```
    STREAM INFO
    	endpoint	 https://streamercli.servicebus.windows.net/cli
    	name		 deposit
    ```
    If the value of the endpoint is still `n/a`, ensure that the `ENV` variables in your `Dockerfile` are set correctly.

1. Push your updated image up to the container registry. `$registry` should already contain the address to your registy; if not, feel free to update it accordingly.
    ```sh
    # __RemoteHost__
    sudo docker tag $app $repository
    sudo docker push $repository
    ```

    ```
    The push refers to repository [streamercli.azurecr.io/streamer]
    7c628f71b988: Pushed
    afea60e837d3: Pushed
    c4b8fb3eedcf: Layer already exists
    0f5c40fcc0e7: Layer already exists
    7660ded5319c: Layer already exists
    94e5c4ea5da6: Layer already exists
    5d74a98c48bc: Layer already exists
    604cbde1a4c8: Layer already exists
    latest: digest: sha256:c3e67ac963d2f2cd5b82bc3405de6aa799cd349c2c1db5e32285f828b41b815a size: 1994
    ```

1. x
    ```sh
    # __LocalHost__
    az container restart --name $repository --resource-group $group
    az container logs --name $repository --resource-group $group --follow
    ```



---



Move on to [Capturing events in Cosmos DB](LogicApps.md).
