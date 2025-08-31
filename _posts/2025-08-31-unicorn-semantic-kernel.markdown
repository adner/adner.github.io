---
layout: post
title:  "Automatic report generation using advanced MCP features"
date:   2025-08-21
image: /images/250831/unicorn.png
---
![title](/images/250831/unicorn_small.png)

Over the last couple of months, I have used the [Semantic Kernel](https://github.com/microsoft/semantic-kernel) in different ways, usually as part of my exploration on how to use various LLMs together with the [Dataverse MCP Server](https://learn.microsoft.com/en-us/power-apps/maker/data-platform/data-platform-mcp). <!--end_excerpt--> I have [blogged](https://nullpointer.se/2025/07/19/semantic-kernel-mcp.html) about how to use Semantic Kernel, and how it relates to the [Microsoft.Extensions.AI](https://learn.microsoft.com/en-us/dotnet/ai/microsoft-extensions-ai) libraries. I used the Semantic Kernel when I evaluated a number of large language models together with the Dataverse MCP Server, as part of my "Pizza Party" benchmark, which I describe in [this blog post](https://nullpointer.se/dataverse/mcp/llm/2025/07/14/dataverse-llm-evaluation.html).

### The future of Semantic Kernel

When I started looking into Semantic Kernel it seemed to be the most 'enterprise-grade' offering from Microsoft, when it came to more sophisticated AI agent orchestration. But it seems that things are happening internally at Microsoft that might change this in the future. A while back I stumbled across a [video](https://youtu.be/t8IrRo-_frQ?si=6Eyj93U-c6JBCjXH) from [Rasmus Wulff Jensen](https://www.linkedin.com/in/rasmuswulffjensen/) where he talked about the future of Semantic Kernel - how it is now entering "maintenance mode" and that the Semantic Kernel team is merging with the [Autogen](https://github.com/microsoft/autogen) team. The goal seems to be to introduce a new agent orchestration framework that will replace Semantic Kernel and Autogen. I started attending the Semantic Kernel team's weekly "[Office Hours](https://www.linkedin.com/safety/go?url=https%3A%2F%2Fteams.microsoft.com%2Fmeet%2F2344899661716%3Fp%3DbIxbaT1oqHeFsbPqT8&trk=flagship-messaging-web&messageThreadUrn=urn%3Ali%3AmessagingThread%3A2-OTg5YWU4NDQtNDc0Mi00YjA2LWI2MzctMzE2NjJjOGE4MDg3XzEwMA%3D%3D&lipi=urn%3Ali%3Apage%3Ad_flagship3_messaging_conversation_detail%3BQjEZpas8TxWVIIGinLirXw%3D%3D)" calls to learn more. This was a great experience, the team was super-helpful and the TL;DR regarding the future of Semantic Kernel seems to be:

- A new framework will be released, probably this year. 
- The name of the framework is currently unknown.
- It should be considered a "Semantic Kernel 2.0", and there will be clear migration paths for customers that are using SK today.

So, that sounds pretty good for existing users of SK, and there seems to be exciting things ahead when Microsoft launches the new "Agent Orchestration Framework" (or whatever it will be called...).

The SK team also shared a lot of other interesting information, for example that MCP support for the C# SDK has been [available a while](https://devblogs.microsoft.com/semantic-kernel/integrating-model-context-protocol-tools-with-semantic-kernel-a-step-by-step-guide/), although the [documentation](https://learn.microsoft.com/en-us/semantic-kernel/concepts/plugins/adding-mcp-plugins?pivots=programming-language-csharp) has not been updated. They pointed to some useful [sample code](https://github.com/microsoft/semantic-kernel/tree/main/dotnet/samples/Demos/ModelContextProtocolClientServer) in GitHub.

Another interesting thing was the support for the OpenAI Responses API in SK, through the Responses Agent, as is discussed [here](https://github.com/microsoft/semantic-kernel/discussions/11187#discussioncomment-14160431). There are some code samples available [here](https://github.com/microsoft/semantic-kernel/blob/main/dotnet/samples/GettingStartedWithAgents/OpenAIResponse/Step01_OpenAIResponseAgent.cs), and I thought it would be fun to test how Semantic Kernel can be used to call the Responses API...

This led me down a rabbit hole exploring experimental libraries, running Transformers locally, creating Dockerfiles, forking of both the Semantic Kernel and the C# Open AI SDK and in the end - short stories of unicorns and rainbows... 🦄🌈

### The OpenAI Responses API and Semantic Kernel
I have wanted to look into the [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses) for a while. OpenAI describes it as  **"...the most advanced interface for generating model responses"* and it has a lot of cool features, for example:

- You don't have to pass all previous messages with every call (like you have to do with the [Chat Completions API](https://platform.openai.com/docs/api-reference/chat)), the service keeps track of the conversations for you.
- It has built-in support for [file search](https://platform.openai.com/docs/guides/tools-file-search), [web search](https://platform.openai.com/docs/guides/tools-web-search?api-mode=responses), [computer use](https://platform.openai.com/docs/guides/tools-computer-use) and [code execution](https://platform.openai.com/docs/guides/tools-code-interpreter). So there are some cool things that the LLM can do internally, without having to rely on external MCP Servers for these things.

And as mentioned above, Semantic Kernel supports the Responses API, so let's try it out to call the OpenAI Responses API using the Semantic Kernel, and use the Web Search tool to search for information about unicorns.

In the example below I have added a Http-handler so I can output the request that is actually sent to the OpenAI API. Since the `OpenAIResponseClient` is experimental, we need to add some `pragma` directives to suppress the warnings.

```csharp
var httpClient = new HttpClient(new LoggingHandler(new HttpClientHandler()));
var transport = new HttpClientPipelineTransport(httpClient);

#pragma warning disable OPENAI001
OpenAIResponseClient client = new OpenAIResponseClient("gpt-5-mini", new ApiKeyCredential("..."), new OpenAI.OpenAIClientOptions()
    {
        Transport = transport
    });

    OpenAIResponseAgent agent = new(client)
    {
        StoreEnabled = false,
    };

    // ResponseCreationOptions allows you to specify tools for the agent.
    ResponseCreationOptions creationOptions = new();
    creationOptions.Tools.Add(ResponseTool.CreateWebSearchTool());
    OpenAIResponseAgentInvokeOptions invokeOptions = new()
    {
        ResponseCreationOptions = creationOptions,

    };

    // Invoke the agent and output the response
    var responseItems = agent.InvokeStreamingAsync("Do a web search for information about unicorns (the mythnical creature), summarize in three sentences.", options: invokeOptions);

...
public sealed class LoggingHandler : DelegatingHandler
{
    public LoggingHandler(HttpMessageHandler inner) : base(inner) { }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage req, CancellationToken ct)
    {
        // Log URL
        Console.WriteLine($"Request URL: {req.RequestUri}");
        // Log headers
        Console.WriteLine("Request Headers:");
        foreach (var header in req.Headers)
        {
            Console.WriteLine($"{header.Key}: {string.Join(", ", header.Value)}");
        }
        if (req.Content != null)
        {
            foreach (var header in req.Content.Headers)
            {
                Console.WriteLine($"{header.Key}: {string.Join(", ", header.Value)}");
            }
            // Log content
            var content = await req.Content.ReadAsStringAsync();
            Console.WriteLine("Request Content:");
            Console.WriteLine(content);
        }
        else
        {
            Console.WriteLine("No request content.");
        }
        return await base.SendAsync(req, ct);
    }
}
```
The above results in the following request:
```csharp
Request URL: https://api.openai.com/v1/responses
Request Headers:
Accept: application/json, text/event-stream
User-Agent: OpenAI/2.3.0, (.NET 9.0.8; Microsoft Windows 10.0.26100)
Authorization: Bearer ...
Content-Type: application/json
Request Content:
{"instructions":"","model":"gpt-5-mini","input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"Do a web search for information about unicorns (the mythnical creature), summarize in three sentences."}]}],"stream":true,"user":"UnnamedAgent","store":false,"tools":[{"type":"web_search_preview"}]}
```
And the response:
```json
The unicorn is a mythological creature—usually depicted as a horse- or goat‑like animal with a single spiraling horn—whose stories appear in ancient cultures from the Indus Valley and Mesopotamia through classical Greece, China, and medieval Europe. ([britannica.com](https://www.britannica.com/topic/unicorn?utm_source=openai), [worldhistory.org](https://www.worldhistory.org/article/1629/the-unicorn-myth/?utm_source=openai))

...

By the Middle Ages the unicorn was widely used as an allegory of purity and Christ in bestiaries and art (notably The Hunt of the Unicorn tapestries), and it survives today as a pervasive cultural symbol in literature, art, and popular media. ([britannica.com](https://www.britannica.com/topic/unicorn?utm_source=openai), [worldhistory.org](https://www.worldhistory.org/article/1629/the-unicorn-myth/?utm_source=openai))
```
This works well, no problem at all. It should be noted that the Semantic Kernel uses the [OpenAI C# SDK](https://github.com/openai/openai-dotnet) under the hood, so SK is closely tied to that library. This will be of importance as we continue exploring.

It should be noted that even for this simple request - consisting of a single question to the AI - the request is serialized to this somewhat complex format:

```json
"input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"Do a web search for information about unicorns (the mythnical creature), summarize in three sentences."}]}]
```
If one reads the [Responses API documentation](https://platform.openai.com/docs/api-reference/responses/create?lang=curl), it is clear that there is a simplified format, where the input is a simple string instead of the more complex structure above:

```json
{
    "model": "gpt-4.1",
    "input": "Tell me a three sentence bedtime story about a unicorn."
}
```
This simplified format can [also be used](https://platform.openai.com/docs/guides/text#message-roles-and-instruction-following) for calls that contains several messages:

```json
"input": [
            {
                "role": "developer",
                "content": "Talk like a pirate."
            },
            {
                "role": "user",
                "content": "Are semicolons optional in JavaScript?"
            }
        ]
```
So which format is correct? I tried to find a formal specification of the input formats that can be used for the Responses API, but I couldn't find it (if you can, let me know!) My assumption is that both the simple and the more complex formats are perfectly fine, and should be supported by all endpoints that supports the Responses API. But as it turns out, that is not the case...
### Using Semantic Kernel and the Responses API locally
If you have read my blog and my posts on LinkedIn, you know that I like to run LLMs locally. I have blogged about [Foundry Local](https://nullpointer.se/2025/08/10/foundry-local-harmony.html) and [experimented](https://www.linkedin.com/feed/update/urn:li:activity:7357383421557465088/) with using the open weights OpenAI gpt-oss models together with the Dataverse MCP Server. So, of course I had to try if it was possible to call the [gpt-oss](https://github.com/openai/gpt-oss) models using the Responses API somehow. These models are [compatible](https://openai.com/index/introducing-gpt-oss/) with the Responses API, so it should be possible to do, right?

As it turns out, the [Hugging Face Transformers](https://huggingface.co/docs/transformers/en/index) framework has [experimental support](https://huggingface.co/docs/transformers/en/serving#responses-api) for the Responses API and there even is an OpenAI [cookbook](https://cookbook.openai.com/articles/gpt-oss/run-transformers) that explains how to run gpt-oss locally using Transformers! So let's try it out!

### Setting up the Hugging Face Transformers library

This is really not my area of expertise, and it took a lot of tinkering - but eventually I was able to create a Docker image that runs the Transformers library and that can run the `openai/gpt-oss-20b` model and serve up a Responses API compatible endpoint at `http://localhost:8000/v1/responses`! The repo that contains the [Dockerfile](https://github.com/adner/SemanticKernel_OpenAiResponsesApi/blob/main/Dockerfile) and [docker-compose.yml](https://github.com/adner/SemanticKernel_OpenAiResponsesApi/blob/main/docker-compose.yml) can be found [here](https://github.com/adner/SemanticKernel_OpenAiResponsesApi).

If we call it using Postman we get a gazillion streaming chunks back:

![](/images/250831/1.gif)

So far, so good. Now let's try the Semantic Kernel, and see if it can talk to the API:

```csharp
var httpClient = new HttpClient(new LoggingHandler(new HttpClientHandler()));
var transport = new HttpClientPipelineTransport(httpClient);

#pragma warning disable OPENAI001
OpenAIResponseClient client = new OpenAIResponseClient("openai/gpt-oss-20b", new ApiKeyCredential("No API key needed!"), new OpenAI.OpenAIClientOptions()
    {
        Endpoint = new Uri("http://localhost:8000/v1"),
        Transport = transport
    });

OpenAIResponseAgent agent = new(client);

// Invoke the agent and output the response
var responseItems = agent.InvokeStreamingAsync("Tell me a joke!");

```
Ouch! This returns an *internal server error*, and if we review the Transformers logs we can see that something has gone wrong:

![](/images/250831/2.png)
If we inspect the request that was sent to the endpoint we can see that it has the "complex" format:
```json
Request URL: http://localhost:8000/v1/responses
Request Headers:
Accept: application/json, text/event-stream
User-Agent: OpenAI/2.3.0, (.NET 9.0.8; Microsoft Windows 10.0.26100)
Authorization: Bearer No API key needed!
Content-Type: application/json
Request Content:
{"instructions":"","model":"openai/gpt-oss-20b","input":[{"type":"message","role":"user","content":[{"type":"input_text","text":"Tell me a joke!"}]}],"stream":true,"user":"UnnamedAgent","store":false}
```
As it turns out, the Transformers Responses API doesn't like this format. As we saw before, it works fine with the simpler format - but for some reason this doesn't work. Probably because it is experimental. I logged an [issue](https://github.com/huggingface/transformers/issues/40571), so we'll have to see what happens.

So what should we do? 

### Forking the C# OpenAI SDK and Semantic Kernel
I really wanted to make this work, and I thought that my only option was to make sure that the request sent from Semantic Kernel was in the simplified format that Transformers like. So, I [forked](https://github.com/adner/openai-dotnet) the [OpenAI .NET API library](https://github.com/openai/openai-dotnet) and tried to tweak it to make sure that it works in my scenario.

It turns out that [OpenAIResponse.Serialization.cs](https://github.com/adner/openai-dotnet/blob/main/src/Generated/Models/Responses/OpenAIResponse.Serialization.cs) is responsible for serializing the input, and could be tweaked to emit the simplified format instead. Note that this is not a bug in the serializer - it has been automatically generated based on the OpenAI API spec, so it works as it should.

When this was fixed it still didn't work because of some strangeness in the format of the response that was returned from Transformers, which meant that I had to [fork](https://github.com/adner/semantic-kernel) Semantic Kernel also, and do a tweak there as well.

After all this tweaking it finally works - a joke has been generated using a local gpt-oss-20b model, running on the Hugging Face Transformer library and using the Responses API. Great success!

```json
➡️  POST http://localhost:8000/v1/responses
Accept: application/json,text/event-stream
User-Agent: OpenAI/2.3.0,(.NET 8.0.19; Microsoft Windows 10.0.26100)
Authorization: [MASKED]
{"user":"UnnamedAgent","model":"openai/gpt-oss-20b","instructions":"","input":[
{"role":"user","content":"Tell me a joke!"}],"store":false,"stream":true}
⬅️  200 OK
here’s one for you:

Why did the scarecrow win an award?

Because he was outstanding in his field! 🌾😄
```
### Generating short stories about Unicorns using Semantic Kernel, Transformers and Responses API
So, at the depth of the Responses API rabbit hole, it was finally possible to ask the AI to create some short stories about unicorns, some emojis and some nice, bright colors. A repo containing this demo, as well as the tweaked forks of the C# OpenAI SDK and Semantic Kernel can be found [here](https://github.com/adner/SemanticKernel_OpenAiResponsesApi). Here's the result:

<iframe width="560" height="315" src="https://www.youtube.com/embed/0s08c9sEh3U?si=GN3udxSicLwGs2KA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

It feels like I probably spent way too much time to be able to ask the AI about unicorns, but at least I learned some things about Docker, Transformers and got a chance to dive deeply into the SK and OpenAI .NET codebases. 😄