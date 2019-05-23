# Sharing Our APIs With Others
Return to [Enriching the event's payload](Functions.md).



---



In this section, we will create an API Management (APIM) layer that will help add extra security and auditing to our Functions. To keep it simple, we will rewrite our function URLs from something like
  ```
  https://streamer-utils.azurewebsites.net/api/HttpTrigger1?timestamp=1552309994&code=vWfasFDFerSFDGC1UgbfA423rfYctKHVVgdMAF2FWr7D3rfsFSdgEt343=
  ```
  to something like
  ```
  https://streamer.azure-api.net/utils/ConvertTimestamp?timestamp=1552309994
  ```

**Section Outline**
1. [Creating the API Management Service](#creating-the-api-management-service)
1. [Importing the Functions](#importing-the-functions)



---



## Creating the API Management Service

1. Click on `Create a resource` and find the `APIM Management` service.
  ![Create a resource](APIM/Creation/1.png)

1. Click `Create`.
  ![Create](APIM/Creation/2.png)

1. Fill in the form, giving your service a globally unique name. Select the workshop resource group and a preferred location. Upon successful validation, click `Create`.
  ![Create from form](APIM/Creation/3.png)

Note: *If you were directed here an effort to preload the service, please return to the section you were working on; the remainder of this workshop will depend on services created in prior sections.*



---



## Importing the Functions

1. Once the API Management service has been successfully deployed, head on over to the `APIs` section. We will now import our functions into APIM add some usage policies. Click on `+ Add API`, followed by `Function App`.
  ![Add API](APIM/Import/1.png)

1. Click on `Browse`.
  ![Browse](APIM/Import/2.png)

1. Click on the `Function App` option; select the app and hit `Select`.
  ![Select function app](APIM/Import/3.png)

1. The functions in the Function App should be listed. Select the functions you want to make available via APIM, and hit `Select`.
  ![Select functions](APIM/Import/4.png)

1. Expand the metadata editor by clicking `Full`. Add some metadata to your collection of APIs; ensure that you have a product selected before hitting `Create`.
  ![Import APIs](APIM/Import/5.png)

1. You should see your newly created set of APIs; select the collection and click on `Test`. You may want to keep an extra browser tab handy as you will do a lot of back-and-forth between `Design` and `Test` sections.
  ![Test](APIM/Import/6.png)

1. We will now do some debugging to see what's really happening under the covers. Click on the `GET` API and add the `timestamp` parameter. Notice how the request URL updates as you add query parameters. Click `Send` to make the HTTP request.
  ![Send a GET request](APIM/Import/7.png)

1. The output is printed in the `Message` log. You can also view more detailed info by switching to the `Trace`.
  ![Log](APIM/Import/8.png)

1. We will now make the necessary set of changes to transform our API's URL. In our APIM designer, click on the `Edit` icon under the `Frontend` section.
  ![Edit Frontend](APIM/Import/9.png)

1. You will be presented by a JSON document. Find the `paths` key, and update its value to:
    ```json
    {
        "/ConvertTimestamp": {
            "get": {
                "description": "A utility to help with the conversion of Unix timestamps into human readable DateTime objects.",
                "operationId": "get-httptrigger1",
                "summary": "ConvertTimestamp",
                "parameters": [
                    {
                        "name": "timestamp",
                        "in": "query",
                        "required": true,
                        "type": "string"
                    }
                ],
                "responses": {}
            },
            "post": {
                "description": "A utility to help with the conversion of Unix timestamps into human readable DateTime objects.",
                "operationId": "post-httptrigger1",
                "summary": "ConvertTimestamp",
                "parameters": [
                    {
                        "name": "",
                        "in": "body",
                        "schema": {
                            "example": "{ \"timestamp\" : 1552309994 }"
                        }
                    }
                ],
                "consumes": [ "application/json" ],
                "responses": {}
            }
        }
    }
    ```
    ![Update metadata](APIM/Import/10.png)

1. What did we just do in the previous step? We updated the description of each operation and provided information on expected inputs (query parameters and body). We  also changed the signature of the endpoints from `/HttpTrigger1` to `/ConvertTimestamp`; these changes should now be visible in the endpoint listing. We need to make one more change before our revised endpoints are functional. Click on `+ Add policy` in the `Inbound processing` section.
  ![Add policy](APIM/Import/11.png)

1. Add the following as an inbound policy and hit `Save`.
    ```xml
    <rewrite-uri template="/HttpTrigger1" />
    ```
    ![Rewrite URI policy](APIM/Import/12.png)

1. Head back to our `Test` section to test out the changes we just made. You'll notice that some information is already preloaded; this is the result of the JSON update (for the API definition) we made earlier.
  ![Test changes](APIM/Import/13.png)

1. Again, can see the output of our request here. Tou can also step into the `Trace` to see where the URI is being rewritten.
  ![Logs](APIM/Import/14.png)

1. To view a policy that has rate limiting enabled, head on over to the `Products` section of the service and select the `Starter` product. Would you like to add try adding rate limiting to your service? Give it a go...
  ![Additional policies](APIM/Import/15.png)



---



Move on to [Review and next steps](Review.md).
