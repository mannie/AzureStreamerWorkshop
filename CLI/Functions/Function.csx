#r "Newtonsoft.Json"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log)
{
    log.LogInformation("C# HTTP trigger function processed a request.");

    // Obtain the "timestamp" query param from the URL: "http://...?timestamp=1552053470"
    string value = req.Query["timestamp"];

    // If we don't have a "timestamp" query param, try and read the request's body to find one
    // { "timestamp" : 1552053470, ... }
    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);
    value = value ?? data?.timestamp;

    // Convert the "timestamp" from a string to an int
    var timestamp = Convert.ToInt64(value);

    // Convert the offset to a DateTime object.
    DateTimeOffset dateTimeOffset = DateTimeOffset.FromUnixTimeSeconds(timestamp);
    DateTime dateTime = dateTimeOffset.UtcDateTime;

    // Return the human readable dateTime in the response body.
    return dateTime != null
        ? (ActionResult)new OkObjectResult(dateTime)
        : new BadRequestObjectResult(null);
}
