---
layout: post
title:  "The Teams AI Library, M365 Agents SDK and running Doom in Teams"
date:   2025-10-18
image: /images/251018/splash.png
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

When deploying AI agents to an organization, there are quite a lot of options available in the Microsoft ecosystem. For example, [Copilot Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/) is the go-to no-code framework for creating AI agents that can be deployed to [various channels](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-fundamentals-publish-channels?tabs=web) - such as Microsoft Teams, a webpage, M365 Copilot Chat and many more. 

<!--end_excerpt-->

One way of making an agent created in Copilot Studio in a custom channel - such as a native app or a web page - is to the use the [Copilot Studio Client](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-integrate-web-or-native-app-m365-agents-sdk?tabs=dotnet#copilot-studio-client-samples) that is part of the [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp). I explored this option in [this video](https://www.youtube.com/watch?v=6B60HVbnHmw) where the Copilot Studio Client is used to embed an agent created in Copilot Studio in a custom web page (the code can be found in [this repo](https://github.com/adner/CustomCopilotStudioAgentUI)):

[![](/images/251018/image1.png)](https://www.youtube.com/watch?v=6B60HVbnHmw)

In many cases, Microsoft Teams is the channel of choice when deploying AI agents. So what options are available if you want to create an AI agent that is available in Teams? As mentioned above, Copilot Studio is a good option, especially if you want a no-code approach. But what if you want more control? In this blog post I intend to explore some other options available for creating agents in Teams:

- The [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp) - An extensive framework that allows for the creation of AI agents that can be deployed to many different channels, Microsoft Teams being one of them.
- The [Teams AI Library](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/welcome) - An SDK that abtracts away a lot of the complexity of the M365 Agents SDK, and allows for rapid creation of Teams AI agents. 
- The [Microsoft 365 Agents Toolkit](https://learn.microsoft.com/en-us/microsoft-365/developer/overview-m365-agents-toolkit) - Tooling that simplifies the scaffolding of agent projects, deployment, etc. 

So, let's look into these in a little more detail.

### Microsoft 365 Agents Toolkit and SDK
The Microsoft 365 Agents Toolkit is an extension that can be installed to [VS Code](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/install-agents-toolkit?tabs=vscode), [Visual Studio](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/toolkit-v4/install-agents-toolkit-vs) as well as [GitHub Copilot](https://github.com/marketplace/teamsapp). There is also a [CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three) available.

Currently, the VS Code version can only scaffold Python and TypeScript projects, which is not really my cup of tea. The Visual Studio variant can create C# projects, so let's explore that one. The Visual Studio extension gives access to a number of project templates, for example the "Basic Agent for Teams" template.

![alt text](/images/251018/image2.png)

If we create a project based on this template ("Basic Agent for Teams"), it scaffolds up a lot of code for an AI agent that uses a deployment of gpt-35-turbo in Azure OpenAI for inference (which I choose, using OpenAI API was the other option). Hitting F5 allows us to try the agent out locally, using the [Microsoft 365 Agent Playground](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/create-test-basic-agent?tabs=csharp):

![alt text](/images/251018/image3.png)

This is pretty cool, but if I change the model to `gpt-5-mini` or any of the other newer models everything seems to break. Seems that the project templates that ship with the Visual Studio extension aren't updated to support newer OpenAI models (?), perhaps because of the [older version of the Microsoft.Teams.AI](https://www.nuget.org/packages/Microsoft.Teams.AI/1.8.0) SDK that it uses?

Ah well, let's try another project template. We'll try the "Weather Agent" template, that uses Semantic Kernel for orchestration. This one actually works in the Playground with the model `gpt-5-mini`:

![alt text](/images/251018/image4.png)

One of the main benefits of using the M365 Agents Toolkit is that it helps you with the provisioning of all the infrastructure that is needed to actually test your agent in Teams (and debug it locally). Options are available for debugging the agent both in Teams and Copilot:

![alt text](/images/251018/debuginteams.png)

If I select "Microsoft Teams (browser)" and hit "Start", the toolkit starts provisioning all the infra necessary to debug the Teams agent:

![alt text](/images/251018/image6.png)

It does a number of things:

Creates a "Teams app" (which can be found at [dev.teams.microsoft.com](https://dev.teams.microsoft.com/)):

![alt text](/images/251018/teamsdevportal.png)

Creates an app registration in Azure AD, with a client secret. Also, creates a bot framework bot (visible in [dev.botframework.com](https://dev.botframework.com/)) that is tied to this app registration, and that uses this client secret.

This is all a bit confusing, since the bot can be configured in multiple places - both at [dev.botframework.com](https://dev.botframework.com/) and [dev.teams.microsoft.com/tools/bots](https://dev.teams.microsoft.com/tools/bots).

On snag that I hit was the the provisioning failed until I manually created a dev tunnel in Visual Studio:

![alt text](/images/251018/devtunnel.png)

When the dev tunnel was in place, the provisioning worked and the bot was successfully deployed to [dev.teams.microsoft.com](https://dev.teams.microsoft.com/) and I could run it in Teams. The magic sauce here is that the endpoint of the bot that is created is pointing to my local dev tunnel, so that requests from the Teams app is passed to my local machine, so that I can debug the bot locally! Here is the configuration that makes this possible:

![alt text](/images/251018/botendpoint.png)

Here is the bot running in Teams and being debugged locally, it all its glory:

![alt text](/images/251018/image5.png)

And here is the bot being debugged in M365 Copilot. Amazing stuff, the M365 Agents SDK makes it possible to run the same agent in multiple channels! Write once - deploy anywhere! 🚀🚀🚀

![alt text](/images/251018/copilot.png)

While all of this is very exciting and pretty usable, using the M365 Agents Toolkit and SDK is not for the faint of heart. Maybe it is just me, but the large amount of "black box magic" that goes on when provisioning infrastructure using the toolkit makes me feel that I am not really in control, and I find it a bit hard to understand why sometime the Bot Framework is used, and sometimes the Azure Bot Service, confusing (old?) versioning of libraries that are part the toolkit, etc. 

M365 Agents SDK is for sure the most powerful "pro code" option out there, but since our use-case is to create a bot for Teams, there is also another option - the Teams AI Library. So let's explore it!

### The Teams AI Library

The [Teams AI Library v2](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/welcome) (not v1, which was the one used in the Teams agent template in the toolkit, see above) is a simpler, more developer friendly framework that can be used to create AI Agents in Teams. It says that it has an "improved developer experience in mind", and a "streamlined developer experience".

It comes with a [CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/developer-tools/cli) - not to be confused with the [Teams Toolkit CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three), and we can use this CLI to scaffold a C# agent project:

```bash
teams new csharp MyDoomAgent --template echo --atk basic
```

The documentation claims that there is a `ai` template available also, but that doesn't seem to be the case - so we'll go for the `echo` template. We also ask it to add the "Agent toolkit configuration", hoping that we could get some of that infrastructure magic that we saw in the previous section. Opening up the solution in Visual Studio, it looks nice and clean:

![alt text](/images/251018/vsteamsailibrary.png)

When debugging the project locally, instead of the M365 Agents Playground we get something called [Devtools chat](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/developer-tools/devtools/chat) that can be used to try out the agent locally:

![alt text](/images/251018/devtoolschat.png)

The automatic provisioning of the infra needed to debug the bot locally also works like a charm - but once again I had to create a dev tunnel manually for it to work. 

So, how do we add AI to this project? Of course, we have the option of adding any agent orchestration framework, for example [Microsoft Agent Framework](https://github.com/microsoft/agent-framework), but the Teams AI Library actually has some [included features](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/overview) that makes it simple to add some AI goodness to our project. 

We start by adding the nuget package [Microsoft.Teams.AI](https://www.nuget.org/packages/Microsoft.Teams.AI), as well as the [Microsoft.Teams.AI.Models.OpenAI](https://www.nuget.org/packages/Microsoft.Teams.AI.Models.OpenAI) package.

We update the `MainController` and add the code for calling the AI:

```csharp
using Microsoft.Teams.AI.Models.OpenAI;
using Microsoft.Teams.AI.Prompts;

...

[Message]
public async Task OnMessage([Context] MessageActivity activity, [Context] IContext.Client client)
{
    // Create the OpenAI chat model
    var model = new OpenAIChatModel(
        model: "gpt-5-mini",
        apiKey: "sk-proj...kA"
    );

    // Create a chat prompt
    var prompt = new OpenAIChatPrompt(
        model,
        new ChatPromptOptions().WithInstructions("You are a friendly assistant who talks like a pirate.")
    );

    // Send the user's message to the prompt and get a response
    var response = await prompt.Send(activity.Text);
    if (!string.IsNullOrEmpty(response.Content))
    {
        var responseActivity = new MessageActivity { Text = response.Content }.AddAIGenerated();
        await client.Send(responseActivity);
        // Ahoy, matey! 🏴‍☠️ How be ye doin' this fine day on th' high seas? What can this ol’ salty sea dog help ye with? 🚢☠️
    }
}
```
If we want streaming responses, we can change the code like this:

```csharp
 public async Task OnMessage(IContext<MessageActivity> context)
 {
     // Create the OpenAI chat model
     var model = new OpenAIChatModel(
         model: "gpt-5-mini",
         apiKey: "sk-proj..kA"
     );

     // Create a chat prompt
     var prompt = new OpenAIChatPrompt(
         model,
         new ChatPromptOptions().WithInstructions("You are a friendly assistant who talks like a pirate.")
     );

     var response = await prompt.Send(context.Activity.Text, null,
      (chunk) => Task.Run(() => context.Stream.Emit(chunk)),
      context.CancellationToken);
 }
 ```
 The AI framework found in Teams AI SDK is pretty limited, but it has support for [function calling](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/function-calling) and even [MCP](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/mcp/overview). It's not by any means a full blown agent orchestration framework, but if you only need basic AI functionality, and only OpenAI models, this might be a useful way of adding AI to your agent, without too much work.

 ### Running Doom in Teams

 So, how do we make it run Doom? The demo I created showcasing this can be found [here on YouTube](https://www.youtube.com/watch?v=aH82Q6oJI90) and the code can can be found in [this repo](https://github.com/adner/TeamsDoom). It uses the plumbing described in the docs for using [Adaptive Cards](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/adaptive-cards/overview) to allow the user to launch a [Dialog](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/dialogs/overview) containing the WASM Doom-application, that is hosted as a [Web App](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/essentials/hosting-web-apps) inside a tab in Teams. It is based on [this sample](https://github.com/microsoft/teams.net/tree/main/Samples/Samples.Tab) that can be found in the [Teams SDK .NET repo](https://github.com/microsoft/teams.net/).

 Here is the demo:

 <iframe width="560" height="315" src="https://www.youtube.com/embed/aH82Q6oJI90?si=-HU7lWyC9G5DXrsA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>







