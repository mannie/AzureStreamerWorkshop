# Deploying The Streaming App Into Azure
Return to [Getting Started with Azure CLI](ReadMe.md).



---



In this section, we will deploy the streamer app into Azure to run in Container Instances. In order to do so, we will need to make sure we have an active Git client and Docker installation that we can use. The instructions below assume that you don't have either installed; if you already have these tools installed and prefer to use the local versions, feel free to do so.

**Section Outline**
1. [Creating the Staging VM](#creating-the-staging-vm)
1. [Configuring the VM](#configuring-the-vm)
1. [Obtaining the Streamer App](#obtaining-the-streamer-app)
1. [Deploying the Streamer App](#deploying-the-streamer-app)



---



## Creating the Staging VM

1. x
    ```sh
    # __LocalHost__
    vm=__virtual_machine_name__ # example: vm=staging
    az vm create \
        --name $vm \
        --resource-group $group \
        --location $location \
        --image $(az vm image list --all -p Canonical -f Ubuntu --query "[?sku=='18.10']".urn -o tsv | sort -u | head -n 1) \
        --authentication-type ssh \
        --generate-ssh-keys \
        --size Standard_D2s_v3
    ```

    ```json
    SSH key files '/Users/mannie/.ssh/id_rsa' and '/Users/mannie/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
    {
      "fqdns": "",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.Compute/virtualMachines/staging",
      "location": "eastus2",
      "macAddress": "00-0D-3A-0D-E8-91",
      "powerState": "VM running",
      "privateIpAddress": "10.0.0.4",
      "publicIpAddress": "52.225.130.62",
      "resourceGroup": "StreamerCLI",
      "zones": ""
    }
    ```



---



## Configuring the VM

1. SSH into your new VM via CLI using the login info provided at creation time:
    ```sh
    # __LocalHost__
    printf -v __getIP '%q ' az vm list-ip-addresses --resource-group $group --query "[?virtualMachine.name=='$vm'].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv
    ssh `eval $__getIP`
    ```
    You may receive a message (similar to this) asking you to confirm that you want to connect to the VM.
    ```
    The authenticity of host '52.225.130.62 (52.225.130.62)' can't be established.
    ECDSA key fingerprint is SHA256:U9KPN2lzxEcEO9qaW26vpf63JTVN5v2BHLdMlwR1IUM.
    Are you sure you want to continue connecting (yes/no)?
    ```
    To confirm that you want to continue accessing the VM, type `yes` and hit `Enter`.

1. x
    ```sh
    # __RemoteHost__
    src=https://raw.githubusercontent.com/mannie/AzureStreamerWorkshop/cli/CLI
    ```

1. x
    ```sh
    # __RemoteHost__
    curl --silent --show-error $src/ACI/InstallDevTools.sh | sudo bash
    ```

1. x
    ```sh
    # __RemoteHost__
    az login
    az account set --subscription __subscription_name_or_id__ # example: az account set --subscription AIRS
    ```



---



## Obtaining the Streamer App

1. Git `clone` the [Event Streamer](https://github.com/mannie/EventStreamer) app.
    ```sh
    # __RemoteHost__
    git clone https://github.com/mannie/EventStreamer.git
    ```
    You should see the output similar to the following...
    ```
    Cloning into 'EventStreamer'...
    remote: Enumerating objects: 181, done.
    remote: Counting objects: 100% (181/181), done.
    remote: Compressing objects: 100% (113/113), done.
    remote: Total 251 (delta 77), reused 148 (delta 53), pack-reused 70
    Receiving objects: 100% (251/251), 14.01 MiB | 0 bytes/s, done.
    Resolving deltas: 100% (104/104), done.
    ```
    ...and find that a new directory is available: `EventStreamer`. Change directory into the project's root, and list the contents.
    ```sh
    # __RemoteHost__
    cd EventStreamer && ls -F
    ```
    You don't need to know what to do with this folder structure yet: just note that the `Dockerfile` file exists as we will update this later.
    ```
    Container.gif  Dockerfile  Package.swift  PrepareXCodeProj.sh*  README.md  Sources/  Tests/  Xcode.gif
    ```

1. Build the app and run it.
    ```sh
    # __RemoteHost__
    app=__app_name_or_tag__ # example: app=streamer
    sudo docker build --tag $app .
    sudo docker run --interactive --tty --rm $app
    ```
    Once the app finishes building and starts running, the following output should be somewhat familiar:
    ```
    ...
    STREAM INFO
    	endpoint	 n/a
    	name		 deposit

    STREAM INFO
    	endpoint	 n/a
    	name		 withdrawal

    STREAM INFO
    	endpoint	 n/a
    	name		 purchase

    2019-05-03 19:28:43		depo...	1000 		["initial": 1000, "current": 1000, "name": "deposit"]
    2019-05-03 19:28:43		with...	50 		["initial": 50, "current": 50, "name": "withdrawal"]
    2019-05-03 19:28:44		purc...	10 		["name": "purchase", "current": 10, "initial": 10]
    2019-05-03 19:28:47		purc...	10 		["previous": 10, "initial": 10, "name": "purchase", "current": 10]
    2019-05-03 19:28:47		with...	52 		["previous": 50, "current": 52, "name": "withdrawal", "initial": 50]
    2019-05-03 19:28:48		purc...	12 		["previous": 10, "initial": 10, "name": "purchase", "current": 12]
    ...
    ```
    To stop the streamer, hit  `Ctrl + C`.



---



## Deploying the Streamer App

1. x
    ```sh
    # __LocalHost__
    acr=__globally_unique_name__ # example: acr=streamercli
    az acr create \
        --name $acr \
        --resource-group $group \
        --sku Basic \
        --admin-enabled true \
        --location $location
    ```
    ```json
    {
      "adminUserEnabled": true,
      "creationDate": "2019-05-02T20:51:26.728439+00:00",
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.ContainerRegistry/registries/streamercli",
      "location": "eastus2",
      "loginServer": "streamercli.azurecr.io",
      "name": "streamercli",
      "networkRuleSet": null,
      "provisioningState": "Succeeded",
      "resourceGroup": "StreamerCLI",
      "sku": {
        "name": "Basic",
        "tier": "Basic"
      },
      "status": null,
      "storageAccount": null,
      "tags": {},
      "type": "Microsoft.ContainerRegistry/registries"
    }
    ```

1. x
    ```sh
    # __RemoteHost__
    group=__name_of_your_resource_group__ # example: group=StreamerCLI
    acr=__name_of_your_newly_created_registry__ # example: acr=streamercli

    registry=$(az acr list --query "[?name=='$acr'].loginServer" --output tsv)

    printf -v __getACRUsername '%q ' az acr credential show -n $acr -g $group --query username -o tsv
    printf -v __getACRPassword '%q ' az acr credential show -n $acr -g $group --query passwords[0].value -o tsv

    sudo docker login $registry --username `eval ` --password `eval `
    ```
    ```
    Username: streamercli
    Password:
    WARNING! Your password will be stored unencrypted in /home/mannie/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded
    ```

1. x
    ```sh
    # __RemoteHost__
    repository=$registry/$app
    sudo docker tag $app $repository
    sudo docker push $repository
    ```

    ```
    The push refers to repository [streamercli.azurecr.io/streamer]
    d9912d906116: Pushed
    dd50c323d66d: Pushed
    c4b8fb3eedcf: Pushing [==>                                                ]  56.23MB/940MB
    0f5c40fcc0e7: Pushing [=======>                                           ]  50.96MB/342.3MB
    7660ded5319c: Pushed
    94e5c4ea5da6: Pushed
    5d74a98c48bc: Pushed
    604cbde1a4c8: Pushing [=======>                                           ]  15.24MB/101.7MB
    ```

1. x
    ```sh
    # __LocalHost__
    repository=$(az acr repository list --name $acr --query [0] --output tsv)
    az acr repository show-manifests --name $acr --repository $repository --detail
    ```

    ```json
    [
      {
        "architecture": "amd64",
        "changeableAttributes": {
          "deleteEnabled": true,
          "listEnabled": true,
          "readEnabled": true,
          "writeEnabled": true
        },
        "createdTime": "2019-05-02T21:22:56.5796654Z",
        "digest": "sha256:667858043fa532d71cf23eb4935bab2995f0d04ebc871f8128046495717e2671",
        "imageSize": 500401046,
        "lastUpdateTime": "2019-05-02T21:22:56.5796654Z",
        "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
        "os": "linux",
        "tags": [
          "latest"
        ]
      }
    ]
    ```

1. x
    ```sh
    # __LocalHost__
    az container create \
        --name $repository \
        --resource-group $group \
        --location $location \
        --image $(az acr show -n $acr -g $group --query loginServer -o tsv)/$repository \
        --registry-username $(az acr credential show -n $acr -g $group --query username -o tsv) \
        --registry-password $(az acr credential show -n $acr -g $group --query passwords[0].value -o tsv) \
        --os-type Linux \
        --cpu 1 \
        --memory 0.5 \
        --ip-address Private
    ```

    ```json
    {
      "containers": [ ... ],
      "diagnostics": null,
      "dnsConfig": null,
      "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/StreamerCLI/providers/Microsoft.ContainerInstance/containerGroups/streamer",
      "identity": null,
      "imageRegistryCredentials": [ ... ],
      "instanceView": {
        "events": [],
        "state": "Running"
      },
      "ipAddress": null,
      "location": "eastus2",
      "name": "streamer",
      "networkProfile": null,
      "osType": "Linux",
      "provisioningState": "Succeeded",
      "resourceGroup": "StreamerCLI",
      "restartPolicy": "Always",
      "tags": {},
      "type": "Microsoft.ContainerInstance/containerGroups",
      "volumes": null
    }
    ```

1. x
    ```sh
    # __LocalHost__
    az container logs --name $repository --resource-group $group --follow
    ```

    ```
    Fetching https://github.com/mannie/AzureCocoaSAS.git
    Fetching https://github.com/krzyzanowskim/CryptoSwift.git
    Completed resolution in 4.04s
    Cloning https://github.com/mannie/AzureCocoaSAS.git
    Resolving https://github.com/mannie/AzureCocoaSAS.git at master
    Cloning https://github.com/krzyzanowskim/CryptoSwift.git
    Resolving https://github.com/krzyzanowskim/CryptoSwift.git at 1.0.0
    [1/4] Compiling Swift Module 'CryptoSwift' (75 sources)
    [2/4] Compiling Swift Module 'AzureCocoaSAS' (1 sources)
    [3/4] Compiling Swift Module 'EventStreamer' (4 sources)
    [4/4] Linking ./.build/x86_64-unknown-linux/debug/EventStreamer
    STREAM INFO
      endpoint	 n/a
      name		 deposit
    ...
    ```


---



Move on to [Ingesting events into Event Hubs](EventHubs.md).
