---
layout: post
title:  "Part 2 - Building the agent"
date:   2025-12-02
image: /images/251205/splash.png
permalink: /agent-365-mcp-servers-part-2.html
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

In the [last blog post](/images/251205https://nullpointer.se/agent-365-mcp-servers-part-1.html) I demonstrated how to connect to some of the MCP Servers that are part of the [tooling servers](/images/251205https://learn.microsoft.com/en-us/microsoft-agent-365/tooling-servers-overview) in Agent 365. We used the tools [MCP Inspector](/images/251205https://github.com/modelcontextprotocol/inspector) and [Postman](/images/251205https://www.postman.com/) to do this. In this blog post the goal is to use these MCP Servers from Microsoft Agent Framework, and present the resulting agent in a custom UI that uses [CopilotKit](/images/251205https://www.copilotkit.ai/) and the [Agent-User Interaction Protocol](/images/251205https://github.com/ag-ui-protocol/ag-ui) (AG-UI).<!--end_excerpt-->

### Creating the agent backend

We start by creating a web app that exposes and AG-UI endpoint, and that implements an agent using Microsoft Agent Framework. The code for the backend can be found in [this](/images/251205https://github.com/adner/Agent365McpServers/tree/main/AgentBackend) repo.

```csharp
using ModelContextProtocol.Client;
using OpenAI;
using Microsoft.Agents.AI;
...
using Microsoft.Agents.AI.Hosting.AGUI.AspNetCore;

// Two HttpClient configurations are needed because different MCP servers have different requirements:
// - Most MCP servers (Agent365) work fine with standard HTTP chunked transfer encoding
// - Some servers does NOT support chunked encoding and requires Content-Length header
using var httpClient = new HttpClient();
using var httpClientWithContentLength = new HttpClient(new ContentLengthEnforcingHandler());
```

We add the plumbing for handling the OAuth2 flow. We implement a special authentication handler called [OAuthAuthorizationHandler](/images/251205https://github.com/adner/Agent365McpServers/blob/e214db3a5bafb9603cf70593c6de999e52048060/AgentBackend/Program.cs#L116) for this purpose.

In this example, we set up the authorization the be able to access the Agent 365 MCP Management MCP Server. See the [last blog post](/images/251205https://nullpointer.se/agent-365-mcp-servers-part-1.html) for details on how to setup the prerequisites (App Registration, API permissions) in Entra ID. A client secret is also needed here, in the last blog post we used Authorization Code Flow with PKCE, this time we use Authorization Code Flow.

```csharp
// Create OAuth handler with semaphore to serialize auth flows (they share the same redirect port)
var oauthHandler = new OAuthAuthorizationHandler();

// Create SSE client transport for the MCP server
var managementMcpServerUrl = $"https://agent365.svc.cloud.microsoft/mcp/environments/{dataverseEnvironmentId}/servers/MCPManagement";
var managementMcpTransport = new HttpClientTransport(new()
{
    Endpoint = new Uri(managementMcpServerUrl),
    Name = "Agent365 Management Client",
    OAuth = new()
    {
        ClientId = clientId,
        ClientSecret = clientSecret,
        Scopes = ["ea9ffc3e-8a23-4a7d-836d-234d7c7565c1/McpServers.Management.All", "offline_access", "openid", "profile"],
        RedirectUri = new Uri("http://localhost:1179/callback"),
        AuthorizationRedirectDelegate = oauthHandler.HandleAuthorizationUrlAsync,
    }
}, httpClientWithContentLength, consoleLoggerFactory);
```

Then we connect to the MCP Server and enumerate the available tools:

```csharp
await using var managementMcpClient = await McpClient.CreateAsync(managementMcpTransport, loggerFactory: consoleLoggerFactory);
``` 
Then we create the agent, and supply the tools and map the AG-UI endpoint that can be used by our frontend.

```csharp
AIAgent agent = new OpenAIClient(openAiApiKey)
    .GetChatClient("gpt-5.1")
    .CreateAIAgent(instructions: "You are a helpful agent that allows the user to perform management tasks in Agent 365 and call Agent 365 MCP Servers.", tools: [.. managementTools]);

app.MapAGUI("/", agent);

app.Run();
```

However, if we run this - it fails! The reason for the failure is that the  Entra - which is securing the MCP Server - does not accept the `resource` parameter that is sent by the [C# Model Context Protocol SDK](/images/251205https://github.com/modelcontextprotocol/csharp-sdk) in the OAuth2 flow. This problem is discussed in various places:

- [This issue](/images/251205https://github.com/modelcontextprotocol/csharp-sdk/issues/939) discusses this issue in detail.
- [Here](/images/251205https://github.com/modelcontextprotocol/csharp-sdk/pull/940) is a pull request that claims to fix the issue.

The C# MCP SDK actually follows the MCP specification, which [mandates](/images/251205https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization#resource-parameter-implementation) that the `resource` parameter should be passed. But Entra doesn't accept it. There actually is a [proposal](/images/251205https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1614) to make this parameter optional, not mandatory, for MCP Clients so we'll have to see where this ends up... In the meantime - and in the interest of finishing the demo, I simply forked the C# MCP SDK and did [this change](/images/251205https://github.com/modelcontextprotocol/csharp-sdk/pull/940/files#diff-c50d00a1141a07ed23e1e5169c0c9af516ab09162628ecd0b0dae70724de1dd3):

![alt text](/images/251205image.png)

With this fixed, the backend is working and we can move on to to implementing the frontend using CopilotKit.

### Creating the frontend

As mentioned above, we use CopilotKit to create the frontend, a framework that can use the [AG-UI protocol](/images/251205https://github.com/ag-ui-protocol/ag-ui) to talk to our backend. AG-UI greatly simplifies to the process of building UI:s for agents, by automatically handling e.g. streaming, state management and using tool call results in the UI.

The frontend is based on the [quickstart code](/images/251205https://docs.copilotkit.ai/microsoft-agent-framework/quickstart) for the CopilotKit/AG-UI integration with Microsoft Agent Framework, and can be found in [this repo](/images/251205https://github.com/adner/Agent365McpServers/tree/main/copilotkitagentframework).

CopilotKit makes it easy too render tool call progress and result as custom React components. For example, this code implements a default tool calling GUI that handles all tool calls for our agent:

```typescript
useDefaultTool({
  render: ({ name, args, status, result }) => {
    const isComplete = status === "complete";
    const isRunning = status === "inProgress" || status === "executing";

    return (
      <div className="my-3 rounded-xl overflow-hidden shadow-lg bg-gradient-to-br from-slate-900 to-slate-800 border border-slate-700">
        <div className="px-4 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 flex items-center justify-between">
          ...
            {isRunning && "Running..."}
            {isComplete && "Complete"}
          </span>
        </div>

        ...

          {isComplete && result && (
            <div>
              <p className="text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-2">Result</p>
              <pre className="text-sm text-slate-200 bg-slate-950/50 p-3 rounded-lg border border-slate-700 overflow-x-auto max-h-64 overflow-y-auto">
                {JSON.stringify(result, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>
    );
  },
});
```
This looks like this when we call one of the tools in the MCP Management MCP Server:

![alt text](/images/251205image-1.png)

It also has built in support for handling "human in the loop" flows, using this code:

```typescript
  useHumanInTheLoop(
    {
      name: "go_to_moon",
      description: "Go to the moon on request.",
      render: ({ respond, status }) => {
        return (
          <MoonCard themeColor={themeColor} status={status} respond={respond} />
        );
      },
    },
    [themeColor],
  );
```
This is what happens when I tell the agent that I want to go to the moon, the custom UI is rendered:

![alt text](/images/251205image-2.png)

And when the button is clicked:

![alt text](/images/251205image-3.png)

This is a video of the agent, accessing different Agent 365 MCP Servers:

<iframe width="560" height="315" src="https://www.youtube.com/embed/fPwdB1N0AgM?si=qLLKqGQFjz5zM_ai" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

For more information, check out the [CopilotKit docs](/images/251205https://docs.copilotkit.ai/). Until next time, happy hacking!
