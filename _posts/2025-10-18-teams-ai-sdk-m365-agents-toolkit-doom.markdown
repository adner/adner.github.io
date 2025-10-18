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

### Microsoft 365 Agents Toolkit
The Microsoft 365 Agents Toolkit is an extension that can be installed to [VS Code](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/install-agents-toolkit?tabs=vscode), [Visual Studio](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/toolkit-v4/install-agents-toolkit-vs) as well as [GitHub Copilot](https://github.com/marketplace/teamsapp). There is also a [CLI](https://learn.microsoft.com/en-us/microsoftteams/platform/toolkit/teams-toolkit-cli?pivots=version-three) available.

Currently, the VS Code version can only scaffold Python and TypeScript projects, which is not really my cup of tea. The Visual Studio variant can create C# projects, so let's explore that one. The Visual Studio extension gives access to a number of project templates, for example the "Basic Agent for Teams" template.

![alt text](image.png)

If we create a project based on this template, it scaffolds up a lot of code for an AI agent that uses a deployment of gpt-35-turbo in Azure OpenAI for inference (which I choose, using OpenAI API was the other option). Hitting F5 allows us to try the agent out locally, using the [Microsoft 365 Agent Playground](https://learn.microsoft.com/en-us/microsoft-365/agents-sdk/create-test-basic-agent?tabs=csharp):






