---
layout: post
title:  "The anatomy of FetchXmlBuilder with AI"
date:   2025-07-29
image: /images/250729/title.png
---
![title](/images/250729/title.png)

[Jonas Rapp](https://www.linkedin.com/in/rappen/) has just released an update to [FetchXmlBuilder](https://fetchxmlbuilder.com/) that includes the possibility to use AI to construct FetchXml queries, see the [release notes](https://fetchxmlbuilder.com/releases/1-2025-7/) and his post on [LinkedIn](https://www.linkedin.com/posts/rappen_ai-chat-in-fetchxml-builder-getting-to-activity-7355935874234171393-wfZW?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w). As I have [mentioned](https://www.linkedin.com/posts/andreas-adner-70b1153_fetchxmlbuilder-infused-with-ai-activity-7353891922370793472-PgcI?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w), I had the pleasure of helping out with implementing this functionality, which was fun in all kinds of ways.<!--end_excerpt--> In this blog post I will try to explain a little bit about how the AI-functionality is implemented - specifically from an AI tool calling perspective. 

Jonas has also blogged about this and have some insights on how the AI-code found in the XTB Helpers library can be utilized also by other tools, check it out [here](https://jonasr.app/ai-code-helpers/). Also, check out his [video](https://www.youtube.com/watch?v=E4Lj9C1ZMVU) that gives a great overview.

## General architecture 
The AI functionality in FetchXmlBuilder is based on the abstractions in [Microsoft.Extensions.AI](https://learn.microsoft.com/en-us/dotnet/ai/microsoft-extensions-ai), a library that is used throughout the Microsoft AI stack, for example in:

- [**Semantic Kernel**](https://learn.microsoft.com/en-us/semantic-kernel/overview/) - the AI (agent) orchestration framework from Microsoft, which is have [blogged](https://nullpointer.se/2025/07/19/semantic-kernel-mcp.html) about. 

- [**The C# Model Context Protocol SDK**](https://github.com/modelcontextprotocol/csharp-sdk) that I have used in a number of tech demos, for example [this one](https://nullpointer.se/dataverse/mcp/2025/07/06/dataverse-mcp-claude.html).

*Microsoft.Extensions.AI* contains abstractions that are generally useful when developing AI stuff, and Tanguy Tozard - the maintainer of [XrmToolBox](https://www.xrmtoolbox.com/) - has been kind enough to include this library "out-of-the-box" in the latest version of XTB, so that other plugins can use it as well.

This version of FXC supports two model providers - **OpenAI** and **Anthropic** through the use of the following libraries, that are built on top of *Microsoft.Extensions.AI*:

- [Anthropic](https://github.com/tryAGI/Anthropic)
- [Microsoft.Extensions.AI.OpenAI](https://www.nuget.org/packages/Microsoft.Extensions.AI.OpenAI/9.7.1-preview.1.25365.4?_src=template)

These libraries allow the use of these models - hosted by Anthropic and OpenAI - through a common API and using for example the `IChatClient` interface in *Microsoft.Extensions.AI*. This allows us to create a `IChatClient` uniformly, regardless of supplier:

```csharp
private static ChatClientBuilder GetChatClientBuilder(string supplier, string model, string apikey)
{
    IChatClient client =
        supplier == "Anthropic" ? new AnthropicClient(apikey) :
        supplier == "OpenAI" ? new ChatClient(model, apikey).AsIChatClient() :
        throw new NotImplementedException($"AI Supplier {supplier} not implemented!");

    return client.AsBuilder().ConfigureOptions(options =>
    {
        options.ModelId = model;
        options.MaxOutputTokens = 4096;
    });
}
```
At the moment, we are targeting the API:s of OpenAI and Anthropic directly, but the design makes should make it easy to use models deployed to e.g. [Azure AI Foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/) in the future.

## Function calling

*Microsoft.Extensions.AI* also makes it simple to wire up **function calling** for the IChatClient, which is used extensively in FXB:

```csharp
  using (IChatClient chatClient = clientBuilder.UseFunctionInvocation().Build())
  {
      var chatOptions = new ChatOptions();
      if (internalTools?.Count() > 0)
      {
          chatOptions.Tools = internalTools.Select(tool => AIFunctionFactory.Create(tool) as AITool).ToList();
      }
...
```

This gives the LLM of choice access to a number of internal *functions*, that are called by the LLM att appropriate times:

- **ExecuteFetchXMLQuery** - Executes the current FetchXml request. Similar to clicking **Execute** in FXB, but allows the AI to catch any error that occurs when running the query and (try to) fix it.

- **UpdateCurrentFetchXmlQuery** - Should be called by the AI as soon as the AI has suggested a modification of the current FetchXML - makes sure that the query is properly updated in the GUI.
- **GetMetadataForUnknownEntity** - Called by the AI to retrieve metadata for one or several tables, matching the user's request.
- **GetMetadataForUnknownAttribute** - Called by the AI to retrieve metadata for one or many fields, matching the user's request.

Borrowing a page from the Model Context Protocol (MCP) playbook - the tools above have the ability to themself do *internal* calls to the LLM, similar to the concept called  [**sampling**](https://modelcontextprotocol.io/specification/2025-06-18/client/sampling) in MCP. 

In FXB this is used to search for fields based on the user's (sometimes very vague and ambiguous) descriptions. For example, if a user asks "to add the field that contains the users mobile number", the tool can internally query the LLM to resolve which attribute best matches that description.

The metadata that is returned to the LLM contains information such as logical names, display names and optionset display values, which allows the AI to handle queries such as "only return the accounts that are in the industry 'agriculture'.

## Examples

Let's review some examples of queries, and what happens internally in FXB.

![](/images/250729/image_1.webp)

In this simple example, the AI relies on its training data to construct the (very simple) FetchXml query, and doesn't make any function calls to retrieve metadata. It constructs the query, updates the FetchXml in the GUI and when the user requests it, executes the query by calling the `ExecuteFetchXml` function.

![](/images/250729/image2.png)

In the following example, the AI needs to retrieve metadata to find out the display texts for an optionset.

![](/images/250729/image_3.webp)

First, the AI calls the `GetMetadataForUnknownEntity` to get metadata for the tables that match the description. There are two possibilities:

![](/images/250729/image4.png)

As mentioned above, the function accomplishes this by making an *internal* call to the LLM to match the user's description of the table with one or many tables in the list of table metadata:

![](/images/250729/image5.png)

Then, the AI uses the function `GetMetadataForUnknownAttribute` to get the field matching the "industry" description, and the optionset value matching "agriculture":

![](/images/250729/image6.png)

The AI correctly identifies that the field `industrycode` and the optionset value `2` - *Agriculture and Non-petrol Natural Resource Extraction* matches the description. Also in this case it has made an internal call to the LLM to find the correct attribute. 

If you want to check out the code for yourself, see these two repo:s in Jonas Rapp's GitHub. And as mentioned above, check out his [blog post](https://jonasr.app/ai-code-helpers/) on how to use AI in your own XTB plugins.

- [FetchXml](https://github.com/rappen/FetchXMLBuilder)
- [Rappen.XTB.Helper](https://github.com/rappen/Rappen.XTB.Helper)

But there is one more thing... What is this, are OpenAI using our FXB requests to train their upcoming **ChatGPT 5** model?? Or which model is `gpt-5-mini-bench-chatcompletions-gpt41m-api-ev3`?

Exciting times ahead for sure!

![](/images/250729/image7.png)

