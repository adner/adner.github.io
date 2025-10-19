---
layout: post
title:  "The Teams AI Library, M365 Agents SDK and Toolkit and running Doom in Teams"
date:   2025-10-18
image: /images/251018/splash.png
---
{% if page.image %}
  <a href="{{ page.url | relative_url }}">
    <img src="{{ page.image | relative_url }}" alt="{{ page.title }}">
  </a>
{% endif %}

When deploying AI agents in an organization, there are quite a lot of options available in the Microsoft ecosystem. For example, [Copilot Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/) is the go-to no-code framework for creating AI agents that can be deployed to [various channels](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-fundamentals-publish-channels?tabs=web) - such as Microsoft Teams, a custom webpage, M365 Copilot and more. 

<!--end_excerpt-->

One way of making a Copilot Studio agent available in a custom channel, such as a native app or a web page, is to use the [Copilot Studio Client](https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-integrate-web-or-native-app-m365-agents-sdk?tabs=dotnet#copilot-studio-client-samples) that is part of the [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp). I explored this option in [this video](https://www.youtube.com/watch?v=6B60HVbnHmw) where the Copilot Studio Client is used to implement a custom chat agent in a webpage, that is orchestrated in Copilot Studio (the code can be found in [this repo](https://github.com/adner/CustomCopilotStudioAgentUI)):

<iframe width="560" height="315" src="https://www.youtube.com/embed/6B60HVbnHmw?si=xjlSpgjeRbzQOHOc" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

In many cases, Microsoft Teams is the channel of choice when deploying AI agents. So what options are available if you want to create an AI agent that should be available in Teams? As mentioned above, Copilot Studio is a good option, especially if you want a no-code approach. But what if you want more control? Let's explore some other options available for publishing agents in Teams:

- The [Microsoft 365 Agents SDK](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/agents-sdk-overview?tabs=csharp) - An extensive framework that allows for the creation of AI agents that can be deployed to many different channels, Microsoft Teams being one of them.
- The [Teams AI Library](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/welcome) - An SDK that abstracts away a lot of the complexity of the M365 Agents SDK, and allows for rapid creation of Teams AI agents. 
- The [Microsoft 365 Agents Toolkit](https://learn.microsoft.com/en-us/microsoft-365/developer/overview-m365-agents-toolkit) - Tooling that simplifies the scaffolding of agent projects, provisioning of infrastructure, deployment, etc, which is available as extensions to Visual Studio and VS Code. 

So, let's look into some of these options in a little more detail.

### Microsoft 365 Agents Toolkit and SDK
The Microsoft 365 Agents Toolkit is an extension that can be installed in [VS Code](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/install-agents-toolkit?tabs=vscode), [Visual Studio](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/toolkit-v4/install-agents-toolkit-vs) as well as [GitHub Copilot](https://github.com/marketplace/teamsapp). There is also a [CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three) available.

Currently, the VS Code version can only scaffold Python and TypeScript projects (this will probably change it the future, check out this [video](https://www.youtube.com/watch?v=CY8_Mm3lfk4&t=875s)), which is not really my cup of tea. The **Visual Studio** variant can create C# projects, so let's focus on exploring that one. The VS extension gives access to a number of project templates, for example the "Basic Agent for Teams":

![alt text](/images/251018/image2.png)

If we create a project based on this particular template, it gives us the option to use OpenAI models deployed to either Azure AI Foundry, or using the OpenAI API directly. The template scaffolds up **a lot** of code. The template defaults to the very old model `gpt-35-turbo`, and I tried it out this model, deployed to Azure AI Foundry. Hitting F5 allows us to debug the agent locally, using the [Microsoft 365 Agent Playground](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/create-test-basic-agent?tabs=csharp):

![alt text](/images/251018/image3.png)

This works well, but if I change the model to `gpt-5-mini` or any of the other newer models everything seems to break. It seems that the project templates that ship with the Visual Studio extension aren't updated to support newer OpenAI models (?), probably because it uses the [older version of the Microsoft.Teams.AI](https://www.nuget.org/packages/Microsoft.Teams.AI/1.8.0) SDK. There is a new version available of this SDK (v2), and the template probably needs to be updated to use this one.

Ah well, let's try another project template. We'll try the "Weather Agent" template, that has no reliance on the Microsoft.Teams.AI bits, and uses Semantic Kernel for orchestration. This template actually works in the Playground with the model `gpt-5-mini`:

![alt text](/images/251018/image4.png)

One of the main benefits of using the M365 Agents Toolkit is that it helps you with the provisioning of all the infrastructure that is needed to test your agent in Teams (and debug it locally). Options are available for debugging the agent both in Teams and Copilot:

![alt text](/images/251018/debuginteams.png)

If I select "Microsoft Teams (browser)" and hit "Start", the toolkit starts provisioning all the infrastructure necessary to debug the Teams agent locally:

![alt text](/images/251018/image6.png)

It does a number of things, for example:

- Creates a **Teams app** (which can be found at [dev.teams.microsoft.com](https://dev.teams.microsoft.com/)):

![alt text](/images/251018/teamsdevportal.png)

- Creates an **app registration** in Azure AD, with a **client secret**. Also, creates a **Bot Framework bot** (visible in [dev.botframework.com](https://dev.botframework.com/)) that is tied to this app registration, and that uses this client secret.

This is all a bit confusing, as there are so many moving parts when deploying the agent to Teams. Although the toolkit simplifies deployment, it is not super-clear what is going on, and how the different parts in the infrastructure relate to each-other. For example, the bot can be configured in multiple places - both at [dev.botframework.com](https://dev.botframework.com/) and [dev.teams.microsoft.com/tools/bots](https://dev.teams.microsoft.com/tools/bots). The toolkit uses the Bot Framework bot, but parts of the documentation instead talks about creating the bot in Azure Bot Service. 

One snag that I hit was that the provisioning failed until I manually created a **dev tunnel** in Visual Studio:

![alt text](/images/251018/devtunnel.png)

I thought the the toolkit would create a dev tunnel automatically, but this didn't seem to be the case. So I had to remove the existing dev tunnel and create a new one. When the dev tunnel was in place, the provisioning worked and the bot was successfully deployed to [dev.teams.microsoft.com](https://dev.teams.microsoft.com/) and I could run it in Teams. The magic sauce here is that the **endpoint** of the bot that is created is pointing to my local dev tunnel, so that requests from the Teams app is passed to my local machine, so that I can debug the bot locally! Here is the configuration that makes this possible:

![alt text](/images/251018/botendpoint.png)

When we are done debugging and want to deploy the bot for real, then we change this endpoint to point to our agent code running as an App Service in Azure.

Here is the bot running in Teams and being debugged locally, in all its glory:

![alt text](/images/251018/image5.png)

And here is the bot being debugged in M365 Copilot. Amazing stuff, the M365 Agents SDK makes it possible to run the same agent in multiple channels! Write once - deploy anywhere! 🚀🚀🚀

![alt text](/images/251018/copilot.png)

While all of this is very exciting and pretty usable, using the M365 Agents Toolkit and SDK is not for the faint of heart. The large amount of "black box magic" involved in provisioning infrastructure can make it feel like you're not fully in control. Additionally, when searching for documentation online, the sheer number of framework versions and similarly-named Teams CLIs makes my head spin, to say the least (more on that below).

M365 Agents SDK is for sure the most powerful "pro code" option out there, but since our use-case is to create a bot only in Teams, there is also another option - the **Teams AI Library**. So let's explore it!

### The Teams AI Library

The [Teams AI Library v2](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/welcome) (not v1, which was the one used in the Teams agent template in the toolkit, see above) is a simpler, more developer-friendly framework that can be used to create AI Agents in Teams. It says that it has an "improved, streamlined developer experience in mind". Let's find out if that is indeed the case...

It comes with a [CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/developer-tools/cli) (not to be confused with the older [Teams Toolkit CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three)), and we can use this CLI to scaffold a C# agent project:

```bash
teams new csharp MyDoomAgent --template echo --atk basic
```

The documentation claims that there is a `ai` template available also, but that doesn't seem to be the case (for once, the docs are actually ahead of the actual tooling) - so we'll go for the `echo` template. We also ask it to add a basic "Agent toolkit configuration" by passing the `atk` parameter, hoping that will result in some of that infrastructure magic that we saw in the previous section. Opening up the solution in Visual Studio, it looks nice and clean - much less boilerplate code:

![alt text](/images/251018/vsteamsailibrary.png)

When debugging the project locally, instead of the M365 Agents Playground we get something called [Devtools chat](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/developer-tools/devtools/chat) that can be used to try out the agent locally:

![alt text](/images/251018/devtoolschat.png)

The automatic provisioning of the infra needed to debug the bot locally also works like a charm - but once again I had to recreate my dev tunnel manually for it to work. 

So, how do we add AI to this project? Of course, we have the option of using any agent orchestration framework that we wish, for example [Microsoft Agent Framework](https://github.com/microsoft/agent-framework). But to simplify for the developer, the Teams AI Library actually has some [included proprietary AI libraries](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/overview) that makes it a breeze to add some *basic* AI goodness to our project. 

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
 The AI framework found in Teams AI SDK is pretty limited, but it has support for [function calling](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/function-calling), some basic conversation state management and even [MCP](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/ai/mcp/overview). It's not by any means a full blown agent orchestration framework, but if you only need basic AI functionality, and only OpenAI models, this might be a useful way of adding AI to your agent, without too much work. The way that it handles function calling, and the extent that the framework is configurable leaves a bit to be desired, to be honest. We'll simply have to see how this framework evolves, and how usable it will be in the future.

 So, how can we make it run Doom? The demo that I [posted to LinkedIn](https://www.linkedin.com/posts/andreas-adner-70b1153_microsoftteams-ai-llm-activity-7384658863293231104-SUyb?utm_source=share&utm_medium=member_desktop&rcm=ACoAAACM8rsBEgQIrYgb4NZAbnxwfDRk_Tu5e3w) showed how to embed Doom in Teams, and the code that illustrates how to do this can be found in [this repo](https://github.com/adner/TeamsDoom). It uses the plumbing described in the docs for using [Adaptive Cards](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/adaptive-cards/overview) to allow the user to launch a [Dialog](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/in-depth-guides/dialogs/overview) containing the WASM Doom-application, that is hosted as a [Web App](https://learn.microsoft.com/en-us/microsoftteams/platform/teams-ai-library/csharp/essentials/hosting-web-apps) inside a tab in Teams. It is based on [this sample](https://github.com/microsoft/teams.net/tree/main/Samples/Samples.Tab) that can be found in the [Teams SDK .NET repo](https://github.com/microsoft/teams.net/).

 To summarize, Microsoft offers several approaches for deploying AI agents in Teams, each with different tradeoffs:

**Microsoft 365 Agents SDK & Toolkit** provides the most comprehensive and powerful "pro code" solution, supporting multiple channels beyond Teams (including M365 Copilot). The toolkit automates infrastructure provisioning and deployment. However, it comes with a steep learning curve, involves considerable "black box infra voodoo" and the versioning of the included project templates is a hot mess. 

**Teams AI Library v2** offers a more streamlined, developer-friendly experience specifically focused on Teams. It provides a cleaner project structure, and some basic AI orchestration functionality. While less powerful than the M365 Agents SDK, in my opinion it strikes a pretty good balance between simplicity and functionality for Teams-specific agents. The documentation is a bit lacking at the moment, and I look forward to seeing more code samples, and I hope the AI bits evolve to include more orchestration features.

That being said, thanks for reading. And here is the demo of Doom running in Teams:

 <iframe width="560" height="315" src="https://www.youtube.com/embed/aH82Q6oJI90?si=-HU7lWyC9G5DXrsA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>







