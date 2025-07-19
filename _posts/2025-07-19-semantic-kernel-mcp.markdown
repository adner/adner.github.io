---
layout: post
title:  "Semantic Kernel - what it is and how to use it for MCP"
date:   2025-07-19
image: /images/250719/title.png
---
![title](/images/250719/title.png)
# Semantic Kernel - what it is and how to use it for MCP
The [Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/) from Microsoft is an *AI orchestration framework* designed to simplify the development of applications powered by **Large Language Models** (LLMs). It serves a similar purpose as frameworks like [LangChain](https://www.langchain.com/), providing tools and abstractions to integrate LLMs, connect to external data sources like Model Context Protocol (MCP) Servers, and to orchestrate AI agents.<!--end_excerpt-->

Semantic Kernel has been around for a while, and has recently been updated so that it uses [*Microsoft.Extensions.AI*](https://learn.microsoft.com/en-us/dotnet/ai/microsoft-extensions-ai) - a library of standard AI interfaces and abstractions for .NET.

Microsoft.Extensions.AI is a *foundational* AI library that provides the basic building blocks for integrating AI into your applications, while Semantic Kernel is a *specialized SDK* that provides higher-level features for Agentic AI orchestration, etc. A series of good blog posts from Microsoft that explains when to use which one can be found [here](https://devblogs.microsoft.com/semantic-kernel/semantic-kernel-and-microsoft-extensions-ai-better-together-part-1/).

If you’ve followed my blog or LinkedIn posts, you have seen that I have explored the MCP protocol lately. I wanted to learn more about the capabilities of Semantic Kernel in that context, and specifically how it can be used with the [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp).

While the Semantic Kernel [documentation](https://learn.microsoft.com/en-us/semantic-kernel/concepts/plugins/adding-mcp-plugins?pivots=programming-language-csharp#add-plugins-from-a-local-mcp-server) is currently lacking any examples on how to use MCP Servers, the Semantic Kernel [Github repo](https://github.com/microsoft/semantic-kernel/tree/79d3dde556e4cdc482d83c9f5f0a459c5cc79a48/dotnet/samples/Demos/ModelContextProtocolClientServer) has a lot of sample code that describes how to use the tools exposed by MCP Servers as *functions* in Semantic Kernel - that can be called by an LLM.

I wanted to explore how well various LLMs could use the Dataverse MCP Server, and I wanted to use Semantic Kernel for this purpose. This resulted in:

- A [LinkedIn post](https://www.linkedin.com/posts/andreas-adner-70b1153_dataversemcp-semantickernel-llmevaluation-activity-7349537355499745281-42j8?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) with a video that demonstrated how a number of LLMs were evaluated by an *Orchestrator agent*.
- A [blog post](https://nullpointer.se/dataverse/mcp/llm/2025/07/14/dataverse-llm-evaluation.html) where even more models were evaluated.

The code that was used to implement this can be found [here](https://github.com/adner/SemanticKernelMcp/tree/llm-orchestrator).

## Technical details
Based on the samples found in the Semantic Kernel repo, I tried to wire up the Dataverse MCP Server tools as Semantic Kernel functions:

```csharp
...
this.ChatHistory = new ChatHistory();
        this.kernel = kernel;

        if (_dataVerseMcpClient == null) _dataVerseMcpClient = getDataverseMcpClient().Result;

        IList<McpClientTool> tools = _dataVerseMcpClient.ListToolsAsync().Result;
        this.kernel.Plugins.AddFromFunctions("Tools", tools.Select(aiFunction => aiFunction.AsKernelFunction()));
...
```
Semantic Kernel uses the [Model Context Protocol C# SDK](https://github.com/modelcontextprotocol/csharp-sdk) "under the hood" for its MCP capabilities.

I tried to connect to my local Dataverse MCP Server using the STDIO transport, as documented [here](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp#configure-dataverse-mcp-server-in-claude-desktop). This involves starting the **Microsoft.PowerPlatform.Dataverse.MCP** process with a lot of parameters. I have done this before programmatically, for example in my [demo](https://www.linkedin.com/posts/andreas-adner-70b1153_dataverse-mcp-server-running-from-excel-activity-7345177569844953088-H3Y9?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) on how to use the Dataverse MCP Server from Excel.

```csharp
 private async static Task<IMcpClient> getDataverseMcpClient(
        Kernel? kernel = null,
        Func<Kernel, CreateMessageRequestParams?, IProgress<ProgressNotificationValue>, CancellationToken, Task<CreateMessageResult>>? samplingRequestHandler = null)
    {
        var clientTransport = new StdioClientTransport(new StdioClientTransportOptions
        {
            Name = "DataverseMcpServer",
            Command = "Microsoft.PowerPlatform.Dataverse.MCP",
            Arguments = [
                "--ConnectionUrl",
                "https://make.powerautomate.com/environments/6d4b5002-f3d1-e8e3-8e8d-4a8983d6535c/connections?apiName=shared_commondataserviceforapps\"&\"connectionName=5006ad27f35e4dd59e1ecfdd2f99e09f",
                "--MCPServerName",
                "DataverseMCPServer",
                "--TenantId",
                "d6d4b12d-51da-48bf-a808-a0e527802b89",
                "--EnableHttpLogging",
                "true",
                "--EnableMsalLogging",
                "false",
                "--Debug",
                "false",
                "--BackendProtocol",
                "HTTP"
                ],
        });

        var client = await McpClientFactory.CreateAsync(clientTransport);

        return client;
    }
```
This time, however, it didn't work. It turns out that the way the MCP C# SDK uses `cmd.exe`to setup the STDIO transport with the Dataverse MCP Server doesn't play well with the parameters that needs to be supplied to the MCP Server - specifically the *ampersand* (&) character in the `ConnectionUrl` parameter breaks things, since ´cmd.exe´ interprets this a chaining of commands, and it fails.

I raised this as an [issue](https://github.com/issues/created?issue=modelcontextprotocol%7Ccsharp-sdk%7C594) and forked the [Modelcontext Protocol C# SDK](https://github.com/adner/csharp-sdk) to see if I could fix the issue myself, in the meantime. 

As it turns out, using `Powershell.exe` instead of `cmd.exe` works better, and a temporary fix that makes it possible to use the Dataverse MCP Server can be found in [this commit](https://github.com/adner/csharp-sdk/commit/63cdcbb5ceca1bdf835b14ee39607f2bc0cadc1c).

A slight modification was also required to the `ConnectionUrl` parameter - the ampersand character needed to be escaped like so:

```csharp
\"&\"
```
With this issue out of the way, the tools from the Dataverse MCP Server are properly wired up in Semantic Kernel, and can be used by the LLMs.

When calling the LLM, we need to apply some settings to tell the LLM to actually use the tools available:

- `FunctionChoiceBehavior.Auto` tells the LLM to automatically use tools, when it deems it necessary.
- `AllowParallelCalls` is set to `false` because I didn´t want the LLM to call several tools at once - this is especially important for the *Orchestrator agent* that uses function calling to invoke other LLMs, and I wanted these to be called in sequence - not at the same time.

```csharp
 public async IAsyncEnumerable<string> GetChatMessageStreamingAsync(string userMessage)
    {
        ChatHistory.AddUserMessage(userMessage);

        var chatCompletionService = kernel.GetRequiredService<IChatCompletionService>();

        // Enable automatic function calling
        PromptExecutionSettings executionSettings = null;

        if (this.model == "o4-mini" || this.model == "o3") //AllowParallelCalls parameter not supported for some models
        {
            executionSettings = new()
            {
                FunctionChoiceBehavior = FunctionChoiceBehavior.Auto(options: new() { RetainArgumentTypes = true })
            };
        }
        else
        {
            executionSettings = new()
            {
                FunctionChoiceBehavior = FunctionChoiceBehavior.Auto(options: new() { RetainArgumentTypes = true, AllowParallelCalls = false })
            };
        }

       var response = chatCompletionService.GetStreamingChatMessageContentsAsync(
       chatHistory: ChatHistory,
       kernel: kernel,
       executionSettings: executionSettings
   );
   ...
```
For the *Orchestrator agent* I used Semantic Kernel [plugins](https://learn.microsoft.com/en-us/semantic-kernel/concepts/plugins/?pivots=programming-language-csharp) to define a number of functions that the orchestrator can call when doing its evaluation of the other LLMs:

```csharp
public class OrchestratorKernelPlugin
{

    private OrchestratorKernel _orchestratorKernel;
    public OrchestratorKernelPlugin(OrchestratorKernel orchestratorKernel)
    {
        this._orchestratorKernel = orchestratorKernel;
    }

    [KernelFunction("SendMessageToModel")]
    [Description("Sends a message to the model that you are currently evaluating.")]
    public async Task<string> SendMessageToModel(
        [Description("The message to send to the model.")]
        string message
    )
    {
        await this._orchestratorKernel.SendInfoMessageToOrchestratorAsync("[SendToModel]:" + message);

        return "The message has been sent to the model. Please wait until you get a response starting with [modelName].";
    }

    [KernelFunction("SetCurrentModel")]
    [Description("Sets the current large language model that is being evaluated by the orchestrator.")]
    public async Task SetCurrentModel(
        [Description("The name of the model that is to be evaluated.")]
        string modelName
    )
    {
        this._orchestratorKernel.SetCurrentModel(modelName);
        await Task.CompletedTask;
    }
}
```
These tools allow the orchestrator agent to:
- Send messages to the LLM that it is currently evaluating.
- Switch to a new model that should be evaluated.

The evaluation is done in a simple web app that uses SignalR to stream responses from LLMs, and a lot of really ugly JavaScript that facilitates the communication between the orchestrator and the LLM that is being evaluated. 

The result can be seen in this video:

<iframe width="560" height="315" src="https://www.youtube.com/embed/xmCX85DCBt8?si=j-_FtcfZfZomXnvR" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>



