---
layout: post
title:  "Automatic report generation using advanced MCP features"
date:   2025-08-21
image: /images/250821/splash2.png
---
![title](/images/250821/splash2.png)

The Model Context Protocol [specification](https://modelcontextprotocol.io/specification/2025-06-18) has the goal of standardizing the way that Large Language Models (LLM) connect to your data sources and tools - like a ***USB-C*** for AI. <!--end_excerpt-->The most common and well-known way of using MCP is to allow your AI of choice to call **tools** in an **MCP Server**, to allow it to interact with external data sources. Even though the MCP specification is not even a year old ([introduced by Anthropic](https://www.anthropic.com/news/model-context-protocol) in November 2024), the adoption of it has exploded and there is now a [gazillion](https://github.com/modelcontextprotocol/servers) MCP Servers available, for all kinds of purposes. Some of my favorites:

- The [Microsoft Learn MCP Server](https://learn.microsoft.com/en-us/training/support/mcp) - gives the LLM access to the Microsoft docs, which is extremely useful when coding.
- The [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) which I have talked a lot about.
- The [GitHub MCP Server](https://github.com/github/github-mcp-server).

And there are so many more... For example, I am currently evaluating how an MCP Server can be used together with my note-taking tool of choice - [Obsidian](https://obsidian.md/) - to let an AI help me plan my day and manage my notes and knowledge sources. More on that topic in a future blog post. 😊

### Tool calling in MCP

In this blog, on my channel on [Youtube](https://www.youtube.com/channel/UCDQSTOqQRFNRIQzkkrw4oYA) and on [LinkedIn](https://www.linkedin.com/in/andreas-adner-70b1153/) I have explored the *[tool calling](https://modelcontextprotocol.io/docs/learn/server-concepts#tools-ai-actions)* part of MCP in great detail, especially in the context of Power Platform and Dataverse:

- In numerous posts (see [here](https://www.linkedin.com/posts/andreas-adner-70b1153_mvp-agenticai-powerplatform-activity-7318953890094235650-g8ut?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w), [here](https://www.linkedin.com/posts/andreas-adner-70b1153_agenticai-mcp-dataverse-activity-7319027765075165185-QCBR?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) and [here](https://www.linkedin.com/posts/andreas-adner-70b1153_mcp-agenticai-dataverse-activity-7319281911330185216-kQ_O?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w)) I have explored how a custom built MCP Server can query Dataverse using FetchXml queries. It turns out that many LLM s are *very* proficient in FetchXml which makes this a very effective pattern for getting data from Dataverse using natural language. The [Claude models](https://docs.anthropic.com/en/docs/about-claude/models/overview) are especially good at this, in my experience. 
- When Microsoft released the preview version of the [Dataverse MCP server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp) I tested the capabilities of this server in great detail, putting it through its paces in several different scenarios - see [here](https://www.linkedin.com/posts/andreas-adner-70b1153_dataversemcpserver-activity-7344003681740075008-W3x4?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) and [here](https://www.linkedin.com/posts/andreas-adner-70b1153_benchmark-of-llms-using-dataverse-mcp-server-activity-7348442438119665665-lLhZ?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w). I also did a pretty thorough benchmark of which LLMs (at that time, before the release of GPT-5) that worked best with the Dataverse MCP Server, which can be found in [this blog post](https://nullpointer.se/dataverse/mcp/llm/2025/07/14/dataverse-llm-evaluation.html). I have also participated in the [private preview](https://msdynamicsworld.com/story/microsoft-enhance-dataverse-mcp-server-major-capabilities) of a new version of this server - and I intend to write more about it once it reaches general availability.
- An especially fun experiment was to use the [Dataverse MCP Server from Excel](https://www.linkedin.com/posts/andreas-adner-70b1153_dataverse-mcp-server-running-from-excel-activity-7345177569844953088-H3Y9?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w), showing that MCP is truly a USB-C for data that can be used from anywhere - not only from AI chatbots.

### Beyond Tool Calling: Advanced MCP Features

The posts and articles mentioned above focused strictly on the *tool calling* part of the MCP specification - the ability for your AI of choice to automatically call tools exposed by MCP Servers - which is probably what most people think about when MCP is mentioned. However, the MCP specification contains a lot of more cool features, and lately I have explored many of these in a number of posts on LinkedIn. Since it is still early days for the MCP specification, a lot of MCP Clients don't support all features of the MCP spec, as can be seen in this [feature support matrix](https://modelcontextprotocol.io/clients#feature-support-matrix). Lucky for me, VS Code has continuously been on the bleeding edge of MCP and is (at the time of writing), together with [fast-agent](https://fast-agent.ai/), the only client that supports all MCP features. So, VS Code has been my "weapon of choice" when exploring these features, as well as the [MCP C# SDK](https://github.com/modelcontextprotocol/csharp-sdk) which seems to evolve at the same rapid pace as VS Code, when it comes to the MCP spec.

The MCP features that I have tried out lately are:

- [**Sampling**](https://modelcontextprotocol.io/docs/learn/client-concepts#sampling) - The ability for an MCP tool to do an **internal** call to an LLM is an extremely powerful feature. In [this](https://www.linkedin.com/posts/andreas-adner-70b1153_vscode-vscode-modelcontextprotocol-activity-7343352802733084673-hUiV?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) post I explored how sampling can be used to allow an MCP tool to orchestrate its own **internal** tools.
- [**Elicitation**](https://modelcontextprotocol.io/docs/learn/client-concepts#elicitation) - This feature allows an MCP tool to ask questions to the user, and return the responses to the server. I first explored this feature in my post about [Data migration using MCP](https://www.linkedin.com/posts/andreas-adner-70b1153_vscode-vscode-modelcontextprotocol-activity-7343352802733084673-hUiV?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) where the user was asked how to handle duplicate records.
- [**Resources**](https://modelcontextprotocol.io/docs/learn/server-concepts#resources-context-data) - Allows the server to provide *structured information* to the client that can be added to the AI context window. I wrote about this in [this post](https://www.linkedin.com/posts/andreas-adner-70b1153_new-video-exploring-advanced-features-activity-7362558514013138944-4GD5?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) where the MCP server optionally can return the results of Dataverse queries as Resources, and the user decided whether to add these to the AI context window.

### Bringing It All Together

I wanted to tie all these features together in an example that demonstrates the full MCP feature set (well, there are other MCP features that I haven't yet gotten around to trying out, more on that later). The result was [this post](https://www.linkedin.com/posts/andreas-adner-70b1153_from-data-to-insights-automatically-activity-7363559967104131072-HtYf?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) on LinkedIn that shows how an MCP Server uses tool calling, sampling, elicitation and resources to allow the user to create reports based on Dataverse data - using natural language. 

In this blog post I want to dive a bit deeper into how this is all put together. The interested reader can find the code in [this GitHub repo](https://github.com/adner/Mcp_ResourceLinks), and try it out for yourself.

### Building an MCP Server with Streamable HTTP

While most of the previous MCP Servers I have built are using the [STDIO transport](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#stdio), for this example I implemented a server that uses [**Streamable HTTP transport**](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports#streamable-http) instead. Besides having the benefit of being much easier to debug in VS Code (VS Code [currently only supports debugging](https://code.visualstudio.com/api/extension-guides/ai/mcp#mcp-development-mode-in-vs-code) using `node`and `python`, if you are using C# like I am - you are out of luck), it means that the MCP Server is basically a web server - which I utilize in the example to serve the reports as static web pages.

I use the [ModelContextProtocol.AspNetCore](https://github.com/modelcontextprotocol/csharp-sdk/tree/main/src/ModelContextProtocol.AspNetCore) library to create the server, which basically adds MCP Server functionality to an ASP.NET web server.

### Inside the `CreateReportFromQuery` Tool

Let's examine the tool `CreateReportFromQuery` that includes a couple of the MCP features that I mention above. The purpose of the tool is to create a report based on a user query. The description makes it clear that this tool should be called if the LLM intends to run the query and create the report in *one combined* operation. 

```csharp
 [McpServerTool, Description("Executes an FetchXML request using the supplied expression that needs to be a valid FetchXml expression, then create a report using Chart.js that visualizes the result and returns a link to the report. If the request fails, the response will be prepended with [ERROR] and the error should be presented to the user.")]

    public static async Task<string> CreateReportFromQuery([Description("The FetchXml query. Should be kept simple, no aggregate functions!")] string fetchXmlRequest, [Description("A description in natural language of the report that is to be created.'")] string reportDescription, [Description("A heading for the report. Max 50 characters.")] string reportHeading, IOrganizationService orgService, IMcpServer server, RequestContext<CallToolRequestParams> context, CancellationToken ct)
    {
        try
        {
            ProgressToken? progressToken = context.Params?.ProgressToken is ProgressToken pt ? pt : null;  

            await NotifyProgress(server, progressToken, 0, "Executing query...");

            FetchExpression fetchExpression = new FetchExpression(fetchXmlRequest);
            EntityCollection result = orgService.RetrieveMultiple(fetchExpression);
            
            await NotifyProgress(server, progressToken, 1, "Generating report...");
        ...
```
The server uses the nifty [**Progress**](https://modelcontextprotocol.io/specification/2025-03-26/basic/utilities/progress) feature in MCP to write to the client that the query is being executed and that the report is being generated:

![alt text](image-1.png)

The notification is sent to the client, and since no `total` parameter is supplied, this simply becomes an information message and no progress indication is displayed, which is kind of useful if you just want to display informational messages to the client.

```csharp
 private static async Task NotifyProgress(IMcpServer server, ProgressToken? token, int progress, string message, int? total = null)
    {
        if (token == null) return; // No progress token supplied by caller
        try
        {
            await server.NotifyProgressAsync(token.Value, new()
            {
                Progress = progress,
                Message = message,
                Total = total ?? 0
            });
```

Let's inspect the LLMs call to `CreateReportFromQuery` a bit deeper. We can see that it supplies both the FetchXml that is to be executed, as well as a textual description of the report that is to be generated, based on the result.

```json
{
  "fetchXmlRequest": "<fetch top=\"10\"><entity name=\"contact\"><attribute name=\"contactid\"/><attribute name=\"firstname\"/><attribute name=\"lastname\"/><attribute name=\"gendercode\"/></entity></fetch>",
  "reportDescription": "Bar chart showing count of male and female contacts in top 10.",
  "reportHeading": "Top 10 Contacts: Gender Distribution"
}
```

### MCP Sampling for report creation

Then, the server uses [MCP Sampling](https://modelcontextprotocol.io/docs/learn/client-concepts#sampling) to call the LLM and ask it to create the report. There is a template file that contains the boilerplate HTML to create a Chart.js graph, and the LLM is asked to create the javascript code that is then inserted into the file, in the right places:

```csharp
var samplingResponse = await server.SampleAsync([
                 new ChatMessage(ChatRole.User, $"A report should be generated in Chart.js that fulfills this requirement: {reportDescription}. I want you to create Chart.js code that replaces the '[ChartJsCode]' placeholder in this template: ```const ctx = document.getElementById('myChart'); [ChartJsCode] new Chart(ctx, config);  ``` Only return the exact code, nothing else. Dont't return markdown, always return pure Javascript code. The data that the report should be based on is the following: {jsonResult}. If you need to insert data under the chart, there is a div with id 'additionalContent' that you can access using Javascript."),
            ],
             options: new ChatOptions
             {
                 MaxOutputTokens = 65536,
                 Temperature = 0f,
             },
             cancellationToken: ct);

             // Read the template file
            string templatePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "chartTemplates", "template.html");
            string templateHtml = await File.ReadAllTextAsync(templatePath, ct);

            // Replace the placeholder
            string reportHtml = templateHtml.Replace("[ChartJsCode]", samplingResponse.Text);

            reportHtml = reportHtml.Replace("[reportHeading]", reportHeading);
```
VS Code allows you to see what the sampling call to the LLM looked like:

![](/images/250821/1.gif)

It is also possible in VS Code to [select the model that will be used for the sampling call](https://code.visualstudio.com/api/extension-guides/ai/mcp#sampling-preview) that will be used for the sampling call, so if the reports it generates look poor, you can always try a better model.

The resulting HTML file is then served as both an MCP Resource...

```csharp
var uri = await ResourceAdder.AddHtmlFile(server, DateTime.Now.ToString(), reportHtml, ct, reportDescription);
            return $"The report has been saved to an MCP resource and is viewable at: {uri}. You can open this URL in a browser, or add it as context via 'Add Context...' -> 'MCP Resources' in the Copilot chat window.";

...
}

### Publishing the report

public static async Task<string> AddHtmlFile(IMcpServer server, string resourceName, string content, CancellationToken ct, string description)
    {
        // Create an internal file:// uri for storage & MCP catalog key
        string internalUri = NextUri("html"); // e.g. file://files/3.html
        var idFileName = internalUri.Split('/').Last(); // 3.html

        // Public HTTP URL exposed via dynamic endpoint
        string publicUrl = $"{BaseHttpUrl}/dynamic/{idFileName}";

        var resource = new Resource
        {
            Uri = publicUrl, // Expose HTTP URL to clients
            Name = resourceName,
            Title = resourceName,
            MimeType = "text/html",
            Description = description
        };

        // Store under internalUri so retrieval endpoint can locate it; also store under public URL for direct mapping
        _files[internalUri] = new FileEntry(resource.MimeType!, content, null);
        _files[resource.Uri] = new FileEntry(resource.MimeType!, content, null);

        await AddAsync(server, resource, ct);

        return resource.Uri;
    }

```

...as well as a web page that can be opened in a web browser.

![](/images/250821/2.gif)

### Demo of all the features

This video demonstrates the full set of MCP features mentioned above - sampling, elicitation and resources:

<iframe width="560" height="315" src="https://www.youtube.com/embed/xZ4fWOyD_dk?si=kL5H1VUrYe1GvQTQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

### What’s Next 
There are still more features in MCP that I haven't explored yet, for example [**Prompts**](https://modelcontextprotocol.io/docs/learn/server-concepts#prompts-interaction-templates), so looking forward to diving into that later. There are also exciting things in the [MCP roadmap](https://modelcontextprotocol.io/development/roadmap), for example better support for agentic workflows and multimodality, that I look forward to looking into in the future.



