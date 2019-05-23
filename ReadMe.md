# Azure Streamer Workshop

Serverless is reshaping the way developers think about software/system architectures. By simplifying infrastructure, technologies such as Functions, Logic Apps, and Event Hubs have made is easier to develop reusable APIs (consumed by mobile, desktop, web, and IoT clients).

The burden of managing infrastructure no longer lies with the developer, leaving them to focus on solving the problem (i.e. writing code) instead of worrying about managing the environment. Infrastructure professionals also benefit from PaaS; thanks to auto-scale and micro-billing, there are financial savings to be realized without sacrificing scalability per demand.

In this workshop, you will develop an end-to-end data streaming/processing solution using a variety of technologies. We will walk through how to deploy an event generation/streaming application into [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/); this app will be the data source of our pipeline. Events will be streamed to [Event Hubs](https://azure.microsoft.com/en-us/services/event-hubs/), after which [Logic Apps](https://azure.microsoft.com/en-us/services/logic-apps/) will respond to each event entering the pipeline, using [Functions](https://azure.microsoft.com/en-us/services/functions/) for data enrichment prior to storing the events in [Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db/) for future consumption. [API Management](https://azure.microsoft.com/en-us/services/api-management/) will provide an abstraction layer over our newly created APIs, to support reuse of code by others.

![Architecture](Architecture.png)

### Target Audience
* Technical roles (engineers, architects, infrastructure managers, etc.).
* Anyone interested in automating business processes.
* Anyone interested in learning about Azure and Serverless.

### Requirements
* An active [Azure Subscription](https://azure.microsoft.com/en-us/free/).
* An internet enabled computer.

### Before You Start
* Ensure that you have access to command line interface (CLI) that is capable of [SSH tunneling](https://www.ssh.com/ssh/tunneling/). If your local CLI cannot SSH, feel free to use the [Azure Cloud Shell](https://shell.azure.com); follow these [instructions to set up your environment](CloudShell.md) if this is your first time using it.
* Ensure that you have the Azure CLI `az` installed if you plan on working through the CLI path; follow these [instructions to install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). The Azure Cloud Shell has `az` readily available; this is a viable option if you prefer to not have `az` installed locally.
* It may be worth preloading your API Management service (which will be required later in the workshop) as this service typically take a little while to deploy and provision; for more info on how to do so, see the relevant section for your chosen path:
  * [Portal](Portal/APIM.md#creating-the-api-management-service);
  * [CLI](CLI/APIM.md#creating-the-api-management-service).

### How would you like to complete the workshop?
| Interface | Description | Level |
| --- | --- | --- |
| [Portal](Portal) | Use a combination of the Azure Portal and the CLI, where required, to work through the workshop. | Beginner |
| [CLI](CLI) | Work through the workshop entirely via Command Line Interface; this assumes familiarity with the concepts presented in the preceding level. | Intermediate |



---



![Workshop](Workshop.gif)
